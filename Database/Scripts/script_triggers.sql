DELIMITER $$

-- ============================================================================
-- TRIGGERS: Rol
-- ============================================================================
CREATE TRIGGER trg_rol_after_insert
AFTER INSERT ON Rol
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Rol', NEW.id_rol, 'INSERT',
            CONCAT('Se creó el rol "', NEW.nombre_rol, '".'));
END$$

CREATE TRIGGER trg_rol_after_update
AFTER UPDATE ON Rol
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Rol', NEW.id_rol, 'UPDATE',
            CONCAT('Se actualizó el rol "', OLD.nombre_rol, '" -> "', NEW.nombre_rol, '".'));
END$$

CREATE TRIGGER trg_rol_after_delete
AFTER DELETE ON Rol
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Rol', OLD.id_rol, 'DELETE',
            CONCAT('Se eliminó el rol "', OLD.nombre_rol, '".'));
END$$

-- ============================================================================
-- TRIGGERS: Usuario
-- ============================================================================
CREATE TRIGGER trg_usuario_after_insert
AFTER INSERT ON Usuario
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, NEW.id_usuario), 'Usuario', NEW.id_usuario, 'INSERT',
            CONCAT('Se registró el usuario "', NEW.nombre, ' ', NEW.apellido, '" (', NEW.correo, ').'));
END$$

CREATE TRIGGER trg_usuario_after_update
AFTER UPDATE ON Usuario
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, NEW.id_usuario), 'Usuario', NEW.id_usuario, 'UPDATE',
            CONCAT('Se actualizó el usuario "', NEW.correo, '". Estado: ', OLD.estado, ' -> ', NEW.estado, '.'));
END$$

CREATE TRIGGER trg_usuario_after_delete
AFTER DELETE ON Usuario
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Usuario', OLD.id_usuario, 'DELETE',
            CONCAT('Se eliminó el usuario "', OLD.correo, '".'));
END$$

-- ============================================================================
-- TRIGGERS: Mesa
-- ============================================================================
CREATE TRIGGER trg_mesa_after_insert
AFTER INSERT ON Mesa
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Mesa', NEW.id_mesa, 'INSERT',
            CONCAT('Se creó la mesa número ', NEW.numero_mesa, '.'));
END$$

CREATE TRIGGER trg_mesa_after_update
AFTER UPDATE ON Mesa
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Mesa', NEW.id_mesa, 'UPDATE',
            CONCAT('Se actualizó la mesa ', NEW.numero_mesa, '. Estado: ', OLD.estado_mesa, ' -> ', NEW.estado_mesa, '.'));
END$$

CREATE TRIGGER trg_mesa_after_delete
AFTER DELETE ON Mesa
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Mesa', OLD.id_mesa, 'DELETE',
            CONCAT('Se eliminó la mesa número ', OLD.numero_mesa, '.'));
END$$

-- ============================================================================
-- TRIGGERS: Categoria_producto
-- ============================================================================
CREATE TRIGGER trg_categoria_after_insert
AFTER INSERT ON Categoria_producto
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Categoria_producto', NEW.id_categoria, 'INSERT',
            CONCAT('Se creó la categoría "', NEW.nombre_categoria, '".'));
END$$

CREATE TRIGGER trg_categoria_after_update
AFTER UPDATE ON Categoria_producto
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Categoria_producto', NEW.id_categoria, 'UPDATE',
            CONCAT('Se actualizó la categoría "', OLD.nombre_categoria, '" -> "', NEW.nombre_categoria, '".'));
END$$

CREATE TRIGGER trg_categoria_after_delete
AFTER DELETE ON Categoria_producto
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Categoria_producto', OLD.id_categoria, 'DELETE',
            CONCAT('Se eliminó la categoría "', OLD.nombre_categoria, '".'));
END$$

-- ============================================================================
-- TRIGGERS: Producto
-- ============================================================================
CREATE TRIGGER trg_producto_after_insert
AFTER INSERT ON Producto
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Producto', NEW.id_producto, 'INSERT',
            CONCAT('Se creó el producto "', NEW.nombre_producto, '" con precio ', NEW.precio, '.'));
END$$

CREATE TRIGGER trg_producto_after_update
AFTER UPDATE ON Producto
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Producto', NEW.id_producto, 'UPDATE',
            CONCAT('Se actualizó el producto "', NEW.nombre_producto, '". Precio: ', OLD.precio, ' -> ', NEW.precio,
                   ', Stock: ', OLD.stock, ' -> ', NEW.stock, '.'));
END$$

CREATE TRIGGER trg_producto_after_delete
AFTER DELETE ON Producto
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Producto', OLD.id_producto, 'DELETE',
            CONCAT('Se eliminó el producto "', OLD.nombre_producto, '".'));
END$$

-- ============================================================================
-- TRIGGERS: Reservacion
-- ============================================================================
CREATE TRIGGER trg_reservacion_after_insert
AFTER INSERT ON Reservacion
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, NEW.id_usuario), 'Reservacion', NEW.id_reservacion, 'INSERT',
            CONCAT('Se creó la reservación para la mesa ', NEW.id_mesa, ' el ', NEW.fecha_reservacion,
                   ' a las ', NEW.hora_reservacion, '.'));
