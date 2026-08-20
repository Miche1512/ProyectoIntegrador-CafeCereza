-- ============================================================================
-- SIMULACIÓN DE DATOS: CAFETERÍA
-- Requiere haber ejecutado antes cafeteria_db.sql (tablas, FKs y triggers)
-- Requiere que Rol, Mesa, Categoria_producto y Producto YA tengan datos,
-- ya que este script solo llena Usuario, Reservacion, Pedido,
-- Detalle_pedido y Pago (catálogos fuera del alcance solicitado).
-- Orden de creación: 1) SP de limpieza  2) Funciones + SP de usuarios
-- 3) Funciones + SP del flujo completo de compra/reservación
-- ============================================================================

USE cafeteria_db;

-- ============================================================================
-- 1) PROCEDIMIENTO: sp_limpiar_datos_simulacion
-- Vacía Usuario, Reservacion, Pedido, Detalle_pedido y Pago, reiniciando
-- cada AUTO_INCREMENT a 1. Se usa TRUNCATE porque además de vaciar la tabla
-- reinicia el contador de identidad automáticamente y NO dispara los
-- triggers de Bitácora (evita llenarla de miles de renglones "DELETE" por
-- cada corrida de la simulación). FOREIGN_KEY_CHECKS se desactiva de forma
-- temporal porque estas tablas están referenciadas entre sí (y por
-- Bitacora.id_usuario); los registros históricos de Bitácora permanecen
-- intactos, ya que un log de auditoría no debe desaparecer al reiniciar
-- la simulación.
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_limpiar_datos_simulacion;

DELIMITER $$

CREATE PROCEDURE sp_limpiar_datos_simulacion()
BEGIN
    SET FOREIGN_KEY_CHECKS = 0;

    TRUNCATE TABLE Pago;
    TRUNCATE TABLE Detalle_pedido;
    TRUNCATE TABLE Pedido;
    TRUNCATE TABLE Reservacion;
    TRUNCATE TABLE Usuario;

    SET FOREIGN_KEY_CHECKS = 1;

    SELECT 'Tablas Usuario, Reservacion, Pedido, Detalle_pedido y Pago limpiadas. IDs reiniciados a 1.' AS resultado;
END$$

DELIMITER ;


-- ============================================================================
-- 2) FUNCIONES DE APOYO PARA GENERAR USUARIOS ALEATORIOS
-- Se crean antes del procedimiento porque este las invoca.
-- ============================================================================

DROP FUNCTION IF EXISTS fn_nombre_aleatorio;
DROP FUNCTION IF EXISTS fn_apellido_aleatorio;
DROP FUNCTION IF EXISTS fn_telefono_aleatorio;
DROP FUNCTION IF EXISTS fn_correo_aleatorio;
DROP FUNCTION IF EXISTS fn_password_hash_aleatorio;
DROP FUNCTION IF EXISTS fn_estado_usuario_aleatorio;
DROP FUNCTION IF EXISTS fn_fecha_aleatoria_en_rango;
DROP FUNCTION IF EXISTS fn_hora_aleatoria;

DELIMITER $$

-- Nombre de pila aleatorio, tomado de un catálogo fijo de 20 valores.
CREATE FUNCTION fn_nombre_aleatorio()
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    RETURN ELT(1 + FLOOR(RAND() * 20),
        'Ana','Luis','María','Carlos','Sofía','Jorge','Valeria','Diego',
        'Camila','Andrés','Fernanda','Miguel','Paula','Ricardo','Daniela',
        'Javier','Lucía','Emilio','Renata','Héctor');
END$$

-- Apellido aleatorio, tomado de un catálogo fijo de 20 valores.
CREATE FUNCTION fn_apellido_aleatorio()
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    RETURN ELT(1 + FLOOR(RAND() * 20),
        'García','Hernández','Martínez','López','González','Pérez','Sánchez',
        'Ramírez','Torres','Flores','Rivera','Gómez','Díaz','Cruz','Morales',
        'Reyes','Ortiz','Gutiérrez','Chávez','Mendoza');
END$$

