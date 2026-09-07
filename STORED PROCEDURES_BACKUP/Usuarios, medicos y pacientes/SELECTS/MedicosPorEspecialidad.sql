USE [tuSanatorio]
GO
/****** Object:  StoredProcedure [dbo].[MedicosPorEspecialidad]    Script Date: 28/08/2025 16:43:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[MedicosPorEspecialidad]
@id_especialidad int

as
begin
	SELECT m.id_medico, u.nombres, u.apellido
        FROM Medicos m
        JOIN Usuarios u ON m.id_usuario = u.id_usuario
        WHERE m.id_especialidad = @id_especialidad

end
