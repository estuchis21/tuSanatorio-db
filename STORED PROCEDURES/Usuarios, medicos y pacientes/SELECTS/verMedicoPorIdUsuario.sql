CREATE OR ALTER PROCEDURE verMedicoPorIdUsuario
@id_usuario int
as
begin
	SELECT id_medico FROM Medicos WHERE id_usuario = @id_usuario
end
go