CREATE OR ALTER PROCEDURE getHistoriasPorMedico

@id_medico int

as
begin
	
		select u.nombres, u.apellido, h.fecha_registro, dh.historia_clinica 
		from HistClinicas h, Detalle_Historias dh, Usuarios u, Medicos me, Pacientes pa
		where h.id_historia_clinica = dh.id_historia_clinica
		and h.id_paciente = pa.id_paciente
		and pa.id_usuario = u.id_usuario
		and dh.id_medico = me.id_medico
		and dh.id_medico = @id_medico

end
go