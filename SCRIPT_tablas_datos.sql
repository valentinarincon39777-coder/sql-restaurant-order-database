-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema sistema_restauante_db
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema sistema_restauante_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `sistema_restauante_db` DEFAULT CHARACTER SET utf8 ;
USE `sistema_restauante_db` ;

-- -----------------------------------------------------
-- Table `sistema_restauante_db`.`persona`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sistema_restauante_db`.`persona` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(45) NOT NULL,
  `apellido` VARCHAR(45) NOT NULL,
  `telefono` VARCHAR(45) NULL,
  `direccion` VARCHAR(255) NULL,
  `email` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sistema_restauante_db`.`cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sistema_restauante_db`.`cliente` (
  `id` INT NOT NULL,
  `puntos` INT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `cliente_fk_1`
    FOREIGN KEY (`id`)
    REFERENCES `sistema_restauante_db`.`persona` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sistema_restauante_db`.`repartidor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sistema_restauante_db`.`repartidor` (
  `id` INT NOT NULL,
  `zona_asignada` ENUM('Norte', 'Sur', 'Centro') NULL,
  `estado` ENUM('disponible', 'no_disponible') NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `repartidor_fk_1`
    FOREIGN KEY (`id`)
    REFERENCES `sistema_restauante_db`.`persona` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sistema_restauante_db`.`pizza`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sistema_restauante_db`.`pizza` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(45) NOT NULL,
  `tamaño` ENUM('Grande', 'Pequeña') NOT NULL,
  `precio` DECIMAL(10,2) NOT NULL,
  `tipo` ENUM('Vegetariana', 'Especial', 'Clásica') NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sistema_restauante_db`.`ingrediente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sistema_restauante_db`.`ingrediente` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(45) NOT NULL,
  `precio_por_gramo` DECIMAL(10,4) NULL,
  `stock` DECIMAL(10,2) NULL,
  `stock_minimo` DECIMAL(10,2) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sistema_restauante_db`.`pizza_ingrediente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sistema_restauante_db`.`pizza_ingrediente` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `pizza_fk` INT NOT NULL,
  `ingrediente_fk` INT NOT NULL,
  `cantidad_gramos` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `pizza_ingrediente_fk_1_idx` (`pizza_fk` ASC) VISIBLE,
  INDEX `pizza_ingrediente_fk_2_idx` (`ingrediente_fk` ASC) VISIBLE,
  CONSTRAINT `pizza_ingrediente_fk_1`
    FOREIGN KEY (`pizza_fk`)
    REFERENCES `sistema_restauante_db`.`pizza` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `pizza_ingrediente_fk_2`
    FOREIGN KEY (`ingrediente_fk`)
    REFERENCES `sistema_restauante_db`.`ingrediente` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sistema_restauante_db`.`pedido`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sistema_restauante_db`.`pedido` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cliente_fk` INT NOT NULL,
  `total` DECIMAL(10,2) NOT NULL,
  `fecha_hora` DATETIME NOT NULL,
  `metodo_pago` ENUM('Efectivo', 'Tarjeta', 'App') NOT NULL,
  `estado_pedido` ENUM('pendiente', 'preparacion', 'camino', 'entregado', 'cancelado') NULL,
  PRIMARY KEY (`id`),
  INDEX `pedido_fk_1_idx` (`cliente_fk` ASC) VISIBLE,
  CONSTRAINT `pedido_fk_1`
    FOREIGN KEY (`cliente_fk`)
    REFERENCES `sistema_restauante_db`.`cliente` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sistema_restauante_db`.`detalle_pedido`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sistema_restauante_db`.`detalle_pedido` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `pedido_fk` INT NOT NULL,
  `pizza_fk` INT NOT NULL,
  `cantidad_pizzas` INT NOT NULL,
  `precio_unitario` DECIMAL(10,2) NOT NULL,
  `subtotal` DECIMAL(10,2) NULL,
  PRIMARY KEY (`id`),
  INDEX `detalle_pedido_fk_1_idx` (`pedido_fk` ASC) VISIBLE,
  INDEX `detalle_pedido_fk_2_idx` (`pizza_fk` ASC) VISIBLE,
  CONSTRAINT `detalle_pedido_fk_1`
    FOREIGN KEY (`pedido_fk`)
    REFERENCES `sistema_restauante_db`.`pedido` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `detalle_pedido_fk_2`
    FOREIGN KEY (`pizza_fk`)
    REFERENCES `sistema_restauante_db`.`pizza` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sistema_restauante_db`.`domicilio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sistema_restauante_db`.`domicilio` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `pedido_fk` INT NOT NULL,
  `repartidor_fk` INT NOT NULL,
  `distancia_aproximada` DECIMAL(10,2) NOT NULL,
  `direccion_entrega` VARCHAR(255) NULL,
  `hora_salida` DATETIME NOT NULL,
  `hora_entrega` DATETIME NULL,
  `costo_envio` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `domicilio_fk_1_idx` (`pedido_fk` ASC) VISIBLE,
  INDEX `domicilio_fk_2_idx` (`repartidor_fk` ASC) VISIBLE,
  CONSTRAINT `domicilio_fk_1`
    FOREIGN KEY (`pedido_fk`)
    REFERENCES `sistema_restauante_db`.`pedido` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `domicilio_fk_2`
    FOREIGN KEY (`repartidor_fk`)
    REFERENCES `sistema_restauante_db`.`repartidor` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sistema_restauante_db`.`historial_precio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sistema_restauante_db`.`historial_precio` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `pizza_fk` INT NOT NULL,
  `precio_anterior` DECIMAL(10,2) NOT NULL,
  `precio_nuevo` DECIMAL(10,2) NOT NULL,
  `fecha` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `historial_precio_fk_1_idx` (`pizza_fk` ASC) VISIBLE,
  CONSTRAINT `historial_precio_fk_1`
    FOREIGN KEY (`pizza_fk`)
    REFERENCES `sistema_restauante_db`.`pizza` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sistema_restauante_db`.`ganancia_diaria`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sistema_restauante_db`.`ganancia_diaria` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `fecha` DATETIME NOT NULL,
  `ganancia_neta` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;





-- =====================================================
--                    DATOS DE PRUEBA
-- =====================================================
 
INSERT INTO persona (nombre, apellido, telefono, direccion, email) VALUES
('María José', 'Rodríguez', '6001-1111', 'Calle 50, Ciudad de Panamá', 'maria.rodriguez@gmail.com'),
('Carlos Alberto', 'Pérez', '6002-2222', 'Vía España, Ciudad de Panamá', 'carlos.perez@gmail.com'),
('Ana Lucía', 'Gómez', '6003-3333', 'El Cangrejo, Ciudad de Panamá', 'ana.gomez@gmail.com'),
('Luis Fernando', 'Castillo', '6004-4444', 'Bella Vista, Ciudad de Panamá', 'luis.castillo@gmail.com'),
('Gabriela', 'Sánchez', '6005-5555', 'San Francisco, Ciudad de Panamá', 'gabriela.sanchez@gmail.com'),
('Roberto', 'Martínez', '6006-6666', 'Obarrio, Ciudad de Panamá', 'roberto.martinez@gmail.com'),
('Valentina', 'Herrera', '6007-7777', 'Costa del Este, Ciudad de Panamá', 'valentina.herrera@gmail.com'),
('Diego Alejandro', 'Ríos', '6008-8888', 'Punta Pacífica, Ciudad de Panamá', 'diego.rios@gmail.com'),
('Camila', 'Torres', '6009-9999', 'Marbella, Ciudad de Panamá', 'camila.torres@gmail.com'),
('Andrés Felipe', 'Morales', '6010-1010', 'Betania, Ciudad de Panamá', 'andres.morales@gmail.com'),
('Isabella', 'Vargas', '6011-1212', 'Parque Lefevre, Ciudad de Panamá', 'isabella.vargas@gmail.com'),
('Sebastián', 'Quintero', '6012-1313', 'Río Abajo, Ciudad de Panamá', 'sebastian.quintero@gmail.com'),
('Daniela', 'Navarro', '6013-1414', 'Vista Hermosa, Ciudad de Panamá', 'daniela.navarro@gmail.com'),
('Mateo', 'Jiménez', '6014-1515', 'Ancón, Ciudad de Panamá', 'mateo.jimenez@gmail.com'),
('Sofía', 'Delgado', '6015-1616', 'Albrook, Ciudad de Panamá', 'sofia.delgado@gmail.com'),
('Julián', 'Cárdenas', '6016-1717', 'Chanis, Ciudad de Panamá', 'julian.cardenas@gmail.com'),
('Paola', 'Restrepo', '6017-1818', 'San Francisco, Ciudad de Panamá', 'paola.restrepo@gmail.com'),
('Nicolás', 'Ospina', '6018-1919', 'El Dorado, Ciudad de Panamá', 'nicolas.ospina@gmail.com'),
('Renata', 'Salazar', '6019-2020', 'Los Angeles, Ciudad de Panamá', 'renata.salazar@gmail.com'),
('Emilio', 'Fonseca', '6020-2121', 'Bethania, Ciudad de Panamá', 'emilio.fonseca@gmail.com'),
('Jorge Luis', 'Batista', '6101-0001', 'Curundú, Ciudad de Panamá', 'jorge.batista@gmail.com'),
('Kevin', 'Sánchez', '6102-0002', 'Chorrillo, Ciudad de Panamá', 'kevin.sanchez@gmail.com'),
('Yariela', 'Pinzón', '6103-0003', 'Calidonia, Ciudad de Panamá', 'yariela.pinzon@gmail.com'),
('Ricardo', 'Aguilar', '6104-0004', 'Juan Díaz, Ciudad de Panamá', 'ricardo.aguilar@gmail.com'),
('Melissa', 'Cedeño', '6105-0005', 'Tocumen, Ciudad de Panamá', 'melissa.cedeno@gmail.com'),
('Franklin', 'Quintero', '6106-0006', 'San Miguelito, Ciudad de Panamá', 'franklin.quintero@gmail.com'),
('Ariadna', 'Solís', '6107-0007', 'Pedregal, Ciudad de Panamá', 'ariadna.solis@gmail.com'),
('Bryan', 'Castillo', '6108-0008', '24 de Diciembre, Ciudad de Panamá', 'bryan.castillo@gmail.com'),
('Yolanda', 'Peña', '6109-0009', 'Las Cumbres, Ciudad de Panamá', 'yolanda.pena@gmail.com'),
('Esteban', 'Rodríguez', '6110-0010', 'Santa Librada, Ciudad de Panamá', 'esteban.rodriguez@gmail.com');
 
INSERT INTO cliente (id, puntos) VALUES
(1,0),(2,0),(3,0),(4,0),(5,0),(6,0),(7,0),(8,0),(9,0),(10,0),
(11,0),(12,0),(13,0),(14,0),(15,0),(16,0),(17,0),(18,0),(19,0),(20,0);
 
-- -----------------------------------------------------
-- REPARTIDOR -- CAMBIO 1: estado según si TODOS sus domicilios
-- asignados están en un estado terminal (entregado/cancelado).
-- Si tiene AL MENOS un domicilio en un pedido activo (pendiente,
-- preparacion, camino), queda 'no_disponible' porque está ocupado
-- con esa entrega, sin importar que otro de sus pedidos ya haya
-- terminado. Mapeo real según tus 15 domicilios:
--   21 -> pedido1(pendiente) + pedido11(preparacion)      => no_disponible
--   22 -> pedido2(preparacion) + pedido12(entregado)      => no_disponible (tiene uno activo)
--   23 -> pedido3(camino) + pedido13(entregado)           => no_disponible (tiene uno activo)
--   24 -> pedido4(entregado) + pedido14(pendiente)        => no_disponible (tiene uno activo)
--   25 -> pedido5(entregado) + pedido15(entregado)        => disponible (ambos terminales)
--   26 -> pedido6(pendiente)                              => no_disponible
--   27 -> pedido7(entregado)                               => disponible
--   28 -> pedido8(entregado)                               => disponible
--   29 -> pedido9(cancelado)                               => disponible
--   30 -> pedido10(entregado)                              => disponible
-- -----------------------------------------------------
INSERT INTO repartidor (id, zona_asignada, estado) VALUES
(21,'Norte','no_disponible'),
(22,'Sur','no_disponible'),
(23,'Centro','no_disponible'),
(24,'Norte','no_disponible'),
(25,'Sur','disponible'),
(26,'Centro','no_disponible'),
(27,'Norte','disponible'),
(28,'Sur','disponible'),
(29,'Centro','disponible'),
(30,'Norte','disponible');
 
INSERT INTO ingrediente (nombre, precio_por_gramo, stock, stock_minimo) VALUES
('Queso mozzarella', 0.02, 15000, 3000),
('Tomate', 0.01, 8000, 1500),
('Albahaca', 0.05, 1000, 200),
('Cebolla', 0.0080, 5000, 1000),
('Pepperoni', 0.03, 6000, 1000),
('Jamón', 0.0250, 5000, 1000),
('Piña', 0.0150, 4000, 800),
('Champiñones', 0.02, 3000, 600),
('Pimentón', 0.0120, 3000, 600),
('Aceitunas negras', 0.04, 2000, 400),
('Prosciutto', 0.08, 1500, 300),
('Queso gorgonzola', 0.06, 1200, 250),
('Higo', 0.07, 800, 150),
('Camarones', 0.09, 2000, 400),
('Curry en polvo', 0.0500, 500, 100),
('Pato confitado', 0.12, 1000, 200),
('Naranja confitada', 0.04, 700, 150),
('Trufa negra', 0.50, 300, 50),
('Rúcula', 0.02, 1500, 300),
('Salsa BBQ', 0.0150, 3000, 600),
('Pollo desmenuzado', 0.03, 4000, 800),
('Maíz dulce', 0.01, 2500, 500);
 
-- -----------------------------------------------------
-- PIZZA -- CAMBIO 2: precio = costo_ingredientes + $2.00 mano de obra + $3.00 utilidad
-- -----------------------------------------------------
INSERT INTO pizza (nombre, tamaño, precio, tipo) VALUES
('Margarita', 'Pequeña', 9.50, 'Clásica'),                              -- 1
('Margarita', 'Grande', 14.00, 'Clásica'),                              -- 2
('Pepperoni', 'Pequeña', 11.80, 'Clásica'),                             -- 3
('Pepperoni', 'Grande', 18.60, 'Clásica'),                              -- 4
('Hawaiana', 'Pequeña', 11.70, 'Clásica'),                              -- 5
('Hawaiana', 'Grande', 18.40, 'Clásica'),                               -- 6
('Cuatro Quesos', 'Pequeña', 12.56, 'Especial'),                        -- 7
('Cuatro Quesos', 'Grande', 20.12, 'Especial'),                         -- 8
('Vegetariana Mediterránea', 'Pequeña', 10.64, 'Vegetariana'),          -- 9
('Vegetariana Mediterránea', 'Grande', 16.28, 'Vegetariana'),           -- 10
('BBQ Pollo', 'Pequeña', 11.54, 'Especial'),                            -- 11
('BBQ Pollo', 'Grande', 18.08, 'Especial'),                             -- 12
('Higo, Prosciutto y Gorgonzola', 'Pequeña', 18.90, 'Especial'),        -- 13
('Higo, Prosciutto y Gorgonzola', 'Grande', 32.80, 'Especial'),         -- 14
('Camarones al Curry', 'Pequeña', 18.79, 'Especial'),                   -- 15
('Camarones al Curry', 'Grande', 32.58, 'Especial'),                    -- 16
('Pato a la Naranja', 'Pequeña', 23.64, 'Especial'),                    -- 17
('Pato a la Naranja', 'Grande', 42.28, 'Especial'),                     -- 18
('Trufa Negra con Rúcula', 'Pequeña', 16.30, 'Vegetariana'),            -- 19
('Trufa Negra con Rúcula', 'Grande', 27.60, 'Vegetariana');             -- 20
 
INSERT INTO pizza_ingrediente (pizza_fk, ingrediente_fk, cantidad_gramos) VALUES
(1,1,150),(1,2,100),(1,3,10),
(2,1,300),(2,2,200),(2,3,20),
(3,1,150),(3,2,80),(3,5,100),
(4,1,300),(4,2,160),(4,5,200),
(5,1,150),(5,6,100),(5,7,80),
(6,1,300),(6,6,200),(6,7,160),
(7,1,120),(7,12,60),(7,9,30),(7,10,30),
(8,1,240),(8,12,120),(8,9,60),(8,10,60),
(9,1,100),(9,2,100),(9,9,60),(9,10,40),(9,4,40),
(10,1,200),(10,2,200),(10,9,120),(10,10,80),(10,4,80),
(11,1,120),(11,21,100),(11,20,60),(11,4,30),
(12,1,240),(12,21,200),(12,20,120),(12,4,60),
(13,12,60),(13,11,80),(13,13,50),(13,19,20),
(14,12,120),(14,11,160),(14,13,100),(14,19,40),
(15,1,100),(15,14,120),(15,15,15),(15,4,30),
(16,1,200),(16,14,240),(16,15,30),(16,4,60),
(17,1,100),(17,16,120),(17,17,50),(17,4,30),
(18,1,200),(18,16,240),(18,17,100),(18,4,60),
(19,1,120),(19,18,15),(19,19,30),(19,10,20),
(20,1,240),(20,18,30),(20,19,60),(20,10,40);
 
-- -----------------------------------------------------
-- PEDIDO -- total RECALCULADO: subtotal_pizzas (con precios +$3) + costo_envio + IVA 7% sobre subtotal_pizzas
-- -----------------------------------------------------
INSERT INTO pedido (cliente_fk, total, fecha_hora, metodo_pago, estado_pedido) VALUES
(1, 17.98, '2026-09-01 10:00:00', 'Efectivo', 'pendiente'),      -- 1
(1, 24.90, '2026-09-03 12:30:00', 'Tarjeta',  'preparacion'),    -- 2
(1, 33.85, '2026-09-05 19:00:00', 'App',      'camino'),         -- 3
(1, 23.53, '2026-09-08 20:15:00', 'Efectivo', 'entregado'),      -- 4
(1, 40.84, '2026-09-10 13:45:00', 'Tarjeta',  'entregado'),      -- 5
(1, 22.35, '2026-09-11 18:00:00', 'App',      'pendiente'),      -- 6
(2, 29.25, '2026-08-15 12:00:00', 'Efectivo', 'entregado'),      -- 7
(3, 42.10, '2026-09-02 14:20:00', 'Tarjeta',  'entregado'),      -- 8
(4, 39.86, '2026-09-06 19:30:00', 'App',      'cancelado'),      -- 9
(5, 53.24, '2026-07-20 20:00:00', 'Efectivo', 'entregado'),      -- 10
(6, 32.53, '2026-09-09 13:10:00', 'Tarjeta',  'preparacion'),    -- 11
(7, 40.88, '2026-09-04 11:45:00', 'App',      'entregado'),      -- 12
(8, 23.69, '2026-08-28 17:50:00', 'Efectivo', 'entregado'),      -- 13
(9, 19.42, '2026-09-07 21:00:00', 'Tarjeta',  'pendiente'),      -- 14
(10,43.69, '2026-09-11 15:30:00', 'App',      'entregado');      -- 15
 
-- -----------------------------------------------------
-- DETALLE_PEDIDO -- precio_unitario y subtotal RECALCULADOS con el nuevo precio de pizza (+$3 utilidad)
-- -----------------------------------------------------
INSERT INTO detalle_pedido (pedido_fk, pizza_fk, cantidad_pizzas, precio_unitario, subtotal) VALUES
(1, 2, 1, 14.00, 14.00),
(2, 4, 1, 18.60, 18.60),
(3, 6, 1, 18.40, 18.40),
(3, 1, 1, 9.50, 9.50),
(4, 8, 1, 20.12, 20.12),
(5, 10, 2, 16.28, 32.56),
(6, 12, 1, 18.08, 18.08),
(7, 3, 2, 11.80, 23.60),
(8, 14, 1, 32.80, 32.80),
(9, 16, 1, 32.58, 32.58),
(10, 18, 1, 42.28, 42.28),
(11, 20, 1, 27.60, 27.60),
(12, 2, 1, 14.00, 14.00),
(12, 4, 1, 18.60, 18.60),
(13, 6, 1, 18.40, 18.40),
(14, 10, 1, 16.28, 16.28),
(15, 12, 2, 18.08, 36.16);
 
INSERT INTO domicilio (pedido_fk, repartidor_fk, distancia_aproximada, direccion_entrega, hora_salida, hora_entrega, costo_envio) VALUES
(1, 21, 3, 'Calle 50, Ciudad de Panamá',        '2026-09-01 10:15:00', NULL,                   3.00),
(2, 22, 5, 'Vía España, Ciudad de Panamá',      '2026-09-03 12:45:00', NULL,                   5.00),
(3, 23, 4, 'Calle 50, Ciudad de Panamá',        '2026-09-05 19:15:00', NULL,                   4.00),
(4, 24, 2, 'Calle 50, Ciudad de Panamá',        '2026-09-08 20:30:00', '2026-09-08 21:00:00',  2.00),
(5, 25, 6, 'Calle 50, Ciudad de Panamá',        '2026-09-10 14:00:00', '2026-09-10 14:45:00',  6.00),
(6, 26, 3, 'Calle 50, Ciudad de Panamá',        '2026-09-11 18:15:00', NULL,                   3.00),
(7, 27, 4, 'Vía España, Ciudad de Panamá',      '2026-08-15 12:15:00', '2026-08-15 12:50:00',  4.00),
(8, 28, 7, 'El Cangrejo, Ciudad de Panamá',     '2026-09-02 14:35:00', '2026-09-02 15:20:00',  7.00),
(9, 29, 5, 'Bella Vista, Ciudad de Panamá',     '2026-09-06 19:45:00', NULL,                   5.00),
(10,30, 8, 'San Francisco, Ciudad de Panamá',   '2026-07-20 20:15:00', '2026-07-20 21:05:00',  8.00),
(11,21, 3, 'Obarrio, Ciudad de Panamá',         '2026-09-09 13:25:00', NULL,                   3.00),
(12,22, 6, 'Costa del Este, Ciudad de Panamá',  '2026-09-04 12:00:00', '2026-09-04 12:50:00',  6.00),
(13,23, 4, 'Punta Pacífica, Ciudad de Panamá',  '2026-08-28 18:05:00', '2026-08-28 18:45:00',  4.00),
(14,24, 2, 'Marbella, Ciudad de Panamá',        '2026-09-07 21:15:00', NULL,                   2.00),
(15,25, 5, 'Betania, Ciudad de Panamá',         '2026-09-11 15:45:00', '2026-09-11 16:30:00',  5.00);
 
-- historial_precio y ganancia_neta se deja vacía a propósito.
 