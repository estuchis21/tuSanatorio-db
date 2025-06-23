CREATE OR ALTER PROCEDURE TurnoDisponibleCheck
	@id_turno int
	as
	begin

		SELECT * FROM Turnos_disponibles WHERE id_turno = @id_turno

	end 
	go
