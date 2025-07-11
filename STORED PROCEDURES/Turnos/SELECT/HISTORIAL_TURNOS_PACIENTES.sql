USE [tuSanatorio]
GO
/****** Object:  StoredProcedure [dbo].[HistorialTurnos]    Script Date: 09/06/2025 21:40:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[HistorialTurnos]
	@id_paciente INT
AS
BEGIN
	SELECT td.fecha_turno AS 'Fecha del turno', um.nombres AS'Medico', e.nombre as 'Especialidad'
	FROM Usuarios u, Pacientes p, turnos_asignados ta, turnos_disponibles td, Medicos m, especialidades e, Usuarios um
	WHERE u.id_usuario=p.id_usuario
	AND p.id_paciente=ta.id_paciente
	AND ta.id_turno=td.id_turno
	AND td.id_medico=m.id_medico
	AND m.id_usuario=um.id_usuario
	AND m.id_especialidad=e.id_especialidad
	AND p.id_paciente = @id_paciente
	AND td.fecha_turno < GETDATE();

END;
