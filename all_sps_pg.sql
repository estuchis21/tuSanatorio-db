/* ============================================================
   TU SANATORIO
   STORED PROCEDURES - POSTGRESQL
   ============================================================ */


/* ============================================================
   1. actualizarContrasena
   ============================================================ */

CREATE OR REPLACE PROCEDURE actualizarContrasena(
    p_contrasena VARCHAR(250),
    p_id_usuario INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   2. actualizarMail
   ============================================================ */

CREATE OR REPLACE PROCEDURE actualizarMail(
    p_contrasena VARCHAR(250),
    p_id_usuario INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   3. actualizarPerfil
   ============================================================ */

CREATE OR REPLACE PROCEDURE actualizarPerfil(
    p_email VARCHAR(100),
    p_telefono VARCHAR(100),
    p_username VARCHAR(100),
    p_contrasena VARCHAR(200),
    p_id_usuario INT
)
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


/* ============================================================
   4. actualizarUsername
   ============================================================ */

CREATE OR REPLACE PROCEDURE actualizarUsername(
    p_username VARCHAR(50),
    p_id_usuario INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   5. AsignarTurno
   ============================================================ */

CREATE OR REPLACE PROCEDURE AsignarTurno(
    p_id_turno INT,
    p_id_paciente INT,
    p_id_obra_social INT
)
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


/* ============================================================
   6. BuscarPacientePorTexto
   ============================================================ */

CREATE OR REPLACE PROCEDURE BuscarPacientePorTexto(
    p_texto VARCHAR(400),
    INOUT cur REFCURSOR
)
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


/* ============================================================
   7. CancelarTurno
   ============================================================ */

CREATE OR REPLACE PROCEDURE CancelarTurno(
    p_id_paciente INT,
    p_id_turno_asignado INT
)
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


/* ============================================================
   8. checkDobleTurno
   ============================================================ */

CREATE OR REPLACE PROCEDURE checkDobleTurno(
    p_id_medico INT,
    p_id_rango INT,
    p_fecha_turno DATE,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   9. CheckTurnoAsignado
   ============================================================ */

CREATE OR REPLACE PROCEDURE CheckTurnoAsignado(
    p_id_turno_asignado INT,
    INOUT cur REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN

    OPEN cur FOR
        SELECT *
        FROM Turnos_asignados
        WHERE id_turno_asignado = p_id_turno_asignado;

END;
$$;


/* ============================================================
   10. DatosDelTurno
   ============================================================ */

CREATE OR REPLACE PROCEDURE DatosDelTurno(
    p_id_turno INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   11. EXISTENTE
   ============================================================ */

CREATE OR REPLACE PROCEDURE EXISTENTE(
    p_DNI BIGINT,
    p_email VARCHAR(100),
    p_username VARCHAR(100),
    INOUT cur REFCURSOR
)
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


/* ============================================================
   12. ExistePaciente
   ============================================================ */

CREATE OR REPLACE PROCEDURE ExistePaciente(
    p_id_paciente INT,
    INOUT cur REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN

    OPEN cur FOR
        SELECT COUNT(*) AS count
        FROM Pacientes
        WHERE id_paciente = p_id_paciente;

END;
$$;


/* ============================================================
   13. getEspecialidades
   ============================================================ */

CREATE OR REPLACE PROCEDURE getEspecialidades(
    INOUT cur REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN

    OPEN cur FOR
        SELECT *
        FROM Especialidades
        ORDER BY nombre;

END;
$$;


/* ============================================================
   14. getEspecialidadesPorMédico
   ============================================================ */

CREATE OR REPLACE PROCEDURE getEspecialidadesPorMédico(
    p_id_medico INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   15. getHistoriasPorDniPaciente
   ============================================================ */

CREATE OR REPLACE PROCEDURE getHistoriasPorDniPaciente(
    p_dni BIGINT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   16. getHistoriasPorMedico
   ============================================================ */

CREATE OR REPLACE PROCEDURE getHistoriasPorMedico(
    p_id_medico INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   17. getHistoriasPorPaciente
   ============================================================ */

CREATE OR REPLACE PROCEDURE getHistoriasPorPaciente(
    p_id_paciente INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   18. GetObrasSociales
   ============================================================ */

CREATE OR REPLACE PROCEDURE GetObrasSociales(
    INOUT cur REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN

    OPEN cur FOR
        SELECT *
        FROM Obras_sociales
        ORDER BY obra_social;

END;
$$;


/* ============================================================
   19. GetObrasSocialesPorMedico
   ============================================================ */

CREATE OR REPLACE PROCEDURE GetObrasSocialesPorMedico(
    p_id_medico INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   20. GetObrasSocialesPorPaciente
   ============================================================ */

CREATE OR REPLACE PROCEDURE GetObrasSocialesPorPaciente(
    p_id_paciente INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   21. GetRangos
   ============================================================ */

CREATE OR REPLACE PROCEDURE GetRangos(
    INOUT cur REFCURSOR
)
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


/* ============================================================
   22. GetTurnosDisponibles
   ============================================================ */

CREATE OR REPLACE PROCEDURE GetTurnosDisponibles(
    p_id_medico INT,
    p_id_especialidad INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   23. getUserByUsername
   ============================================================ */

CREATE OR REPLACE PROCEDURE getUserByUsername(
    p_username VARCHAR(100),
    INOUT cur REFCURSOR
)
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


/* ============================================================
   24. HistorialTurnos
   ============================================================ */

CREATE OR REPLACE PROCEDURE HistorialTurnos(
    p_id_paciente INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   25. HistorialTurnosMedico
   ============================================================ */

CREATE OR REPLACE PROCEDURE HistorialTurnosMedico(
    p_id_medico INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   26. horariosPorMedico
   ============================================================ */

CREATE OR REPLACE PROCEDURE horariosPorMedico(
    p_id_medico INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   27. IdPaciente_IdTurnoAsignado
   ============================================================ */

CREATE OR REPLACE PROCEDURE IdPaciente_IdTurnoAsignado(
    p_id_paciente INT,
    p_id_turno_asignado INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   28. insertarHistoriaConDetalle
   ============================================================ */

CREATE OR REPLACE PROCEDURE insertarHistoriaConDetalle(
    p_id_paciente INT,
    p_id_medico INT,
    p_historia_clinica TEXT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   29. insertarUsuario
   ============================================================ */

CREATE OR REPLACE PROCEDURE insertarUsuario(
    p_DNI BIGINT,
    p_nombres VARCHAR(100),
    p_apellido VARCHAR(50),
    p_email VARCHAR(100),
    p_username VARCHAR(50),
    p_telefono VARCHAR(100),
    p_contrasena VARCHAR(200),
    p_id_rol INT,
    p_id_especialidad INT,
    p_id_obra_social INT
)
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


/* ============================================================
   30. InsertTurnosDisponibles
   ============================================================ */

CREATE OR REPLACE PROCEDURE InsertTurnosDisponibles(
    p_id_medico INT,
    p_id_rango INT,
    p_fecha_turno DATE
)
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


/* ============================================================
   31. MedicosPorEspecialidad
   ============================================================ */

CREATE OR REPLACE PROCEDURE MedicosPorEspecialidad(
    p_id_especialidad INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   32. MisProximosTurnos
   ============================================================ */

CREATE OR REPLACE PROCEDURE MisProximosTurnos(
    p_id_paciente INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   33. MisTurnosHistoricos
   ============================================================ */

CREATE OR REPLACE PROCEDURE MisTurnosHistoricos(
    p_id_paciente INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   34. MisTurnosProximos
   ============================================================ */

CREATE OR REPLACE PROCEDURE MisTurnosProximos(
    p_id_paciente INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   35. modificarTurno
   ============================================================ */

CREATE OR REPLACE PROCEDURE modificarTurno(
    p_id_turno_asignado INT,
    p_id_nuevo_turno INT,
    p_id_paciente INT,
    p_id_obra_social INT
)
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


/* ============================================================
   36. obtenerDatosUsuario
   ============================================================ */

CREATE OR REPLACE PROCEDURE obtenerDatosUsuario(
    p_id_paciente INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   37. PacienteEnTurnosAsignados
   ============================================================ */

CREATE OR REPLACE PROCEDURE PacienteEnTurnosAsignados(
    p_id_paciente INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   38. sp_GetPacienteByDNI
   ============================================================ */

CREATE OR REPLACE PROCEDURE sp_GetPacienteByDNI(
    p_dni BIGINT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   39. sp_GetUsuarioById
   ============================================================ */

CREATE OR REPLACE PROCEDURE sp_GetUsuarioById(
    p_id_usuario INT,
    INOUT cur REFCURSOR
)
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


/* ============================================================
   40. sp_MoverTurnosHistoricos
   ============================================================ */

CREATE OR REPLACE PROCEDURE sp_MoverTurnosHistoricos()
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


/* ============================================================
   41. TurnoAsignadoCheck
   ============================================================ */

CREATE OR REPLACE PROCEDURE TurnoAsignadoCheck(
    p_id_turno INT,
    INOUT cur REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN

    OPEN cur FOR
        SELECT 1
        FROM Turnos_asignados
        WHERE id_turno = p_id_turno;

END;
$$;


/* ============================================================
   42. TurnoDisponibleCheck
   ============================================================ */

CREATE OR REPLACE PROCEDURE TurnoDisponibleCheck(
    p_id_turno INT,
    INOUT cur REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN

    OPEN cur FOR
        SELECT *
        FROM Turnos_disponibles
        WHERE id_turno = p_id_turno;

END;
$$;


/* ============================================================
   43. verMedicoPorIdUsuario
   ============================================================ */

CREATE OR REPLACE PROCEDURE verMedicoPorIdUsuario(
    p_id_usuario INT,
    INOUT cur REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN

    OPEN cur FOR
        SELECT id_medico
        FROM Medicos
        WHERE id_usuario = p_id_usuario;

END;
$$;


/* ============================================================
   44. verPacientePorIdUsuario
   ============================================================ */

CREATE OR REPLACE PROCEDURE verPacientePorIdUsuario(
    p_id_usuario INT,
    INOUT cur REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN

    OPEN cur FOR
        SELECT id_paciente
        FROM Pacientes
        WHERE id_usuario = p_id_usuario;

END;
$$;