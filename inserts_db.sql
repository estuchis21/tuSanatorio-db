INSERT INTO Roles (rol) VALUES 
('Administrador'),
('Paciente'),
('Médico');

INSERT INTO Usuarios (nombres, apellido, DNI, email, contrasena, username, telefono, id_rol) VALUES
('Esteban', 'Álvarez', '12345678', 'esteban.alvarez@mail.com', 'pass1234', 'estalvarez', '1122334455', 1),
('María', 'Gómez', '23456789', 'maria.gomez@mail.com', 'maria2025', 'mgomez', '1166778899', 2),
('Juan', 'Pérez', '34567890', 'juan.perez@mail.com', 'juanpass', 'jperez', '1199887766', 2),
('Laura', 'Rodríguez', '45678901', 'laura.rodriguez@mail.com', 'laura2025', 'lrodriguez', '1144556677', 3);


INSERT INTO especialidades (nombre) VALUES
('Cardiología'),
('Pediatría'),
('Dermatología'),
('Ginecología'),
('Traumatología'),
('Neurología'),
('Oftalmología'),
('Otorrinolaringología'),
('Psiquiatría'),
('Endocrinología');

INSERT INTO obras_sociales (obra_social) VALUES
('OSDE'),
('Swiss Medical'),
('Galeno'),
('Medifé'),
('PAMI'),
('IOMA'),
('Sancor Salud'),
('OSECAC'),
('Federada Salud'),
('Prevención Salud');


INSERT INTO Rangos (hora_inicio, hora_fin) VALUES
('08:00:00', '08:30:00'),
('08:30:00', '09:00:00'),
('09:00:00', '09:30:00'),
('09:30:00', '10:00:00'),
('10:00:00', '10:30:00'),
('10:30:00', '11:00:00'),
('11:00:00', '11:30:00'),
('11:30:00', '12:00:00'),
('13:00:00', '13:30:00'),
('13:30:00', '14:00:00');

SELECT * 
FROM Turnos_asignados
WHERE id_paciente = 6;

SELECT *
FROM TurnosDescartados td
INNER JOIN Rangos r ON r.id_rango = td.id_rango
WHERE td.id_turno IN (SELECT id_turno FROM Turnos_asignados WHERE id_paciente = 6);


EXEC MisTurnosHistoricos @id_paciente = 6;


exec actualizarPerfil @email = 'micaelavega_@gmail.com', @id_usuario = 52

INSERT INTO Turnos_disponibles (id_medico, id_rango, fecha_turno) VALUES
(9, 1, '2026-05-02')

insert into Medicos_ObrasSociales (id_medico, id_obra_social, fecha_registro)
values (9, 6, GETDATE());

INSERT INTO Turnos_asignados (id_turno, id_paciente, id_obra_social) VALUES
(68, 6, 1)



-- Turno disponible / descartado
INSERT INTO TurnosDescartados (id_turno, id_medico, id_rango, fecha_turno)
VALUES (63, 1, 1, '2025-08-10');

-- Turno asignado a paciente
INSERT INTO Turnos_asignados (id_turno, id_paciente, id_obra_social, fecha_asignacion)
VALUES (9, 6, 1, GETDATE());


USE tuSanatorio;
GO

INSERT INTO Turnos_asignados (
    id_paciente,
    id_turno,
    fecha_asignacion
)
VALUES (
    1,                     -- id_paciente (ejemplo)
    10,                    -- id_turno (ejemplo)
    '2025-08-20'           -- fecha_asignacion
);
GO



INSERT INTO Medio_pago (medio_pago) VALUES
('Efectivo'),
('Tarjeta de Débito'),
('Tarjeta de Crédito'),
('Transferencia'),
('Mercado Pago'),
('Cheque'),
('Bitcoin'),
('Pago Fácil'),
('Rapipago'),
('PayPal');



INSERT INTO Pagos (id_turno_asignado, id_medio_pago, monto) VALUES
(1, 1, 1500.00),
(2, 2, 1800.00),
(3, 3, 2000.00),
(4, 4, 1700.00),
(5, 5, 1600.00),
(6, 6, 1900.00),
(7, 7, 2200.00),
(8, 8, 2100.00),
(9, 9, 1950.00),
(10, 10, 2050.00);

