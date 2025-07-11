USE [tuSanatorio]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[insertarUsuario]
    @DNI INT,
    @nombres VARCHAR(100),
    @apellido VARCHAR(50),
    @email VARCHAR(100),
    @username VARCHAR(50),
    @telefono VARCHAR(100),
    @contrasena VARCHAR(200),
    @id_rol INT,
    @id_especialidad INT = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insertar en Usuarios
        INSERT INTO Usuarios (DNI, nombres, apellido, email, username, telefono, contrasena, id_rol)
        VALUES (@DNI, @nombres, @apellido, @email, @username, @telefono, @contrasena, @id_rol);

        DECLARE @id_usuario INT = SCOPE_IDENTITY();

        -- Insertar en Pacientes si el rol es 1
        IF @id_rol = 1
        BEGIN
            INSERT INTO Pacientes (id_usuario) VALUES (@id_usuario);
        END

        -- Insertar en Médicos si el rol es 2 y se especificó una especialidad
        IF @id_rol = 2
        BEGIN
            IF @id_especialidad IS NOT NULL
            BEGIN
                INSERT INTO Medicos (id_usuario, id_especialidad)
                VALUES (@id_usuario, @id_especialidad);
            END
            ELSE
            BEGIN
                THROW 51000, 'id_especialidad no puede ser NULL para médicos.', 1;
            END
        END

        COMMIT;
        PRINT 'Transacción completada correctamente. Usuario, y según el rol, paciente o médico insertado.';

    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Se produjo un error. La transacción fue cancelada.';
        PRINT ERROR_MESSAGE();
    END CATCH
END
