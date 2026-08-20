"""
================================================================================
 GENERADOR DE DATASET DE VENTAS - CAFETERÍA CAFE-CEREZA
================================================================================
Genera un dataset sintético (CSV) que simula el histórico de ventas de la
cafetería, uniendo la información de usuario, pedido, detalle_pedido,
producto, mesa, reservación y pago, más columnas de análisis para medir el impacto 
del canal e-commerce frente al canal presencial.

El dataset se genera EN DOS VERSIONES:
  1. dataset_ventas_limpio.csv   -> datos "ideales", sin errores
  2. dataset_ventas_sucio.csv    -> mismos datos + errores insertados a propósito

Errores insertados a propósito
  - Valores nulos
  - Registros duplicados
  - Fechas con formatos distintos (texto libre, no un solo estándar)
  - Categorías mal escritas (typos, mayúsculas/minúsculas inconsistentes)
  - Valores fuera de rango (precios negativos, cantidades absurdas, etc.)
  - Datos atípicos (outliers estadísticos en montos)
  - Campos incompletos (strings vacíos, truncados, "N/A", etc.)
================================================================================
"""

import random
import numpy as np
import pandas as pd
from datetime import datetime, timedelta, date, time

# ------------------------------------------------------------------------
# CONFIGURACIÓN GENERAL
# ------------------------------------------------------------------------
SEED = 42
random.seed(SEED)
np.random.seed(SEED)

N_CLIENTES = 250          # cantidad de clientes (usuarios con rol Cliente)
N_PEDIDOS = 1500          # cantidad de pedidos/ventas a generar
FECHA_INICIO = date(2025, 1, 1)     # arranque del negocio
FECHA_LANZAMIENTO_WEB = date(2025, 7, 1)   # fecha en que se lanzó la página web
FECHA_FIN = date(2026, 8, 19)       # "hoy"

PORC_ERRORES = 0.12   # % aprox. de filas afectadas por cada tipo de error en la versión "sucia"

# ------------------------------------------------------------------------
# CATÁLOGOS (alineados al esquema de la base de datos)
# ------------------------------------------------------------------------

CATEGORIAS_PRODUCTO = {
    "Café caliente": ["Espresso", "Americano", "Capuchino", "Latte", "Café de olla", "Mocaccino"],
    "Café frío": ["Frappé de café", "Cold brew", "Café helado", "Frappuccino de caramelo"],
    "Repostería": ["Concha", "Croissant", "Muffin de arándano", "Pay de queso", "Brownie", "Dona glaseada"],
    "Alimentos": ["Sandwich club", "Bagel con queso crema", "Ensalada César", "Panini de jamón y queso"],
    "Bebidas frías": ["Té helado", "Limonada", "Agua mineral", "Refresco de cola", "Jugo de naranja"],
    "Bebidas calientes": ["Té chai", "Chocolate caliente", "Té verde", "Infusión de manzanilla"],
}

TIPO_CLIENTE = ["Nuevo", "Recurrente", "Frecuente", "VIP", "Inactivo"]
CANAL_VENTA = ["Página web", "Presencial (mostrador)", "Presencial (mesero)"]
TIPO_PEDIDO = ["para llevar", "en el lugar"]
ESTADO_PEDIDO = ["entregado", "listo", "en preparación", "cancelado"]
METODO_PAGO = ["efectivo", "tarjeta", "transferencia", "pago en línea"]
ESTADO_PAGO = ["pagado", "pendiente", "reembolsado"]
ESTADO_RESERVACION = ["completada", "cancelada", "no_show", "pendiente"]
UBICACION_MESA = ["Terraza", "Salón principal", "Zona de estudio", "Barra"]
TIPO_MESA = ["individual", "pareja", "grupal"]

NOMBRES = ["José", "Michelle", "Yuleni", "Carlos", "Ana", "Luis", "María", "Fernanda", "Jorge", "Paola",
           "Ricardo", "Daniela", "Emilio", "Valeria", "Diego", "Ximena", "Alejandro", "Renata", "Iván",
           "Camila", "Sergio", "Andrea", "Julián", "Mariana", "Adrián", "Sofía", "Raúl", "Karla", "Óscar",
           "Lucía", "Marco", "Regina", "Hugo", "Estefanía", "Pablo", "Gabriela"]
APELLIDOS = ["Hernández", "De la Cruz", "Martínez", "García", "López", "Pérez", "Sánchez", "Ramírez",
             "Torres", "Flores", "Gómez", "Díaz", "Reyes", "Morales", "Cruz", "Ortiz", "Jiménez",
             "Castillo", "Vázquez", "Romero"]

# ------------------------------------------------------------------------
# FUNCIONES AUXILIARES
# ------------------------------------------------------------------------

def fecha_aleatoria(inicio: date, fin: date) -> date:
    delta = (fin - inicio).days
    return inicio + timedelta(days=random.randint(0, max(delta, 0)))


def hora_aleatoria() -> time:
    # la cafetería opera de 7:00 a 21:00
    h = random.randint(7, 20)
    m = random.choice([0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55])
    return time(h, m)


def generar_clientes(n: int) -> pd.DataFrame:
    """Genera la tabla base de clientes (equivalente a `usuario` con rol Cliente)."""
    filas = []
    for i in range(1, n + 1):
        nombre = random.choice(NOMBRES)
        apellido = random.choice(APELLIDOS)
        correo = f"{nombre.lower()}.{apellido.lower().replace(' ', '')}{i}@correo.com"
        fecha_registro = fecha_aleatoria(FECHA_INICIO, FECHA_FIN)
        # el tipo de cliente se decide luego según su frecuencia de compra real,
        # pero aquí generamos una "etiqueta declarada" inicial (puede no coincidir,
        # eso también es realista)
        filas.append({
            "id_cliente": i,
            "nombre_cliente": f"{nombre} {apellido}",
            "correo": correo,
            "telefono": f"771{random.randint(1000000, 9999999)}",
            "fecha_registro": fecha_registro,
            "registrado_via_web": random.random() < 0.7 if fecha_registro >= FECHA_LANZAMIENTO_WEB else False,
        })
    return pd.DataFrame(filas)


def elegir_producto():
    categoria = random.choice(list(CATEGORIAS_PRODUCTO.keys()))
    producto = random.choice(CATEGORIAS_PRODUCTO[categoria])
    precio_base = {
        "Café caliente": (28, 55), "Café frío": (35, 65), "Repostería": (25, 60),
        "Alimentos": (45, 95), "Bebidas frías": (20, 40), "Bebidas calientes": (25, 45),
    }[categoria]
    precio = round(random.uniform(*precio_base), 2)
    return categoria, producto, precio


def clasificar_tipo_cliente(n_pedidos_cliente: int) -> str:
    if n_pedidos_cliente == 1:
        return "Nuevo"
    elif n_pedidos_cliente <= 3:
        return "Recurrente"
    elif n_pedidos_cliente <= 7:
        return "Frecuente"
    elif n_pedidos_cliente > 7:
        return "VIP"
    return "Inactivo"


# ------------------------------------------------------------------------
# 1) GENERAR CLIENTES
# ------------------------------------------------------------------------
clientes = generar_clientes(N_CLIENTES)

# contador de pedidos por cliente para luego derivar tipo_cliente y canal preferido
pedidos_por_cliente = {c: 0 for c in clientes["id_cliente"]}

# ------------------------------------------------------------------------
# 2) GENERAR VENTAS (una fila = un producto dentro de un pedido, ya "aplanado")
# ------------------------------------------------------------------------
registros = []
id_pedido_actual = 1000

