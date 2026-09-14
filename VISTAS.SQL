/*VISTAS ------------------------------------------*/

/*1)Vista de resumen de pedidos por cliente (nombre del cliente, cantidad de pedidos, total gastado).*/


create view resumen_pedidos_cliente  as select 
per.nombre as cliente, count(ped.id) as cantidad_pedidos, 
sum(ped.total) as total_gastado from persona per join cliente cli 
on per.id=cli.id join pedido ped  on cli.id=ped.cliente_fk group by cliente_fk;


select * from resumen_pedidos_cliente; 



/*2)Vista de desempeño de repartidores (número de entregas, tiempo promedio, zona).*/

create view desempeño_repartidor as select per.nombre as nombre_repartidor, count(if( ped.estado_pedido='entregado',dom.id, null)) as 
numero_entregas, ifnull(concat(format(avg( timestampdiff(minute, hora_salida, hora_entrega)), 1), ' minutos' ), '0 minutos'  )
as 'tiempo_promedio', 
rep.zona_asignada 
from persona per join repartidor rep on per.id=rep.id 
left join domicilio  dom on rep.id=repartidor_fk 
left join pedido ped on dom.pedido_fk=ped.id
 group by rep.id; 
 
  select * from desempeño_repartidor;


/*3)Vista de stock de ingredientes por debajo del mínimo permitido.*/


create view stock_bajo as select nombre as ingrediente, stock as stock_actual, stock_minimo as stock_minimo_permitido

 from ingrediente where stock < stock_minimo; 
 
 select * from stock_bajo;




