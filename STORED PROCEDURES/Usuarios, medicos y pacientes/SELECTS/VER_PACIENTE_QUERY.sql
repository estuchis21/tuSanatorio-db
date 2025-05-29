CREATE PROCEDURE MisTurnos
    @id_usuario INT
AS
BEGIN
    SELECT ta.fecha_asignacion AS 'Fecha de Asignación del Turno'
    FROM Pacientes p, Usuarios u, Turnos_asignados ta
    WHERE u.id_usuario = p.id_usuario
      AND p.id_paciente = ta.id_paciente
      AND u.id_usuario = @id_usuario;
END;
GO



