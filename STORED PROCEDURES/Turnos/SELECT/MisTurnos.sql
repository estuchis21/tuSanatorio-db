USE [tuSanatorio]
GO
/****** Object:  StoredProcedure [dbo].[MisTurnos]    Script Date: 07/07/2025 19:03:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[MisTurnos]
    @id_paciente INT
AS
BEGIN
    SELECT DISTINCT
      ta.id_turno_asignado,
      td.fecha_turno,
      ra.hora_inicio,
      ra.hora_fin,
      e.nombre AS especialidad
    FROM Turnos_asignados ta
    INNER JOIN Pacientes p ON p.id_paciente = ta.id_paciente
    INNER JOIN Turnos_disponibles td ON ta.id_turno = td.id_turno
    INNER JOIN Rangos ra ON ra.id_rango = td.id_rango
    INNER JOIN Medicos me ON me.id_medico = td.id_medico 
    INNER JOIN Especialidades e ON e.id_especialidad = me.id_especialidad
    WHERE p.id_paciente = @id_paciente
    ORDER BY td.fecha_turno DESC;
END;
