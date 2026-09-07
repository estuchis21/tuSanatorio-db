USE [tuSanatorio]
GO
/****** Object:  StoredProcedure [dbo].[horariosPorMedico]    Script Date: 28/08/2025 18:32:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[horariosPorMedico]
@id_medico int

as
begin
	select me.id_medico, u.nombres, u.apellido, turnDis.fecha_turno, ra.hora_inicio, ra.hora_fin
	from Medicos me, Rangos ra, Usuarios u, Turnos_disponibles turnDis
	where me.id_usuario = u.id_usuario
	and turnDis.id_rango = ra.id_rango
	and me.id_medico = turnDis.id_medico
	and turnDis.id_medico = @id_medico

end
