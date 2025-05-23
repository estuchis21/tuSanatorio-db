USE [tuSanatorio]
GO
/****** Object:  StoredProcedure [dbo].[insertarUsuario]    Script Date: 23/05/2025 06:27:53 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*insert de usuario: pacientes y medicos*/
ALTER PROCEDURE [dbo].[insertarUsuario]
    @nombres VARCHAR(100),
	@apellido VARCHAR(100),
	@dni int,
	@mail varchar(100),
    @telefono VARCHAR(50),
	@username varchar(100),
	@contrasena varchar(100),
    @id_rol INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Usuarios (nombres, apellido, dni, mail, telefono, username, contrasena, rol_id)
        VALUES (@nombres, @apellido, @dni, @mail, @telefono, @username, @contrasena, @id_rol );

        PRINT 'Usuario insertado correctamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar el usuario.';
        PRINT ERROR_MESSAGE();
    END CATCH
END

