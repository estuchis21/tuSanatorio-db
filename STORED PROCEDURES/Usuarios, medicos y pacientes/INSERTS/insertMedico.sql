CREATE PROCEDURE insertMedico
    @id_usuario INT,
    @id_especialidad INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Medicos (id_usuario, id_especialidad)
        VALUES (@id_usuario, @id_especialidad);

        PRINT 'Datos de mÃ©dico agregado correctamente';
    END TRY
    BEGIN CATCH
        PRINT 'Error al ingresar mÃ©dico';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

