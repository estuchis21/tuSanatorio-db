ALTER PROCEDURE [dbo].[AsignarTurno]
  @id_turno INT,
  @id_paciente INT,
  @id_obra_social INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @id_turno IS NULL OR @id_paciente IS NULL OR @id_obra_social IS NULL
    BEGIN
        RAISERROR('Los parámetros no pueden ser NULL.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el turno está disponible
        IF NOT EXISTS (SELECT 1 FROM Turnos_disponibles WHERE id_turno = @id_turno)
        BEGIN
            RAISERROR('El turno no está disponible para asignar.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insertar el turno asignado
        INSERT INTO Turnos_asignados (id_turno, id_paciente, id_obra_social, fecha_asignacion)
        VALUES (@id_turno, @id_paciente, @id_obra_social, GETDATE());

        -- Eliminar el turno de los disponibles (esto activará el trigger y lo pasará a TurnosDescartados)
        DELETE FROM Turnos_disponibles
        WHERE id_turno = @id_turno;

        COMMIT TRANSACTION;
        PRINT 'Turno asignado correctamente.';

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        PRINT 'Error para asignar turno:';
        PRINT ERROR_MESSAGE();
    END CATCH
END
