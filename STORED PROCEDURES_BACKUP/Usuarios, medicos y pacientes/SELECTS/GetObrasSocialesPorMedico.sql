USE [tuSanatorio]
GO
/****** Object:  StoredProcedure [dbo].[GetObrasSocialesPorMedico]    Script Date: 11/09/2025 20:37:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GetObrasSocialesPorMedico]
    @id_medico INT
AS
BEGIN
    -- Trae las obras sociales asignadas al médico
    SELECT os.id_obra_social, os.obra_social
    FROM Obras_sociales os
    INNER JOIN Medicos_ObrasSociales mo
        ON os.id_obra_social = mo.id_obra_social
    WHERE mo.id_medico = @id_medico
END



