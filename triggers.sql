/*TRIGGERS ------------------------------------------*/

/*1) Trigger de actualización automática de stock de ingredientes cuando se realiza un pedido. (serán dos triggers, uno BEFORE y uno AFTER) */


/*trigger para verificar que si hay stock suficiente BEFORE INSERT*/


delimiter // 


create trigger verificar_stock 
before insert on detalle_pedido 
for each row

begin

declare stock_minimo decimal(10,2);

select min(i.stock-(pi.cantidad_gramos*new.cantidad_pizzas)) into 
stock_minimo from ingrediente i join pizza_ingrediente pi on i.id=pi.ingrediente_fk
where pi.pizza_fk=new.pizza_fk;   

if stock_minimo < 0 then
signal sqlstate '45000' set message_text = 'Stock insuficiente para preparar la pizza'; 
end if; 

end //
delimiter ; 


	/*trigger para restar el stock de ingrediente AFTER INSERT*/
	
	
 
delimiter // 


create trigger restar_stock 
after insert on detalle_pedido 
for each row

begin

update ingrediente i join pizza_ingrediente pi on i.id=pi.ingrediente_fk 
set i.stock=i.stock-(pi.cantidad_gramos*new.cantidad_pizzas)
where pi.pizza_fk=new.pizza_fk; 


end //
delimiter ; 


/*PRUEBA*/


/*NUEVO PEDIDO*/
INSERT INTO pedido (cliente_fk, total, fecha_hora, metodo_pago, estado_pedido)
VALUES (11, 0.00, NOW(), 'Efectivo', 'pendiente');

SET @nuevo_pedido = LAST_INSERT_ID();


/*debe aparecer stock completo al hacerle select a ingredientes*/
select * from ingrediente where id in (1,2,3);
select * from pizza_ingrediente where pizza_fk=2;

/*NUEVO DETALLE DE PED (recordar activar trigger que inserta automatico precio unitario y subtotal)*/ 
INSERT INTO detalle_pedido (pedido_fk, pizza_fk, cantidad_pizzas, precio_unitario, subtotal)
VALUES (@nuevo_pedido, 2, 1, 00.00, 00.00); 



/*debe aparecer stock incompleto al hacerle select a ingredientes (tendra menos la cantidad de pizza_ingrediente)*/
select * from ingrediente where id in (1,2,3);
select * from pizza_ingrediente where pizza_fk=2;

/*deben verse reflejadas las pizzas en el total ya */
SELECT * FROM pedido WHERE id = @nuevo_pedido;

/*NUEVO DOMICILIO*/
INSERT INTO domicilio (pedido_fk, repartidor_fk, distancia_aproximada, direccion_entrega, hora_salida, hora_entrega, costo_envio)
VALUES (@nuevo_pedido, 21, 4, 'Río Abajo, Ciudad de Panamá', NOW(), NULL, 4.00);

/*ya debe verse reflejado el total completo*/
SELECT * FROM pedido WHERE id = @nuevo_pedido;


/**************************************************************************************************************************************************/	
	




/*2) Trigger de auditoría que registre en una tabla historial_precios cada vez que se modifique el precio de una pizza.*/


delimiter // 

create trigger auditoria_historial_precios  
after update on pizza
for each row 
begin 


/*armando receta es la variable que se usa para que
 al ingresar una nueva receta de pizza, no se llenen esos precios temporales en esta tabla 
de historial de precios, y solo se llene si se quiere 'realmente'
actualizar un precio de un ingrediente*/

if old.precio <> new.precio and (@armando_receta is null or @armando_receta=0) then 
insert into historial_precio (pizza_fk, precio_anterior, precio_nuevo, fecha) values (new.id, old.precio, new.precio, now());

end if; 

end //
delimiter ; 

/*PRUEBA*/


update pizza 
set precio=9.51 where id=1; 


select * from historial_precio; 


/**************************************************************************************************************************************************/	

/*3)Trigger para marcar repartidor como “disponible” nuevamente cuando termina un domicilio.*/

 
delimiter // 

create trigger actualizar_disponiblidad_repartidor 
after update on domicilio
for each row
begin 



if old.hora_entrega is null and new.hora_entrega is not null then 
update repartidor 
set estado='disponible'
where id=new.repartidor_fk;

end if; 

end // 
delimiter ;

/*PRUEBA*/ 

select * from domicilio; 
select * from repartidor;

update domicilio 
set hora_entrega = '2026-09-08 23:00:00'
where id=3;





/**************************************************************************************************************************************************/	





/*4)Trigger que calcule el precio unitario una vez se registra una nueva pizza (NO cuando se hace un nuevo pedido, solo al registrar nueva pizza)tomando en cuenta los ingredientes que usa en pizza_ingredientes y la mano de obra  que es de $2 y  la utilidad fija que es de 3 */



delimiter // 

create trigger calcular_precio_pizza 
after insert on pizza_ingrediente

for each row 

begin 

update pizza 
set precio=(
select sum(pi.cantidad_gramos*i.precio_por_gramo)
from pizza_ingrediente pi join ingrediente i on i.id=pi.ingrediente_fk
where pi.pizza_fk=new.pizza_fk
) + 2.00 + 3.00
where id =new.pizza_fk; 


end //


delimiter ; 

/*PRUEBA*/
/*1. Registrar pizza nueva  (precio en 0.00, el trigger lo va a llenar)*/
INSERT INTO pizza (nombre, tamaño, precio, tipo)
VALUES ('Búfala con Rúcula', 'Pequeña', 0.00, 'Especial');

SET @nueva_pizza = LAST_INSERT_ID();

/*Verificamos que comenzó en cero*/
SELECT * FROM pizza WHERE id = @nueva_pizza;

 /* Insertar la receta a apizza_ingrediente (dispara el trigger) */
INSERT INTO pizza_ingrediente (pizza_fk, ingrediente_fk, cantidad_gramos) VALUES
(@nueva_pizza, 1, 130),   
(@nueva_pizza, 2, 90),    
(@nueva_pizza, 19, 15),   
(@nueva_pizza, 10, 20);   

/* Verificar: ahora debe mostrar precio = 9.60 */
SELECT * FROM pizza WHERE id = @nueva_pizza;

/**************************************************************************************************************************************************/	




/*5) 1.Trigger para que se inserte automático el precio unitario que está en tabla pizza en detalle de pedido*/




delimiter // 

create trigger copia_precio_unitario
before insert on detalle_pedido

for each row 

begin 

set new.precio_unitario= (select precio from pizza where id=new.pizza_fk); 

set new.subtotal= (select precio from pizza where id=new.pizza_fk)*new.cantidad_pizzas; 

end //


delimiter ; 

