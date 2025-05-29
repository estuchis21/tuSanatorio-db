CREATE PROCEDURE VerPacientesConTurno
    @id_usuario INT  
AS
BEGIN
    SELECT td.fecha_turno AS 'Fecha del Turno',
           up.nombres AS 'Paciente',
           up.dni AS 'DNI',
           up.telefono AS 'Telefono',
           up.email AS 'Email'
    FROM Medicos m,
         Turnos_disponibles td,
         Turnos_asignados ta,
         Pacientes p,
         Usuarios up
    WHERE 
        m.id_usuario = @id_usuario
        AND m.id_medico = td.id_medico
        AND td.id_turno = ta.id_turno
        AND ta.id_paciente = p.id_paciente
        AND p.id_usuario = up.id_usuario
        AND td.fecha_turno >= GETDATE() 
    ORDER BY td.fecha_turno;
END;
GO

