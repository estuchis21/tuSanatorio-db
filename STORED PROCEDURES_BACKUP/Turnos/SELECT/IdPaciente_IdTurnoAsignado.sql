CREATE OR ALTER Procedure IdPaciente_IdTurnoAsignado
	@id_paciente int,
	@id_turno_asignado int

	as
	begin
		SELECT * FROM Turnos_asignados WHERE id_paciente = @id_paciente AND id_turno_asignado = @id_turno_asignado

	end
	go