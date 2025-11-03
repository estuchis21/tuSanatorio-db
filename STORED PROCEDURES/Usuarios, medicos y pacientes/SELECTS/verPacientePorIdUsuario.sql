CREATE OR ALTER PROCEDURE verPacientePorIdUsuario
@id_usuario int
as
begin

	SELECT id_paciente FROM Pacientes WHERE id_usuario = @id_usuario
end
go