create PROCEDURE [dbo].[getUserByUsername]
  @username VARCHAR(100)
AS
BEGIN
  SELECT * FROM Usuarios
  WHERE username = @username
END;
