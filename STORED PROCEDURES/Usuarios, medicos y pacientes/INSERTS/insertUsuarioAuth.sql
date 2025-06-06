USE [tuSanatorio]
GO
/****** Object:  StoredProcedure [dbo].[insertarUsuario]    Script Date: 29/05/2025 22:37:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*insert de usuario: pacientes y medicos*/
ALTER PROCEDURE [dbo].[insertarUsuario]
    @DNI INT,
    @nombres VARCHAR(100),
    @apellido VARCHAR(50),
    @email VARCHAR(100),
    @username VARCHAR(50),
    @telefono VARCHAR(100),
    @contrasena varchar(50),
    @id_rol INT,
    @id_especialidad int = null
AS
BEGIN
    BEGIN TRY
        INSERT INTO Usuarios (DNI, nombres, apellido, email, username, telefono, contrasena, id_rol)
        VALUES (@DNI, @nombres, @apellido, @email, @username, @telefono, @contrasena, @id_rol);
        PRINT 'Usuario insertado correctamente.';
        
        DECLARE @id_usuario INT = SCOPE_IDENTITY();

        -- Insertar en Pacientes si corresponde
        IF @id_rol = 1
        BEGIN
            INSERT INTO Pacientes (id_usuario) VALUES (@id_usuario);
        END
        PRINT 'Paciente insertado correctamente';

        -- Insertar en Médicos si corresponde
        IF @id_rol = 2
        BEGIN
            IF @id_especialidad IS NOT NULL
            BEGIN
                INSERT INTO Medicos (id_usuario, id_especialidad)
                VALUES (@id_usuario, @id_especialidad);
            END
        END

        PRINT 'Médico insertado correctamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar el usuario.';
        PRINT ERROR_MESSAGE();
    END CATCH
END