for _ in range(N_PEDIDOS):
    id_pedido_actual += 1
    cliente = clientes.sample(1).iloc[0]
    id_cliente = cliente["id_cliente"]
    pedidos_por_cliente[id_cliente] += 1

    fecha_pedido = fecha_aleatoria(
        max(FECHA_INICIO, cliente["fecha_registro"]) if isinstance(cliente["fecha_registro"], date) else FECHA_INICIO,
        FECHA_FIN,
    )
    hora_pedido = hora_aleatoria()

    # Canal de venta: antes del lanzamiento de la web, todo es presencial.
    if fecha_pedido < FECHA_LANZAMIENTO_WEB:
        canal = random.choices(CANAL_VENTA[1:], weights=[0.55, 0.45])[0]
    else:
        # tras el lanzamiento, la web va ganando participación con el tiempo
        avance = min(1.0, (fecha_pedido - FECHA_LANZAMIENTO_WEB).days / 365)
        peso_web = 0.25 + 0.45 * avance   # de 25% hasta ~70%
        canal = random.choices(
            CANAL_VENTA,
            weights=[peso_web, (1 - peso_web) * 0.55, (1 - peso_web) * 0.45],
        )[0]

    tipo_pedido = random.choices(TIPO_PEDIDO, weights=[0.5, 0.5])[0]
    con_reservacion = tipo_pedido == "en el lugar" and random.random() < 0.5

    id_mesa = random.randint(1, 20) if tipo_pedido == "en el lugar" else None
    ubicacion_mesa = random.choice(UBICACION_MESA) if id_mesa else None
    tipo_mesa = random.choice(TIPO_MESA) if id_mesa else None

    estado_reservacion = None
    fecha_reservacion = None
    if con_reservacion:
        fecha_reservacion = fecha_pedido - timedelta(days=random.randint(0, 3))
        estado_reservacion = random.choices(
            ESTADO_RESERVACION, weights=[0.75, 0.10, 0.10, 0.05]
        )[0]

    estado_pedido = random.choices(ESTADO_PEDIDO, weights=[0.70, 0.15, 0.10, 0.05])[0]
    metodo_pago = (
        "pago en línea" if canal == "Página web" and random.random() < 0.85
        else random.choice(["efectivo", "tarjeta", "transferencia"])
    )
    estado_pago = "pagado" if estado_pedido != "cancelado" else random.choice(["pendiente", "reembolsado"])

    n_lineas = random.randint(1, 4)
    productos_pedido = [elegir_producto() for _ in range(n_lineas)]

    subtotal_pedido = 0
    lineas_tmp = []
    for categoria, producto, precio in productos_pedido:
        cantidad = random.randint(1, 3)
        subtotal_linea = round(precio * cantidad, 2)
        subtotal_pedido += subtotal_linea
        lineas_tmp.append((categoria, producto, precio, cantidad, subtotal_linea))

    impuestos = round(subtotal_pedido * 0.16, 2)
    total_pedido = round(subtotal_pedido + impuestos, 2)

    calificacion = None
    if estado_pedido == "entregado":
        calificacion = random.choices([5, 4, 3, 2, 1], weights=[0.45, 0.30, 0.15, 0.07, 0.03])[0]

    tiempo_entrega_min = (
        random.randint(8, 45) if estado_pedido in ("entregado", "listo") else None
    )

    for categoria, producto, precio_unitario, cantidad, subtotal_linea in lineas_tmp:
        registros.append({
            "id_venta": len(registros) + 1,
            "id_pedido": id_pedido_actual,
            "id_cliente": id_cliente,
            "nombre_cliente": cliente["nombre_cliente"],
            "correo_cliente": cliente["correo"],
            "fecha_registro_cliente": cliente["fecha_registro"],
            "canal_venta": canal,
            "categoria_producto": categoria,
            "producto": producto,
            "cantidad": cantidad,
            "precio_unitario": precio_unitario,
            "subtotal_linea": subtotal_linea,
            "tipo_pedido": tipo_pedido,
            "con_reservacion": con_reservacion,
            "id_mesa": id_mesa,
            "ubicacion_mesa": ubicacion_mesa,
            "tipo_mesa": tipo_mesa,
            "fecha_reservacion": fecha_reservacion,
            "estado_reservacion": estado_reservacion,
            "fecha_pedido": fecha_pedido,
            "hora_pedido": hora_pedido,
            "estado_pedido": estado_pedido,
            "metodo_pago": metodo_pago,
            "estado_pago": estado_pago,
            "subtotal_pedido": round(subtotal_pedido, 2),
            "impuestos": impuestos,
            "total_pedido": total_pedido,
            "tiempo_entrega_min": tiempo_entrega_min,
            "calificacion_servicio": calificacion,
            # se completa después de tener el conteo total de pedidos por cliente
            "_id_cliente_ref": id_cliente,
        })

