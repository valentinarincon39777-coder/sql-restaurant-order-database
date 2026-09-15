/*EVENTO ***********************/

/*1) Cree un evento diario que inserté en una tabla una fila con la fecha del día y la ganancia total de dicho día*/

 

delimiter // 

create event registrar_ganancia_neta
on schedule every 1 day 
starts '2026-09-15 23:59:00'
do 
begin 

insert into ganancia_diaria(fecha, ganancia_neta)
values (
curdate(), 
ganancia_neta_diaria(curdate())
);


end // 

delimiter ; 