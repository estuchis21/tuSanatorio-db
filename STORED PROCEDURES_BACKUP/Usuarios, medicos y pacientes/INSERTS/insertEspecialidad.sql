CREATE PROCEDURE insertEspecialidad
    @especialidad VARCHAR(100)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Especialidades (nombre)
        VALUES (@especialidad)

        PRINT 'Se agregó la especialidad correctamente';

    END TRY
    BEGIN CATCH
        PRINT 'Error al agregar la especialidad';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO
				  