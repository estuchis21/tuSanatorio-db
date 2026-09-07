CREATE OR ALTER PROCEDURE PacienteEnTurnosAsignados
	@id_paciente int
	
	as 
	begin
		SELECT * FROM Turnos_asignados WHERE id_paciente = @id_paciente
	end
	go
	