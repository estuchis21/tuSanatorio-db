BEGIN;

-- =========================================================
-- ROLES
-- =========================================================

INSERT INTO roles (rol_id, rol) VALUES
(1, 'Paciente'),
(2, 'Médico'),
(3, 'Administrador');

-- =========================================================
-- ESPECIALIDADES
-- =========================================================

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

-- =========================================================
-- OBRAS SOCIALES
-- =========================================================

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

-- =========================================================
-- RANGOS HORARIOS
-- =========================================================

INSERT INTO rangos (hora_inicio, hora_fin) VALUES
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

COMMIT;
