CREATE PROCEDURE insertPaciente
@id_paciente int,
@id_usuario int

as
begin
	begin try
		insert into Pacientes (id_usuario)
		values (@id_usuario)

		print 'Se agregó al paciente correctamente'

	end try
	begin catch
		print 'Error al ingresar paciente';
		print ERROR_MESSAGE();
	END CATCH

END