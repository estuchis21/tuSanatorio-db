USE [tuSanatorio]
GO
/****** Object:  StoredProcedure [dbo].[InsertTurnosDisponibles]    Script Date: 07/10/2025 19:56:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[InsertTurnosDisponibles]
	@id_medico int,
	@id_rango int, 
	@fecha_turno datetime

	as
	begin
	
		INSERT INTO Turnos_disponibles (id_medico, id_rango, fecha_turno) 
		values (@id_medico, @id_rango, @fecha_turno)

	end

