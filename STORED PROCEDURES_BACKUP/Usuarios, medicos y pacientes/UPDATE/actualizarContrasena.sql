USE [tuSanatorio]
GO
/****** Object:  StoredProcedure [dbo].[actualizarContrasena]    Script Date: 22/09/2025 21:49:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[actualizarContrasena]
    @contrasena varchar(250),
    @id_usuario int
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Usuarios
    SET contrasena = @contrasena
    WHERE id_usuario = @id_usuario;

    SELECT * FROM Usuarios WHERE id_usuario = @id_usuario;
END
