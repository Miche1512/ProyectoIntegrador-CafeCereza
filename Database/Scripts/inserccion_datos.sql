-- Fijamos el usuario actual para la bitácora (Admin Principal)
SET @usuario_actual = 1;
INSERT INTO usuario VALUES 
    -- Contraseña de Chuy: 230535
    (default, 1, 'José de Jesús', 'Hernández', '230535@utxicotepec.edu.mx', '7761263203', '$2b$12$04y3kI34q2iH155rE96a0O6eS9f/93J2L2s4u1E0M6A3K5M7N9O1P', default, 'activo'),
    -- Contraseña de Mich: 230091
    (default, 1, 'Michelle', 'De la Cruz', '230091@utxicotepec.edu.mx', '7461176213', '$2b$12$K19o8Z7q6X5c4V3b2N1m0e4P7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1', default, 'activo'),
    -- Contraseña de Yule: 230145
    (default, 1, 'Yuleni', 'Martinez', '230145@utxicotepec.edu.mx', '2227951947', '$2b$12$R0e1P2o3S4a5N6c7H8e9z0U1V2W3X4Y5Z6A7B8C9D0E1F2G3H4I5J', default, 'activo'),
    -- Contraseña de Cafeteria: Cafe-Cereza
    (default, 1, 'Cafetería', 'Cafe-Cereza', 'cafe-cereza.admin@cafeteria.com', '5556543210', '$2b$12$C1a2F3e4C5e6R7e8Z9a0b1C2D3E4F5G6H7I8J9K0L1M2N3O4P5Q6R', default, 'activo');
