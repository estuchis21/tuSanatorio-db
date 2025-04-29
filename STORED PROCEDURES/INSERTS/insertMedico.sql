create procedure insertMedico

@id_usuario int,
@id_especialidad int

as
begin
	begin try
		insert into Medicos(id_usuario, id_especialidad)
		values (@id_usuario, @id_especialidad)
		print 'Datos de médico agregado correctamente'
	end try
	begin catch
		print 'Error al ingresar médico'
		print ERROR_MESSAGE();
	end catch

END