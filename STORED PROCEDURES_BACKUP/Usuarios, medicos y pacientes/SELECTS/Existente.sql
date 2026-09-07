CREATE OR ALTER PROCEDURE EXISTENTE
	@DNI int,
	@email varchar(100),
	@username varchar(100)

	as 
	begin

		SELECT * FROM Usuarios WHERE DNI = @DNI OR email = @email OR username = @username
	end
	go