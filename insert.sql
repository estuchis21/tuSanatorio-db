-- ============================================
-- DATOS INICIALES - tuSanatorio
-- PostgreSQL
-- ============================================

-- ============================================
-- ROLES
-- ============================================

INSERT INTO roles (rol) VALUES
('Administrador'),
('Paciente'),
('Médico');


-- ============================================
-- USUARIOS
-- ============================================

INSERT INTO usuarios
(
    nombres,
    apellido,
    dni,
    email,
    contrasena,
    username,
    telefono,
    id_rol
)
VALUES
(
    'Esteban',
    'Álvarez',
    12345678,
    'esteban.alvarez@mail.com',
    'pass1234',
    'estalvarez',
    '1122334455',
    1
),
(
    'María',
    'Gómez',
    23456789,
    'maria.gomez@mail.com',
    'maria2025',
    'mgomez',
    '1166778899',
    2
),
(
    'Juan',
    'Pérez',
    34567890,
    'juan.perez@mail.com',
    'juanpass',
    'jperez',
    '1199887766',
    2
),
(
    'Laura',
    'Rodríguez',
    45678901,
    'laura.rodriguez@mail.com',
    'laura2025',
    'lrodriguez',
    '1144556677',
    3
);


-- ============================================
-- ESPECIALIDADES
-- ============================================

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


-- ============================================
-- OBRAS SOCIALES
-- ============================================

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


-- ============================================
-- RANGOS HORARIOS
-- ============================================

INSERT INTO rangos
(
    hora_inicio,
    hora_fin
)
VALUES
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