USE [tuSanatorio]
GO
/****** Object:  StoredProcedure [dbo].[AsignarTurno]    Script Date: 14/06/2025 0:59:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[AsignarTurno]
  @id_turno INT,
  @id_paciente INT,
  @id_obra_social INT
AS
BEGIN
  SET NOCOUNT ON;

  -- Validación básica de parámetros
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

    -- Eliminar el turno de los disponibles
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
