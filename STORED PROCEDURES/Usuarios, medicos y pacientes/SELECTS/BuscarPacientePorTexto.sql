CREATE OR ALTER PROCEDURE BuscarPacientePorTexto
@texto VARCHAR(400)

AS
BEGIN
	SELECT p.id_paciente, u.id_usuario, u.nombres, u.apellido, u.username AS dni
        FROM Pacientes p
        JOIN Usuarios u ON p.id_usuario = u.id_usuario
        WHERE u.nombres LIKE '%' + @texto + '%' 
           OR u.apellido LIKE '%' + @texto + '%'
           OR u.username LIKE '%' + @texto + '%'

END
GO