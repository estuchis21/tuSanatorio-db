exec insertarUsuario @DNI = 49809765, @nombres = 'Lautaro Bustamente', @telefono = '2364308570', @mail = 'lauti_yb2005@gmail.com', @username = 'lauuuti.y', @contrasena = 'Svaaea01', @rol_id = 4

exec insertEspecialidad @especialidad = 'neonatología';

exec insertMedico @id_usuario = 6, @id_especialidad = 6

exec insertPaciente @id_usuario = 1
