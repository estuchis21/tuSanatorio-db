CREATE OR ALTER PROCEDURE sp_GetUsuarioById
  @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id_usuario, nombres, apellido, email, username, telefono, id_rol
    FROM dbo.Usuarios
    WHERE id_usuario = @id_usuario;
END
