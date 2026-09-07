USE [tuSanatorio]
GO

ALTER PROCEDURE [dbo].[MisProximosTurnos]
    @id_paciente INT
AS
BEGIN
    SET NOCOUNT ON;

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
        -- Lista de nombres de obras sociales
        ISNULL(STRING_AGG(o.obra_social, ', '), '') AS obras_sociales,
        -- Lista de IDs de obras sociales
        ISNULL(STRING_AGG(CAST(o.id_obra_social AS VARCHAR), ','), '') AS ids_obras_sociales
    FROM Turnos_asignados ta
    LEFT JOIN TurnosDescartados td
        ON td.id_turno = ta.id_turno
    LEFT JOIN Rangos ra
        ON ra.id_rango = td.id_rango
    LEFT JOIN Medicos me
        ON me.id_medico = td.id_medico
    LEFT JOIN Usuarios u
        ON u.id_usuario = me.id_usuario
    LEFT JOIN Especialidades e
        ON e.id_especialidad = me.id_especialidad
    LEFT JOIN Medicos_ObrasSociales mo
        ON mo.id_medico = me.id_medico
    LEFT JOIN Obras_sociales o
        ON o.id_obra_social = mo.id_obra_social
    WHERE ta.id_paciente = @id_paciente
      AND (
          td.fecha_turno > CAST(GETDATE() AS DATE)
          OR (td.fecha_turno = CAST(GETDATE() AS DATE) AND ra.hora_inicio > CAST(GETDATE() AS TIME))
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
    ORDER BY td.fecha_turno ASC, ra.hora_inicio ASC;
END;