END$$

CREATE TRIGGER trg_reservacion_after_update
AFTER UPDATE ON Reservacion
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, NEW.id_usuario), 'Reservacion', NEW.id_reservacion, 'UPDATE',
            CONCAT('Se actualizó la reservación. Estado: ', OLD.estado_reservacion, ' -> ', NEW.estado_reservacion, '.'));
END$$

CREATE TRIGGER trg_reservacion_after_delete
AFTER DELETE ON Reservacion
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, OLD.id_usuario), 'Reservacion', OLD.id_reservacion, 'DELETE',
            CONCAT('Se eliminó la reservación de la mesa ', OLD.id_mesa, ' del ', OLD.fecha_reservacion, '.'));
END$$

-- ============================================================================
-- TRIGGERS: Pedido
-- ============================================================================
CREATE TRIGGER trg_pedido_after_insert
AFTER INSERT ON Pedido
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, NEW.id_usuario), 'Pedido', NEW.id_pedido, 'INSERT',
            CONCAT('Se creó el pedido tipo "', NEW.tipo_pedido, '" con total ', NEW.total, '.'));
END$$

CREATE TRIGGER trg_pedido_after_update
AFTER UPDATE ON Pedido
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, NEW.id_usuario), 'Pedido', NEW.id_pedido, 'UPDATE',
            CONCAT('Se actualizó el pedido. Estado: ', OLD.estado_pedido, ' -> ', NEW.estado_pedido,
                   ', Total: ', OLD.total, ' -> ', NEW.total, '.'));
END$$

CREATE TRIGGER trg_pedido_after_delete
AFTER DELETE ON Pedido
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, OLD.id_usuario), 'Pedido', OLD.id_pedido, 'DELETE',
            CONCAT('Se eliminó el pedido con total ', OLD.total, '.'));
END$$

-- ============================================================================
-- TRIGGERS: Detalle_pedido
-- ============================================================================
CREATE TRIGGER trg_detalle_pedido_after_insert
AFTER INSERT ON Detalle_pedido
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Detalle_pedido', NEW.id_detalle, 'INSERT',
            CONCAT('Se agregó el producto ', NEW.id_producto, ' (x', NEW.cantidad, ') al pedido ', NEW.id_pedido, '.'));
END$$

CREATE TRIGGER trg_detalle_pedido_after_update
AFTER UPDATE ON Detalle_pedido
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Detalle_pedido', NEW.id_detalle, 'UPDATE',
            CONCAT('Se actualizó el renglón del pedido ', NEW.id_pedido, '. Cantidad: ', OLD.cantidad, ' -> ', NEW.cantidad, '.'));
END$$

CREATE TRIGGER trg_detalle_pedido_after_delete
AFTER DELETE ON Detalle_pedido
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Detalle_pedido', OLD.id_detalle, 'DELETE',
            CONCAT('Se eliminó el renglón del producto ', OLD.id_producto, ' del pedido ', OLD.id_pedido, '.'));
END$$

-- ============================================================================
-- TRIGGERS: Pago
-- ============================================================================
CREATE TRIGGER trg_pago_after_insert
AFTER INSERT ON Pago
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Pago', NEW.id_pago, 'INSERT',
            CONCAT('Se registró un pago de ', NEW.monto, ' (', NEW.metodo_pago, ') para el pedido ', NEW.id_pedido, '.'));
END$$

CREATE TRIGGER trg_pago_after_update
AFTER UPDATE ON Pago
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Pago', NEW.id_pago, 'UPDATE',
            CONCAT('Se actualizó el pago del pedido ', NEW.id_pedido, '. Estado: ', OLD.estado_pago, ' -> ', NEW.estado_pago, '.'));
END$$

CREATE TRIGGER trg_pago_after_delete
AFTER DELETE ON Pago
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_usuario, tabla_afectada, id_registro_afectado, tipo_operacion, descripcion)
    VALUES (COALESCE(@usuario_actual, 1), 'Pago', OLD.id_pago, 'DELETE',
            CONCAT('Se eliminó el pago de ', OLD.monto, ' del pedido ', OLD.id_pedido, '.'));
END$$

-- ============================================================================
-- TRIGGERS DE PROTECCIÓN: Bitacora
-- La bitácora debe ser inalterable una vez generada (sección 7 del documento):
-- ningún usuario, ni siquiera un administrador, puede modificarla o borrarla.
-- ============================================================================
CREATE TRIGGER trg_bitacora_block_update
BEFORE UPDATE ON Bitacora
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'La bitácora es de solo lectura: no se permite UPDATE sobre sus registros.';
END$$

CREATE TRIGGER trg_bitacora_block_delete
BEFORE DELETE ON Bitacora
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'La bitácora es de solo lectura: no se permite DELETE sobre sus registros.';
END$$

DELIMITER ;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================