CREATE PROCEDURE CancelarTurno
    @id_paciente INT,
    @id_turno INT
AS
BEGIN

    IF EXISTS (
        SELECT 1 
        FROM turnos_asignados 
        WHERE id_turno = @id_turno AND id_paciente = @id_paciente
    )
    BEGIN
        DELETE FROM turnos_asignados
        WHERE id_turno = @id_turno AND id_paciente = @id_paciente;

        PRINT 'El turno ha sido cancelado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'No se encontró un turno asignado para cancelar.';
    END
END;
GO
