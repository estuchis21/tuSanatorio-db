create or alter procedure TurnoAsignadoCheck
	@id_turno int

	as
	begin
		SELECT * FROM Turnos_asignados WHERE id_turno = @id_turno
	end
	go
