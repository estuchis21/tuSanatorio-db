USE [tuSanatorio]
GO
/****** Object:  StoredProcedure [dbo].[GetTurnosDisponibles]    Script Date: 23/06/2025 20:55:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[GetTurnosDisponibles]
	@id_medico int
	as
	begin
		select * from Turnos_disponibles where id_medico = @id_medico

	end 
