ALTER PROCEDURE [dbo].[actualizarMail]
    @email varchar(100),
    @id_usuario int
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Usuarios
    SET email = @email
    WHERE id_usuario = @id_usuario;

    SELECT * FROM Usuarios WHERE id_usuario = @id_usuario;
END
