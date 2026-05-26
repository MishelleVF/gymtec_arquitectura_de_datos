# Pipeline SILVER → GOLD

## Objetivo

Este proceso transforma los logs limpios de la capa SILVER en una tabla GOLD agregada por fecha y hora, lista para análisis y modelamiento predictivo del aforo del gimnasio.

La tabla GOLD permite resumir los eventos individuales de ingreso y salida en variables útiles para el modelo baseline de predicción de aforo.

---

## Flujo de datos

```text
gymtec_raw.raw_logs_gimnasio
        ↓
gymtec_silver.silver_logs_gimnasio
        ↓
gymtec_gold.gold_aforo_horario_modelo
```

---

## Tabla fuente

```text
Proyecto: gymtec-dpd-mvp
Dataset: gymtec_silver
Tabla: silver_logs_gimnasio
```

La tabla SILVER contiene los eventos limpios de ingreso y salida del gimnasio.

Columnas principales utilizadas:

- `fecha`
- `hora`
- `timestamp_evento`
- `accion`
- `senal_movimiento`
- `hora_num`
- `dia_semana_num`
- `dia_semana_nombre`
- `mes`
- `semana_anio`
- `bloque_horario`
- `es_fin_de_semana`
- `ocupacion_acumulada`
- `flag_calidad`

---

## Tabla destino

```text
Proyecto: gymtec-dpd-mvp
Dataset: gymtec_gold
Tabla: gold_aforo_horario_modelo
```

La tabla GOLD tiene granularidad por:

```text
fecha_date + hora_num
```

Es decir, cada fila representa el comportamiento del gimnasio en una fecha y hora específica.

---

## Columnas generadas en GOLD

| Columna | Tipo | Descripción |
|---|---|---|
| `fecha_date` | DATE | Fecha del bloque horario. |
| `hora_num` | INTEGER | Hora del día en formato numérico. |
| `ocupacion_max` | INTEGER | Ocupación máxima registrada durante esa hora. |
| `ocupacion_media` | FLOAT | Ocupación promedio durante esa hora. |
| `n_ingresos` | INTEGER | Cantidad de ingresos registrados en esa hora. |
| `dia_semana` | INTEGER | Día de la semana codificado numéricamente. Lunes = 0. |
| `dia_nombre` | STRING | Nombre del día de la semana. |
| `es_fin_de_semana` | INTEGER | Indicador binario. 1 si es fin de semana, 0 si no. |
| `mes` | INTEGER | Mes del registro. |
| `bloque_horario` | STRING | Bloque del día: Mañana, Tarde o Noche. |
| `timestamp_procesamiento` | TIMESTAMP | Fecha y hora en la que se ejecutó el procesamiento. |

---

## Particionado y clustering

La tabla GOLD se crea particionada por:

```text
fecha_date
```

Y agrupada mediante clustering por:

```text
hora_num, dia_semana
```

Esto permite organizar mejor los datos y facilitar consultas por fecha, hora y día de la semana.

---

## Script de creación

El script principal se encuentra en:

```text
pipelines/bigquery/silver_to_gold/create_gold_aforo_horario_modelo.sql
```

Este script crea o reemplaza la tabla:

```text
gymtec_gold.gold_aforo_horario_modelo
```

El script toma como fuente la tabla:

```text
gymtec_silver.silver_logs_gimnasio
```

y genera una tabla agregada por fecha y hora.

---

## Script de validación

El script de validación se encuentra en:

```text
pipelines/bigquery/silver_to_gold/validate_gold_aforo_horario_modelo.sql
```

Este archivo contiene consultas para validar:

- Resumen general de la tabla GOLD.
- Duplicados por fecha y hora.
- Nulos en columnas críticas.
- Valores negativos.
- Horas fuera de rango.
- Vista ordenada de los registros finales.

---

## Transformaciones principales

Durante el proceso SILVER → GOLD se realizan las siguientes transformaciones:

1. Se filtran únicamente eventos válidos desde SILVER usando `flag_calidad = 'valido'`.
2. Se transforma la hora en una variable numérica entera usando `hora_num`.
3. Se agrupan los registros por `fecha_date` y `hora_num`.
4. Se calcula la ocupación máxima por hora mediante `MAX(ocupacion_acumulada)`.
5. Se calcula la ocupación promedio por hora mediante `AVG(ocupacion_acumulada)`.
6. Se calcula el número de ingresos por hora mediante `COUNTIF(accion = 'ingreso')`.
7. Se generan variables temporales como día de semana, mes, fin de semana y bloque horario.
8. Se agrega `timestamp_procesamiento` para registrar cuándo fue generada la tabla.

---

## Validaciones realizadas

Durante la validación se confirmó lo siguiente:

```text
✅ La tabla GOLD tiene datos.
✅ No existen duplicados por fecha_date + hora_num.
✅ No hay nulos en columnas críticas.
✅ No hay ocupaciones negativas.
✅ No hay ingresos negativos.
✅ Las horas están dentro del rango válido.
✅ Los ingresos en GOLD coinciden con los ingresos agregados desde SILVER.
✅ La tabla tiene granularidad correcta: una fila por fecha y hora.
```

---

## Resultado actual

La tabla GOLD actual contiene:

```text
10 filas
1 fecha procesada: 2026-03-30
Horas desde 9 hasta 18
94 ingresos agregados
Ocupación máxima global: 32
```

---

## Uso para modelo baseline

Esta tabla puede ser usada como dataset base para la siguiente tarea del proyecto:

```text
Tarea 7: Crear modelo baseline
```

Features candidatas:

- `hora_num`
- `dia_semana`
- `es_fin_de_semana`
- `mes`
- `bloque_horario`

Target inicial sugerido:

- `ocupacion_max`

---

## Nota sobre `n_ingresos`

La columna `n_ingresos` se conserva como métrica descriptiva porque permite analizar cuántas personas ingresaron al gimnasio en cada hora.

Sin embargo, debe evaluarse con cuidado antes de usarla como variable predictora en el modelo baseline. Si el objetivo es predecir el aforo antes de que ocurra la hora, `n_ingresos` podría generar data leakage, ya que representa información que solo se conoce después de observar esa hora.

Por ello, para el primer modelo baseline se recomienda usar principalmente variables temporales y evaluar `n_ingresos` solo en escenarios exploratorios o retrospectivos.

---

## Estado del pipeline

```text
RAW → SILVER → GOLD
```

Estado actual:

```text
✅ Dataset gymtec_gold creado.
✅ Tabla gold_aforo_horario_modelo creada.
✅ Query de creación guardada en el repo.
✅ Query de validación guardada en el repo.
✅ Validaciones básicas ejecutadas correctamente.
✅ Tabla lista para alimentar el modelo baseline.
```
