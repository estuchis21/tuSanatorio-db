-- 1. Roles
CREATE TABLE [dbo].[Roles] (
    [rol_id] INT IDENTITY(1,1) NOT NULL,
    [rol] VARCHAR(50) NOT NULL,
    CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED ([rol_id])
);

-- 2. Usuarios
CREATE TABLE [dbo].[Usuarios] (
    [id_usuario] INT IDENTITY(1,1) NOT NULL,
    [nombres] VARCHAR(50) NOT NULL,
    [apellido] VARCHAR(50) NOT NULL,
    [dni] VARCHAR(20) NOT NULL UNIQUE,
    [email] VARCHAR(100) NOT NULL UNIQUE,
    [contrasena] VARCHAR(50) NOT NULL,
    [telefono] VARCHAR(20),
    [direccion] VARCHAR(100),
    [fecha_nacimiento] DATE,
    [id_rol] INT NOT NULL,
    CONSTRAINT [PK_Usuarios] PRIMARY KEY CLUSTERED ([id_usuario]),
    CONSTRAINT [FK_Usuarios_Roles] FOREIGN KEY ([id_rol]) REFERENCES [dbo].[Roles]([rol_id])
);

-- 3. Especialidades
CREATE TABLE [dbo].[Especialidades] (
    [id_especialidad] INT IDENTITY(1,1) NOT NULL,
    [nombre] VARCHAR(100) NOT NULL,
    CONSTRAINT [PK_Especialidades] PRIMARY KEY CLUSTERED ([id_especialidad])
);

-- 4. Médicos
CREATE TABLE [dbo].[Medicos] (
    [id_medico] INT IDENTITY(1,1) NOT NULL,
    [id_usuario] INT NOT NULL,
    [id_especialidad] INT NOT NULL,
    CONSTRAINT [PK_Medicos] PRIMARY KEY CLUSTERED ([id_medico]),
    CONSTRAINT [FK_Medicos_Usuarios] FOREIGN KEY ([id_usuario]) REFERENCES [dbo].[Usuarios]([id_usuario]),
    CONSTRAINT [FK_Medicos_Especialidades] FOREIGN KEY ([id_especialidad]) REFERENCES [dbo].[Especialidades]([id_especialidad])
);

-- 5. Pacientes
CREATE TABLE [dbo].[Pacientes] (
    [id_paciente] INT IDENTITY(1,1) NOT NULL,
    [id_usuario] INT NOT NULL,
    CONSTRAINT [PK_Pacientes] PRIMARY KEY CLUSTERED ([id_paciente]),
    CONSTRAINT [FK_Pacientes_Usuarios] FOREIGN KEY ([id_usuario]) REFERENCES [dbo].[Usuarios]([id_usuario])
);

-- 6. Obras Sociales
CREATE TABLE [dbo].[Obras_sociales] (
    [id_obra_social] INT IDENTITY(1,1) NOT NULL,
    [obra_social] VARCHAR(100) NOT NULL,
    CONSTRAINT [PK_ObrasSociales] PRIMARY KEY CLUSTERED ([id_obra_social])
);

-- 7. Rangos
CREATE TABLE [dbo].[Rangos] (
    [id_rango] INT IDENTITY(1,1) NOT NULL,
    [hora_inicio] TIME NOT NULL,
    [hora_fin] TIME NOT NULL,
    CONSTRAINT [PK_Rangos] PRIMARY KEY CLUSTERED ([id_rango])
);

-- 8. Turnos Disponibles
CREATE TABLE [dbo].[Turnos_disponibles] (
    [id_turno] INT IDENTITY(1,1) NOT NULL,
    [id_medico] INT NOT NULL,
    [id_rango] INT NOT NULL,
    [fecha_turno] DATE NOT NULL,
    CONSTRAINT [PK_Turnos_disponibles] PRIMARY KEY CLUSTERED ([id_turno]),
    CONSTRAINT [FK_Turnos_Medicos] FOREIGN KEY ([id_medico]) REFERENCES [dbo].[Medicos]([id_medico]),
    CONSTRAINT [FK_Turnos_Rangos] FOREIGN KEY ([id_rango]) REFERENCES [dbo].[Rangos]([id_rango])
);

-- 9. Turnos Asignados
CREATE TABLE [dbo].[Turnos_asignados] (
    [id_turno_asignado] INT IDENTITY(1,1) NOT NULL,
    [id_turno] INT NOT NULL,
    [id_paciente] INT NOT NULL,
    [id_obra_social] INT NOT NULL,
    [fecha_asignacion] DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK_Turnos_asignados] PRIMARY KEY CLUSTERED ([id_turno_asignado]),
    CONSTRAINT [FK_TurnosAsignados_TurnosDisponibles] FOREIGN KEY ([id_turno]) REFERENCES [dbo].[Turnos_disponibles]([id_turno]),
    CONSTRAINT [FK_TurnosAsignados_Pacientes] FOREIGN KEY ([id_paciente]) REFERENCES [dbo].[Pacientes]([id_paciente]),
    CONSTRAINT [FK_TurnosAsignados_ObrasSociales] FOREIGN KEY ([id_obra_social]) REFERENCES [dbo].[Obras_sociales]([id_obra_social])
);

-- 10. Medio de Pago
CREATE TABLE [dbo].[Medio_pago] (
    [id_medio_pago] INT IDENTITY(1,1) NOT NULL,
    [medio_pago] VARCHAR(50) NOT NULL,
    CONSTRAINT [PK_Medio_pago] PRIMARY KEY CLUSTERED ([id_medio_pago])
);

-- 11. Pagos
CREATE TABLE [dbo].[Pagos] (
    [id_pago] INT IDENTITY(1,1) NOT NULL,
    [id_turno_asignado] INT NOT NULL,
    [id_medio_pago] INT NOT NULL,
    [monto] DECIMAL(10,2) NOT NULL,
    [fecha_pago] DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK_Pagos] PRIMARY KEY CLUSTERED ([id_pago]),
    CONSTRAINT [FK_Pagos_TurnosAsignados] FOREIGN KEY ([id_turno_asignado]) REFERENCES [dbo].[Turnos_asignados]([id_turno_asignado]),
    CONSTRAINT [FK_Pagos_MedioPago] FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_pago]([id_medio_pago])
);
