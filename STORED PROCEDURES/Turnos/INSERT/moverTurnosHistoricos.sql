USE [tuSanatorio]
GO

IF OBJECT_ID('dbo.sp_MoverTurnosHistoricos', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_MoverTurnosHistoricos;
GO

CREATE PROCEDURE dbo.sp_MoverTurnosHistoricos
AS
BEGIN
    SET NOCOUNT ON;

    -- Insertar turnos vencidos en TurnosHistoricos
    INSERT INTO TurnosHistoricos (
        id_turno_asignado,
        id_turno,
        id_paciente,
        id_obra_social,
        fecha_asignacion
    )
    SELECT
        ta.id_turno_asignado,
        ta.id_turno,
        ta.id_paciente,
        ta.id_obra_social,
        td.fecha_turno
    FROM Turnos_asignados ta
    INNER JOIN TurnosDescartados td ON td.id_turno = ta.id_turno
    WHERE td.fecha_turno <= GETDATE()
      AND NOT EXISTS (
          SELECT 1
          FROM TurnosHistoricos th
          WHERE th.id_turno_asignado = ta.id_turno_asignado
      );

    -- Eliminar turnos ya movidos
    DELETE ta
    FROM Turnos_asignados ta
    INNER JOIN TurnosDescartados td ON td.id_turno = ta.id_turno
    WHERE td.fecha_turno <= GETDATE();
END
GO
