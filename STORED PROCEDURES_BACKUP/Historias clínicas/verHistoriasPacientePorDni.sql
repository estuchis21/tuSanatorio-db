USE [tuSanatorio]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[getHistoriasPorDniPaciente]
    @dni NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        u.nombres,
        u.apellido,
        u.dni,
        h.id_historia_clinica,
        h.fecha_registro,
        dh.historia_clinica,
        me.id_medico,
        mu.nombres AS nombre_medico,
        mu.apellido AS apellido_medico
    FROM HistClinicas h
    INNER JOIN Detalle_Historias dh ON h.id_historia_clinica = dh.id_historia_clinica
    INNER JOIN Pacientes p ON h.id_paciente = p.id_paciente
    INNER JOIN Usuarios u ON p.id_usuario = u.id_usuario
    INNER JOIN Medicos me ON dh.id_medico = me.id_medico
    INNER JOIN Usuarios mu ON me.id_usuario = mu.id_usuario
    WHERE u.dni = @dni
    ORDER BY h.fecha_registro DESC;
END
