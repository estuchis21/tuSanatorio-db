--
-- PostgreSQL database dump (solo funciones y procedimientos)
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- TOC entry 262 (class 1255 OID 26429)
-- Name: actualizarcontrasena(character varying, integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actualizarcontrasena(IN p_contrasena character varying, IN p_id_usuario integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    UPDATE Usuarios
    SET contrasena = p_contrasena
    WHERE id_usuario = p_id_usuario;

    OPEN cur FOR
        SELECT *
        FROM Usuarios
        WHERE id_usuario = p_id_usuario;

END;
$$;


ALTER PROCEDURE public.actualizarcontrasena(IN p_contrasena character varying, IN p_id_usuario integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 265 (class 1255 OID 26430)
-- Name: actualizarmail(character varying, integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actualizarmail(IN p_email character varying, IN p_id_usuario integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    UPDATE Usuarios
    SET email = p_email
    WHERE id_usuario = p_id_usuario;

    OPEN cur FOR
        SELECT *
        FROM Usuarios
        WHERE id_usuario = p_id_usuario;

END;
$$;


ALTER PROCEDURE public.actualizarmail(IN p_email character varying, IN p_id_usuario integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 249 (class 1255 OID 26431)
-- Name: actualizarperfil(character varying, character varying, character varying, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actualizarperfil(IN p_email character varying, IN p_telefono character varying, IN p_username character varying, IN p_contrasena character varying, IN p_id_usuario integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

    UPDATE Usuarios
    SET
        email = COALESCE(p_email, email),
        telefono = COALESCE(p_telefono, telefono),
        username = COALESCE(p_username, username),
        contrasena = COALESCE(p_contrasena, contrasena)
    WHERE id_usuario = p_id_usuario;

END;
$$;


ALTER PROCEDURE public.actualizarperfil(IN p_email character varying, IN p_telefono character varying, IN p_username character varying, IN p_contrasena character varying, IN p_id_usuario integer) OWNER TO "tuSanatorio_owner";

-- TOC entry 250 (class 1255 OID 26432)
-- Name: actualizarusername(character varying, integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actualizarusername(IN p_username character varying, IN p_id_usuario integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    UPDATE Usuarios
    SET username = p_username
    WHERE id_usuario = p_id_usuario;

    OPEN cur FOR
        SELECT *
        FROM Usuarios
        WHERE id_usuario = p_id_usuario;

END;
$$;


ALTER PROCEDURE public.actualizarusername(IN p_username character varying, IN p_id_usuario integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 273 (class 1255 OID 26433)
-- Name: asignarturno(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.asignarturno(IN p_id_turno integer, IN p_id_paciente integer, IN p_id_obra_social integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

    IF p_id_turno IS NULL
       OR p_id_paciente IS NULL
       OR p_id_obra_social IS NULL
    THEN
        RAISE EXCEPTION 'Los parámetros no pueden ser NULL.';
    END IF;


    IF NOT EXISTS (
        SELECT 1
        FROM Turnos_disponibles
        WHERE id_turno = p_id_turno
    )
    THEN
        RAISE EXCEPTION 'El turno no está disponible para asignar.';
    END IF;


    INSERT INTO Turnos_asignados(
        id_turno,
        id_paciente,
        id_obra_social,
        fecha_asignacion
    )
    VALUES (
        p_id_turno,
        p_id_paciente,
        p_id_obra_social,
        CURRENT_TIMESTAMP
    );


    DELETE FROM Turnos_disponibles
    WHERE id_turno = p_id_turno;


    RAISE NOTICE 'Turno asignado correctamente.';

END;
$$;


ALTER PROCEDURE public.asignarturno(IN p_id_turno integer, IN p_id_paciente integer, IN p_id_obra_social integer) OWNER TO "tuSanatorio_owner";

-- TOC entry 276 (class 1255 OID 26434)
-- Name: buscarpacienteportexto(character varying, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.buscarpacienteportexto(IN p_texto character varying, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            p.id_paciente,
            u.id_usuario,
            u.nombres,
            u.apellido,
            u.DNI
        FROM Pacientes p
        INNER JOIN Usuarios u
            ON p.id_usuario = u.id_usuario
        WHERE u.nombres ILIKE '%' || p_texto || '%'
           OR u.apellido ILIKE '%' || p_texto || '%'
           OR CAST(u.DNI AS VARCHAR) ILIKE '%' || p_texto || '%';

END;
$$;


ALTER PROCEDURE public.buscarpacienteportexto(IN p_texto character varying, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 281 (class 1255 OID 26435)
-- Name: cancelarturno(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.cancelarturno(IN p_id_paciente integer, IN p_id_turno_asignado integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_turno INT;
    v_id_medico INT;
    v_id_rango INT;
    v_fecha_turno DATE;
BEGIN

    SELECT id_turno
    INTO v_id_turno
    FROM Turnos_asignados
    WHERE id_turno_asignado = p_id_turno_asignado
      AND id_paciente = p_id_paciente;


    IF v_id_turno IS NULL THEN

        RAISE NOTICE 'No se encontró un turno asignado para cancelar.';
        RETURN;

    END IF;


    SELECT
        id_medico,
        id_rango,
        fecha_turno
    INTO
        v_id_medico,
        v_id_rango,
        v_fecha_turno
    FROM TurnosDescartados
    WHERE id_turno = v_id_turno;


    IF v_id_medico IS NULL THEN

        RAISE EXCEPTION
            'No se encontraron los datos del turno descartado %.',
            v_id_turno;

    END IF;


    DELETE FROM Turnos_asignados
    WHERE id_turno_asignado = p_id_turno_asignado
      AND id_paciente = p_id_paciente;


    INSERT INTO Turnos_disponibles(
        id_medico,
        id_rango,
        fecha_turno
    )
    VALUES (
        v_id_medico,
        v_id_rango,
        v_fecha_turno
    );


    RAISE NOTICE
        'El turno ha sido cancelado y vuelto a estar disponible.';

END;
$$;


ALTER PROCEDURE public.cancelarturno(IN p_id_paciente integer, IN p_id_turno_asignado integer) OWNER TO "tuSanatorio_owner";

-- TOC entry 282 (class 1255 OID 26436)
-- Name: checkdobleturno(integer, integer, date, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.checkdobleturno(IN p_id_medico integer, IN p_id_rango integer, IN p_fecha_turno date, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT COUNT(*) AS cantidad
        FROM Turnos_disponibles
        WHERE id_medico = p_id_medico
          AND id_rango = p_id_rango
          AND fecha_turno = p_fecha_turno;

END;
$$;


ALTER PROCEDURE public.checkdobleturno(IN p_id_medico integer, IN p_id_rango integer, IN p_fecha_turno date, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 264 (class 1255 OID 26437)
-- Name: checkturnoasignado(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.checkturnoasignado(IN p_id_turno_asignado integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT *
        FROM Turnos_asignados
        WHERE id_turno_asignado = p_id_turno_asignado;

END;
$$;


ALTER PROCEDURE public.checkturnoasignado(IN p_id_turno_asignado integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 283 (class 1255 OID 26438)
-- Name: datosdelturno(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.datosdelturno(IN p_id_turno integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            td.fecha_turno,
            r.hora_inicio,
            r.hora_fin,
            umed.nombres AS medicoNombre,
            umed.apellido AS medicoApellido,
            upac.nombres AS nombrePac,
            upac.apellido AS apellidoPac,
            umed.telefono AS medicoTelefono,
            e.nombre AS especialidadNombre
        FROM TurnosDescartados td
        INNER JOIN Rangos r
            ON td.id_rango = r.id_rango
        INNER JOIN Medicos me
            ON me.id_medico = td.id_medico
        INNER JOIN Usuarios umed
            ON umed.id_usuario = me.id_usuario
        INNER JOIN Turnos_asignados ta
            ON ta.id_turno = td.id_turno
        INNER JOIN Pacientes pa
            ON pa.id_paciente = ta.id_paciente
        INNER JOIN Usuarios upac
            ON upac.id_usuario = pa.id_usuario
        INNER JOIN Especialidades e
            ON e.id_especialidad = me.id_especialidad
        WHERE td.id_turno = p_id_turno;

END;
$$;


ALTER PROCEDURE public.datosdelturno(IN p_id_turno integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 284 (class 1255 OID 26439)
-- Name: existente(bigint, character varying, character varying, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.existente(IN p_dni bigint, IN p_email character varying, IN p_username character varying, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT *
        FROM Usuarios
        WHERE DNI = p_DNI
           OR email = p_email
           OR username = p_username;

END;
$$;


ALTER PROCEDURE public.existente(IN p_dni bigint, IN p_email character varying, IN p_username character varying, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 285 (class 1255 OID 26440)
-- Name: existepaciente(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.existepaciente(IN p_id_paciente integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT COUNT(*) AS count
        FROM Pacientes
        WHERE id_paciente = p_id_paciente;

END;
$$;


ALTER PROCEDURE public.existepaciente(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 286 (class 1255 OID 26441)
-- Name: getespecialidades(refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.getespecialidades(INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT *
        FROM Especialidades
        ORDER BY nombre;

END;
$$;


ALTER PROCEDURE public.getespecialidades(INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 287 (class 1255 OID 26442)
-- Name: getespecialidadespormédico(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public."getespecialidadespormédico"(IN p_id_medico integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            e.nombre,
            me.id_medico,
            u.nombres,
            u.apellido
        FROM Especialidades e
        INNER JOIN Medicos me
            ON e.id_especialidad = me.id_especialidad
        INNER JOIN Usuarios u
            ON me.id_usuario = u.id_usuario
        WHERE me.id_medico = p_id_medico;

END;
$$;


ALTER PROCEDURE public."getespecialidadespormédico"(IN p_id_medico integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 278 (class 1255 OID 26443)
-- Name: gethistoriaspordnipaciente(bigint, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.gethistoriaspordnipaciente(IN p_dni bigint, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            u.nombres,
            u.apellido,
            u.DNI,
            h.id_historia_clinica,
            h.fecha_registro,
            dh.historia_clinica,
            me.id_medico,
            mu.nombres AS nombre_medico,
            mu.apellido AS apellido_medico
        FROM HistClinicas h
        INNER JOIN Detalle_Historias dh
            ON h.id_historia_clinica = dh.id_historia_clinica
        INNER JOIN Pacientes p
            ON h.id_paciente = p.id_paciente
        INNER JOIN Usuarios u
            ON p.id_usuario = u.id_usuario
        INNER JOIN Medicos me
            ON dh.id_medico = me.id_medico
        INNER JOIN Usuarios mu
            ON me.id_usuario = mu.id_usuario
        WHERE u.DNI = p_dni
        ORDER BY h.fecha_registro DESC;

END;
$$;


ALTER PROCEDURE public.gethistoriaspordnipaciente(IN p_dni bigint, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 271 (class 1255 OID 26444)
-- Name: gethistoriaspormedico(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.gethistoriaspormedico(IN p_id_medico integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            u.nombres,
            u.apellido,
            h.fecha_registro,
            dh.historia_clinica
        FROM HistClinicas h
        INNER JOIN Detalle_Historias dh
            ON h.id_historia_clinica = dh.id_historia_clinica
        INNER JOIN Pacientes pa
            ON h.id_paciente = pa.id_paciente
        INNER JOIN Usuarios u
            ON pa.id_usuario = u.id_usuario
        WHERE dh.id_medico = p_id_medico
        ORDER BY h.fecha_registro DESC;

END;
$$;


ALTER PROCEDURE public.gethistoriaspormedico(IN p_id_medico integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 272 (class 1255 OID 26445)
-- Name: gethistoriasporpaciente(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.gethistoriasporpaciente(IN p_id_paciente integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            u.nombres,
            u.apellido,
            h.fecha_registro,
            dh.historia_clinica
        FROM HistClinicas h
        INNER JOIN Detalle_Historias dh
            ON h.id_historia_clinica = dh.id_historia_clinica
        INNER JOIN Pacientes pa
            ON h.id_paciente = pa.id_paciente
        INNER JOIN Usuarios u
            ON pa.id_usuario = u.id_usuario
        WHERE h.id_paciente = p_id_paciente
        ORDER BY h.fecha_registro DESC;

END;
$$;


ALTER PROCEDURE public.gethistoriasporpaciente(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 274 (class 1255 OID 26446)
-- Name: getobrassociales(refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.getobrassociales(INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT *
        FROM Obras_sociales
        ORDER BY obra_social;

END;
$$;


ALTER PROCEDURE public.getobrassociales(INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 275 (class 1255 OID 26447)
-- Name: getobrassocialespormedico(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.getobrassocialespormedico(IN p_id_medico integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            os.id_obra_social,
            os.obra_social
        FROM Obras_sociales os
        INNER JOIN Medicos_ObrasSociales mo
            ON os.id_obra_social = mo.id_obra_social
        WHERE mo.id_medico = p_id_medico
        ORDER BY os.obra_social;

END;
$$;


ALTER PROCEDURE public.getobrassocialespormedico(IN p_id_medico integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 277 (class 1255 OID 26448)
-- Name: getobrassocialesporpaciente(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.getobrassocialesporpaciente(IN p_id_paciente integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            os.id_obra_social,
            os.obra_social
        FROM Obras_sociales os
        INNER JOIN Pacientes_ObrasSociales po
            ON os.id_obra_social = po.id_obra_social
        WHERE po.id_paciente = p_id_paciente
        ORDER BY os.obra_social;

END;
$$;


ALTER PROCEDURE public.getobrassocialesporpaciente(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 279 (class 1255 OID 26449)
-- Name: getrangos(refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.getrangos(INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            id_rango,
            hora_inicio,
            hora_fin
        FROM Rangos
        ORDER BY hora_inicio;

END;
$$;


ALTER PROCEDURE public.getrangos(INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 288 (class 1255 OID 26450)
-- Name: getturnosdisponibles(integer, integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.getturnosdisponibles(IN p_id_medico integer, IN p_id_especialidad integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            t.id_turno,
            t.fecha_turno,
            ra.hora_inicio,
            ra.hora_fin,
            u.nombres AS nombre_medico,
            u.apellido AS apellido_medico,
            e.nombre AS especialidad
        FROM Turnos_disponibles t
        INNER JOIN Rangos ra
            ON t.id_rango = ra.id_rango
        INNER JOIN Medicos me
            ON me.id_medico = t.id_medico
        INNER JOIN Usuarios u
            ON u.id_usuario = me.id_usuario
        INNER JOIN Especialidades e
            ON e.id_especialidad = me.id_especialidad
        WHERE me.id_medico = p_id_medico
          AND me.id_especialidad = p_id_especialidad
        ORDER BY
            t.fecha_turno,
            ra.hora_inicio;

END;
$$;


ALTER PROCEDURE public.getturnosdisponibles(IN p_id_medico integer, IN p_id_especialidad integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 289 (class 1255 OID 26451)
-- Name: getuserbyusername(character varying, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.getuserbyusername(IN p_username character varying, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            u.id_usuario,
            u.nombres,
            u.apellido,
            u.DNI,
            u.email,
            u.username,
            u.contrasena,
            u.telefono,
            u.id_rol,
            p.id_paciente
        FROM Usuarios u
        LEFT JOIN Pacientes p
            ON u.id_usuario = p.id_usuario
        WHERE u.username = p_username;

END;
$$;


ALTER PROCEDURE public.getuserbyusername(IN p_username character varying, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 290 (class 1255 OID 26452)
-- Name: historialturnos(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.historialturnos(IN p_id_paciente integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            td.fecha_turno AS "Fecha del turno",
            um.nombres AS "Medico",
            e.nombre AS "Especialidad"
        FROM Turnos_asignados ta
        INNER JOIN Pacientes p
            ON p.id_paciente = ta.id_paciente
        INNER JOIN TurnosDescartados td
            ON ta.id_turno = td.id_turno
        INNER JOIN Medicos m
            ON td.id_medico = m.id_medico
        INNER JOIN Usuarios um
            ON m.id_usuario = um.id_usuario
        INNER JOIN Especialidades e
            ON m.id_especialidad = e.id_especialidad
        WHERE p.id_paciente = p_id_paciente
          AND td.fecha_turno < CURRENT_DATE
        ORDER BY td.fecha_turno DESC;

END;
$$;


ALTER PROCEDURE public.historialturnos(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 291 (class 1255 OID 26453)
-- Name: historialturnosmedico(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.historialturnosmedico(IN p_id_medico integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            th.id_turno AS id_turno_historico,
            u.nombres || ' ' || u.apellido AS Paciente,
            um.nombres || ' ' || um.apellido AS Medico,
            e.nombre AS Especialidad,
            ra.hora_inicio,
            ra.hora_fin,
            td.fecha_turno
        FROM TurnosHistoricos th
        INNER JOIN Pacientes p
            ON th.id_paciente = p.id_paciente
        INNER JOIN Usuarios u
            ON p.id_usuario = u.id_usuario
        INNER JOIN TurnosDescartados td
            ON th.id_turno = td.id_turno
        INNER JOIN Medicos me
            ON td.id_medico = me.id_medico
        INNER JOIN Usuarios um
            ON me.id_usuario = um.id_usuario
        INNER JOIN Especialidades e
            ON me.id_especialidad = e.id_especialidad
        INNER JOIN Rangos ra
            ON td.id_rango = ra.id_rango
        WHERE td.fecha_turno < CURRENT_DATE
          AND td.id_medico = p_id_medico
        ORDER BY td.fecha_turno DESC;

END;
$$;


ALTER PROCEDURE public.historialturnosmedico(IN p_id_medico integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 292 (class 1255 OID 26454)
-- Name: horariospormedico(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.horariospormedico(IN p_id_medico integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            me.id_medico,
            u.nombres,
            u.apellido,
            ra.hora_inicio,
            ra.hora_fin
        FROM Medicos me
        INNER JOIN Usuarios u
            ON me.id_usuario = u.id_usuario
        INNER JOIN Turnos_disponibles td
            ON me.id_medico = td.id_medico
        INNER JOIN Rangos ra
            ON td.id_rango = ra.id_rango
        WHERE me.id_medico = p_id_medico
        ORDER BY ra.hora_inicio;

END;
$$;


ALTER PROCEDURE public.horariospormedico(IN p_id_medico integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 293 (class 1255 OID 26455)
-- Name: idpaciente_idturnoasignado(integer, integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.idpaciente_idturnoasignado(IN p_id_paciente integer, IN p_id_turno_asignado integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT *
        FROM Turnos_asignados
        WHERE id_paciente = p_id_paciente
          AND id_turno_asignado = p_id_turno_asignado;

END;
$$;


ALTER PROCEDURE public.idpaciente_idturnoasignado(IN p_id_paciente integer, IN p_id_turno_asignado integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 294 (class 1255 OID 26456)
-- Name: insertarhistoriacondetalle(integer, integer, text, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insertarhistoriacondetalle(IN p_id_paciente integer, IN p_id_medico integer, IN p_historia_clinica text, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_historia_clinica INT;
BEGIN

    IF p_id_paciente IS NULL THEN
        RAISE EXCEPTION 'Debe especificar id_paciente';
    END IF;


    IF p_id_medico IS NULL THEN
        RAISE EXCEPTION 'Debe especificar id_medico';
    END IF;


    IF p_historia_clinica IS NULL
       OR BTRIM(p_historia_clinica) = ''
    THEN
        RAISE EXCEPTION
            'El contenido de la historia clínica no puede estar vacío';
    END IF;


    INSERT INTO HistClinicas(
        id_paciente,
        fecha_registro
    )
    VALUES (
        p_id_paciente,
        CURRENT_TIMESTAMP
    )
    RETURNING id_historia_clinica
    INTO v_id_historia_clinica;


    INSERT INTO Detalle_Historias(
        id_historia_clinica,
        id_medico,
        historia_clinica,
        fecha_detalle
    )
    VALUES (
        v_id_historia_clinica,
        p_id_medico,
        p_historia_clinica,
        CURRENT_TIMESTAMP
    );


    OPEN cur FOR
        SELECT v_id_historia_clinica AS id_historia_clinica;

END;
$$;


ALTER PROCEDURE public.insertarhistoriacondetalle(IN p_id_paciente integer, IN p_id_medico integer, IN p_historia_clinica text, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 295 (class 1255 OID 26457)
-- Name: insertarusuario(bigint, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insertarusuario(IN p_dni bigint, IN p_nombres character varying, IN p_apellido character varying, IN p_email character varying, IN p_username character varying, IN p_telefono character varying, IN p_contrasena character varying, IN p_id_rol integer, IN p_id_especialidad integer, IN p_id_obra_social integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_usuario INT;
    v_id_paciente INT;
    v_id_medico INT;
BEGIN

    IF p_DNI IS NULL THEN
        RAISE EXCEPTION 'El DNI no puede ser NULL';
    END IF;


    IF p_id_rol IS NULL THEN
        RAISE EXCEPTION 'El rol no puede ser NULL';
    END IF;


    INSERT INTO Usuarios(
        DNI,
        nombres,
        apellido,
        email,
        username,
        telefono,
        contrasena,
        id_rol
    )
    VALUES (
        p_DNI,
        p_nombres,
        p_apellido,
        p_email,
        p_username,
        p_telefono,
        p_contrasena,
        p_id_rol
    )
    RETURNING id_usuario
    INTO v_id_usuario;


    /* ========================================================
       ROL 1 = PACIENTE
       ======================================================== */

    IF p_id_rol = 1 THEN

        IF p_id_obra_social IS NULL THEN
            RAISE EXCEPTION
                'id_obra_social no puede ser NULL para pacientes.';
        END IF;


        INSERT INTO Pacientes(
            id_usuario
        )
        VALUES (
            v_id_usuario
        )
        RETURNING id_paciente
        INTO v_id_paciente;


        INSERT INTO Pacientes_ObrasSociales(
            id_paciente,
            id_obra_social,
            fecha_registro
        )
        VALUES (
            v_id_paciente,
            p_id_obra_social,
            CURRENT_TIMESTAMP
        );

    END IF;


    /* ========================================================
       ROL 2 = MÉDICO
       ======================================================== */

    IF p_id_rol = 2 THEN

        IF p_id_especialidad IS NULL THEN
            RAISE EXCEPTION
                'id_especialidad no puede ser NULL para médicos.';
        END IF;


        IF p_id_obra_social IS NULL THEN
            RAISE EXCEPTION
                'id_obra_social no puede ser NULL para médicos.';
        END IF;


        INSERT INTO Medicos(
            id_usuario,
            id_especialidad
        )
        VALUES (
            v_id_usuario,
            p_id_especialidad
        )
        RETURNING id_medico
        INTO v_id_medico;


        INSERT INTO Medicos_ObrasSociales(
            id_medico,
            id_obra_social,
            fecha_registro
        )
        VALUES (
            v_id_medico,
            p_id_obra_social,
            CURRENT_TIMESTAMP
        );

    END IF;


    RAISE NOTICE
        'Usuario creado correctamente. ID: %',
        v_id_usuario;

END;
$$;


ALTER PROCEDURE public.insertarusuario(IN p_dni bigint, IN p_nombres character varying, IN p_apellido character varying, IN p_email character varying, IN p_username character varying, IN p_telefono character varying, IN p_contrasena character varying, IN p_id_rol integer, IN p_id_especialidad integer, IN p_id_obra_social integer) OWNER TO "tuSanatorio_owner";

-- TOC entry 280 (class 1255 OID 26458)
-- Name: insertturnosdisponibles(integer, integer, date); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insertturnosdisponibles(IN p_id_medico integer, IN p_id_rango integer, IN p_fecha_turno date)
    LANGUAGE plpgsql
    AS $$
BEGIN

    INSERT INTO Turnos_disponibles(
        id_medico,
        id_rango,
        fecha_turno
    )
    VALUES (
        p_id_medico,
        p_id_rango,
        p_fecha_turno
    );

END;
$$;


ALTER PROCEDURE public.insertturnosdisponibles(IN p_id_medico integer, IN p_id_rango integer, IN p_fecha_turno date) OWNER TO "tuSanatorio_owner";

-- TOC entry 251 (class 1255 OID 26459)
-- Name: medicosporespecialidad(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.medicosporespecialidad(IN p_id_especialidad integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            m.id_medico,
            u.nombres,
            u.apellido
        FROM Medicos m
        INNER JOIN Usuarios u
            ON m.id_usuario = u.id_usuario
        WHERE m.id_especialidad = p_id_especialidad
        ORDER BY u.apellido, u.nombres;

END;
$$;


ALTER PROCEDURE public.medicosporespecialidad(IN p_id_especialidad integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 296 (class 1255 OID 26460)
-- Name: misproximosturnos(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.misproximosturnos(IN p_id_paciente integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            ta.id_turno_asignado,
            td.id_turno,
            me.id_medico,
            u.nombres,
            u.apellido,
            e.nombre AS especialidad,
            e.id_especialidad,
            td.fecha_turno,
            ra.id_rango,
            ra.hora_inicio,
            ra.hora_fin,
            COALESCE(
                STRING_AGG(
                    DISTINCT o.obra_social,
                    ', '
                ),
                ''
            ) AS obras_sociales,
            COALESCE(
                STRING_AGG(
                    DISTINCT CAST(o.id_obra_social AS VARCHAR),
                    ','
                ),
                ''
            ) AS ids_obras_sociales
        FROM Turnos_asignados ta
        INNER JOIN TurnosDescartados td
            ON td.id_turno = ta.id_turno
        INNER JOIN Rangos ra
            ON ra.id_rango = td.id_rango
        INNER JOIN Medicos me
            ON me.id_medico = td.id_medico
        INNER JOIN Usuarios u
            ON u.id_usuario = me.id_usuario
        INNER JOIN Especialidades e
            ON e.id_especialidad = me.id_especialidad
        LEFT JOIN Medicos_ObrasSociales mo
            ON mo.id_medico = me.id_medico
        LEFT JOIN Obras_sociales o
            ON o.id_obra_social = mo.id_obra_social
        WHERE ta.id_paciente = p_id_paciente
          AND (
                td.fecha_turno > CURRENT_DATE
                OR (
                    td.fecha_turno = CURRENT_DATE
                    AND ra.hora_inicio > CURRENT_TIME
                )
              )
        GROUP BY
            ta.id_turno_asignado,
            td.id_turno,
            me.id_medico,
            u.nombres,
            u.apellido,
            e.nombre,
            e.id_especialidad,
            td.fecha_turno,
            ra.id_rango,
            ra.hora_inicio,
            ra.hora_fin
        ORDER BY
            td.fecha_turno ASC,
            ra.hora_inicio ASC;

END;
$$;


ALTER PROCEDURE public.misproximosturnos(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 297 (class 1255 OID 26461)
-- Name: misturnoshistoricos(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.misturnoshistoricos(IN p_id_paciente integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            th.id_turno AS id_turno_historico,
            u.nombres AS paciente_nombre,
            u.apellido AS paciente_apellido,
            e.nombre AS especialidad,
            td.fecha_turno,
            ra.hora_inicio,
            ra.hora_fin,
            o.obra_social,
            um.nombres AS medico_nombre,
            um.apellido AS medico_apellido
        FROM TurnosHistoricos th
        INNER JOIN TurnosDescartados td
            ON th.id_turno = td.id_turno
        INNER JOIN Rangos ra
            ON td.id_rango = ra.id_rango
        INNER JOIN Pacientes p
            ON th.id_paciente = p.id_paciente
        INNER JOIN Usuarios u
            ON p.id_usuario = u.id_usuario
        INNER JOIN Medicos me
            ON td.id_medico = me.id_medico
        INNER JOIN Usuarios um
            ON me.id_usuario = um.id_usuario
        INNER JOIN Especialidades e
            ON me.id_especialidad = e.id_especialidad
        LEFT JOIN Obras_sociales o
            ON th.id_obra_social = o.id_obra_social
        WHERE p.id_paciente = p_id_paciente
          AND td.fecha_turno < CURRENT_DATE
        ORDER BY td.fecha_turno DESC;

END;
$$;


ALTER PROCEDURE public.misturnoshistoricos(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 298 (class 1255 OID 26462)
-- Name: misturnosproximos(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.misturnosproximos(IN p_id_paciente integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            ta.id_turno_asignado,
            td.id_turno AS id_turno_descartado,
            u.nombres,
            u.apellido,
            e.nombre AS especialidad,
            td.fecha_turno,
            ra.hora_inicio,
            ra.hora_fin,
            COALESCE(
                STRING_AGG(
                    DISTINCT o.obra_social,
                    ', '
                ),
                ''
            ) AS obras_sociales
        FROM Turnos_asignados ta
        INNER JOIN TurnosDescartados td
            ON td.id_turno = ta.id_turno
        INNER JOIN Rangos ra
            ON ra.id_rango = td.id_rango
        INNER JOIN Medicos me
            ON me.id_medico = td.id_medico
        INNER JOIN Usuarios u
            ON u.id_usuario = me.id_usuario
        INNER JOIN Especialidades e
            ON e.id_especialidad = me.id_especialidad
        LEFT JOIN Medicos_ObrasSociales mo
            ON mo.id_medico = me.id_medico
        LEFT JOIN Obras_sociales o
            ON o.id_obra_social = mo.id_obra_social
        WHERE ta.id_paciente = p_id_paciente
          AND (
                td.fecha_turno > CURRENT_DATE
                OR (
                    td.fecha_turno = CURRENT_DATE
                    AND ra.hora_fin > CURRENT_TIME
                )
              )
        GROUP BY
            ta.id_turno_asignado,
            td.id_turno,
            u.nombres,
            u.apellido,
            e.nombre,
            td.fecha_turno,
            ra.hora_inicio,
            ra.hora_fin
        ORDER BY
            td.fecha_turno ASC,
            ra.hora_inicio ASC;

END;
$$;


ALTER PROCEDURE public.misturnosproximos(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 299 (class 1255 OID 26463)
-- Name: modificarturno(integer, integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.modificarturno(IN p_id_turno_asignado integer, IN p_id_nuevo_turno integer, IN p_id_paciente integer, IN p_id_obra_social integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_turno_viejo INT;
    v_id_medico INT;
    v_id_rango INT;
    v_fecha_turno DATE;
BEGIN

    SELECT id_turno
    INTO v_id_turno_viejo
    FROM Turnos_asignados
    WHERE id_turno_asignado = p_id_turno_asignado
      AND id_paciente = p_id_paciente;


    IF v_id_turno_viejo IS NULL THEN

        RAISE EXCEPTION
            'No se encontró un turno asignado para el paciente.';

    END IF;


    SELECT
        id_medico,
        id_rango,
        fecha_turno
    INTO
        v_id_medico,
        v_id_rango,
        v_fecha_turno
    FROM TurnosDescartados
    WHERE id_turno = v_id_turno_viejo;


    IF v_id_medico IS NULL THEN

        RAISE EXCEPTION
            'No se encontraron los datos del turno actual.';

    END IF;


    /* Devolver el turno viejo a disponibles */

    INSERT INTO Turnos_disponibles(
        id_medico,
        id_rango,
        fecha_turno
    )
    VALUES (
        v_id_medico,
        v_id_rango,
        v_fecha_turno
    );


    /* Eliminar asignación anterior */

    DELETE FROM Turnos_asignados
    WHERE id_turno_asignado = p_id_turno_asignado
      AND id_paciente = p_id_paciente;


    /* Verificar que el nuevo turno exista */

    IF NOT EXISTS (
        SELECT 1
        FROM Turnos_disponibles
        WHERE id_turno = p_id_nuevo_turno
    )
    THEN
        RAISE EXCEPTION
            'El nuevo turno no está disponible.';
    END IF;


    /* Crear nueva asignación */

    INSERT INTO Turnos_asignados(
        id_turno,
        id_paciente,
        id_obra_social,
        fecha_asignacion
    )
    VALUES (
        p_id_nuevo_turno,
        p_id_paciente,
        p_id_obra_social,
        CURRENT_TIMESTAMP
    );


    /* Sacar nuevo turno de disponibles */

    DELETE FROM Turnos_disponibles
    WHERE id_turno = p_id_nuevo_turno;


    RAISE NOTICE
        'Turno modificado correctamente.';

END;
$$;


ALTER PROCEDURE public.modificarturno(IN p_id_turno_asignado integer, IN p_id_nuevo_turno integer, IN p_id_paciente integer, IN p_id_obra_social integer) OWNER TO "tuSanatorio_owner";

-- TOC entry 300 (class 1255 OID 26464)
-- Name: obtenerdatosusuario(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.obtenerdatosusuario(IN p_id_paciente integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            u.nombres,
            u.apellido,
            u.telefono,
            u.email
        FROM Usuarios u
        INNER JOIN Pacientes pa
            ON u.id_usuario = pa.id_usuario
        WHERE pa.id_paciente = p_id_paciente;

END;
$$;


ALTER PROCEDURE public.obtenerdatosusuario(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 301 (class 1255 OID 26465)
-- Name: pacienteenturnosasignados(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.pacienteenturnosasignados(IN p_id_paciente integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT *
        FROM Turnos_asignados
        WHERE id_paciente = p_id_paciente
        ORDER BY fecha_asignacion DESC;

END;
$$;


ALTER PROCEDURE public.pacienteenturnosasignados(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 302 (class 1255 OID 26466)
-- Name: sp_getpacientebydni(bigint, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_getpacientebydni(IN p_dni bigint, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            p.id_paciente,
            u.nombres,
            u.apellido,
            u.DNI
        FROM Pacientes p
        INNER JOIN Usuarios u
            ON p.id_usuario = u.id_usuario
        WHERE u.DNI = p_dni;

END;
$$;


ALTER PROCEDURE public.sp_getpacientebydni(IN p_dni bigint, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 303 (class 1255 OID 26467)
-- Name: sp_getusuariobyid(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_getusuariobyid(IN p_id_usuario integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT
            id_usuario,
            nombres,
            apellido,
            email,
            username,
            telefono,
            id_rol
        FROM Usuarios
        WHERE id_usuario = p_id_usuario;

END;
$$;


ALTER PROCEDURE public.sp_getusuariobyid(IN p_id_usuario integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 266 (class 1255 OID 26468)
-- Name: sp_moverturnoshistoricos(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_moverturnoshistoricos()
    LANGUAGE plpgsql
    AS $$
BEGIN

    INSERT INTO TurnosHistoricos(
        id_turno_asignado,
        id_turno,
        id_paciente,
        id_obra_social,
        fecha_asignacion
    )
    SELECT
        ta.id_turno_asignado,
        ta.id_turno,
        ta.id_paciente,
        ta.id_obra_social,
        ta.fecha_asignacion
    FROM Turnos_asignados ta
    INNER JOIN TurnosDescartados td
        ON td.id_turno = ta.id_turno
    WHERE td.fecha_turno <= CURRENT_DATE
      AND NOT EXISTS (
          SELECT 1
          FROM TurnosHistoricos th
          WHERE th.id_turno_asignado = ta.id_turno_asignado
      );


    DELETE FROM Turnos_asignados ta
    USING TurnosDescartados td
    WHERE td.id_turno = ta.id_turno
      AND td.fecha_turno <= CURRENT_DATE;

END;
$$;


ALTER PROCEDURE public.sp_moverturnoshistoricos() OWNER TO "tuSanatorio_owner";

-- TOC entry 267 (class 1255 OID 26469)
-- Name: turnoasignadocheck(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.turnoasignadocheck(IN p_id_turno integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT 1
        FROM Turnos_asignados
        WHERE id_turno = p_id_turno;

END;
$$;


ALTER PROCEDURE public.turnoasignadocheck(IN p_id_turno integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 268 (class 1255 OID 26470)
-- Name: turnodisponiblecheck(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.turnodisponiblecheck(IN p_id_turno integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT *
        FROM Turnos_disponibles
        WHERE id_turno = p_id_turno;

END;
$$;


ALTER PROCEDURE public.turnodisponiblecheck(IN p_id_turno integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 269 (class 1255 OID 26471)
-- Name: vermedicoporidusuario(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.vermedicoporidusuario(IN p_id_usuario integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT id_medico
        FROM Medicos
        WHERE id_usuario = p_id_usuario;

END;
$$;


ALTER PROCEDURE public.vermedicoporidusuario(IN p_id_usuario integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";

-- TOC entry 270 (class 1255 OID 26472)
-- Name: verpacienteporidusuario(integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.verpacienteporidusuario(IN p_id_usuario integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    OPEN cur FOR
        SELECT id_paciente
        FROM Pacientes
        WHERE id_usuario = p_id_usuario;

END;
$$;


ALTER PROCEDURE public.verpacienteporidusuario(IN p_id_usuario integer, INOUT cur refcursor) OWNER TO "tuSanatorio_owner";


-- TOC entry 5120 (class 0 OID 0)
-- Dependencies: 262
-- Name: PROCEDURE actualizarcontrasena(IN p_contrasena character varying, IN p_id_usuario integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.actualizarcontrasena(IN p_contrasena character varying, IN p_id_usuario integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5121 (class 0 OID 0)
-- Dependencies: 265
-- Name: PROCEDURE actualizarmail(IN p_email character varying, IN p_id_usuario integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.actualizarmail(IN p_email character varying, IN p_id_usuario integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5122 (class 0 OID 0)
-- Dependencies: 249
-- Name: PROCEDURE actualizarperfil(IN p_email character varying, IN p_telefono character varying, IN p_username character varying, IN p_contrasena character varying, IN p_id_usuario integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.actualizarperfil(IN p_email character varying, IN p_telefono character varying, IN p_username character varying, IN p_contrasena character varying, IN p_id_usuario integer) TO "tuSanatorio_owner";

-- TOC entry 5123 (class 0 OID 0)
-- Dependencies: 250
-- Name: PROCEDURE actualizarusername(IN p_username character varying, IN p_id_usuario integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.actualizarusername(IN p_username character varying, IN p_id_usuario integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5124 (class 0 OID 0)
-- Dependencies: 273
-- Name: PROCEDURE asignarturno(IN p_id_turno integer, IN p_id_paciente integer, IN p_id_obra_social integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.asignarturno(IN p_id_turno integer, IN p_id_paciente integer, IN p_id_obra_social integer) TO "tuSanatorio_owner";

-- TOC entry 5125 (class 0 OID 0)
-- Dependencies: 276
-- Name: PROCEDURE buscarpacienteportexto(IN p_texto character varying, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.buscarpacienteportexto(IN p_texto character varying, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5126 (class 0 OID 0)
-- Dependencies: 281
-- Name: PROCEDURE cancelarturno(IN p_id_paciente integer, IN p_id_turno_asignado integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.cancelarturno(IN p_id_paciente integer, IN p_id_turno_asignado integer) TO "tuSanatorio_owner";

-- TOC entry 5127 (class 0 OID 0)
-- Dependencies: 282
-- Name: PROCEDURE checkdobleturno(IN p_id_medico integer, IN p_id_rango integer, IN p_fecha_turno date, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.checkdobleturno(IN p_id_medico integer, IN p_id_rango integer, IN p_fecha_turno date, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5128 (class 0 OID 0)
-- Dependencies: 264
-- Name: PROCEDURE checkturnoasignado(IN p_id_turno_asignado integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.checkturnoasignado(IN p_id_turno_asignado integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5129 (class 0 OID 0)
-- Dependencies: 283
-- Name: PROCEDURE datosdelturno(IN p_id_turno integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.datosdelturno(IN p_id_turno integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5130 (class 0 OID 0)
-- Dependencies: 284
-- Name: PROCEDURE existente(IN p_dni bigint, IN p_email character varying, IN p_username character varying, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.existente(IN p_dni bigint, IN p_email character varying, IN p_username character varying, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5131 (class 0 OID 0)
-- Dependencies: 285
-- Name: PROCEDURE existepaciente(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.existepaciente(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5132 (class 0 OID 0)
-- Dependencies: 286
-- Name: PROCEDURE getespecialidades(INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.getespecialidades(INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5133 (class 0 OID 0)
-- Dependencies: 287
-- Name: PROCEDURE "getespecialidadespormédico"(IN p_id_medico integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public."getespecialidadespormédico"(IN p_id_medico integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5134 (class 0 OID 0)
-- Dependencies: 278
-- Name: PROCEDURE gethistoriaspordnipaciente(IN p_dni bigint, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.gethistoriaspordnipaciente(IN p_dni bigint, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5135 (class 0 OID 0)
-- Dependencies: 271
-- Name: PROCEDURE gethistoriaspormedico(IN p_id_medico integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.gethistoriaspormedico(IN p_id_medico integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5136 (class 0 OID 0)
-- Dependencies: 272
-- Name: PROCEDURE gethistoriasporpaciente(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.gethistoriasporpaciente(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5137 (class 0 OID 0)
-- Dependencies: 274
-- Name: PROCEDURE getobrassociales(INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.getobrassociales(INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5138 (class 0 OID 0)
-- Dependencies: 275
-- Name: PROCEDURE getobrassocialespormedico(IN p_id_medico integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.getobrassocialespormedico(IN p_id_medico integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5139 (class 0 OID 0)
-- Dependencies: 277
-- Name: PROCEDURE getobrassocialesporpaciente(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.getobrassocialesporpaciente(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5140 (class 0 OID 0)
-- Dependencies: 279
-- Name: PROCEDURE getrangos(INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.getrangos(INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5141 (class 0 OID 0)
-- Dependencies: 288
-- Name: PROCEDURE getturnosdisponibles(IN p_id_medico integer, IN p_id_especialidad integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.getturnosdisponibles(IN p_id_medico integer, IN p_id_especialidad integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5142 (class 0 OID 0)
-- Dependencies: 289
-- Name: PROCEDURE getuserbyusername(IN p_username character varying, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.getuserbyusername(IN p_username character varying, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5143 (class 0 OID 0)
-- Dependencies: 290
-- Name: PROCEDURE historialturnos(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.historialturnos(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5144 (class 0 OID 0)
-- Dependencies: 291
-- Name: PROCEDURE historialturnosmedico(IN p_id_medico integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.historialturnosmedico(IN p_id_medico integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5145 (class 0 OID 0)
-- Dependencies: 292
-- Name: PROCEDURE horariospormedico(IN p_id_medico integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.horariospormedico(IN p_id_medico integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5146 (class 0 OID 0)
-- Dependencies: 293
-- Name: PROCEDURE idpaciente_idturnoasignado(IN p_id_paciente integer, IN p_id_turno_asignado integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.idpaciente_idturnoasignado(IN p_id_paciente integer, IN p_id_turno_asignado integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5147 (class 0 OID 0)
-- Dependencies: 294
-- Name: PROCEDURE insertarhistoriacondetalle(IN p_id_paciente integer, IN p_id_medico integer, IN p_historia_clinica text, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.insertarhistoriacondetalle(IN p_id_paciente integer, IN p_id_medico integer, IN p_historia_clinica text, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5148 (class 0 OID 0)
-- Dependencies: 295
-- Name: PROCEDURE insertarusuario(IN p_dni bigint, IN p_nombres character varying, IN p_apellido character varying, IN p_email character varying, IN p_username character varying, IN p_telefono character varying, IN p_contrasena character varying, IN p_id_rol integer, IN p_id_especialidad integer, IN p_id_obra_social integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.insertarusuario(IN p_dni bigint, IN p_nombres character varying, IN p_apellido character varying, IN p_email character varying, IN p_username character varying, IN p_telefono character varying, IN p_contrasena character varying, IN p_id_rol integer, IN p_id_especialidad integer, IN p_id_obra_social integer) TO "tuSanatorio_owner";

-- TOC entry 5149 (class 0 OID 0)
-- Dependencies: 280
-- Name: PROCEDURE insertturnosdisponibles(IN p_id_medico integer, IN p_id_rango integer, IN p_fecha_turno date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.insertturnosdisponibles(IN p_id_medico integer, IN p_id_rango integer, IN p_fecha_turno date) TO "tuSanatorio_owner";

-- TOC entry 5150 (class 0 OID 0)
-- Dependencies: 251
-- Name: PROCEDURE medicosporespecialidad(IN p_id_especialidad integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.medicosporespecialidad(IN p_id_especialidad integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5151 (class 0 OID 0)
-- Dependencies: 296
-- Name: PROCEDURE misproximosturnos(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.misproximosturnos(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5152 (class 0 OID 0)
-- Dependencies: 297
-- Name: PROCEDURE misturnoshistoricos(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.misturnoshistoricos(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5153 (class 0 OID 0)
-- Dependencies: 298
-- Name: PROCEDURE misturnosproximos(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.misturnosproximos(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5154 (class 0 OID 0)
-- Dependencies: 299
-- Name: PROCEDURE modificarturno(IN p_id_turno_asignado integer, IN p_id_nuevo_turno integer, IN p_id_paciente integer, IN p_id_obra_social integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.modificarturno(IN p_id_turno_asignado integer, IN p_id_nuevo_turno integer, IN p_id_paciente integer, IN p_id_obra_social integer) TO "tuSanatorio_owner";

-- TOC entry 5155 (class 0 OID 0)
-- Dependencies: 300
-- Name: PROCEDURE obtenerdatosusuario(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.obtenerdatosusuario(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5156 (class 0 OID 0)
-- Dependencies: 301
-- Name: PROCEDURE pacienteenturnosasignados(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.pacienteenturnosasignados(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5157 (class 0 OID 0)
-- Dependencies: 302
-- Name: PROCEDURE sp_getpacientebydni(IN p_dni bigint, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.sp_getpacientebydni(IN p_dni bigint, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5158 (class 0 OID 0)
-- Dependencies: 303
-- Name: PROCEDURE sp_getusuariobyid(IN p_id_usuario integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.sp_getusuariobyid(IN p_id_usuario integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5159 (class 0 OID 0)
-- Dependencies: 266
-- Name: PROCEDURE sp_moverturnoshistoricos(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.sp_moverturnoshistoricos() TO "tuSanatorio_owner";

-- TOC entry 5160 (class 0 OID 0)
-- Dependencies: 267
-- Name: PROCEDURE turnoasignadocheck(IN p_id_turno integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.turnoasignadocheck(IN p_id_turno integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5161 (class 0 OID 0)
-- Dependencies: 268
-- Name: PROCEDURE turnodisponiblecheck(IN p_id_turno integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.turnodisponiblecheck(IN p_id_turno integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5162 (class 0 OID 0)
-- Dependencies: 269
-- Name: PROCEDURE vermedicoporidusuario(IN p_id_usuario integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.vermedicoporidusuario(IN p_id_usuario integer, INOUT cur refcursor) TO "tuSanatorio_owner";

-- TOC entry 5163 (class 0 OID 0)
-- Dependencies: 270
-- Name: PROCEDURE verpacienteporidusuario(IN p_id_usuario integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.verpacienteporidusuario(IN p_id_usuario integer, INOUT cur refcursor) TO "tuSanatorio_owner";

--
-- PostgreSQL database dump complete (solo funciones y procedimientos)
--