-- Teléfono aleatorio de 10 dígitos (formato mexicano, sin separadores).
CREATE FUNCTION fn_telefono_aleatorio()
RETURNS VARCHAR(15)
DETERMINISTIC
BEGIN
    RETURN LPAD(FLOOR(RAND() * 10000000000), 10, '0');
END$$

-- Correo aleatorio a partir de nombre y apellido, con sufijo numérico y
-- dominio aleatorio; el sufijo de 6 dígitos minimiza colisiones con la
-- restricción UNIQUE de Usuario.correo.
CREATE FUNCTION fn_correo_aleatorio(p_nombre VARCHAR(50), p_apellido VARCHAR(50))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE v_dominio VARCHAR(30);
    SET v_dominio = ELT(1 + FLOOR(RAND() * 4),
        'correo.com','gmail.com','hotmail.com','outlook.com');
    RETURN LOWER(CONCAT(
        p_nombre, '.', p_apellido, FLOOR(RAND() * 900000) + 100000, '@', v_dominio
    ));
END$$

-- Simula una contraseña ya cifrada (hash) con SHA-256 sobre datos aleatorios.
CREATE FUNCTION fn_password_hash_aleatorio()
RETURNS VARCHAR(255)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN SHA2(CONCAT(RAND(), NOW(6), UUID()), 256);
END$$

-- Estado del usuario, con distribución ponderada: la mayoría "activo".
CREATE FUNCTION fn_estado_usuario_aleatorio()
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE v_num DECIMAL(5,2);
    SET v_num = RAND() * 100;
    RETURN CASE
        WHEN v_num < 80 THEN 'activo'
        WHEN v_num < 90 THEN 'inactivo'
        WHEN v_num < 96 THEN 'suspendida'
        ELSE 'eliminada'
    END;
END$$

-- Fecha aleatoria entre hoy y N días atrás.
CREATE FUNCTION fn_fecha_aleatoria_en_rango(p_dias_atras INT)
RETURNS DATE
DETERMINISTIC
BEGIN
    RETURN DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * p_dias_atras) DAY);
END$$

-- Hora aleatoria dentro del horario de servicio (08:00 a 21:00).
CREATE FUNCTION fn_hora_aleatoria()
RETURNS TIME
DETERMINISTIC
BEGIN
    RETURN SEC_TO_TIME(FLOOR(RAND() * (21 * 3600 - 8 * 3600)) + 8 * 3600);
END$$

DELIMITER ;


-- ============================================================================
-- 3) PROCEDIMIENTO: sp_llenar_usuarios_aleatorios
-- Genera p_cantidad usuarios con rol "Cliente" y datos aleatorios.
-- Requiere que la tabla Rol ya contenga el registro 'Cliente'.
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_llenar_usuarios_aleatorios;

DELIMITER $$

CREATE PROCEDURE sp_llenar_usuarios_aleatorios(IN p_cantidad INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_nombre VARCHAR(50);
    DECLARE v_apellido VARCHAR(50);
    DECLARE v_id_rol INT;

    SELECT id_rol INTO v_id_rol
    FROM Rol
    WHERE nombre_rol = 'Cliente'
    LIMIT 1;

    IF v_id_rol IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No existe el rol "Cliente" en la tabla Rol. Créelo antes de generar usuarios.';
    END IF;

    WHILE i < p_cantidad DO
        SET v_nombre = fn_nombre_aleatorio();
        SET v_apellido = fn_apellido_aleatorio();

        INSERT INTO Usuario (id_rol, nombre, apellido, correo, telefono, contrasena_hash, fecha_registro, estado)
        VALUES (
            v_id_rol,
            v_nombre,
            v_apellido,
            fn_correo_aleatorio(v_nombre, v_apellido),
            fn_telefono_aleatorio(),
            fn_password_hash_aleatorio(),
            TIMESTAMP(fn_fecha_aleatoria_en_rango(365), fn_hora_aleatoria()),
            fn_estado_usuario_aleatorio()
        );

        SET i = i + 1;
    END WHILE;

    SELECT CONCAT(p_cantidad, ' usuarios generados con rol Cliente.') AS resultado;
END$$

DELIMITER ;

-- Ejemplo de uso solicitado: 100 usuarios aleatorios.
-- CALL sp_llenar_usuarios_aleatorios(100);


-- ============================================================================
-- 4) FUNCIONES DE APOYO PARA EL FLUJO DE COMPRA/RESERVACIÓN
-- ============================================================================

