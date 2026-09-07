USE [tuSanatorio]
GO

CREATE TABLE Medio_pago (
    id_medio_pago INT IDENTITY(1,1) PRIMARY KEY,
    medio_pago VARCHAR(50) NOT NULL
);
GO

CREATE TABLE Pagos (
    id_pago INT IDENTITY(1,1) PRIMARY KEY,
    id_turno_asignado INT NOT NULL,
    id_medio_pago INT NOT NULL,
    monto DECIMAL(10, 2) NOT NULL,
    fecha_pago DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (id_turno_asignado) REFERENCES Turnos_asignados(id_turno_asignado),
    FOREIGN KEY (id_medio_pago) REFERENCES Medio_pago(id_medio_pago)
);
GO

CREATE TABLE HistClinicas (
    id_historia_clinica INT IDENTITY PRIMARY KEY,
    id_paciente INT NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
GO

CREATE TABLE Detalle_Historias (
    id_detalle INT IDENTITY PRIMARY KEY,
    id_historia_clinica INT NOT NULL,
    id_medico INT NOT NULL,
    historia_clinica NVARCHAR(MAX) NOT NULL,
    fecha_detalle DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_historia_clinica) REFERENCES HistClinicas(id_historia_clinica)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_medico) REFERENCES Medicos(id_medico)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO
