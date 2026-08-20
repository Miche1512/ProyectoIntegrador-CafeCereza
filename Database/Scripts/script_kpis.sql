-- -----------------------------------------------------------------------------
-- KPI 1: Ingresos Totales en Tiempo Real (Día Actual)
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_kpi1_ingresos_hoy;

CREATE VIEW vw_kpi1_ingresos_hoy AS
SELECT 
    CURDATE() AS fecha,
    COALESCE(SUM(p.monto), 0) AS ingresos_totales_hoy,
    COUNT(DISTINCT ped.id_pedido) AS total_pedidos_pagados
FROM pago p
INNER JOIN pedido ped ON p.id_pedido = ped.id_pedido
WHERE ped.fecha_pedido = CURDATE() 
  AND p.estado_pago = 'completado';


-- -----------------------------------------------------------------------------
-- KPI 2: Volumen de Pedidos Activos por Estado (Cocina/Barra)
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_kpi2_pedidos_activos;

CREATE VIEW vw_kpi2_pedidos_activos AS
SELECT 
    estado_pedido,
    COUNT(*) AS cantidad_pedidos,
    MIN(hora_pedido) AS pedido_mas_antiguo
FROM pedido
WHERE fecha_pedido = CURDATE() 
  AND estado_pedido IN ('pendiente', 'en preparación', 'listo')
GROUP BY estado_pedido;


-- -----------------------------------------------------------------------------
-- KPI 3: Porcentaje de Ocupación de Mesas en Sala
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_kpi3_ocupacion_mesas;

CREATE VIEW vw_kpi3_ocupacion_mesas AS
SELECT 
    COUNT(*) AS total_mesas,
    COUNT(CASE WHEN estado_mesa = 'ocupada' THEN 1 END) AS mesas_ocupadas,
    COUNT(CASE WHEN estado_mesa = 'disponible' THEN 1 END) AS mesas_disponibles,
    ROUND(
        (COUNT(CASE WHEN estado_mesa = 'ocupada' THEN 1 END) * 100.0) / NULLIF(COUNT(*), 0), 2
    ) AS porcentaje_ocupacion
FROM mesa;


-- -----------------------------------------------------------------------------
-- KPI 4: Ticket Promedio por Pedido (AOV)
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_kpi4_ticket_promedio;

CREATE VIEW vw_kpi4_ticket_promedio AS
SELECT 
    CURDATE() AS fecha,
    COALESCE(AVG(total), 0) AS ticket_promedio,
    MIN(total) AS ticket_minimo,
    MAX(total) AS ticket_maximo
FROM pedido
WHERE fecha_pedido = CURDATE() 
  AND estado_pedido != 'cancelado';


-- -----------------------------------------------------------------------------
-- KPI 5: Productos Críticos con Stock Bajo
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_kpi5_stock_critico;

CREATE VIEW vw_kpi5_stock_critico AS
SELECT 
    id_producto,
    nombre_producto,
    precio,
    stock,
    disponible
FROM producto
WHERE disponible = 1 
  AND stock <= 5
ORDER BY stock ASC;


-- -----------------------------------------------------------------------------
-- KPI 6: Tasa de Cancelación de Pedidos
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_kpi6_tasa_cancelacion;

CREATE VIEW vw_kpi6_tasa_cancelacion AS
SELECT 
    CURDATE() AS fecha,
    COUNT(*) AS total_pedidos_generados,
    COUNT(CASE WHEN estado_pedido = 'cancelado' THEN 1 END) AS pedidos_cancelados,
    ROUND(
        (COUNT(CASE WHEN estado_pedido = 'cancelado' THEN 1 END) * 100.0) / NULLIF(COUNT(*), 0), 2
    ) AS tasa_cancelacion_pct
FROM pedido
WHERE fecha_pedido = CURDATE();


-- -----------------------------------------------------------------------------
-- KPI 7: Top 5 Productos Más Vendidos del Día
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_kpi7_top5_productos_hoy;

CREATE VIEW vw_kpi7_top5_productos_hoy AS
SELECT 
    p.id_producto,
    p.nombre_producto,
    SUM(dp.cantidad) AS unidades_vendidas,
    SUM(dp.subtotal_linea) AS ingreso_generado
FROM detalle_pedido dp
INNER JOIN pedido ped ON dp.id_pedido = ped.id_pedido
INNER JOIN producto p ON dp.id_producto = p.id_producto
WHERE ped.fecha_pedido = CURDATE() 
  AND ped.estado_pedido != 'cancelado'
GROUP BY p.id_producto, p.nombre_producto
ORDER BY unidades_vendidas DESC
LIMIT 5;


-- -----------------------------------------------------------------------------
-- KPI 8: Reservaciones Pendientes de Arribo Hoy
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_kpi8_reservaciones_pendientes_hoy;

CREATE VIEW vw_kpi8_reservaciones_pendientes_hoy AS
SELECT 
    id_reservacion,
    id_usuario,
    id_mesa,
    hora_reservacion,
    numero_personas,
    estado_reservacion
FROM reservacion
WHERE fecha_reservacion = CURDATE() 
  AND estado_reservacion = 'confirmada' 
  AND hora_llegada IS NULL
ORDER BY hora_reservacion ASC;


-- -----------------------------------------------------------------------------
-- KPI 9: Distribución por Métodos de Pago
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_kpi9_distribucion_metodos_pago;

CREATE VIEW vw_kpi9_distribucion_metodos_pago AS
SELECT 
    p.metodo_pago,
    COUNT(p.id_pago) AS cantidad_transacciones,
    SUM(p.monto) AS total_recaudado,
    ROUND(
        (SUM(p.monto) * 100.0) / NULLIF((
            SELECT SUM(p2.monto) 
            FROM pago p2 
            INNER JOIN pedido ped2 ON p2.id_pedido = ped2.id_pedido 
            WHERE ped2.fecha_pedido = CURDATE() AND p2.estado_pago = 'completado'
        ), 0), 2
    ) AS porcentaje_del_total
FROM pago p
INNER JOIN pedido ped ON p.id_pedido = ped.id_pedido
WHERE ped.fecha_pedido = CURDATE() 
  AND p.estado_pago = 'completado'
GROUP BY p.metodo_pago;


-- -----------------------------------------------------------------------------
-- KPI 10: Actividad Reciente del Sistema (Audit Log)
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_kpi10_actividad_reciente;

CREATE VIEW vw_kpi10_actividad_reciente AS
SELECT 
    b.id_bitacora,
    b.fecha_hora,
    u.nombre AS usuario,
    u.id_rol,
    b.tabla_afectada,
    b.tipo_operacion,
    b.descripcion
FROM bitacora b
LEFT JOIN usuario u ON b.id_usuario = u.id_usuario
ORDER BY b.fecha_hora DESC
LIMIT 10;