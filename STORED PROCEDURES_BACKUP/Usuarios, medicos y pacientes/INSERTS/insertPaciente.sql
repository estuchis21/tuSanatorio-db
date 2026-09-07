CREATE PROCEDURE insertPaciente
    @id_usuario INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Pacientes (id_usuario)
        VALUES (@id_usuario);

        PRINT 'Se agregó al paciente correctamente';
    END TRY
    BEGIN CATCH
        PRINT 'Error al ingresar paciente';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO
