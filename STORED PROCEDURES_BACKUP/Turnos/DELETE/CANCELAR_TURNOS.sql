USE [tuSanatorio]
GO
ALTER PROCEDURE [dbo].[CancelarTurno]
    @id_paciente INT,
    @id_turno_asignado INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @id_turno INT,
        @id_medico INT,
        @id_rango INT,
        @fecha_turno DATE;

    IF EXISTS (
        SELECT 1 
        FROM Turnos_asignados 
        WHERE id_turno_asignado = @id_turno_asignado
          AND id_paciente = @id_paciente
    )
    BEGIN
        -- Obtenemos el id_turno
        SELECT @id_turno = id_turno
        FROM Turnos_asignados
        WHERE id_turno_asignado = @id_turno_asignado
          AND id_paciente = @id_paciente;

        -- Recuperamos datos del turno desde turnos descartados
        SELECT 
            @id_medico = id_medico,
            @id_rango = id_rango,
            @fecha_turno = fecha_turno
        FROM TurnosDescartados
        WHERE id_turno = @id_turno;

        -- Eliminamos el turno asignado
        DELETE FROM Turnos_asignados
        WHERE id_turno_asignado = @id_turno_asignado
          AND id_paciente = @id_paciente;

        -- Insertamos el turno de nuevo en la lista de disponibles (sin id_turno)
        INSERT INTO Turnos_disponibles (id_medico, id_rango, fecha_turno)
        VALUES (@id_medico, @id_rango, @fecha_turno);

        PRINT '✅ El turno ha sido cancelado y vuelto a estar disponible.';
    END
    ELSE
    BEGIN
        PRINT '⚠️ No se encontró un turno asignado para cancelar.';
    END
END;
GO
