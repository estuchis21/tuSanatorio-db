create procedure insertMedico

@id_usuario int,
@id_especialidad int

as
begin
	begin try
		insert into Medicos(id_usuario, id_especialidad)
		values (@id_usuario, @id_especialidad)
		print 'Datos de m�dico agregado correctamente'
	end try
	begin catch
		print 'Error al ingresar m�dico'
		print ERROR_MESSAGE();
	end catch

END