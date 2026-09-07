--
-- PostgreSQL database dump
--

\restrict SdBmRvVmhTGFYY875olsZqTjXPFqZ1YrfNTdY3A5oTYBSR7lBSO0CevGO0v6tj1

-- Dumped from database version 17.9
-- Dumped by pg_dump version 17.9

-- Started on 2026-09-07 18:34:15

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

--
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


ALTER PROCEDURE public.actualizarcontrasena(IN p_contrasena character varying, IN p_id_usuario integer, INOUT cur refcursor) OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 26430)
-- Name: actualizarmail(character varying, integer, refcursor); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.actualizarmail(IN p_contrasena character varying, IN p_id_usuario integer, INOUT cur refcursor)
    LANGUAGE plpgsql
    AS $$
BEGIN

    UPDATE Usuarios
    SET email = p_contrasena
    WHERE id_usuario = p_id_usuario;

    OPEN cur FOR
        SELECT *
        FROM Usuarios
        WHERE id_usuario = p_id_usuario;

END;
$$;


ALTER PROCEDURE public.actualizarmail(IN p_contrasena character varying, IN p_id_usuario integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.actualizarperfil(IN p_email character varying, IN p_telefono character varying, IN p_username character varying, IN p_contrasena character varying, IN p_id_usuario integer) OWNER TO postgres;

--
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


ALTER PROCEDURE public.actualizarusername(IN p_username character varying, IN p_id_usuario integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.asignarturno(IN p_id_turno integer, IN p_id_paciente integer, IN p_id_obra_social integer) OWNER TO postgres;

--
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


ALTER PROCEDURE public.buscarpacienteportexto(IN p_texto character varying, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.cancelarturno(IN p_id_paciente integer, IN p_id_turno_asignado integer) OWNER TO postgres;

--
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


ALTER PROCEDURE public.checkdobleturno(IN p_id_medico integer, IN p_id_rango integer, IN p_fecha_turno date, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.checkturnoasignado(IN p_id_turno_asignado integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.datosdelturno(IN p_id_turno integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.existente(IN p_dni bigint, IN p_email character varying, IN p_username character varying, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.existepaciente(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.getespecialidades(INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public."getespecialidadespormédico"(IN p_id_medico integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.gethistoriaspordnipaciente(IN p_dni bigint, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.gethistoriaspormedico(IN p_id_medico integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.gethistoriasporpaciente(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.getobrassociales(INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.getobrassocialespormedico(IN p_id_medico integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.getobrassocialesporpaciente(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.getrangos(INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.getturnosdisponibles(IN p_id_medico integer, IN p_id_especialidad integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.getuserbyusername(IN p_username character varying, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.historialturnos(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.historialturnosmedico(IN p_id_medico integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.horariospormedico(IN p_id_medico integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.idpaciente_idturnoasignado(IN p_id_paciente integer, IN p_id_turno_asignado integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.insertarhistoriacondetalle(IN p_id_paciente integer, IN p_id_medico integer, IN p_historia_clinica text, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.insertarusuario(IN p_dni bigint, IN p_nombres character varying, IN p_apellido character varying, IN p_email character varying, IN p_username character varying, IN p_telefono character varying, IN p_contrasena character varying, IN p_id_rol integer, IN p_id_especialidad integer, IN p_id_obra_social integer) OWNER TO postgres;

--
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


ALTER PROCEDURE public.insertturnosdisponibles(IN p_id_medico integer, IN p_id_rango integer, IN p_fecha_turno date) OWNER TO postgres;

--
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


ALTER PROCEDURE public.medicosporespecialidad(IN p_id_especialidad integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.misproximosturnos(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.misturnoshistoricos(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.misturnosproximos(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.modificarturno(IN p_id_turno_asignado integer, IN p_id_nuevo_turno integer, IN p_id_paciente integer, IN p_id_obra_social integer) OWNER TO postgres;

--
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


ALTER PROCEDURE public.obtenerdatosusuario(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.pacienteenturnosasignados(IN p_id_paciente integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.sp_getpacientebydni(IN p_dni bigint, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.sp_getusuariobyid(IN p_id_usuario integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.sp_moverturnoshistoricos() OWNER TO postgres;

--
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


ALTER PROCEDURE public.turnoasignadocheck(IN p_id_turno integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.turnodisponiblecheck(IN p_id_turno integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.vermedicoporidusuario(IN p_id_usuario integer, INOUT cur refcursor) OWNER TO postgres;

--
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


ALTER PROCEDURE public.verpacienteporidusuario(IN p_id_usuario integer, INOUT cur refcursor) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 248 (class 1259 OID 26411)
-- Name: detalle_historias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detalle_historias (
    id_detalle integer NOT NULL,
    id_historia_clinica integer NOT NULL,
    id_medico integer NOT NULL,
    historia_clinica text NOT NULL,
    fecha_detalle timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.detalle_historias OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 26410)
-- Name: detalle_historias_id_detalle_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.detalle_historias ALTER COLUMN id_detalle ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.detalle_historias_id_detalle_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 220 (class 1259 OID 26226)
-- Name: especialidades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.especialidades (
    id_especialidad integer NOT NULL,
    nombre character varying(100) NOT NULL
);


ALTER TABLE public.especialidades OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 26225)
-- Name: especialidades_id_especialidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.especialidades ALTER COLUMN id_especialidad ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.especialidades_id_especialidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 246 (class 1259 OID 26399)
-- Name: histclinicas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.histclinicas (
    id_historia_clinica integer NOT NULL,
    id_paciente integer NOT NULL,
    fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.histclinicas OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 26398)
-- Name: histclinicas_id_historia_clinica_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.histclinicas ALTER COLUMN id_historia_clinica ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.histclinicas_id_historia_clinica_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 224 (class 1259 OID 26251)
-- Name: medicos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medicos (
    id_medico integer NOT NULL,
    id_usuario integer NOT NULL,
    id_especialidad integer NOT NULL
);


ALTER TABLE public.medicos OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 26250)
-- Name: medicos_id_medico_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.medicos ALTER COLUMN id_medico ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.medicos_id_medico_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 232 (class 1259 OID 26303)
-- Name: medicos_obrassociales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medicos_obrassociales (
    id_medico_obras integer NOT NULL,
    id_medico integer NOT NULL,
    id_obra_social integer NOT NULL,
    fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.medicos_obrassociales OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 26302)
-- Name: medicos_obrassociales_id_medico_obras_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.medicos_obrassociales ALTER COLUMN id_medico_obras ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.medicos_obrassociales_id_medico_obras_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 242 (class 1259 OID 26376)
-- Name: medio_pago; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medio_pago (
    id_medio_pago integer NOT NULL,
    medio_pago character varying(50) NOT NULL
);


ALTER TABLE public.medio_pago OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 26375)
-- Name: medio_pago_id_medio_pago_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.medio_pago ALTER COLUMN id_medio_pago ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.medio_pago_id_medio_pago_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 228 (class 1259 OID 26278)
-- Name: obras_sociales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.obras_sociales (
    id_obra_social integer NOT NULL,
    obra_social character varying(100) NOT NULL
);


ALTER TABLE public.obras_sociales OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 26277)
-- Name: obras_sociales_id_obra_social_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.obras_sociales ALTER COLUMN id_obra_social ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.obras_sociales_id_obra_social_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 226 (class 1259 OID 26267)
-- Name: pacientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pacientes (
    id_paciente integer NOT NULL,
    id_usuario integer NOT NULL
);


ALTER TABLE public.pacientes OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 26266)
-- Name: pacientes_id_paciente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.pacientes ALTER COLUMN id_paciente ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.pacientes_id_paciente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 230 (class 1259 OID 26284)
-- Name: pacientes_obrassociales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pacientes_obrassociales (
    id_paciente_obras integer NOT NULL,
    id_paciente integer NOT NULL,
    id_obra_social integer NOT NULL,
    fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.pacientes_obrassociales OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 26283)
-- Name: pacientes_obrassociales_id_paciente_obras_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.pacientes_obrassociales ALTER COLUMN id_paciente_obras ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.pacientes_obrassociales_id_paciente_obras_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 244 (class 1259 OID 26382)
-- Name: pagos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pagos (
    id_pago integer NOT NULL,
    id_turno_asignado integer NOT NULL,
    id_medio_pago integer NOT NULL,
    monto numeric(10,2) NOT NULL,
    fecha_pago timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.pagos OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 26381)
-- Name: pagos_id_pago_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.pagos ALTER COLUMN id_pago ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.pagos_id_pago_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 234 (class 1259 OID 26322)
-- Name: rangos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rangos (
    id_rango integer NOT NULL,
    hora_inicio time without time zone NOT NULL,
    hora_fin time without time zone NOT NULL
);


ALTER TABLE public.rangos OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 26321)
-- Name: rangos_id_rango_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.rangos ALTER COLUMN id_rango ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.rangos_id_rango_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 218 (class 1259 OID 26220)
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    rol_id integer NOT NULL,
    rol character varying(50) NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 26219)
-- Name: roles_rol_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.roles ALTER COLUMN rol_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.roles_rol_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 238 (class 1259 OID 26344)
-- Name: turnos_asignados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.turnos_asignados (
    id_turno_asignado integer NOT NULL,
    id_turno integer NOT NULL,
    id_paciente integer NOT NULL,
    id_obra_social integer NOT NULL,
    fecha_asignacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.turnos_asignados OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 26343)
-- Name: turnos_asignados_id_turno_asignado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.turnos_asignados ALTER COLUMN id_turno_asignado ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.turnos_asignados_id_turno_asignado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 236 (class 1259 OID 26328)
-- Name: turnos_disponibles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.turnos_disponibles (
    id_turno integer NOT NULL,
    id_medico integer NOT NULL,
    id_rango integer NOT NULL,
    fecha_turno date NOT NULL
);


ALTER TABLE public.turnos_disponibles OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 26327)
-- Name: turnos_disponibles_id_turno_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.turnos_disponibles ALTER COLUMN id_turno ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.turnos_disponibles_id_turno_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 239 (class 1259 OID 26365)
-- Name: turnosdescartados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.turnosdescartados (
    id_turno integer NOT NULL,
    id_medico integer NOT NULL,
    id_rango integer NOT NULL,
    fecha_turno date NOT NULL
);


ALTER TABLE public.turnosdescartados OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 26370)
-- Name: turnoshistoricos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.turnoshistoricos (
    id_turno_asignado integer NOT NULL,
    id_turno integer NOT NULL,
    id_paciente integer NOT NULL,
    id_obra_social integer,
    fecha_asignacion timestamp without time zone NOT NULL
);


ALTER TABLE public.turnoshistoricos OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 26232)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id_usuario integer NOT NULL,
    nombres character varying(50) NOT NULL,
    apellido character varying(50) NOT NULL,
    dni bigint NOT NULL,
    email character varying(100) NOT NULL,
    contrasena character varying(200) NOT NULL,
    username character varying(50) NOT NULL,
    telefono character varying(20) NOT NULL,
    id_rol integer NOT NULL
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 26231)
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.usuarios ALTER COLUMN id_usuario ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.usuarios_id_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 5113 (class 0 OID 26411)
-- Dependencies: 248
-- Data for Name: detalle_historias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.detalle_historias (id_detalle, id_historia_clinica, id_medico, historia_clinica, fecha_detalle) FROM stdin;
\.


--
-- TOC entry 5085 (class 0 OID 26226)
-- Dependencies: 220
-- Data for Name: especialidades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.especialidades (id_especialidad, nombre) FROM stdin;
1	Cardiología
2	Pediatría
3	Dermatología
4	Ginecología
5	Traumatología
6	Neurología
7	Oftalmología
8	Otorrinolaringología
9	Psiquiatría
10	Endocrinología
\.


--
-- TOC entry 5111 (class 0 OID 26399)
-- Dependencies: 246
-- Data for Name: histclinicas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.histclinicas (id_historia_clinica, id_paciente, fecha_registro) FROM stdin;
\.


--
-- TOC entry 5089 (class 0 OID 26251)
-- Dependencies: 224
-- Data for Name: medicos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medicos (id_medico, id_usuario, id_especialidad) FROM stdin;
\.


--
-- TOC entry 5097 (class 0 OID 26303)
-- Dependencies: 232
-- Data for Name: medicos_obrassociales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medicos_obrassociales (id_medico_obras, id_medico, id_obra_social, fecha_registro) FROM stdin;
\.


--
-- TOC entry 5107 (class 0 OID 26376)
-- Dependencies: 242
-- Data for Name: medio_pago; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medio_pago (id_medio_pago, medio_pago) FROM stdin;
\.


--
-- TOC entry 5093 (class 0 OID 26278)
-- Dependencies: 228
-- Data for Name: obras_sociales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.obras_sociales (id_obra_social, obra_social) FROM stdin;
1	OSDE
2	Swiss Medical
3	Galeno
4	Medifé
5	PAMI
6	IOMA
7	Sancor Salud
8	OSECAC
9	Federada Salud
10	Prevención Salud
\.


--
-- TOC entry 5091 (class 0 OID 26267)
-- Dependencies: 226
-- Data for Name: pacientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pacientes (id_paciente, id_usuario) FROM stdin;
\.


--
-- TOC entry 5095 (class 0 OID 26284)
-- Dependencies: 230
-- Data for Name: pacientes_obrassociales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pacientes_obrassociales (id_paciente_obras, id_paciente, id_obra_social, fecha_registro) FROM stdin;
\.


--
-- TOC entry 5109 (class 0 OID 26382)
-- Dependencies: 244
-- Data for Name: pagos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pagos (id_pago, id_turno_asignado, id_medio_pago, monto, fecha_pago) FROM stdin;
\.


--
-- TOC entry 5099 (class 0 OID 26322)
-- Dependencies: 234
-- Data for Name: rangos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rangos (id_rango, hora_inicio, hora_fin) FROM stdin;
1	08:00:00	08:30:00
2	08:30:00	09:00:00
3	09:00:00	09:30:00
4	09:30:00	10:00:00
5	10:00:00	10:30:00
6	10:30:00	11:00:00
7	11:00:00	11:30:00
8	11:30:00	12:00:00
9	13:00:00	13:30:00
10	13:30:00	14:00:00
\.


--
-- TOC entry 5083 (class 0 OID 26220)
-- Dependencies: 218
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (rol_id, rol) FROM stdin;
1	Administrador
2	Paciente
3	Médico
\.


--
-- TOC entry 5103 (class 0 OID 26344)
-- Dependencies: 238
-- Data for Name: turnos_asignados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.turnos_asignados (id_turno_asignado, id_turno, id_paciente, id_obra_social, fecha_asignacion) FROM stdin;
\.


--
-- TOC entry 5101 (class 0 OID 26328)
-- Dependencies: 236
-- Data for Name: turnos_disponibles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.turnos_disponibles (id_turno, id_medico, id_rango, fecha_turno) FROM stdin;
\.


--
-- TOC entry 5104 (class 0 OID 26365)
-- Dependencies: 239
-- Data for Name: turnosdescartados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.turnosdescartados (id_turno, id_medico, id_rango, fecha_turno) FROM stdin;
\.


--
-- TOC entry 5105 (class 0 OID 26370)
-- Dependencies: 240
-- Data for Name: turnoshistoricos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.turnoshistoricos (id_turno_asignado, id_turno, id_paciente, id_obra_social, fecha_asignacion) FROM stdin;
\.


--
-- TOC entry 5087 (class 0 OID 26232)
-- Dependencies: 222
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (id_usuario, nombres, apellido, dni, email, contrasena, username, telefono, id_rol) FROM stdin;
1	Esteban	Álvarez	12345678	esteban.alvarez@mail.com	pass1234	estalvarez	1122334455	1
2	María	Gómez	23456789	maria.gomez@mail.com	maria2025	mgomez	1166778899	2
3	Juan	Pérez	34567890	juan.perez@mail.com	juanpass	jperez	1199887766	2
4	Laura	Rodríguez	45678901	laura.rodriguez@mail.com	laura2025	lrodriguez	1144556677	3
\.


--
-- TOC entry 5196 (class 0 OID 0)
-- Dependencies: 247
-- Name: detalle_historias_id_detalle_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.detalle_historias_id_detalle_seq', 1, false);


--
-- TOC entry 5197 (class 0 OID 0)
-- Dependencies: 219
-- Name: especialidades_id_especialidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.especialidades_id_especialidad_seq', 10, true);


--
-- TOC entry 5198 (class 0 OID 0)
-- Dependencies: 245
-- Name: histclinicas_id_historia_clinica_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.histclinicas_id_historia_clinica_seq', 1, false);


--
-- TOC entry 5199 (class 0 OID 0)
-- Dependencies: 223
-- Name: medicos_id_medico_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medicos_id_medico_seq', 1, false);


--
-- TOC entry 5200 (class 0 OID 0)
-- Dependencies: 231
-- Name: medicos_obrassociales_id_medico_obras_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medicos_obrassociales_id_medico_obras_seq', 1, false);


--
-- TOC entry 5201 (class 0 OID 0)
-- Dependencies: 241
-- Name: medio_pago_id_medio_pago_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medio_pago_id_medio_pago_seq', 1, false);


--
-- TOC entry 5202 (class 0 OID 0)
-- Dependencies: 227
-- Name: obras_sociales_id_obra_social_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.obras_sociales_id_obra_social_seq', 10, true);


--
-- TOC entry 5203 (class 0 OID 0)
-- Dependencies: 225
-- Name: pacientes_id_paciente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pacientes_id_paciente_seq', 1, false);


--
-- TOC entry 5204 (class 0 OID 0)
-- Dependencies: 229
-- Name: pacientes_obrassociales_id_paciente_obras_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pacientes_obrassociales_id_paciente_obras_seq', 1, false);


--
-- TOC entry 5205 (class 0 OID 0)
-- Dependencies: 243
-- Name: pagos_id_pago_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pagos_id_pago_seq', 1, false);


--
-- TOC entry 5206 (class 0 OID 0)
-- Dependencies: 233
-- Name: rangos_id_rango_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rangos_id_rango_seq', 10, true);


--
-- TOC entry 5207 (class 0 OID 0)
-- Dependencies: 217
-- Name: roles_rol_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_rol_id_seq', 3, true);


--
-- TOC entry 5208 (class 0 OID 0)
-- Dependencies: 237
-- Name: turnos_asignados_id_turno_asignado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.turnos_asignados_id_turno_asignado_seq', 1, false);


--
-- TOC entry 5209 (class 0 OID 0)
-- Dependencies: 235
-- Name: turnos_disponibles_id_turno_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.turnos_disponibles_id_turno_seq', 1, false);


--
-- TOC entry 5210 (class 0 OID 0)
-- Dependencies: 221
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_id_usuario_seq', 4, true);


--
-- TOC entry 4918 (class 2606 OID 26418)
-- Name: detalle_historias detalle_historias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_historias
    ADD CONSTRAINT detalle_historias_pkey PRIMARY KEY (id_detalle);


--
-- TOC entry 4876 (class 2606 OID 26230)
-- Name: especialidades especialidades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.especialidades
    ADD CONSTRAINT especialidades_pkey PRIMARY KEY (id_especialidad);


--
-- TOC entry 4916 (class 2606 OID 26404)
-- Name: histclinicas histclinicas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.histclinicas
    ADD CONSTRAINT histclinicas_pkey PRIMARY KEY (id_historia_clinica);


--
-- TOC entry 4898 (class 2606 OID 26308)
-- Name: medicos_obrassociales medicos_obrassociales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos_obrassociales
    ADD CONSTRAINT medicos_obrassociales_pkey PRIMARY KEY (id_medico_obras);


--
-- TOC entry 4888 (class 2606 OID 26255)
-- Name: medicos medicos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos
    ADD CONSTRAINT medicos_pkey PRIMARY KEY (id_medico);


--
-- TOC entry 4912 (class 2606 OID 26380)
-- Name: medio_pago medio_pago_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medio_pago
    ADD CONSTRAINT medio_pago_pkey PRIMARY KEY (id_medio_pago);


--
-- TOC entry 4892 (class 2606 OID 26282)
-- Name: obras_sociales obras_sociales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.obras_sociales
    ADD CONSTRAINT obras_sociales_pkey PRIMARY KEY (id_obra_social);


--
-- TOC entry 4894 (class 2606 OID 26289)
-- Name: pacientes_obrassociales pacientes_obrassociales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacientes_obrassociales
    ADD CONSTRAINT pacientes_obrassociales_pkey PRIMARY KEY (id_paciente_obras);


--
-- TOC entry 4890 (class 2606 OID 26271)
-- Name: pacientes pacientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacientes
    ADD CONSTRAINT pacientes_pkey PRIMARY KEY (id_paciente);


--
-- TOC entry 4914 (class 2606 OID 26387)
-- Name: pagos pagos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT pagos_pkey PRIMARY KEY (id_pago);


--
-- TOC entry 4902 (class 2606 OID 26326)
-- Name: rangos rangos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rangos
    ADD CONSTRAINT rangos_pkey PRIMARY KEY (id_rango);


--
-- TOC entry 4874 (class 2606 OID 26224)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (rol_id);


--
-- TOC entry 4906 (class 2606 OID 26349)
-- Name: turnos_asignados turnos_asignados_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turnos_asignados
    ADD CONSTRAINT turnos_asignados_pkey PRIMARY KEY (id_turno_asignado);


--
-- TOC entry 4904 (class 2606 OID 26332)
-- Name: turnos_disponibles turnos_disponibles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turnos_disponibles
    ADD CONSTRAINT turnos_disponibles_pkey PRIMARY KEY (id_turno);


--
-- TOC entry 4908 (class 2606 OID 26369)
-- Name: turnosdescartados turnosdescartados_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turnosdescartados
    ADD CONSTRAINT turnosdescartados_pkey PRIMARY KEY (id_turno);


--
-- TOC entry 4910 (class 2606 OID 26374)
-- Name: turnoshistoricos turnoshistoricos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turnoshistoricos
    ADD CONSTRAINT turnoshistoricos_pkey PRIMARY KEY (id_turno_asignado);


--
-- TOC entry 4900 (class 2606 OID 26310)
-- Name: medicos_obrassociales uq_medico_obra; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos_obrassociales
    ADD CONSTRAINT uq_medico_obra UNIQUE (id_medico, id_obra_social);


--
-- TOC entry 4896 (class 2606 OID 26291)
-- Name: pacientes_obrassociales uq_paciente_obra; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacientes_obrassociales
    ADD CONSTRAINT uq_paciente_obra UNIQUE (id_paciente, id_obra_social);


--
-- TOC entry 4878 (class 2606 OID 26238)
-- Name: usuarios usuarios_dni_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_dni_key UNIQUE (dni);


--
-- TOC entry 4880 (class 2606 OID 26240)
-- Name: usuarios usuarios_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_email_key UNIQUE (email);


--
-- TOC entry 4882 (class 2606 OID 26236)
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 4884 (class 2606 OID 26244)
-- Name: usuarios usuarios_telefono_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_telefono_key UNIQUE (telefono);


--
-- TOC entry 4886 (class 2606 OID 26242)
-- Name: usuarios usuarios_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_username_key UNIQUE (username);


--
-- TOC entry 4935 (class 2606 OID 26419)
-- Name: detalle_historias fk_detallehistorias_historia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_historias
    ADD CONSTRAINT fk_detallehistorias_historia FOREIGN KEY (id_historia_clinica) REFERENCES public.histclinicas(id_historia_clinica) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4936 (class 2606 OID 26424)
-- Name: detalle_historias fk_detallehistorias_medico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_historias
    ADD CONSTRAINT fk_detallehistorias_medico FOREIGN KEY (id_medico) REFERENCES public.medicos(id_medico) ON UPDATE CASCADE;


--
-- TOC entry 4934 (class 2606 OID 26405)
-- Name: histclinicas fk_histclinicas_paciente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.histclinicas
    ADD CONSTRAINT fk_histclinicas_paciente FOREIGN KEY (id_paciente) REFERENCES public.pacientes(id_paciente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4925 (class 2606 OID 26311)
-- Name: medicos_obrassociales fk_medico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos_obrassociales
    ADD CONSTRAINT fk_medico FOREIGN KEY (id_medico) REFERENCES public.medicos(id_medico);


--
-- TOC entry 4920 (class 2606 OID 26261)
-- Name: medicos fk_medicos_especialidades; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos
    ADD CONSTRAINT fk_medicos_especialidades FOREIGN KEY (id_especialidad) REFERENCES public.especialidades(id_especialidad);


--
-- TOC entry 4921 (class 2606 OID 26256)
-- Name: medicos fk_medicos_usuarios; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos
    ADD CONSTRAINT fk_medicos_usuarios FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario);


--
-- TOC entry 4926 (class 2606 OID 26316)
-- Name: medicos_obrassociales fk_obrasocialmedico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos_obrassociales
    ADD CONSTRAINT fk_obrasocialmedico FOREIGN KEY (id_obra_social) REFERENCES public.obras_sociales(id_obra_social);


--
-- TOC entry 4923 (class 2606 OID 26297)
-- Name: pacientes_obrassociales fk_obrasocialpaciente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacientes_obrassociales
    ADD CONSTRAINT fk_obrasocialpaciente FOREIGN KEY (id_obra_social) REFERENCES public.obras_sociales(id_obra_social);


--
-- TOC entry 4924 (class 2606 OID 26292)
-- Name: pacientes_obrassociales fk_paciente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacientes_obrassociales
    ADD CONSTRAINT fk_paciente FOREIGN KEY (id_paciente) REFERENCES public.pacientes(id_paciente);


--
-- TOC entry 4922 (class 2606 OID 26272)
-- Name: pacientes fk_pacientes_usuarios; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacientes
    ADD CONSTRAINT fk_pacientes_usuarios FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario);


--
-- TOC entry 4932 (class 2606 OID 26393)
-- Name: pagos fk_pagos_mediopago; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT fk_pagos_mediopago FOREIGN KEY (id_medio_pago) REFERENCES public.medio_pago(id_medio_pago);


--
-- TOC entry 4933 (class 2606 OID 26388)
-- Name: pagos fk_pagos_turnoasignado; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT fk_pagos_turnoasignado FOREIGN KEY (id_turno_asignado) REFERENCES public.turnos_asignados(id_turno_asignado);


--
-- TOC entry 4929 (class 2606 OID 26360)
-- Name: turnos_asignados fk_turnosasignados_obrasocial; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turnos_asignados
    ADD CONSTRAINT fk_turnosasignados_obrasocial FOREIGN KEY (id_obra_social) REFERENCES public.obras_sociales(id_obra_social) ON UPDATE CASCADE;


--
-- TOC entry 4930 (class 2606 OID 26355)
-- Name: turnos_asignados fk_turnosasignados_paciente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turnos_asignados
    ADD CONSTRAINT fk_turnosasignados_paciente FOREIGN KEY (id_paciente) REFERENCES public.pacientes(id_paciente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4931 (class 2606 OID 26350)
-- Name: turnos_asignados fk_turnosasignados_turno; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turnos_asignados
    ADD CONSTRAINT fk_turnosasignados_turno FOREIGN KEY (id_turno) REFERENCES public.turnos_disponibles(id_turno) ON UPDATE CASCADE;


--
-- TOC entry 4927 (class 2606 OID 26333)
-- Name: turnos_disponibles fk_turnosdisponibles_medicos; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turnos_disponibles
    ADD CONSTRAINT fk_turnosdisponibles_medicos FOREIGN KEY (id_medico) REFERENCES public.medicos(id_medico);


--
-- TOC entry 4928 (class 2606 OID 26338)
-- Name: turnos_disponibles fk_turnosdisponibles_rangos; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turnos_disponibles
    ADD CONSTRAINT fk_turnosdisponibles_rangos FOREIGN KEY (id_rango) REFERENCES public.rangos(id_rango);


--
-- TOC entry 4919 (class 2606 OID 26245)
-- Name: usuarios fk_usuarios_roles; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT fk_usuarios_roles FOREIGN KEY (id_rol) REFERENCES public.roles(rol_id);


--
-- TOC entry 5119 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO "tuSanatorio";


--
-- TOC entry 5120 (class 0 OID 0)
-- Dependencies: 262
-- Name: PROCEDURE actualizarcontrasena(IN p_contrasena character varying, IN p_id_usuario integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.actualizarcontrasena(IN p_contrasena character varying, IN p_id_usuario integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5121 (class 0 OID 0)
-- Dependencies: 265
-- Name: PROCEDURE actualizarmail(IN p_contrasena character varying, IN p_id_usuario integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.actualizarmail(IN p_contrasena character varying, IN p_id_usuario integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5122 (class 0 OID 0)
-- Dependencies: 249
-- Name: PROCEDURE actualizarperfil(IN p_email character varying, IN p_telefono character varying, IN p_username character varying, IN p_contrasena character varying, IN p_id_usuario integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.actualizarperfil(IN p_email character varying, IN p_telefono character varying, IN p_username character varying, IN p_contrasena character varying, IN p_id_usuario integer) TO "tuSanatorio";


--
-- TOC entry 5123 (class 0 OID 0)
-- Dependencies: 250
-- Name: PROCEDURE actualizarusername(IN p_username character varying, IN p_id_usuario integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.actualizarusername(IN p_username character varying, IN p_id_usuario integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5124 (class 0 OID 0)
-- Dependencies: 273
-- Name: PROCEDURE asignarturno(IN p_id_turno integer, IN p_id_paciente integer, IN p_id_obra_social integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.asignarturno(IN p_id_turno integer, IN p_id_paciente integer, IN p_id_obra_social integer) TO "tuSanatorio";


--
-- TOC entry 5125 (class 0 OID 0)
-- Dependencies: 276
-- Name: PROCEDURE buscarpacienteportexto(IN p_texto character varying, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.buscarpacienteportexto(IN p_texto character varying, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5126 (class 0 OID 0)
-- Dependencies: 281
-- Name: PROCEDURE cancelarturno(IN p_id_paciente integer, IN p_id_turno_asignado integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.cancelarturno(IN p_id_paciente integer, IN p_id_turno_asignado integer) TO "tuSanatorio";


--
-- TOC entry 5127 (class 0 OID 0)
-- Dependencies: 282
-- Name: PROCEDURE checkdobleturno(IN p_id_medico integer, IN p_id_rango integer, IN p_fecha_turno date, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.checkdobleturno(IN p_id_medico integer, IN p_id_rango integer, IN p_fecha_turno date, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5128 (class 0 OID 0)
-- Dependencies: 264
-- Name: PROCEDURE checkturnoasignado(IN p_id_turno_asignado integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.checkturnoasignado(IN p_id_turno_asignado integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5129 (class 0 OID 0)
-- Dependencies: 283
-- Name: PROCEDURE datosdelturno(IN p_id_turno integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.datosdelturno(IN p_id_turno integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5130 (class 0 OID 0)
-- Dependencies: 284
-- Name: PROCEDURE existente(IN p_dni bigint, IN p_email character varying, IN p_username character varying, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.existente(IN p_dni bigint, IN p_email character varying, IN p_username character varying, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5131 (class 0 OID 0)
-- Dependencies: 285
-- Name: PROCEDURE existepaciente(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.existepaciente(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5132 (class 0 OID 0)
-- Dependencies: 286
-- Name: PROCEDURE getespecialidades(INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.getespecialidades(INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5133 (class 0 OID 0)
-- Dependencies: 287
-- Name: PROCEDURE "getespecialidadespormédico"(IN p_id_medico integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public."getespecialidadespormédico"(IN p_id_medico integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5134 (class 0 OID 0)
-- Dependencies: 278
-- Name: PROCEDURE gethistoriaspordnipaciente(IN p_dni bigint, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.gethistoriaspordnipaciente(IN p_dni bigint, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5135 (class 0 OID 0)
-- Dependencies: 271
-- Name: PROCEDURE gethistoriaspormedico(IN p_id_medico integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.gethistoriaspormedico(IN p_id_medico integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5136 (class 0 OID 0)
-- Dependencies: 272
-- Name: PROCEDURE gethistoriasporpaciente(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.gethistoriasporpaciente(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5137 (class 0 OID 0)
-- Dependencies: 274
-- Name: PROCEDURE getobrassociales(INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.getobrassociales(INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5138 (class 0 OID 0)
-- Dependencies: 275
-- Name: PROCEDURE getobrassocialespormedico(IN p_id_medico integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.getobrassocialespormedico(IN p_id_medico integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5139 (class 0 OID 0)
-- Dependencies: 277
-- Name: PROCEDURE getobrassocialesporpaciente(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.getobrassocialesporpaciente(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5140 (class 0 OID 0)
-- Dependencies: 279
-- Name: PROCEDURE getrangos(INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.getrangos(INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5141 (class 0 OID 0)
-- Dependencies: 288
-- Name: PROCEDURE getturnosdisponibles(IN p_id_medico integer, IN p_id_especialidad integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.getturnosdisponibles(IN p_id_medico integer, IN p_id_especialidad integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5142 (class 0 OID 0)
-- Dependencies: 289
-- Name: PROCEDURE getuserbyusername(IN p_username character varying, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.getuserbyusername(IN p_username character varying, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5143 (class 0 OID 0)
-- Dependencies: 290
-- Name: PROCEDURE historialturnos(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.historialturnos(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5144 (class 0 OID 0)
-- Dependencies: 291
-- Name: PROCEDURE historialturnosmedico(IN p_id_medico integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.historialturnosmedico(IN p_id_medico integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5145 (class 0 OID 0)
-- Dependencies: 292
-- Name: PROCEDURE horariospormedico(IN p_id_medico integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.horariospormedico(IN p_id_medico integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5146 (class 0 OID 0)
-- Dependencies: 293
-- Name: PROCEDURE idpaciente_idturnoasignado(IN p_id_paciente integer, IN p_id_turno_asignado integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.idpaciente_idturnoasignado(IN p_id_paciente integer, IN p_id_turno_asignado integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5147 (class 0 OID 0)
-- Dependencies: 294
-- Name: PROCEDURE insertarhistoriacondetalle(IN p_id_paciente integer, IN p_id_medico integer, IN p_historia_clinica text, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.insertarhistoriacondetalle(IN p_id_paciente integer, IN p_id_medico integer, IN p_historia_clinica text, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5148 (class 0 OID 0)
-- Dependencies: 295
-- Name: PROCEDURE insertarusuario(IN p_dni bigint, IN p_nombres character varying, IN p_apellido character varying, IN p_email character varying, IN p_username character varying, IN p_telefono character varying, IN p_contrasena character varying, IN p_id_rol integer, IN p_id_especialidad integer, IN p_id_obra_social integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.insertarusuario(IN p_dni bigint, IN p_nombres character varying, IN p_apellido character varying, IN p_email character varying, IN p_username character varying, IN p_telefono character varying, IN p_contrasena character varying, IN p_id_rol integer, IN p_id_especialidad integer, IN p_id_obra_social integer) TO "tuSanatorio";


--
-- TOC entry 5149 (class 0 OID 0)
-- Dependencies: 280
-- Name: PROCEDURE insertturnosdisponibles(IN p_id_medico integer, IN p_id_rango integer, IN p_fecha_turno date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.insertturnosdisponibles(IN p_id_medico integer, IN p_id_rango integer, IN p_fecha_turno date) TO "tuSanatorio";


--
-- TOC entry 5150 (class 0 OID 0)
-- Dependencies: 251
-- Name: PROCEDURE medicosporespecialidad(IN p_id_especialidad integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.medicosporespecialidad(IN p_id_especialidad integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5151 (class 0 OID 0)
-- Dependencies: 296
-- Name: PROCEDURE misproximosturnos(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.misproximosturnos(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5152 (class 0 OID 0)
-- Dependencies: 297
-- Name: PROCEDURE misturnoshistoricos(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.misturnoshistoricos(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5153 (class 0 OID 0)
-- Dependencies: 298
-- Name: PROCEDURE misturnosproximos(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.misturnosproximos(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5154 (class 0 OID 0)
-- Dependencies: 299
-- Name: PROCEDURE modificarturno(IN p_id_turno_asignado integer, IN p_id_nuevo_turno integer, IN p_id_paciente integer, IN p_id_obra_social integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.modificarturno(IN p_id_turno_asignado integer, IN p_id_nuevo_turno integer, IN p_id_paciente integer, IN p_id_obra_social integer) TO "tuSanatorio";


--
-- TOC entry 5155 (class 0 OID 0)
-- Dependencies: 300
-- Name: PROCEDURE obtenerdatosusuario(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.obtenerdatosusuario(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5156 (class 0 OID 0)
-- Dependencies: 301
-- Name: PROCEDURE pacienteenturnosasignados(IN p_id_paciente integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.pacienteenturnosasignados(IN p_id_paciente integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5157 (class 0 OID 0)
-- Dependencies: 302
-- Name: PROCEDURE sp_getpacientebydni(IN p_dni bigint, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.sp_getpacientebydni(IN p_dni bigint, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5158 (class 0 OID 0)
-- Dependencies: 303
-- Name: PROCEDURE sp_getusuariobyid(IN p_id_usuario integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.sp_getusuariobyid(IN p_id_usuario integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5159 (class 0 OID 0)
-- Dependencies: 266
-- Name: PROCEDURE sp_moverturnoshistoricos(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.sp_moverturnoshistoricos() TO "tuSanatorio";


--
-- TOC entry 5160 (class 0 OID 0)
-- Dependencies: 267
-- Name: PROCEDURE turnoasignadocheck(IN p_id_turno integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.turnoasignadocheck(IN p_id_turno integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5161 (class 0 OID 0)
-- Dependencies: 268
-- Name: PROCEDURE turnodisponiblecheck(IN p_id_turno integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.turnodisponiblecheck(IN p_id_turno integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5162 (class 0 OID 0)
-- Dependencies: 269
-- Name: PROCEDURE vermedicoporidusuario(IN p_id_usuario integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.vermedicoporidusuario(IN p_id_usuario integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5163 (class 0 OID 0)
-- Dependencies: 270
-- Name: PROCEDURE verpacienteporidusuario(IN p_id_usuario integer, INOUT cur refcursor); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.verpacienteporidusuario(IN p_id_usuario integer, INOUT cur refcursor) TO "tuSanatorio";


--
-- TOC entry 5164 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE detalle_historias; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.detalle_historias TO "tuSanatorio";


--
-- TOC entry 5165 (class 0 OID 0)
-- Dependencies: 247
-- Name: SEQUENCE detalle_historias_id_detalle_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.detalle_historias_id_detalle_seq TO "tuSanatorio";


--
-- TOC entry 5166 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE especialidades; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.especialidades TO "tuSanatorio";


--
-- TOC entry 5167 (class 0 OID 0)
-- Dependencies: 219
-- Name: SEQUENCE especialidades_id_especialidad_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.especialidades_id_especialidad_seq TO "tuSanatorio";


--
-- TOC entry 5168 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE histclinicas; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.histclinicas TO "tuSanatorio";


--
-- TOC entry 5169 (class 0 OID 0)
-- Dependencies: 245
-- Name: SEQUENCE histclinicas_id_historia_clinica_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.histclinicas_id_historia_clinica_seq TO "tuSanatorio";


--
-- TOC entry 5170 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE medicos; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.medicos TO "tuSanatorio";


--
-- TOC entry 5171 (class 0 OID 0)
-- Dependencies: 223
-- Name: SEQUENCE medicos_id_medico_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.medicos_id_medico_seq TO "tuSanatorio";


--
-- TOC entry 5172 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE medicos_obrassociales; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.medicos_obrassociales TO "tuSanatorio";


--
-- TOC entry 5173 (class 0 OID 0)
-- Dependencies: 231
-- Name: SEQUENCE medicos_obrassociales_id_medico_obras_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.medicos_obrassociales_id_medico_obras_seq TO "tuSanatorio";


--
-- TOC entry 5174 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE medio_pago; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.medio_pago TO "tuSanatorio";


--
-- TOC entry 5175 (class 0 OID 0)
-- Dependencies: 241
-- Name: SEQUENCE medio_pago_id_medio_pago_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.medio_pago_id_medio_pago_seq TO "tuSanatorio";


--
-- TOC entry 5176 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE obras_sociales; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.obras_sociales TO "tuSanatorio";


--
-- TOC entry 5177 (class 0 OID 0)
-- Dependencies: 227
-- Name: SEQUENCE obras_sociales_id_obra_social_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.obras_sociales_id_obra_social_seq TO "tuSanatorio";


--
-- TOC entry 5178 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE pacientes; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.pacientes TO "tuSanatorio";


--
-- TOC entry 5179 (class 0 OID 0)
-- Dependencies: 225
-- Name: SEQUENCE pacientes_id_paciente_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.pacientes_id_paciente_seq TO "tuSanatorio";


--
-- TOC entry 5180 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE pacientes_obrassociales; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.pacientes_obrassociales TO "tuSanatorio";


--
-- TOC entry 5181 (class 0 OID 0)
-- Dependencies: 229
-- Name: SEQUENCE pacientes_obrassociales_id_paciente_obras_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.pacientes_obrassociales_id_paciente_obras_seq TO "tuSanatorio";


--
-- TOC entry 5182 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE pagos; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.pagos TO "tuSanatorio";


--
-- TOC entry 5183 (class 0 OID 0)
-- Dependencies: 243
-- Name: SEQUENCE pagos_id_pago_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.pagos_id_pago_seq TO "tuSanatorio";


--
-- TOC entry 5184 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE rangos; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.rangos TO "tuSanatorio";


--
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 233
-- Name: SEQUENCE rangos_id_rango_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.rangos_id_rango_seq TO "tuSanatorio";


--
-- TOC entry 5186 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE roles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.roles TO "tuSanatorio";


--
-- TOC entry 5187 (class 0 OID 0)
-- Dependencies: 217
-- Name: SEQUENCE roles_rol_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.roles_rol_id_seq TO "tuSanatorio";


--
-- TOC entry 5188 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE turnos_asignados; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.turnos_asignados TO "tuSanatorio";


--
-- TOC entry 5189 (class 0 OID 0)
-- Dependencies: 237
-- Name: SEQUENCE turnos_asignados_id_turno_asignado_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.turnos_asignados_id_turno_asignado_seq TO "tuSanatorio";


--
-- TOC entry 5190 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE turnos_disponibles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.turnos_disponibles TO "tuSanatorio";


--
-- TOC entry 5191 (class 0 OID 0)
-- Dependencies: 235
-- Name: SEQUENCE turnos_disponibles_id_turno_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.turnos_disponibles_id_turno_seq TO "tuSanatorio";


--
-- TOC entry 5192 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE turnosdescartados; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.turnosdescartados TO "tuSanatorio";


--
-- TOC entry 5193 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE turnoshistoricos; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.turnoshistoricos TO "tuSanatorio";


--
-- TOC entry 5194 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE usuarios; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.usuarios TO "tuSanatorio";


--
-- TOC entry 5195 (class 0 OID 0)
-- Dependencies: 221
-- Name: SEQUENCE usuarios_id_usuario_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.usuarios_id_usuario_seq TO "tuSanatorio";


--
-- TOC entry 2167 (class 826 OID 26475)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO "tuSanatorio";


--
-- TOC entry 2168 (class 826 OID 26476)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO "tuSanatorio";


--
-- TOC entry 2166 (class 826 OID 26474)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO "tuSanatorio";


-- Completed on 2026-09-07 18:34:15

--
-- PostgreSQL database dump complete
--

\unrestrict SdBmRvVmhTGFYY875olsZqTjXPFqZ1YrfNTdY3A5oTYBSR7lBSO0CevGO0v6tj1

