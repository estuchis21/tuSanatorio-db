USE [tuSanatorio]
GO
/****** Object:  StoredProcedure [dbo].[DatosDelTurno]    Script Date: 14/10/2025 17:17:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DatosDelTurno]
    @id_turno INT
AS
BEGIN
    SELECT 
        td.fecha_turno,
        r.hora_inicio,
        r.hora_fin,
        umed.nombres AS medicoNombre,
        umed.apellido AS medicoApellido,
        upac.nombres AS nombrePac,
        upac.apellido AS apellidoPac,
        umed.telefono AS medicoTelefono,
        e.nombre AS especialidadNombre
    FROM TurnosDescartados td, Rangos r, Medicos me, Usuarios umed, Usuarios upac, Pacientes pa, Especialidades e, Turnos_asignados ta
    WHERE td.id_rango = r.id_rango
      AND me.id_medico = td.id_medico
      AND umed.id_usuario = me.id_usuario          -- médico
      AND pa.id_usuario = upac.id_usuario          -- paciente
      AND ta.id_turno = td.id_turno
      AND ta.id_paciente = pa.id_paciente
      AND e.id_especialidad = me.id_especialidad
      AND ta.id_turno = @id_turno;

END
