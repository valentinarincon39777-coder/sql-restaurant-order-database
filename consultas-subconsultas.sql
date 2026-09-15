/*CONSULTAS/SUBCONSULTAS ------------------------------------------*/

/*1)Clientes con pedidos entre dos fechas (BETWEEN).*/



select concat(per.nombre, ' ',per.apellido)
 as nombre_cliente from persona per
join  cliente  on cliente.id=per.id 
join  pedido on cliente.id=cliente_fk
where fecha_hora BETWEEN '2026-8-1' AND '2026-9-1 23:59:59' group by cliente.id; 



/*2)Pizzas más vendidas (más de dos) (GROUP BY y COUNT).*/

select pi.nombre as pizza, sum(cantidad_pizzas) as cantidad_pizzas_vendidas 
from pizza pi join detalle_pedido dp on dp.pizza_fk=pi.id 
 group by pi.id having cantidad_pizzas_vendidas>2;




/*3)Pedidos por repartidor (JOIN).*/


select per.nombre as nombre_repartidor, 
count(dom.id) as pedidos_repartidor from persona 
 per 
join repartidor rep on per.id=rep.id 
join domicilio dom on rep.id=dom.repartidor_fk group by rep.id; 


/*4)Promedio de entrega por zona (AVG y JOIN).*/

select rep.zona_asignada as zona, concat(format(avg( timestampdiff(minute, hora_salida, hora_entrega)), 1), ' minutos' )
as promedio_tiempo_entrega  from repartidor rep join domicilio dom  on
 rep.id=dom.repartidor_fk  where dom.hora_entrega is not null group by zona_asignada; 




/*5)Clientes que gastaron más de un monto  (más de 50) (HAVING).*/


select per.nombre as cliente, sum(ped.total) as total_comprado from persona per join cliente cli  on 
per.id=cli.id join pedido ped on  cli.id=ped.cliente_fk group by cli.id having total_comprado > 50; 



/*6)Búsqueda por coincidencia parcial de nombre de pizza (LIKE)..*/

select nombre from pizza where nombre like '%ar%'; 





/*7)Subconsulta para obtener los clientes frecuentes (más de 5 pedidos mensuales).*/

select concat(per.nombre,' ' ,per.apellido ) as cliente_mayor_5_pedidos from persona per join cliente cli on per.id=cli.id
where cli.id in (select cliente_fk from pedido group by cliente_fk, year(fecha_hora), month(fecha_hora)
having count(id)>5
); 