USE [tuSanatorio]
GO
/****** Object:  Trigger [dbo].[trg_MoverTurnosHistoricos]    Script Date: 02/11/2025 15:15:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   TRIGGER [dbo].[trg_MoverTurnosHistoricos]
ON [dbo].[Turnos_asignados]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Llamar al SP para mover turnos vencidos de los registros afectados
    EXEC dbo.sp_MoverTurnosHistoricos;
END
GO