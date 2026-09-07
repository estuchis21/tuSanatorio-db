CREATE PROCEDURE insertRol
AS
BEGIN
    BEGIN TRY
        INSERT INTO Roles (rol)
        VALUES ('Paciente'), ('MÃ©dico');

        PRINT 'Roles creados correctamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al agregar roles:';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO



