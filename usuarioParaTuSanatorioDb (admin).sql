-- crear_admin.sql
CREATE LOGIN estuchis WITH PASSWORD = 'Svaaea01';
ALTER SERVER ROLE sysadmin ADD MEMBER estuchis;
