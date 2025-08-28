CREATE PROCEDURE getEspecialidadesPorMédico
@id_medico int

as
begin
	
	SELECT e.nombre, me.id_medico, u.nombres, u.apellido
	FROM Especialidades e, Medicos me, Usuarios u
	WHERE e.id_especialidad = me.id_especialidad
	and me.id_usuario = u.id_usuario
	and me.id_medico = @id_medico

end
go
