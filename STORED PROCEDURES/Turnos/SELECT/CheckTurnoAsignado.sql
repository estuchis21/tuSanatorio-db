CREATE OR ALTER PROCEDURE CheckTurnoAsignado
	@id_turno_asignado int
	as 
	begin
		SELECT * FROM Turnos_asignados WHERE id_turno_asignado = @id_turno_asignado

	end
	go