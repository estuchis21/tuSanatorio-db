CREATE OR ALTER PROCEDURE ExistePaciente
@id_paciente int
as
begin
	SELECT COUNT(*) AS count FROM Pacientes WHERE id_paciente = @id_paciente
end
go