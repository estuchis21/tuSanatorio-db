# SQL Server - Stored Procedures para Gestión de Usuarios, Turnos y Pagos

## Introducción

Este repositorio contiene los **Stored Procedures (SPs)** desarrollados en SQL Server para la gestión de usuarios, turnos médicos y pagos asociados a turnos en la aplicación.

Los SPs permiten realizar operaciones comunes como insertar usuarios, obtener datos, gestionar turnos y procesar pagos, asegurando una lógica centralizada y eficiente en la base de datos.

---

## Stored Procedures incluidos

### 1. Insertar usuario
Inserta un nuevo usuario en la base de datos.
- **Nombre:** `insertarUsuario`

### 2. Obtener usuario por username
Obtiene la información del usuario dado su nombre de usuario.
- **Nombre:** `getUserByUsername`

### 3. Agregar turno
Agrega un turno asignado a un usuario.
- **Nombre:** `AsignarTurno`

### 4. Cancelar turno
Cancela un turno previamente asignado.
- **Nombre:** `CancelarTurno`

### 5. Obtener turnos por médico
Obtiene todos los turnos asignados a un médico.
- **Nombre:** `HistorialTurnosMedico`

### 6. Obtener turnos por usuario
Obtiene todos los turnos asignados a un usuario.
- **Nombre:** `MisTurnos`

### 7. Obtener pacientes con turnos recientes
Obtiene los turnos de los pacientes que tengan pendientes a la fecha
- **Nombre:** `VerPacientesConTurnos`
## Uso y despliegue

### Cómo ejecutar los SPs

1. Abrir SQL Server Management Studio (SSMS).
2. Conectarse a la base de datos correspondiente.
3. Ejecutar los scripts para crear cada stored procedure si no están creados.
4. Llamar a los SPs desde el backend o directamente desde SSMS ejecutando el archivo 'ejecucionesTest.sql' ubicado en 'tuSanatorio-db\STORED PROCEDURES\Ejecuciones\ejecucionesTest.sql'
