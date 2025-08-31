CREATE TRIGGER trg_TurnosEliminados
ON Turnos_disponibles
AFTER DELETE
AS
BEGIN
    INSERT INTO TurnosDescartados (id_turno, id_medico, id_rango, fecha_turno)
    SELECT id_turno, id_medico, id_rango, fecha_turno
    FROM deleted;
END;
GO