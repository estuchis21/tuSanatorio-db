USE [tuSanatorio]
GO
/****** Object:  StoredProcedure [dbo].[GetTurnosDisponibles]    Script Date: 31/08/2025 15:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[GetTurnosDisponibles]
	@id_medico int,
    @id_especialidad int
	as
	begin
		SELECT 
            t.id_turno,
            t.fecha_turno,
            ra.hora_inicio,
            ra.hora_fin,
            u.nombres AS nombre_medico,
            u.apellido AS apellido_medico,
            e.nombre AS especialidad
        FROM Turnos_disponibles t
        INNER JOIN Rangos ra ON t.id_rango = ra.id_rango
        INNER JOIN Medicos me ON me.id_medico = t.id_medico
        INNER JOIN Usuarios u ON u.id_usuario = me.id_usuario
        INNER JOIN Especialidades e ON e.id_especialidad = me.id_especialidad
        WHERE me.id_medico = @id_medico
        and me.id_especialidad = @id_especialidad
        AND NOT EXISTS (
          SELECT 1 
          FROM Turnos_asignados ta
          WHERE ta.id_turno = t.id_turno
        )


	end 
