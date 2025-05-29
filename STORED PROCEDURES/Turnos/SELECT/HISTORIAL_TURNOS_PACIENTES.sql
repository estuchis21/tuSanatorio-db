CREATE PROCEDURE HistorialTurnos
    @id_usuarios INT
AS
BEGIN
    SELECT td.fecha_turno AS 'Fecha del turno',
           um.nombres AS 'Medico',
           e.nombre AS 'Especialidad'
    FROM Usuarios u, Pacientes p, Turnos_asignados ta, Turnos_disponibles td,
         Medicos m, Especialidades e, Usuarios um
    WHERE u.id_usuario = p.id_usuario
      AND p.id_paciente = ta.id_paciente
      AND ta.id_turno = td.id_turno
      AND td.id_medico = m.id_medico
      AND m.id_usuario = um.id_usuario
      AND m.id_especialidad = e.id_especialidad
      AND u.id_usuario = @id_usuarios
      AND td.fecha_turno < GETDATE();
END;
GO
