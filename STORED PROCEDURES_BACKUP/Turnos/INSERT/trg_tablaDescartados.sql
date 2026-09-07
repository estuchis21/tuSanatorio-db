-- TUSE [tuSanatorio];
GO

-- Trigger para mover turnos eliminados a TurnosDescartados
IF OBJECT_ID('dbo.trg_MoverATurnosDescartados', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_MoverATurnosDescartados;
GO

CREATE TRIGGER trg_MoverATurnosDescartados
ON Turnos_disponibles
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Insertar en TurnosDescartados todos los turnos eliminados
    INSERT INTO TurnosDescartados (id_turno, id_medico, id_rango, fecha_turno)
    SELECT d.id_turno, d.id_medico, d.id_rango, d.fecha_turno
    FROM deleted d;

END;
GO