DROP FUNCTION IF EXISTS fn_metodo_pago_aleatorio;
DROP FUNCTION IF EXISTS fn_estado_pedido_aleatorio;

DELIMITER $$

-- Método de pago aleatorio.
CREATE FUNCTION fn_metodo_pago_aleatorio()
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    RETURN ELT(1 + FLOOR(RAND() * 3), 'efectivo', 'tarjeta', 'transferencia');
END$$

-- Estado final del pedido, ponderado para que la mayoría se entregue.
CREATE FUNCTION fn_estado_pedido_aleatorio()
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE v_num DECIMAL(5,2);
    SET v_num = RAND() * 100;
    RETURN CASE
        WHEN v_num < 70 THEN 'entregado'
        WHEN v_num < 85 THEN 'listo'
        WHEN v_num < 95 THEN 'en preparación'
        ELSE 'cancelado'
    END;
END$$

DELIMITER ;


-- ============================================================================
-- 5) PROCEDIMIENTO: sp_simular_flujo_compra
-- Simula el flujo de negocio descrito en el documento (sección 3):
-- Usuario -> [Reservación de Mesa] -> Pedido (en el lugar o para llevar)
-- -> Detalle_pedido (1 a 4 productos) -> Pago que liquida el pedido.
-- Genera p_num_transacciones pedidos completos de punta a punta.
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_simular_flujo_compra;

DELIMITER $$

