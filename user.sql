-- Crear el usuario
CREATE USER "tuSanatorio"
WITH PASSWORD 'F.1.atyUmika';

-- Darle todos los privilegios sobre la base
GRANT ALL PRIVILEGES ON DATABASE "tuSanatorio" TO "tuSanatorio";

-- Conectate a la base tuSanatorio antes de ejecutar lo siguiente

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public
TO "tuSanatorio";

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public
TO "tuSanatorio";

GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public
TO "tuSanatorio";

GRANT ALL PRIVILEGES ON ALL PROCEDURES IN SCHEMA public
TO "tuSanatorio";

-- Permitir acceso al schema
GRANT USAGE, CREATE ON SCHEMA public
TO "tuSanatorio";

-- Para que también tenga permisos sobre objetos creados posteriormente
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON TABLES TO "tuSanatorio";

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON SEQUENCES TO "tuSanatorio";

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON FUNCTIONS TO "tuSanatorio";