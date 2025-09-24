CREATE OR ALTER PROCEDURE [dbo].[MisProximosTurnos]
    @id_paciente INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ta.id_turno_asignado,
        td.id_turno AS id_turno_descartado,
        u.nombres,
        u.apellido,
        e.nombre AS especialidad,
        td.fecha_turno,
        ra.hora_inicio,
        ra.hora_fin,
        STRING_AGG(o.obra_social, ', ') AS obras_sociales
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
    INNER JOIN Medicos_ObrasSociales mo
        ON mo.id_medico = me.id_medico
    INNER JOIN Obras_sociales o
        ON o.id_obra_social = mo.id_obra_social
    WHERE ta.id_paciente = @id_paciente
      AND (
          td.fecha_turno > CAST(GETDATE() AS DATE)  -- días futuros
          OR (td.fecha_turno = CAST(GETDATE() AS DATE) AND ra.hora_fin > CAST(GETDATE() AS TIME))  -- hoy, solo horas futuras
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
    ORDER BY td.fecha_turno ASC, ra.hora_inicio ASC;
END;