CREATE PROCEDURE sp_simular_flujo_compra(IN p_num_transacciones INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_id_usuario INT;
    DECLARE v_tipo_pedido VARCHAR(20);
    DECLARE v_con_reservacion BOOLEAN;
    DECLARE v_id_mesa INT;
    DECLARE v_id_reservacion INT;
    DECLARE v_id_pedido INT;
    DECLARE v_num_lineas INT;
    DECLARE j INT;
    DECLARE v_id_producto INT;
    DECLARE v_precio DECIMAL(8,2);
    DECLARE v_cantidad INT;
    DECLARE v_subtotal_linea DECIMAL(8,2);
    DECLARE v_subtotal_pedido DECIMAL(8,2);
    DECLARE v_impuestos DECIMAL(8,2);
    DECLARE v_total DECIMAL(8,2);
    DECLARE v_fecha DATE;
    DECLARE v_hora TIME;
    DECLARE v_estado_pedido VARCHAR(20);
    DECLARE v_fecha_hora_pedido DATETIME;

    sim_loop: WHILE i < p_num_transacciones DO

        -- Cliente aleatorio entre los usuarios con rol Cliente
        SET v_id_usuario = NULL;
        SELECT u.id_usuario INTO v_id_usuario
        FROM Usuario u
        INNER JOIN Rol r ON r.id_rol = u.id_rol
        WHERE r.nombre_rol = 'Cliente'
        ORDER BY RAND()
        LIMIT 1;

        IF v_id_usuario IS NULL THEN
            LEAVE sim_loop;   -- no hay clientes disponibles, se detiene la simulación
        END IF;

        SET v_fecha = fn_fecha_aleatoria_en_rango(90);
        SET v_hora  = fn_hora_aleatoria();
        SET v_fecha_hora_pedido = TIMESTAMP(v_fecha, v_hora);
        SET v_tipo_pedido = IF(RAND() < 0.65, 'en el lugar', 'para llevar');
        SET v_con_reservacion = (v_tipo_pedido = 'en el lugar' AND RAND() < 0.6);

        SET v_id_mesa = NULL;
        SET v_id_reservacion = NULL;

        -- Si el pedido es para consumir en el local, se asigna una mesa
        IF v_tipo_pedido = 'en el lugar' THEN
            SELECT id_mesa INTO v_id_mesa FROM Mesa ORDER BY RAND() LIMIT 1;
        END IF;

        -- Camino "reservación -> llegada -> pedido"
        IF v_con_reservacion AND v_id_mesa IS NOT NULL THEN
            INSERT INTO Reservacion (
                id_usuario, id_mesa, fecha_reservacion, hora_reservacion,
                numero_personas, estado_reservacion, fecha_creacion, hora_llegada
            )
            VALUES (
                v_id_usuario, v_id_mesa, v_fecha, v_hora,
                1 + FLOOR(RAND() * 5), 'completada',
                TIMESTAMP(v_fecha, v_hora) - INTERVAL (1 + FLOOR(RAND()*3)) DAY,
                ADDTIME(v_hora, SEC_TO_TIME(FLOOR(RAND() * 600)))
            );
            SET v_id_reservacion = LAST_INSERT_ID();
        END IF;

        -- Cabecera del pedido (los montos se recalculan tras insertar el detalle)
        INSERT INTO Pedido (
            id_usuario, id_mesa, id_reservacion, tipo_pedido, estado_pedido,
            fecha_pedido, hora_pedido, subtotal, impuestos, total
        )
        VALUES (
            v_id_usuario, v_id_mesa, v_id_reservacion, v_tipo_pedido, 'pendiente',
            v_fecha, v_hora, 0.00, 0.00, 0.00
        );
        SET v_id_pedido = LAST_INSERT_ID();

        -- Entre 1 y 4 renglones de producto por pedido
        SET v_num_lineas = 1 + FLOOR(RAND() * 4);
        SET v_subtotal_pedido = 0.00;
        SET j = 0;

        WHILE j < v_num_lineas DO
            SET v_id_producto = NULL;
            SELECT id_producto, precio INTO v_id_producto, v_precio
            FROM Producto
            WHERE disponible = TRUE
            ORDER BY RAND()
            LIMIT 1;

            IF v_id_producto IS NOT NULL THEN
                SET v_cantidad = 1 + FLOOR(RAND() * 3);
                SET v_subtotal_linea = v_precio * v_cantidad;

                INSERT INTO Detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario, subtotal_linea)
                VALUES (v_id_pedido, v_id_producto, v_cantidad, v_precio, v_subtotal_linea);

                SET v_subtotal_pedido = v_subtotal_pedido + v_subtotal_linea;
            END IF;

            SET j = j + 1;
        END WHILE;

        -- Cálculo de impuestos (IVA 16%) y total, y estado final del pedido
        SET v_impuestos = ROUND(v_subtotal_pedido * 0.16, 2);
        SET v_total = v_subtotal_pedido + v_impuestos;
        SET v_estado_pedido = fn_estado_pedido_aleatorio();

        UPDATE Pedido
        SET subtotal = v_subtotal_pedido,
            impuestos = v_impuestos,
            total = v_total,
            estado_pedido = v_estado_pedido,
            fecha_entrega = IF(v_estado_pedido = 'entregado',
                                v_fecha_hora_pedido + INTERVAL (10 + FLOOR(RAND() * 40)) MINUTE,
                                NULL)
        WHERE id_pedido = v_id_pedido;

        -- El pago solo se genera si el pedido no fue cancelado
        IF v_estado_pedido <> 'cancelado' THEN
            INSERT INTO Pago (id_pedido, monto, metodo_pago, fecha_pago, estado_pago)
            VALUES (
                v_id_pedido,
                v_total,
                fn_metodo_pago_aleatorio(),
                v_fecha_hora_pedido + INTERVAL FLOOR(RAND() * 30) MINUTE,
                'pagado'
            );
        END IF;

        SET i = i + 1;
    END WHILE sim_loop;

    SELECT CONCAT(i, ' transacciones de compra/reservación simuladas.') AS resultado;
END$$

DELIMITER ;

-- Ejemplo de uso: simular 200 transacciones completas.
-- CALL sp_simular_flujo_compra(200);


-- ============================================================================
-- ORDEN DE EJECUCIÓN SUGERIDO PARA LA SIMULACIÓN COMPLETA
-- ============================================================================
-- CALL sp_limpiar_datos_simulacion();
-- CALL sp_llenar_usuarios_aleatorios(100);
-- CALL sp_simular_flujo_compra(300);
-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
