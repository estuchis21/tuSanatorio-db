CREATE OR ALTER PROCEDURE [dbo].[ModificarTurno]
    @id_turno_asignado INT,
    @id_nuevo_turno INT,
    @id_paciente INT,
    @id_obra_social INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_turno_viejo INT;

    -- 1. Obtener el turno actual del paciente
    SELECT @id_turno_viejo = id_turno
    FROM Turnos_asignados
    WHERE id_turno_asignado = @id_turno_asignado
      AND id_paciente = @id_paciente;

    IF @id_turno_viejo IS NULL
    BEGIN
        PRINT 'No se encontró un turno asignado para el paciente.';
        RETURN;
    END

    -- 2. Liberar el turno actual: volver a turnos disponibles
    INSERT INTO Turnos_disponibles (id_medico, id_rango, fecha_turno)
    SELECT id_medico, id_rango, fecha_turno
    FROM TurnosDescartados
    WHERE id_turno = @id_turno_viejo;

    -- 3. Eliminar turno actual asignado
    DELETE FROM Turnos_asignados
    WHERE id_turno_asignado = @id_turno_asignado
      AND id_paciente = @id_paciente;

    -- 4. Asignar nuevo turno
    INSERT INTO Turnos_asignados (id_turno, id_paciente, id_obra_social, fecha_asignacion)
    VALUES (@id_nuevo_turno, @id_paciente, @id_obra_social, GETDATE());

    -- 5. Quitar nuevo turno de disponibles
    DELETE FROM Turnos_disponibles
    WHERE id_turno = @id_nuevo_turno;

    PRINT 'Turno modificado correctamente.';
END;
