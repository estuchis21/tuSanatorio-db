CREATE OR ALTER PROCEDURE InsertTurnosDisponibles
	@id_medico int,
	@id_rango int, 
	@fecha_turno datetime

	as
	begin
	
		INSERT INTO Turnos_disponibles (id_medico, id_rango, fecha_turno) 
		values (@id_medico, @id_rango, @fecha_turno)

	end
	go