USE [tuSanatorio]
GO
/****** Object:  StoredProcedure [dbo].[MisTurnosHistoricos]    Script Date: 27/10/2025 15:37:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[MisTurnosHistoricos]
    @id_paciente INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        th.id_turno AS id_turno_historico,
        u.nombres AS paciente_nombre,
        u.apellido AS paciente_apellido,
        e.nombre AS especialidad,
        td.fecha_turno AS fecha_turno,
        ra.hora_inicio AS hora_inicio,
        ra.hora_fin AS hora_fin,
        o.obra_social AS obra_social,
        um.nombres AS medico_nombre,
        um.apellido AS medico_apellido
    FROM TurnosHistoricos th
    JOIN TurnosDescartados td ON th.id_turno = td.id_turno
    JOIN Rangos ra ON td.id_rango = ra.id_rango
    JOIN Pacientes p ON th.id_paciente = p.id_paciente
    JOIN Usuarios u ON p.id_usuario = u.id_usuario
    JOIN Medicos me ON td.id_medico = me.id_medico
    JOIN Usuarios um ON me.id_usuario = um.id_usuario
    JOIN Especialidades e ON me.id_especialidad = e.id_especialidad
    JOIN Obras_sociales o ON th.id_obra_social = o.id_obra_social
    WHERE p.id_paciente = @id_paciente
      AND td.fecha_turno < GETDATE()
    ORDER BY td.fecha_turno DESC;

END;
