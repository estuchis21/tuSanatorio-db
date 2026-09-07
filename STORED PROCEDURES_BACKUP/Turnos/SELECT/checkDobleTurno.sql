create or alter procedure checkDobleTurno

@id_medico int,
@id_rango int, 
@fecha_turno date

as
begin
	SELECT COUNT(*) AS cantidad
    FROM Turnos_disponibles
    WHERE id_medico = @id_medico
      AND id_rango = @id_rango
      AND CAST(fecha_turno AS DATE) = @fecha_turno

end
go