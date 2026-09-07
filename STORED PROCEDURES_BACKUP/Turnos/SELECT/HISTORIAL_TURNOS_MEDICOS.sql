USE [tuSanatorio]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[HistorialTurnosMedico]
    @id_medico INT  
AS
BEGIN
    SELECT 
        th.id_turno AS id_turno_historico,
        u.nombres + ' ' + u.apellido AS Paciente,
        um.nombres + ' ' + um.apellido AS Medico,
        e.nombre AS Especialidad,
        ra.hora_inicio,
        ra.hora_fin,
        td.fecha_turno
    FROM TurnosHistoricos th,
         Pacientes p,
         Usuarios u,
         Medicos me,
         Usuarios um,
         Especialidades e,
         Rangos ra,
         TurnosDescartados td,
         Obras_sociales o
    WHERE th.id_paciente = p.id_paciente
      and th.id_obra_social = o.id_obra_social
      and th.id_turno = td.id_turno
      AND p.id_usuario = u.id_usuario
      AND td.id_medico = me.id_medico
      AND me.id_usuario = um.id_usuario
      AND me.id_especialidad = e.id_especialidad
      AND td.id_rango = ra.id_rango
      and td.fecha_turno < GETDATE()
      AND td.id_medico = @id_medico
    ORDER BY td.fecha_turno DESC;

END;
