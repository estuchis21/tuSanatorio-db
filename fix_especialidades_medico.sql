CREATE OR REPLACE PROCEDURE getEspecialidadesPorMedico(
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
