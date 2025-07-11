USE [tuSanatorio]
GO
/****** Object:  StoredProcedure [dbo].[CancelarTurno]    Script Date: 09/06/2025 21:04:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[CancelarTurno]
    @id_paciente INT,
    @id_turno_asignado INT
AS
BEGIN

    IF EXISTS (
        SELECT 1 
        FROM turnos_asignados 
        WHERE id_turno_asignado = @id_turno_asignado AND id_paciente = @id_paciente
    )
    BEGIN
        DELETE FROM turnos_asignados
        WHERE id_turno_asignado = @id_turno_asignado AND id_paciente = @id_paciente;

        PRINT 'El turno ha sido cancelado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'No se encontró un turno asignado para cancelar.';
    END
END;
