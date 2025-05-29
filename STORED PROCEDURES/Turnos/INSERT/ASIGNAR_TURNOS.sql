CREATE PROCEDURE AsignarTurno
    @id_paciente INT,
    @id_turno INT
AS
BEGIN
    SELECT td.fecha_turno AS 'Fecha del turno', um.nombres AS 'Medico', e.nombre AS 'Especialidad'
    FROM Turnos_disponibles td, Medicos m, Usuarios um, Especialidades e
    WHERE td.id_turno = @id_turno
      AND td.id_medico = m.id_medico
      AND m.id_usuario = um.id_usuario
      AND m.id_especialidad = e.id_especialidad
      AND td.fecha_turno > GETDATE();

    IF NOT EXISTS (
        SELECT 1 
        FROM Turnos_asignados 
        WHERE id_turno = @id_turno
    )
    BEGIN
        INSERT INTO Turnos_asignados (id_turno, id_paciente, fecha_asignacion, id_obra_social)
        VALUES (@id_turno, @id_paciente, GETDATE(), NULL);

        PRINT 'El turno ha sido asignado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'El turno no esta disponible.';
    END
END;
GO

