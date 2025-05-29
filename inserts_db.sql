INSERT INTO Roles (rol) VALUES 
('Administrador'),
('Paciente'),
('Médico');

INSERT INTO Usuarios (nombres, apellido, dni, email, contrasena, telefono, direccion, fecha_nacimiento, id_rol) VALUES 
('Juan', 'Pérez', '12345678', 'juan.perez@mail.com', '1234', '123456789', 'Calle Falsa 123', '1980-05-10', 3),
('Ana', 'Gómez', '23456789', 'ana.gomez@mail.com', '1234', '234567890', 'Av. Siempreviva 742', '1990-07-20', 3),
('Carlos', 'López', '34567890', 'carlos.lopez@mail.com', '1234', '345678901', 'Calle Real 456', '1985-09-15', 3),
('Lucía', 'Martínez', '45678901', 'lucia.martinez@mail.com', '1234', '456789012', 'Diagonal 111', '1992-11-25', 2),
('Pedro', 'Sánchez', '56789012', 'pedro.sanchez@mail.com', '1234', '567890123', 'Av. Corrientes 300', '2000-01-05', 2),
('María', 'Díaz', '67890123', 'maria.diaz@mail.com', '1234', '678901234', 'Mitre 111', '1988-03-30', 2),
('Roberto', 'Fernández', '78901234', 'roberto.fernandez@mail.com', '1234', '789012345', 'Maipú 888', '1975-12-12', 2),
('Elena', 'Ruiz', '89012345', 'elena.ruiz@mail.com', '1234', '890123456', 'Libertad 555', '1982-06-06', 3),
('Sofía', 'Silva', '90123456', 'sofia.silva@mail.com', '1234', '901234567', 'San Martín 101', '1995-10-10', 2),
('Diego', 'Méndez', '01234567', 'diego.mendez@mail.com', '1234', '012345678', 'Belgrano 202', '1999-04-18', 2);

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


INSERT INTO Turnos_disponibles (id_medico, id_rango, fecha_turno) VALUES
(1, 1, '2025-05-24'),
(1, 2, '2025-05-24'),
(2, 3, '2025-05-25'),
(2, 4, '2025-05-25'),
(3, 5, '2025-05-26'),
(3, 6, '2025-05-26'),
(1, 7, '2025-05-27'),
(2, 8, '2025-05-28'),
(3, 9, '2025-05-29'),
(1, 10, '2025-05-30');



INSERT INTO Turnos_asignados (id_turno, id_paciente, id_obra_social) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5),
(6, 6, 6),
(7, 1, 7),
(8, 2, 8),
(9, 3, 9),
(10, 4, 10);


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