df = pd.DataFrame(registros)

# ------------------------------------------------------------------------
# 3) DERIVAR "tipo_cliente" según la frecuencia real de pedidos
# ------------------------------------------------------------------------
df["tipo_cliente"] = df["_id_cliente_ref"].map(
    lambda c: clasificar_tipo_cliente(pedidos_por_cliente[c])
)
df.drop(columns=["_id_cliente_ref"], inplace=True)

# columna clave para el análisis de e-commerce: ¿la venta se originó en la web?
df["origen_ecommerce"] = df["canal_venta"] == "Página web"

# Guardamos una copia "limpia" antes de introducir errores
df_limpio = df.copy()

print(f"Dataset limpio generado: {len(df_limpio)} filas, {len(df_limpio.columns)} columnas")

# ==========================================================================
# 4) INTRODUCIR ERRORES A PROPÓSITO (para la versión "sucia")
# ==========================================================================
df_sucio = df.copy()
n = len(df_sucio)


def indices_aleatorios(frac):
    k = int(n * frac)
    return np.random.choice(df_sucio.index, size=k, replace=False)


# --- 4.1 VALORES NULOS -----------------------------------------------------
# Se insertan nulos aleatorios en varias columnas "opcionales" y algunas que
# no deberían tener nulos (para simular errores reales de captura)
columnas_para_nulos = ["correo_cliente", "telefono" if "telefono" in df_sucio else None,
                        "metodo_pago", "calificacion_servicio", "tiempo_entrega_min",
                        "ubicacion_mesa", "estado_reservacion", "precio_unitario"]
columnas_para_nulos = [c for c in columnas_para_nulos if c]

for col in columnas_para_nulos:
    idx = indices_aleatorios(PORC_ERRORES * 0.6)
    df_sucio.loc[idx, col] = np.nan

# --- 4.2 REGISTROS DUPLICADOS ----------------------------------------------
# Se duplican filas completas (algunos duplicados exactos, otro con pequeñas
# variaciones para simular doble captura)
idx_dup = np.random.choice(df_sucio.index, size=int(n * 0.05), replace=False)
duplicados = df_sucio.loc[idx_dup].copy()
duplicados["id_venta"] = duplicados["id_venta"]  # duplicado EXACTO (mismo id_venta -> inconsistencia)
df_sucio = pd.concat([df_sucio, duplicados], ignore_index=True)
n = len(df_sucio)

# --- 4.3 FECHAS CON FORMATOS DISTINTOS -------------------------------------
def formato_fecha_aleatorio(f):
    if pd.isna(f):
        return f
    if isinstance(f, str):
        return f
    formatos = [
        lambda d: d.strftime("%Y-%m-%d"),          # 2026-08-19
        lambda d: d.strftime("%d/%m/%Y"),           # 19/08/2026
        lambda d: d.strftime("%m-%d-%Y"),           # 08-19-2026
        lambda d: d.strftime("%d de %B de %Y"),     # 19 de August de 2026
        lambda d: d.strftime("%Y/%m/%d"),            # 2026/08/19
        lambda d: d.strftime("%d-%b-%y"),            # 19-Aug-26
    ]
    return random.choice(formatos)(f)

for col in ["fecha_pedido", "fecha_registro_cliente", "fecha_reservacion"]:
    idx = indices_aleatorios(PORC_ERRORES)
    df_sucio.loc[idx, col] = df_sucio.loc[idx, col].apply(formato_fecha_aleatorio)

