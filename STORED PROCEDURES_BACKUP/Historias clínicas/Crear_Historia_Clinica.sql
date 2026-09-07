CREATE OR ALTER PROCEDURE [dbo].[insertarHistoriaConDetalle]
    @id_paciente INT,
    @id_medico INT,
    @historia_clinica NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validaciones básicas
        IF @id_paciente IS NULL
            THROW 51000, 'Debe especificar id_paciente', 1;

        IF @id_medico IS NULL
            THROW 51000, 'Debe especificar id_medico', 1;

        IF @historia_clinica IS NULL OR LTRIM(RTRIM(@historia_clinica)) = ''
            THROW 51000, 'El contenido de la historia clínica no puede estar vacío', 1;

        -- Insertar historia clínica
        INSERT INTO HistClinicas (id_paciente, fecha_registro)
        VALUES (@id_paciente, GETDATE());

        DECLARE @id_historia_clinica INT = SCOPE_IDENTITY();

        -- Insertar detalle de la historia clínica
        INSERT INTO Detalle_Historias(id_historia_clinica, id_medico, historia_clinica, fecha_detalle)
        VALUES (@id_historia_clinica, @id_medico, @historia_clinica, GETDATE());

        COMMIT TRANSACTION;

        -- DEVOLVER EL ID DE LA HISTORIA
        SELECT @id_historia_clinica AS id_historia_clinica;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW; -- Para que Node.js capture el error
    END CATCH
END
