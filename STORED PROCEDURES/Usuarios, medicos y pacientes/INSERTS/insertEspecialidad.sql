create procedure insertEspecialidad
@especialidad varchar(100)
as
begin
	begin try
		insert into especialidades (especialidad)
		values (@especialidad)

		print 'Se agregó la especialidad correctamente';

	end try

	begin catch
		print 'error al agregar la especialidad';
		print ERROR_MESSAGE();
	end catch

end