# --- 4.4 CATEGORÍAS MAL ESCRITAS -------------------------------------------
def ensuciar_categoria(valor):
    variantes = {
        "Café caliente": ["cafe caliente", "Café Caliente ", "CAFE CALIENTE", "cafè caliente", "Cafe caliente"],
        "Café frío": ["cafe frio", "Café Frio", "CAFÉ FRÍO", "café  frío"],
        "Repostería": ["reposteria", "Reposteria ", "REPOSTERÍA", "Resposteria"],
        "Alimentos": ["alimentos ", "Alimento", "ALIMENTOS", "alimntos"],
        "Bebidas frías": ["bebidas frias", "Bebidas Frias", "BEBIDAS FRÍAS"],
        "Bebidas calientes": ["bebidas calientes ", "Bebidas Caliente", "BEBIDAS CALIENTES"],
    }
    opciones = variantes.get(valor, [valor])
    return random.choice(opciones)

idx = indices_aleatorios(PORC_ERRORES)
df_sucio.loc[idx, "categoria_producto"] = df_sucio.loc[idx, "categoria_producto"].apply(ensuciar_categoria)

# también ensuciamos ligeramente canal_venta y estado_pedido (typos comunes)
def ensuciar_texto_libre(valor, typos):
    return random.choice(typos.get(valor, [valor]))

typos_canal = {
    "Página web": ["pagina web", "PÁGINA WEB", "Pagina Web", "web", "Página Web "],
    "Presencial (mostrador)": ["presencial mostrador", "Presencial(mostrador)", "PRESENCIAL (MOSTRADOR)"],
    "Presencial (mesero)": ["presencial mesero", "Presencial(Mesero)", "presencial (mesero) "],
}
idx = indices_aleatorios(PORC_ERRORES * 0.5)
df_sucio.loc[idx, "canal_venta"] = df_sucio.loc[idx, "canal_venta"].apply(
    lambda v: ensuciar_texto_libre(v, typos_canal)
)

typos_estado = {
    "entregado": ["Entregado", "ENTREGADO", "entregao", "entregado "],
    "cancelado": ["Cancelado", "CANCELADO", "cancelaado"],
    "listo": ["Listo", "LISTO"],
    "en preparación": ["en preparacion", "En Preparación", "EN PREPARACIÓN"],
}
idx = indices_aleatorios(PORC_ERRORES * 0.5)
df_sucio.loc[idx, "estado_pedido"] = df_sucio.loc[idx, "estado_pedido"].apply(
    lambda v: ensuciar_texto_libre(v, typos_estado)
)

# --- 4.5 VALORES FUERA DE RANGO --------------------------------------------
# precios negativos, cantidades absurdas, calificaciones fuera de 1-5, horas inválidas
idx = indices_aleatorios(PORC_ERRORES * 0.4)
df_sucio.loc[idx, "precio_unitario"] = df_sucio.loc[idx, "precio_unitario"].apply(
    lambda p: -abs(p) if pd.notna(p) else p  # precio negativo
)

idx = indices_aleatorios(PORC_ERRORES * 0.3)
df_sucio.loc[idx, "cantidad"] = [random.choice([0, -1, 999, 500]) for _ in idx]

idx = indices_aleatorios(PORC_ERRORES * 0.3)
df_sucio.loc[idx, "calificacion_servicio"] = [random.choice([0, 6, 8, -2, 10]) for _ in idx]

idx = indices_aleatorios(PORC_ERRORES * 0.2)
df_sucio.loc[idx, "tiempo_entrega_min"] = [random.choice([-15, 0, 500, 720]) for _ in idx]

# --- 4.6 DATOS ATÍPICOS (OUTLIERS) ------------------------------------------
# montos absurdamente altos comparados con el resto de la distribución
idx = indices_aleatorios(0.02)
df_sucio.loc[idx, "total_pedido"] = df_sucio.loc[idx, "total_pedido"] * random.uniform(20, 60)
df_sucio.loc[idx, "subtotal_pedido"] = df_sucio.loc[idx, "subtotal_pedido"] * random.uniform(20, 60)

# un puñado de "ventas fantasma" con total en 0 pero estado entregado
idx = indices_aleatorios(0.01)
df_sucio.loc[idx, "total_pedido"] = 0
df_sucio.loc[idx, "subtotal_pedido"] = 0

