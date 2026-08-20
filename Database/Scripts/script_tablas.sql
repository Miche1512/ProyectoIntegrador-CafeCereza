-- ============================================================================
-- BASE DE DATOS: CAFETERÍA (catálogo, reservaciones y pedidos)
-- Motor objetivo: MySQL 8.0 / MariaDB 10.x
-- Orden de creación: de entidades fuertes (sin dependencias) a débiles (con FK)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS cafeteria_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE cafeteria_db;

-- ============================================================================
-- 1. TABLA: Rol   (Entidad fuerte - sin dependencias)
-- ============================================================================
CREATE TABLE Rol (
    id_rol       INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol   VARCHAR(30)  NOT NULL,
    descripcion  VARCHAR(150) NULL,
    CONSTRAINT uq_rol_nombre UNIQUE (nombre_rol)
) ENGINE=InnoDB;

-- ============================================================================
-- 2. TABLA: Usuario   (Entidad débil - depende de Rol)
-- ============================================================================
CREATE TABLE Usuario (
    id_usuario       INT AUTO_INCREMENT PRIMARY KEY,
    id_rol           INT NOT NULL,
    nombre           VARCHAR(50)  NOT NULL,
    apellido         VARCHAR(50)  NOT NULL,
    correo           VARCHAR(100) NOT NULL,
    telefono         VARCHAR(15)  NULL,
    contrasena_hash  VARCHAR(255) NOT NULL,
    fecha_registro   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado           VARCHAR(50)  NOT NULL DEFAULT 'activo',
    CONSTRAINT uq_usuario_correo UNIQUE (correo),
    CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol)
        REFERENCES Rol (id_rol)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ============================================================================
-- 3. TABLA: Mesa   (Entidad fuerte - sin dependencias)
-- ============================================================================
CREATE TABLE Mesa (
    id_mesa       INT AUTO_INCREMENT PRIMARY KEY,
    numero_mesa   INT         NOT NULL,
    capacidad     INT         NOT NULL,
    ubicacion     VARCHAR(50) NULL,
    estado_mesa   VARCHAR(20) NOT NULL DEFAULT 'disponible',
    tipo_mesa     VARCHAR(20) NULL,
    CONSTRAINT uq_mesa_numero UNIQUE (numero_mesa)
) ENGINE=InnoDB;

-- ============================================================================
-- 4. TABLA: Categoria_producto   (Entidad fuerte - sin dependencias)
-- ============================================================================
CREATE TABLE Categoria_producto (
    id_categoria      INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria  VARCHAR(50)  NOT NULL,
    descripcion       VARCHAR(150) NULL
) ENGINE=InnoDB;

-- ============================================================================
-- 5. TABLA: Bitacora   (Depende de Usuario; se crea antes que las tablas
--    "críticas" para poder definir los triggers de auditoría sobre ellas)
-- ============================================================================
CREATE TABLE Bitacora (
    id_bitacora           INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario            INT NOT NULL,
    tabla_afectada        VARCHAR(50)  NOT NULL,
    id_registro_afectado  INT NOT NULL,
    tipo_operacion        VARCHAR(10)  NOT NULL,
    fecha_hora            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    descripcion           VARCHAR(255) NULL,
    CONSTRAINT fk_bitacora_usuario FOREIGN KEY (id_usuario)
        REFERENCES Usuario (id_usuario)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_bitacora_operacion CHECK (tipo_operacion IN ('INSERT','UPDATE','DELETE'))
) ENGINE=InnoDB;

-- ============================================================================
-- 6. TABLA: Producto   (Entidad débil - depende de Categoria_producto)
-- ============================================================================
CREATE TABLE Producto (
    id_producto      INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria     INT NOT NULL,
    nombre_producto  VARCHAR(80)   NOT NULL,
    descripcion      VARCHAR(250)  NULL,
    precio           DECIMAL(8,2)  NOT NULL,
    imagen_url       VARCHAR(255)  NULL,
    disponible       BOOLEAN       NOT NULL DEFAULT TRUE,
    stock            INT           NOT NULL DEFAULT 0,
    CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria)
        REFERENCES Categoria_producto (id_categoria)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ============================================================================
-- 7. TABLA: Reservacion   (Entidad débil - depende de Usuario y Mesa)
-- ============================================================================
CREATE TABLE Reservacion (
    id_reservacion       INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario           INT  NOT NULL,
    id_mesa              INT  NOT NULL,
    fecha_reservacion    DATE NOT NULL,
    hora_reservacion     TIME NOT NULL,
    numero_personas      INT  NOT NULL,
    estado_reservacion   VARCHAR(20) NOT NULL DEFAULT 'pendiente',
    fecha_creacion       DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hora_llegada         TIME    NULL,
    observaciones        VARCHAR(200) NULL,
    CONSTRAINT fk_reservacion_usuario FOREIGN KEY (id_usuario)
        REFERENCES Usuario (id_usuario)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_reservacion_mesa FOREIGN KEY (id_mesa)
        REFERENCES Mesa (id_mesa)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ============================================================================
-- 8. TABLA: Pedido   (Entidad débil - depende de Usuario, Mesa y Reservacion)
-- ============================================================================
CREATE TABLE Pedido (
    id_pedido        INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario       INT NOT NULL,
    id_mesa          INT NULL,
    id_reservacion   INT NULL,
    tipo_pedido      VARCHAR(20) NOT NULL,
    estado_pedido    VARCHAR(20) NOT NULL DEFAULT 'pendiente',
    fecha_pedido     DATE NOT NULL,
    hora_pedido      TIME NOT NULL,
    subtotal         DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    impuestos        DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    total            DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    fecha_entrega    DATETIME NULL,
    CONSTRAINT fk_pedido_usuario FOREIGN KEY (id_usuario)
        REFERENCES Usuario (id_usuario)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_pedido_mesa FOREIGN KEY (id_mesa)
        REFERENCES Mesa (id_mesa)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_pedido_reservacion FOREIGN KEY (id_reservacion)
        REFERENCES Reservacion (id_reservacion)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================================
-- 9. TABLA: Detalle_pedido   (Entidad débil - depende de Pedido y Producto)
-- ============================================================================
CREATE TABLE Detalle_pedido (
    id_detalle       INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido        INT NOT NULL,
    id_producto      INT NOT NULL,
    cantidad         INT NOT NULL,
    precio_unitario  DECIMAL(8,2) NOT NULL,
    subtotal_linea   DECIMAL(8,2) NOT NULL,
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido)
        REFERENCES Pedido (id_pedido)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto)
        REFERENCES Producto (id_producto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ============================================================================
-- 10. TABLA: Pago   (Entidad débil - depende de Pedido)
-- ============================================================================
CREATE TABLE Pago (
    id_pago       INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido     INT NOT NULL,
    monto         DECIMAL(8,2) NOT NULL,
    metodo_pago   VARCHAR(20) NOT NULL,
    fecha_pago    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_pago   VARCHAR(20) NOT NULL DEFAULT 'pendiente',
    CONSTRAINT fk_pago_pedido FOREIGN KEY (id_pedido)
        REFERENCES Pedido (id_pedido)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;