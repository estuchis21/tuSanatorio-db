ALTER PROCEDURE [dbo].[actualizarUsername]
    @username varchar(50),
    @id_usuario int
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Usuarios
    SET username = @username
    WHERE id_usuario = @id_usuario;

    -- Devuelve el usuario actualizado
    SELECT * FROM Usuarios WHERE id_usuario = @id_usuario;
END