# --- 4.7 CAMPOS INCOMPLETOS -------------------------------------------------
# strings vacíos, "N/A", truncados, espacios en blanco
valores_incompletos = ["", " ", "N/A", "n/a", "NA", "-", "sin dato", "???"]

for col in ["nombre_cliente", "correo_cliente", "producto", "ubicacion_mesa"]:
    idx = indices_aleatorios(PORC_ERRORES * 0.35)
    df_sucio.loc[idx, col] = [random.choice(valores_incompletos) for _ in idx]

# nombres truncados a la mitad (error típico de captura / longitud de campo)
idx = indices_aleatorios(PORC_ERRORES * 0.15)
df_sucio.loc[idx, "nombre_cliente"] = df_sucio.loc[idx, "nombre_cliente"].apply(
    lambda x: x[:max(2, len(x) // 2)] if isinstance(x, str) and len(x) > 3 else x
)

# --- 4.8 booleanos representados de formas inconsistentes -------------------
df_sucio["con_reservacion"] = df_sucio["con_reservacion"].astype(object)
idx = indices_aleatorios(PORC_ERRORES * 0.4)
df_sucio.loc[idx, "con_reservacion"] = df_sucio.loc[idx, "con_reservacion"].apply(
    lambda v: random.choice(["Sí", "1", "True", "true", "S"]) if v else random.choice(["No", "0", "False", "false", "N"])
)

# desordenamos las filas para que no se note el patrón de inserción de errores
df_sucio = df_sucio.sample(frac=1, random_state=SEED).reset_index(drop=True)

print(f"Dataset sucio generado: {len(df_sucio)} filas, {len(df_sucio.columns)} columnas")
print(f"  (incluye ~{len(df_sucio) - len(df_limpio)} filas extra por duplicados)")

# ==========================================================================
# 5) GUARDAR ARCHIVOS
# ==========================================================================
RUTA_LIMPIO = "C:/230535 - Jose de Jesus/dataset_ventas_limpio.csv"
RUTA_SUCIO = "C:/230535 - Jose de Jesus/dataset_ventas_sucio.csv"

df_limpio.to_csv(RUTA_LIMPIO, index=False, encoding="utf-8-sig")
df_sucio.to_csv(RUTA_SUCIO, index=False, encoding="utf-8-sig")

print("\nArchivos generados:")
print(f"  - {RUTA_LIMPIO}")
print(f"  - {RUTA_SUCIO}")

# ==========================================================================
# 6) RESUMEN RÁPIDO PARA VALIDAR EL IMPACTO DEL E-COMMERCE
# ==========================================================================
# Nos quedamos con una fila por pedido (evita contar de más por tener varias
# líneas de producto dentro del mismo pedido) y calculamos ventas reales
# sumando el subtotal de línea (no el total_pedido repetido por cada línea).
pedidos_unicos = df_limpio.drop_duplicates(subset="id_pedido").copy()
ventas_por_pedido = df_limpio.groupby("id_pedido")["subtotal_linea"].sum()
pedidos_unicos["mes"] = pedidos_unicos["fecha_pedido"].apply(lambda d: d.strftime("%Y-%m"))

resumen = (
    pedidos_unicos.groupby("mes")
    .agg(num_pedidos=("id_pedido", "nunique"),
         pedidos_web=("origen_ecommerce", "sum"))
    .reset_index()
)
resumen["ventas_totales"] = resumen["mes"].map(
    df_limpio.assign(mes=df_limpio["fecha_pedido"].apply(lambda d: d.strftime("%Y-%m")))
    .drop_duplicates(subset="id_pedido").groupby("mes")["total_pedido"].sum()
)
resumen["pct_pedidos_web"] = (resumen["pedidos_web"] / resumen["num_pedidos"] * 100).round(1)
resumen = resumen[["mes", "ventas_totales", "num_pedidos", "pedidos_web", "pct_pedidos_web"]]

print("\nResumen mensual (dataset limpio) — participación del canal web:")
print(resumen.to_string(index=False))
