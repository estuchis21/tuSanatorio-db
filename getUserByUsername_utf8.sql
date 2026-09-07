USE [tuSanatorio]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[getUserByUsername]
  @username VARCHAR(100)
AS
BEGIN
  SELECT 
    u.id_usuario,
    u.username,
    u.contrasena,
    u.id_rol,
    p.id_paciente
  FROM Usuarios u
  LEFT JOIN Pacientes p ON u.id_usuario = p.id_usuario
  WHERE u.username = @username
END;

