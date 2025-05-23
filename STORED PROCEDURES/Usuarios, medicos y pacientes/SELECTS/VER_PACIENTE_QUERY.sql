/*QUERY Ver sus turnos agendados.*/
CREATE PROCEDURE MisTurnos
    @id_usuario INT
AS
BEGIN
    SELECT ta.fecha_asignacion AS 'Mis Turnos'
    FROM Pacientes p, Usuarios u, turnos_asignados ta
    WHERE u.id_usuario = p.id_usuario
      AND p.id_paciente = ta.id_paciente
      AND u.id_usuario = @id_usuario;
END;
GO


