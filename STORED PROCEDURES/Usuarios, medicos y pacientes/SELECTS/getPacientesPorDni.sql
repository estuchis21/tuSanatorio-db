USE [tuSanatorio]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE sp_GetPacienteByDNI
    @dni NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT p.id_paciente, u.nombres, u.apellido
    FROM Pacientes p
    JOIN Usuarios u ON p.id_usuario = u.id_usuario
    WHERE u.username = @dni;
END
