BEGIN;

-- =========================================================
-- PACIENTE
-- username: paciente1
-- password: 123456
-- obra social: OSDE (1)
-- =========================================================

CALL insertarusuario(
    50000001,
    'Juan',
    'Pérez',
    'paciente1@tusanatorio.com',
    'paciente1',
    '1100000001',
    '/AY5YB.2JlkLp7YdMEa/fiONS',
    1,
    NULL,
    1
);

-- =========================================================
-- MÉDICO 1
-- username: medico1
-- password: 123456
-- especialidad: Cardiología (1)
-- obra social: OSDE (1)
-- =========================================================

CALL insertarusuario(
    50000002,
    'María',
    'Gómez',
    'medico1@tusanatorio.com',
    'medico1',
    '1100000002',
    '/5conYORMH5XH.VvN3CqiMAnrLF8oVl8vsa8i.',
    2,
    1,
    1
);

-- =========================================================
-- MÉDICO 2
-- username: medico2
-- password: 123456
-- especialidad: Pediatría (2)
-- obra social: Swiss Medical (2)
-- =========================================================

CALL insertarusuario(
    50000003,
    'Carlos',
    'Rodríguez',
    'medico2@tusanatorio.com',
    'medico2',
    '1100000003',
    '.vsQcUc6krQg/vUKV3pm.0YkU2bAEwwIYgZJB6weN/bfpLFgVFmG',
    2,
    2,
    2
);

COMMIT;
