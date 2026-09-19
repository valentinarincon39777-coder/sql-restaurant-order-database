

/*CONSULTAS REPARTIDORES Y DOMICILIOS*/

/* 1) Mostrar el nombre del repartidor, cantidad de entregas 
realizadas (estado='entregado'), y total acumulado de pedidos entregados.*/

select concat(per.nombre, ' ' ,per.apellido) as 'nombre_repartidor', count(repartidor_fk) as 'cantidad_entregas', 
sum(distancia_aproximada*1) as 'total_generado_pedidos'  from persona per 
join repartidor rep on per.id=rep.id join domicilio dom 
on dom.repartidor_fk=rep.id  where hora_entrega is not null group by nombre_repartidor;  

/*confirmacion: jorge luis no aparece ya que el no tiene pedidos entregados,
mientras que kevin sanchez aparece una vez y son $6 en total para 1 entrega */
select per.nombre as 'nombre_repartidor', dom.pedido_fk, dom.distancia_aproximada, dom.hora_entrega from persona per 
join repartidor rep on per.id=rep.id join domicilio dom 
on dom.repartidor_fk=rep.id; 

/*---------------------------------------------------------------------------------------------------------------------------------*/

/*2) Mostrar los id pedidos y nombre del repartidor cuya entrega tomó más de 40 minutos 
entre hora_salida y hora_entrega
(Usa TIMESTAMPDIFF(MINUTE, hora_salida, hora_entrega) > 40).*/

select ped.id as id_pedido, per.nombre as  nombre_repartidor, 
timestampdiff(minute, hora_salida, hora_entrega ) as tiempo_entrega_minutos
from pedido ped join domicilio dom on dom.pedido_fk=ped.id 
join repartidor rep on dom.repartidor_fk=rep.id 
join persona per on rep.id=per.id 
having tiempo_entrega_minutos>40; 

/*confirmacion: kevin por ejemplo salio a las 12 y llego a las 12:50, se pasó de los 40 min*/
select per.nombre as 'nombre_repartidor',dom.hora_entrega, dom.hora_salida from persona per 
join repartidor rep on per.id=rep.id join domicilio dom 
on dom.repartidor_fk=rep.id where hora_entrega is not null; 

/*---------------------------------------------------------------------------------------------------------------------------------*/

/*3)Mostrar los repartidores con estado 'disponible' que no tienen
 domicilios asignados (usa LEFT JOIN y WHERE domicilio.id_domicilio IS NULL).*/

select per.nombre as nombre_repartidor, 
rep.estado as  estado_repartidor 

from persona per 
join repartidor rep on per.id=rep.id 
left join domicilio dom on dom.repartidor_fk=rep.id where rep.estado='disponible' and dom.id is null;

/*todos los repartidores dispoibles tienen domicilios asignados*/
 
 
 
 
 /*---------------------------------------------------------------------------------------------------------------------------------*/
 
 /*4)Crear una vista vista_desempeno_repartidor que muestre:
nombre_repartidor
entregas_totales
promedio_minutos_entrega*/


select per.nombre, count(if(ped.estado_pedido='entregado', dom.id, null)) as 'cantidad_entregas', 
ifnull(concat(format(avg( timestampdiff(minute, hora_salida, hora_entrega)), 1), ' minutos' ), '0 minutos'  ) as 'promedio_minutos_entrega'
from persona per join repartidor rep on rep.id=per.id join domicilio dom on dom.repartidor_fk=rep.id 
join pedido ped on dom.pedido_fk=ped.id

 group by repartidor_fk ;


/*confirmacion: jorge luis tiene 2 pedidos en camino pero ningun ha sido entregado, p
or lo que su cantidad_entregas es CERO su promedio de minutos por entrega, tamboen lo es*/
select per.nombre as 'nombre_repartidor', dom.pedido_fk, dom.distancia_aproximada, dom.hora_entrega from persona per 
join repartidor rep on per.id=rep.id join domicilio dom 
on dom.repartidor_fk=rep.id ; 


