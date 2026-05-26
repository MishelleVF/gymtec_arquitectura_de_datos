# Transformación RAW → SILVER

## Objetivo

Construir la capa SILVER del proyecto GYMTEC a partir de los logs originales almacenados en BigQuery RAW.

## Flujo implementado

RAW → SILVER → GOLD inicial para modelado

## Tabla origen

- Dataset: `gymtec_raw`
- Tabla: `raw_logs_gimnasio`

## Tabla SILVER

- Dataset: `gymtec_silver`
- Tabla: `silver_logs_gimnasio`

## Tabla GOLD inicial

- Dataset: `gymtec_gold`
- Tabla: `gold_aforo_horario_modelo`

## Transformaciones aplicadas en SILVER

- Limpieza de espacios.
- Normalización de textos.
- Conversión de `fecha` a DATE.
- Conversión de `hora` a TIME.
- Creación de `timestamp_evento`.
- Estandarización de `accion` en `ingreso` y `salida`.
- Creación de `senal_movimiento`.
- Creación de variables temporales.
- Validación de calidad mediante `flag_calidad`.
- Registro de errores mediante `motivo_error`.
- Cálculo de `ocupacion_acumulada`.

## Transformación hacia GOLD inicial

Desde SILVER se generó una tabla agregada por fecha y hora con:

- `ocupacion_max`
- `ocupacion_media`
- `n_ingresos`
- `dia_semana`
- `dia_nombre`
- `es_fin_de_semana`
- `mes`
- `bloque_horario`

Esta tabla queda preparada para integrarse con el modelo predictivo de aforo.

## Estado

Implementado y validado en BigQuery.
