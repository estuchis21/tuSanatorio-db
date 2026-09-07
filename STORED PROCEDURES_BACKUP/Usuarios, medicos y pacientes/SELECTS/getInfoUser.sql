CREATE PROCEDURE obtenerDatosUsuario
@id_paciente int

as
begin
	
	select u.nombres, u.apellido, u.telefono, u.email
	from Usuarios u, Pacientes pa
	where u.id_usuario = pa.id_usuario
	and pa.id_paciente = @id_paciente

end
go