/*FUNCIONES Y PROCEDIMIENTOS**********************************************************************************************************************************/

/*1) Función para calcular el total de un pedido (sumando precios de pizzas (de datlles de pedido) + costo de envío (otomando la distancia aproximada de domiclio y considerando que 1km=1dolar + IVA (tomando 7%)).*/




delimiter // 
create function calcular_total_pedido  (id_pedido_p INT) returns decimal(10,2)
deterministic 
reads sql data 

begin 

declare total_pizzas decimal(10,2); 
declare total_domicilio decimal(10,2);
declare total_pedido decimal(10,2);

 

/* primero necesitamos ir a detalle de pedido y obtener todos
 los detalles que tienen dichos pedidos y agarrar los precios y cantidad de dichas pizzas y sumarlos */
 
 select coalesce(sum(cantidad_pizzas*precio_unitario), 0) into total_pizzas from detalle_pedido where pedido_fk=id_pedido_p; 
 
 /*segundo, necesitamos irnos a domiclio y coincidir con el  pedido y 
 ver cuando km es la dist aproximada y considerar que 1km=$1, pero eso ya lo tengo calculado en costo_envio*/
 select  coalesce(sum(costo_envio), 0) into total_domicilio from domicilio where pedido_fk=id_pedido_p limit 1;
 /*sum permite tener siempre una fila con la cual trabajar, auqnue el trigger de detalle de pedido se dispare antes de que exista un domicilio, el coalesce funcionará/
 
/*tercero se calcula el porcentaje con impuetsoq ue será del 7%*/

set total_pedido= (total_pizzas + total_domicilio)*(1.07) ;

return total_pedido; 


end // 
delimiter ; 



/*PROC ALMACENADO PARA QUE ACTUALICE EL PRECIO */

delimiter //

create procedure actualizar_total_pedido(IN id_pedido INT )


begin 

declare total_pedido decimal(10,2); 

set total_pedido = calcular_total_pedido(id_pedido); 

update pedido 
set total=total_pedido 
where id=id_pedido;


end //
delimiter ;

/*TRIGGERS PARA QUE SE ACTUALICE EL TOTAL cada vez que 1)se editan los detalles de pedido o 2)se edita el domicilio */

/*trigger para detalle pedido*/
delimiter //
create trigger actualizar_total_desde_detalle
after insert on detalle_pedido
for each row
begin
  call actualizar_total_pedido(new.pedido_fk);
end //
delimiter ;


/*trigger para domicilio*/
delimiter //
create trigger actualizar_total_desde_domicilio
after insert on domicilio
for each row
begin
  call actualizar_total_pedido(new.pedido_fk);
end //
delimiter ;


/*Trigger para que se inserte precio automatico a detalle de pedido*/


delimiter // 

create trigger copia_precio_unitario
before insert on detalle_pedido

for each row 

begin 

set new.precio_unitario= (select precio from pizza where id=new.pizza_fk); 

set new.subtotal= (select precio from pizza where id=new.pizza_fk)*new.cantidad_pizzas; 

end //


delimiter ; 




/*PRUEBA*/



/*NUEVO PEDIDO*/
INSERT INTO pedido (cliente_fk, total, fecha_hora, metodo_pago, estado_pedido)
VALUES (11, 0.00, NOW(), 'Efectivo', 'pendiente');

SET @nuevo_pedido = LAST_INSERT_ID();

/*NUEVO DETALLE DE PED (recordar activar trigger que inserta automatico precio unitario y subtotal)*/ 
INSERT INTO detalle_pedido (pedido_fk, pizza_fk, cantidad_pizzas, precio_unitario, subtotal)
VALUES (@nuevo_pedido, 2, 1, 00.00, 00.00);  

/*deben verse reflejadas las pizzas en el total ya */
SELECT * FROM pedido WHERE id = @nuevo_pedido;

/*NUEVO DOMICILIO*/
INSERT INTO domicilio (pedido_fk, repartidor_fk, distancia_aproximada, direccion_entrega, hora_salida, hora_entrega, costo_envio)
VALUES (@nuevo_pedido, 21, 4, 'Río Abajo, Ciudad de Panamá', NOW(), NULL, 4.00);

/*ya debe verse reflejado el total completo*/
SELECT * FROM pedido WHERE id = @nuevo_pedido;






/*************************************************************************************************************************************************************/


/*2) Función para calcular la ganancia neta diaria (ventas - costos de ingredientes).*/



delimiter // 

create function ganancia_neta_diaria ( fecha_p datetime) returns decimal(10,2)

deterministic 
reads sql data
/*
¿qué incluye el total de un pedido?
2 por pizza para mano de obra 
3 por pizza por utilidad
7% de impuesto 
cobro de domicilio (20% se lo queda la empresa en sus ganancias, el resto no)

entonces si son 3 de utilidad por cada pizza, 
conociendo la cantidad de pizzas vendidas ese dia y multiplicandolo por 3 obtengo la utilidad; sin embargo considerando 
el 20% que la empresa se queda del cobro al domicilio, ese valor de cantidad_pizzas por 3 le sumamos 
el 20% de todo lo que se cobro en domicilio, y así obtenemos la ganancia neta

*/


begin 

declare utilidad_pizzas decimal(10,2); 
declare utilidad_domicilios decimal(10,2); 
declare ganancia_neta decimal(10,2); 

select coalesce(sum(cantidad_pizzas*3), 0 )into utilidad_pizzas from detalle_pedido 
join pedido on pedido.id=detalle_pedido.pedido_fk 
where date(fecha_hora)=date(fecha_p) and estado_pedido='entregado'; 

select coalesce(sum(costo_envio)*0.2, 0 )into  utilidad_domicilios from domicilio  
join pedido on pedido.id=domicilio.pedido_fk 
where date(fecha_hora)=date(fecha_p) and estado_pedido='entregado'; 



set ganancia_neta=utilidad_pizzas+utilidad_domicilios; 

return ganancia_neta;



end // 

delimiter ; 

/*PRUEBA*/


select *
from detalle_pedido
where pedido_fk = 5;

select costo_envio
from domicilio
where pedido_fk = 5;



select ganancia_neta_diaria('2026-09-10'); 




/*************************************************************************************************************************************************************/


/*3) Procedimiento para cambiar automáticamente el estado del pedido a “entregado” cuando se registre la hora de entrega 
(esto también activará el trigger que se creó para actualizar disponibilidad de repartidores)*/


delimiter // 
create procedure actualizar_estado_pedido (IN id_pedido INT, IN hora_entrega_p DATETIME)

begin 



update  domicilio
 set hora_entrega=hora_entrega_p
 where id_pedido=pedido_fk; 

update pedido 
set estado_pedido='entregado'
where id=id_pedido; 



end // 
delimiter ; 


/*PRUEBA*/


select * from pedido;
call  actualizar_estado_pedido(14, NOW()); 















