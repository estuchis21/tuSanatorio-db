CREATE or alter PROCEDURE GetRangos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        id_rango,      
        hora_inicio,
        hora_fin
    FROM Rangos
    ORDER BY hora_inicio;
END
go

