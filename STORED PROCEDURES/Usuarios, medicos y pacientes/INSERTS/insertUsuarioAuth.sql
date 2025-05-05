/*insert de usuario: pacientes y medicos*/
CREATE PROCEDURE insertarUsuario
    @DNI INT,
    @nombres VARCHAR(100),
    @telefono VARCHAR(50),
    @mail VARCHAR(100),
    @username VARCHAR(50),
    @contrasena VARCHAR(100),
    @rol_id INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Usuarios (DNI, nombres, telefono, mail, username, contrasena, rol_id)
        VALUES (@DNI, @nombres, @telefono, @mail, @username, @contrasena, @rol_id);

        PRINT 'Usuario insertado correctamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al insertar el usuario.';
        PRINT ERROR_MESSAGE();
    END CATCH
END

