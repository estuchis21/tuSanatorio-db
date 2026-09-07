ALTER PROCEDURE [dbo].[actualizarPerfil]
  @email varchar(100) = null,
  @telefono varchar(100) = null,
  @username varchar(100) = null,
  @contrasena varchar(200) = null,
  @id_usuario int
AS
BEGIN
    UPDATE Usuarios
    SET 
        email = ISNULL(@email, email),
        telefono = ISNULL(@telefono, telefono),
        username = ISNULL(@username, username),
        contrasena = ISNULL(@contrasena, contrasena)
    WHERE id_usuario = @id_usuario;
END