USE `cafeteria_db`;
INSERT INTO `categoria_producto` (`id_categoria`, `nombre_categoria`, `descripcion`) VALUES
(1, 'Bebidas Calientes', 'Cafés e infusiones calientes para acompañar tus momentos.'),
(2, 'Frappés', 'Bebidas frías y frapeadas, ideales para el calor.'),
(3, 'Malteadas', 'Cremosas malteadas elaboradas a base de helado.'),
(4, 'Otras Bebidas', 'Sodas italianas, refrescos y agua embotellada.'),
(5, 'Desayunos', 'Platillos completos para iniciar el día.'),
(6, 'Entre Panes', 'Sandwiches, bagels, tortas y opciones calientes.'),
(7, 'Clásicos y Antojos', 'Chilaquiles, enchiladas, empanadas y más.'),
(8, 'Postres', 'Waffles, crepas, muffins y galletas.');
INSERT INTO `producto` (`id_categoria`, `nombre_producto`, `descripcion`, `precio`, `disponible`, `stock`) VALUES
-- Categoría 1: Bebidas Calientes
(1, 'Espresso Mediano', 'Shot de café', 40.00, 1, 50),
(1, 'Espresso Grande', 'Shot de café', 50.00, 1, 50),
(1, 'Capuchino Mediano', 'Shot de café, leche y espuma', 40.00, 1, 50),
(1, 'Capuchino Grande', 'Shot de café, leche y espuma', 50.00, 1, 50),
(1, 'Latte Mediano', 'Shot de café + leche', 40.00, 1, 50),
(1, 'Latte Grande', 'Shot de café + leche', 50.00, 1, 50),
(1, 'Moka Mediano', 'Shot de café + leche y chocolate', 40.00, 1, 50),
(1, 'Moka Grande', 'Shot de café + leche y chocolate', 50.00, 1, 50),
(1, 'Tisana', 'Infusión frutal', 50.00, 1, 50),
(1, 'Taro Mediano', 'Cremoso, suave y adictivo', 40.00, 1, 50),
(1, 'Taro Grande', 'Cremoso, suave y adictivo', 50.00, 1, 50),
(1, 'Matcha Mediano', 'Notas herbales', 40.00, 1, 50),
(1, 'Matcha Grande', 'Notas herbales', 50.00, 1, 50),
-- Categoría 2: Frappés
(2, 'Frappé Capuchino', 'Refrescante bebida frapeada sabor capuchino', 50.00, 1, 50),
(2, 'Frappé Moka', 'Bebida frapeada sabor chocolate con café', 50.00, 1, 50),
(2, 'Frappé Taro', 'Bebida frapeada cremoso taro', 50.00, 1, 50),
(2, 'Frappé Chocolate', 'Bebida frapeada sabor chocolate', 50.00, 1, 50),
(2, 'Frappé Mazapán', 'Bebida frapeada de mazapán', 50.00, 1, 50),
(2, 'Frappé Oreo', 'Bebida frapeada con galleta Oreo', 50.00, 1, 50),
(2, 'Frappé Gansito', 'Bebida frapeada sabor gansito', 50.00, 1, 50),
-- Categoría 3: Malteadas
(3, 'Malteada Chocolate', 'Cremosa malteada de chocolate hecha con helado', 50.00, 1, 50),
(3, 'Malteada Fresa', 'Cremosa malteada de fresa hecha con helado', 50.00, 1, 50),
(3, 'Malteada Vainilla', 'Cremosa malteada de vainilla hecha con helado', 50.00, 1, 50),
(3, 'Malteada Oreo', 'Cremosa malteada de galleta Oreo hecha con helado', 50.00, 1, 50),
-- Categoría 4: Otras Bebidas
(4, 'Agua Embotellada', 'Agua embotellada de 500ml', 15.00, 1, 100),
(4, 'Soda Italiana', 'Soda refrescante con sabor frutal', 50.00, 1, 50),
(4, 'Coca Cola', 'Refresco de cola refrescante', 25.00, 1, 100),
-- Categoría 5: Desayunos
(5, 'Desayuno Dulce', 'Hot cakes esponjosos, fruta fresca de temporada y café recién hecho', 50.00, 1, 30),
(5, 'Desayuno Clásico', 'Huevos preparados a tu elección, café caliente y un toque dulce', 50.00, 1, 30),
-- Categoría 6: Entre Panes
(6, 'Bagel Hawaiano', 'Pan con queso parmesano, jamón de pierna, piña, queso gratinado y papas', 60.00, 1, 30),
(6, 'Bagel Pizza', 'Pan con queso parmesano, pepperoni, mucho queso y papas', 60.00, 1, 30),
(6, 'Club Sandwich', 'Pollo, jamón, queso. Acompañado de papas', 60.00, 1, 30),
(6, 'Torta de Pollo en Chiltepín', 'Con verduras frescas, aderezos y queso gratinado', 40.00, 1, 30),
(6, 'Torta de Salchicha', 'Con verduras frescas, aderezos y queso gratinado', 35.00, 1, 30),
(6, 'Hot Dog', 'Salchicha envuelta en tocino y queso', 30.00, 1, 40),
(6, 'Sincronizadas', 'Sincronizadas de queso con jamón', 35.00, 1, 40),
-- Categoría 7: Clásicos y Antojos
(7, 'Chilaquiles Sencillos', 'Chilaquiles crujientes con salsa tradicionales', 35.00, 1, 40),
(7, 'Chilaquiles con Huevo al Gusto', 'Chilaquiles acompañados con huevo preparado al gusto', 45.00, 1, 40),
(7, 'Chilaquiles Suizos', 'Chilaquiles bañados en salsa suiza gratinados', 45.00, 1, 40),
(7, 'Chilaquiles Clásicos con Pollo', 'Chilaquiles con pollo deshebrado', 45.00, 1, 40),
(7, 'Enchiladas Clásicas', 'Enchiladas tradicionales', 45.00, 1, 40),
(7, 'Enchiladas Suizas', 'Enchiladas gratinadas con salsa suiza', 40.00, 1, 40),
(7, 'Empanadas de Queso o Pollo', 'Empanadas crujientes rellenas de queso o pollo', 50.00, 1, 40),
-- Categoría 8: Postres
(8, 'Waffles', 'Deliciosos waffles recién hechos', 45.00, 1, 30),
(8, 'Crepas', 'Crepas dulces a elegir (Nutella/Fresa, Nutella/Nuez, Cajeta, etc.)', 60.00, 1, 30),
(8, 'Muffin de Chocolate', 'Muffin esponjoso de chocolate', 30.00, 1, 30),
(8, 'Galletas', 'Galletas tradicionales', 15.00, 1, 50);
INSERT INTO `mesa` (`numero_mesa`, `capacidad`, `ubicacion`, `estado_mesa`, `tipo_mesa`) VALUES
-- 6 Mesas Sencillas (4 personas)
(1, 4, 'Interior', 'disponible', 'Sencilla'),
(2, 4, 'Interior', 'disponible', 'Sencilla'),
(3, 4, 'Interior', 'disponible', 'Sencilla'),
(4, 4, 'Exterior', 'disponible', 'Sencilla'),
(5, 4, 'Exterior', 'disponible', 'Sencilla'),
(6, 4, 'Exterior', 'disponible', 'Sencilla'),
-- 4 Mesas Dobles (8 personas)
(7, 8, 'Interior', 'disponible', 'Doble'),
(8, 8, 'Interior', 'disponible', 'Doble'),
(9, 8, 'Exterior', 'disponible', 'Doble'),
(10, 8, 'Exterior', 'disponible', 'Doble');