# Tarea 1 — Contratos de datos y endpoints GYMTEC

**Proyecto:** GYMTEC
**Fase:** Arquitectura de solución de datos / MLOps
**Responsable principal:** Mish
**Estado:** Propuesta inicial para MVP
**Ruta sugerida en el repositorio:** `docs/contracts/data_and_api_contracts.md`

---

## 1. Objetivo de la tarea

Definir los contratos mínimos de datos y endpoints para que el flujo de GYMTEC pueda implementarse de forma ordenada desde las fuentes de datos hasta la app del usuario.

Esta tarea permite que el equipo trabaje en paralelo:

- **Mish:** arquitectura, GCP, backend, pipeline, calidad e integración.
- **Bihonda:** modelo predictivo, selección de variables y métricas.
- **Fátima:** UX/UI, pantallas y comunicación visual.

La idea es que el pipeline, el modelo y la app se conecten mediante estructuras claras, aunque todavía existan entregables en proceso.

---

## 2. Alcance

Esta versión cubre:

1. Contrato de entrada para logs diarios.
2. Contrato de entrada para horarios/currícula.
3. Contrato de tablas BigQuery por capas: RAW, SILVER, GOLD y LOGS.
4. Contrato de salida para predicciones.
5. Contrato de salida para recomendaciones.
6. Contrato inicial de endpoints para Student App y Admin Web.
7. Reglas mínimas de validación.
8. Issues sugeridos para GitHub.

---

# 3. Convenciones generales

## 3.1 Capas de datos

| Capa | Propósito | Ejemplo |
|---|---|---|
| `RAW` | Datos crudos tal como llegan desde la fuente | `gymtec_raw.logs_raw` |
| `SILVER` | Datos limpios, normalizados y reutilizables | `gymtec_silver.aforo_por_slot` |
| `GOLD` | Datos listos para consumo por modelo, dashboard o app | `gymtec_gold.predicciones_aforo` |
| `LOGS` | Trazabilidad, ejecución y monitoreo de pipelines | `gymtec_logs.pipeline_runs` |

## 3.2 Formato de nombres

### Archivos de entrada

```text
logs_yyyy_mm_dd.csv
curricula_2026-1.csv
```

Ejemplo:

```text
logs_2026_05_25.csv
curricula_2026-1.csv
```

### Datasets BigQuery

```text
gymtec_raw
gymtec_silver
gymtec_gold
gymtec_logs
```

### Tablas BigQuery

Se usará `snake_case`.

Ejemplo:

```text
gymtec_gold.predicciones_aforo
gymtec_gold.recomendaciones_horario
```

---

# 4. Contrato de entrada: logs diarios

## 4.1 Descripción

Los logs representan los eventos de entrada y salida de estudiantes al gimnasio. Estos archivos se cargarán diariamente desde Google Drive y serán procesados por el pipeline batch.

## 4.2 Nombre esperado del archivo

```text
logs_yyyy_mm_dd.csv
```

Ejemplo:

```text
logs_2026_05_25.csv
```

## 4.3 Tabla destino RAW

```text
gymtec_raw.logs_raw
```

## 4.4 Esquema esperado

| Campo | Tipo lógico | Requerido | Descripción | Ejemplo |
|---|---|---:|---|---|
| `fecha` | DATE | Sí | Fecha del evento | `2026-05-25` |
| `hora` | TIME | Sí | Hora exacta del evento | `08:35:00` |
| `student_id` | STRING | Sí | Identificador anónimo del estudiante | `STU_00123` |
| `tipo_evento` | STRING | Sí | Tipo de movimiento registrado | `entrada` |
| `sede` | STRING | No | Sede o ambiente del gimnasio | `gimnasio_utec` |
| `fuente_archivo` | STRING | Sí | Nombre del CSV cargado | `logs_2026_05_25.csv` |
| `created_at` | TIMESTAMP | Sí | Fecha y hora de carga al sistema | `2026-05-25 23:00:00 UTC` |

## 4.5 Valores permitidos

### `tipo_evento`

```text
entrada
salida
```

## 4.6 Reglas de validación

| Regla | Severidad | Acción esperada |
|---|---|---|
| `fecha` no debe ser nula | Error | Rechazar fila |
| `hora` no debe ser nula | Error | Rechazar fila |
| `student_id` no debe ser nulo | Error | Rechazar fila |
| `tipo_evento` debe ser `entrada` o `salida` | Error | Rechazar fila |
| No debe repetirse la combinación `fecha`, `hora`, `student_id`, `tipo_evento` | Warning/Error | Deduplicar o registrar alerta |
| El nombre del archivo debe cumplir `logs_yyyy_mm_dd.csv` | Error | Rechazar archivo |
| La fecha del archivo debe coincidir con la columna `fecha` | Warning | Registrar alerta |

## 4.7 Ejemplo CSV

```csv
fecha,hora,student_id,tipo_evento,sede
2026-05-25,08:05:00,STU_001,entrada,gimnasio_utec
2026-05-25,09:10:00,STU_001,salida,gimnasio_utec
2026-05-25,10:15:00,STU_002,entrada,gimnasio_utec
```

---

# 5. Contrato de entrada: horarios / currícula

## 5.1 Descripción

El archivo de horarios contiene información de cursos, secciones, modalidad, día, hora y matriculados. Esta fuente se carga al inicio del ciclo académico y se usa como insumo para estimar disponibilidad académica y carga presencial por bloque horario.

## 5.2 Nombre esperado del archivo

```text
curricula_2026-1.csv
```

## 5.3 Tabla destino RAW

```text
gymtec_raw.horarios_raw
```

## 5.4 Esquema esperado

| Campo | Tipo lógico | Requerido | Descripción | Ejemplo |
|---|---|---:|---|---|
| `ciclo` | STRING | Sí | Ciclo académico | `2026-1` |
| `cod_curso` | STRING | Sí | Código del curso | `CS1101` |
| `nombre_curso` | STRING | Sí | Nombre del curso | `Programación I` |
| `seccion` | STRING | Sí | Sección del curso | `1.01` |
| `modalidad` | STRING | Sí | Modalidad de clase | `Presencial` |
| `dia` | STRING | Sí | Día de clase | `Lunes` |
| `hora_inicio` | TIME | Sí | Hora de inicio | `08:00:00` |
| `hora_fin` | TIME | Sí | Hora de fin | `10:00:00` |
| `matriculados` | INTEGER | Sí | Cantidad de estudiantes matriculados | `32` |
| `facultad` | STRING | No | Facultad inferida o registrada | `Computación` |
| `fuente_archivo` | STRING | Sí | Nombre del CSV cargado | `curricula_2026-1.csv` |
| `created_at` | TIMESTAMP | Sí | Fecha y hora de carga al sistema | `2026-05-25 23:00:00 UTC` |

## 5.5 Valores permitidos

### `modalidad`

```text
Presencial
Virtual
Híbrido
```

### `dia`

```text
Lunes
Martes
Miércoles
Jueves
Viernes
Sábado
```

## 5.6 Reglas de validación

| Regla | Severidad | Acción esperada |
|---|---|---|
| `ciclo` no debe ser nulo | Error | Rechazar fila |
| `cod_curso` no debe ser nulo | Error | Rechazar fila |
| `modalidad` debe estar normalizada | Error | Corregir si existe mapeo; si no, rechazar |
| `dia` debe estar dentro de los valores permitidos | Error | Rechazar fila |
| `hora_inicio` debe ser menor que `hora_fin` | Error | Rechazar fila |
| `matriculados` debe ser mayor o igual a 0 | Error | Rechazar fila |
| Filas con `matriculados = 0` pueden eliminarse para el análisis | Warning | Filtrar en SILVER |
| Duplicados por curso, sección, día y horario deben revisarse | Warning | Deduplicar o registrar alerta |

## 5.7 Ejemplo CSV

```csv
ciclo,cod_curso,nombre_curso,seccion,modalidad,dia,hora_inicio,hora_fin,matriculados,facultad
2026-1,CS1101,Programación I,1.01,Presencial,Lunes,08:00:00,10:00:00,32,Computación
2026-1,DS2102,Machine Learning,1.02,Virtual,Martes,14:00:00,16:00:00,28,Computación
```

---

# 6. Contrato de tablas BigQuery

## 6.1 Dataset RAW

### `gymtec_raw.logs_raw`

| Campo | Tipo BigQuery |
|---|---|
| `fecha` | DATE |
| `hora` | TIME |
| `student_id` | STRING |
| `tipo_evento` | STRING |
| `sede` | STRING |
| `fuente_archivo` | STRING |
| `created_at` | TIMESTAMP |

### `gymtec_raw.horarios_raw`

| Campo | Tipo BigQuery |
|---|---|
| `ciclo` | STRING |
| `cod_curso` | STRING |
| `nombre_curso` | STRING |
| `seccion` | STRING |
| `modalidad` | STRING |
| `dia` | STRING |
| `hora_inicio` | TIME |
| `hora_fin` | TIME |
| `matriculados` | INT64 |
| `facultad` | STRING |
| `fuente_archivo` | STRING |
| `created_at` | TIMESTAMP |

---

## 6.2 Dataset SILVER

### `gymtec_silver.logs_limpios`

| Campo | Tipo BigQuery | Descripción |
|---|---|---|
| `fecha` | DATE | Fecha del evento |
| `hora` | TIME | Hora del evento |
| `timestamp_evento` | TIMESTAMP | Fecha y hora combinadas |
| `student_id` | STRING | ID anonimizado |
| `tipo_evento` | STRING | Entrada o salida |
| `sede` | STRING | Sede normalizada |
| `fuente_archivo` | STRING | Archivo origen |
| `processed_at` | TIMESTAMP | Fecha de procesamiento |

### `gymtec_silver.horarios_limpios`

| Campo | Tipo BigQuery |
|---|---|
| `ciclo` | STRING |
| `cod_curso` | STRING |
| `nombre_curso` | STRING |
| `seccion` | STRING |
| `modalidad` | STRING |
| `dia` | STRING |
| `dia_num` | INT64 |
| `hora_inicio` | TIME |
| `hora_fin` | TIME |
| `matriculados` | INT64 |
| `facultad` | STRING |
| `processed_at` | TIMESTAMP |

### `gymtec_silver.horarios_expandido_slots`

| Campo | Tipo BigQuery | Descripción |
|---|---|---|
| `ciclo` | STRING | Ciclo académico |
| `dia` | STRING | Día de clase |
| `dia_num` | INT64 | Día en formato numérico |
| `slot_inicio` | TIME | Inicio del bloque |
| `slot_fin` | TIME | Fin del bloque |
| `cod_curso` | STRING | Código de curso |
| `seccion` | STRING | Sección |
| `modalidad` | STRING | Modalidad |
| `matriculados` | INT64 | Cantidad de estudiantes |
| `facultad` | STRING | Facultad |
| `processed_at` | TIMESTAMP | Fecha de procesamiento |

### `gymtec_silver.aforo_por_slot`

| Campo | Tipo BigQuery | Descripción |
|---|---|---|
| `fecha` | DATE | Fecha |
| `dia` | STRING | Día |
| `slot_inicio` | TIME | Inicio del slot |
| `slot_fin` | TIME | Fin del slot |
| `entradas` | INT64 | Cantidad de entradas |
| `salidas` | INT64 | Cantidad de salidas |
| `aforo_real` | INT64 | Aforo estimado del gimnasio |
| `processed_at` | TIMESTAMP | Fecha de procesamiento |

---

## 6.3 Dataset GOLD

### `gymtec_gold.features_aforo_rf01`

Dataset final para entrenamiento e inferencia del RF-01: Predicción y visualización del aforo del gimnasio.

| Campo | Tipo BigQuery | Descripción |
|---|---|---|
| `fecha` | DATE | Fecha objetivo |
| `dia` | STRING | Día |
| `dia_num` | INT64 | Día numérico |
| `hora_inicio` | TIME | Inicio del bloque |
| `hora_fin` | TIME | Fin del bloque |
| `hora_decimal` | FLOAT64 | Hora convertida a número |
| `semana_ciclo` | INT64 | Semana académica |
| `es_sabado` | BOOL | Indicador de sábado |
| `aforo_real` | INT64 | Target histórico si existe |
| `aforo_lag_1` | FLOAT64 | Aforo del bloque anterior |
| `aforo_lag_2` | FLOAT64 | Aforo de dos bloques anteriores |
| `aforo_promedio_historico` | FLOAT64 | Promedio histórico por día y hora |
| `estudiantes_presencial` | INT64 | Estudiantes presenciales activos en el slot |
| `estudiantes_virtual` | INT64 | Estudiantes virtuales activos en el slot |
| `ratio_libres` | FLOAT64 | Proporción estimada de estudiantes libres |
| `carga_academica` | FLOAT64 | Carga presencial estimada |
| `ratio_virtual` | FLOAT64 | Proporción virtual sobre total de clases activas |
| `target_aforo` | FLOAT64 | Variable objetivo para entrenamiento |
| `created_at` | TIMESTAMP | Fecha de creación del registro |

### `gymtec_gold.predicciones_aforo`

| Campo | Tipo BigQuery | Descripción |
|---|---|---|
| `fecha_prediccion` | DATE | Fecha en que se generó la predicción |
| `fecha_objetivo` | DATE | Fecha para la cual aplica la predicción |
| `dia` | STRING | Día |
| `hora_inicio` | TIME | Inicio del bloque |
| `hora_fin` | TIME | Fin del bloque |
| `aforo_predicho` | FLOAT64 | Aforo estimado por el modelo |
| `nivel_aforo` | STRING | Nivel categórico de aforo |
| `modelo_version` | STRING | Versión del modelo usado |
| `created_at` | TIMESTAMP | Timestamp de generación |

### `gymtec_gold.recomendaciones_horario`

| Campo | Tipo BigQuery | Descripción |
|---|---|---|
| `estudiante_id` | STRING | ID anonimizado del estudiante |
| `fecha` | DATE | Fecha recomendada |
| `dia` | STRING | Día |
| `hora_inicio` | TIME | Inicio del horario recomendado |
| `hora_fin` | TIME | Fin del horario recomendado |
| `aforo_predicho` | FLOAT64 | Aforo estimado |
| `score_recomendacion` | FLOAT64 | Puntaje de recomendación |
| `motivo` | STRING | Explicación breve de la recomendación |
| `created_at` | TIMESTAMP | Timestamp de generación |

### `gymtec_gold.dashboard_aforo`

| Campo | Tipo BigQuery | Descripción |
|---|---|---|
| `fecha` | DATE | Fecha |
| `dia` | STRING | Día |
| `hora_inicio` | TIME | Inicio del bloque |
| `hora_fin` | TIME | Fin del bloque |
| `aforo_real` | INT64 | Aforo histórico real, si existe |
| `aforo_predicho` | FLOAT64 | Aforo predicho |
| `nivel_aforo` | STRING | Nivel de aforo |
| `entradas` | INT64 | Entradas registradas |
| `salidas` | INT64 | Salidas registradas |
| `created_at` | TIMESTAMP | Fecha de actualización |

---

## 6.4 Dataset LOGS

### `gymtec_logs.pipeline_runs`

| Campo | Tipo BigQuery | Descripción |
|---|---|---|
| `run_id` | STRING | Identificador único de ejecución |
| `pipeline_name` | STRING | Nombre del pipeline |
| `status` | STRING | Estado: `SUCCESS`, `FAILED`, `WARNING` |
| `started_at` | TIMESTAMP | Inicio de ejecución |
| `finished_at` | TIMESTAMP | Fin de ejecución |
| `input_file` | STRING | Archivo procesado |
| `rows_raw` | INT64 | Filas cargadas a RAW |
| `rows_silver` | INT64 | Filas generadas en SILVER |
| `rows_gold` | INT64 | Filas generadas en GOLD |
| `error_message` | STRING | Mensaje de error, si aplica |

---

# 7. Contrato de niveles de aforo

Para el MVP se propone una clasificación inicial:

| Nivel | Regla inicial sugerida |
|---|---|
| `Bajo` | `aforo_predicho < 20` |
| `Medio` | `20 <= aforo_predicho < 40` |
| `Alto` | `40 <= aforo_predicho < 60` |
| `Muy alto` | `aforo_predicho >= 60` |

> Nota: estos umbrales deben ajustarse cuando se defina la capacidad real del gimnasio y se observe el comportamiento histórico.

---

# 8. Contrato de endpoints

## 8.1 Base API

Para el MVP, el backend expondrá endpoints REST.

Base path sugerido:

```text
/api/v1
```

---

## 8.2 `GET /health`

Endpoint para validar que el backend esté activo.

### Request

```http
GET /api/v1/health
```

### Response 200

```json
{
  "status": "ok",
  "service": "gymtec-api",
  "version": "v1"
}
```

---

## 8.3 `GET /aforo/actual`

Devuelve el aforo actual estimado.

### Request

```http
GET /api/v1/aforo/actual
```

### Response 200

```json
{
  "fecha": "2026-05-25",
  "hora": "10:30",
  "aforo_actual": 32,
  "nivel_aforo": "Medio",
  "updated_at": "2026-05-25T10:30:00Z"
}
```

---

## 8.4 `GET /predicciones`

Devuelve predicciones de aforo para una fecha específica.

### Request

```http
GET /api/v1/predicciones?fecha=2026-05-25
```

### Query params

| Parámetro | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `fecha` | DATE | Sí | Fecha consultada |

### Response 200

```json
{
  "fecha": "2026-05-25",
  "modelo_version": "modelo_aforo_v1",
  "predicciones": [
    {
      "hora_inicio": "08:00",
      "hora_fin": "08:30",
      "aforo_predicho": 18,
      "nivel_aforo": "Bajo"
    },
    {
      "hora_inicio": "08:30",
      "hora_fin": "09:00",
      "aforo_predicho": 24,
      "nivel_aforo": "Medio"
    }
  ]
}
```

---

## 8.5 `GET /recomendaciones`

Devuelve horarios recomendados para un estudiante.

### Request

```http
GET /api/v1/recomendaciones?estudiante_id=STU_001&fecha=2026-05-25
```

### Query params

| Parámetro | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `estudiante_id` | STRING | Sí | ID anonimizado del estudiante |
| `fecha` | DATE | Sí | Fecha para la recomendación |

### Response 200

```json
{
  "estudiante_id": "STU_001",
  "fecha": "2026-05-25",
  "recomendaciones": [
    {
      "hora_inicio": "09:00",
      "hora_fin": "09:30",
      "aforo_predicho": 15,
      "score_recomendacion": 0.92,
      "motivo": "Horario recomendado por bajo aforo esperado y buena disponibilidad académica."
    },
    {
      "hora_inicio": "11:00",
      "hora_fin": "11:30",
      "aforo_predicho": 18,
      "score_recomendacion": 0.88,
      "motivo": "Horario alternativo con aforo esperado bajo."
    }
  ]
}
```

---

## 8.6 `GET /dashboard/resumen`

Devuelve indicadores agregados para el admin web.

### Request

```http
GET /api/v1/dashboard/resumen?fecha=2026-05-25
```

### Query params

| Parámetro | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `fecha` | DATE | Sí | Fecha consultada |

### Response 200

```json
{
  "fecha": "2026-05-25",
  "resumen": {
    "aforo_promedio": 28.5,
    "aforo_maximo": 62,
    "hora_pico": "18:00",
    "nivel_dominante": "Medio"
  },
  "bloques": [
    {
      "hora_inicio": "08:00",
      "hora_fin": "08:30",
      "aforo_predicho": 18,
      "nivel_aforo": "Bajo"
    }
  ]
}
```

---

# 9. Contrato de errores API

Formato estándar de error:

```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "El parámetro fecha es obligatorio.",
    "details": {
      "field": "fecha"
    }
  }
}
```

Códigos iniciales:

| Código | Cuándo ocurre |
|---|---|
| `INVALID_REQUEST` | Parámetros inválidos o faltantes |
| `NOT_FOUND` | No hay datos para la fecha solicitada |
| `INTERNAL_ERROR` | Error inesperado del backend |
| `DATA_NOT_READY` | La predicción todavía no fue generada |

---

# 10. Criterios de aceptación de la tarea 1

La tarea se considera terminada cuando:

- [ ] Existe un documento oficial de contratos en el repositorio.
- [ ] Se definieron los archivos de entrada esperados.
- [ ] Se definieron las tablas RAW, SILVER, GOLD y LOGS.
- [ ] Se definieron columnas y tipos lógicos de las tablas principales.
- [ ] Se definieron reglas mínimas de validación.
- [ ] Se definieron endpoints iniciales para Student App y Admin Web.
- [ ] Se definió el formato estándar de errores del backend.
- [ ] El equipo revisó y aprobó el contrato inicial.
- [ ] Se creó un commit con el documento en el repositorio.

---

# 11. Análisis: ¿es necesario crear issues para esta tarea?

Sí, conviene crear issues porque esta tarea no es solamente escribir documentación. También define decisiones que afectarán al pipeline, a la app, al modelo y a los tests.

Sin embargo, para el MVP no conviene crear demasiados issues pequeños. Lo ideal es crear **un issue principal** y usar checklist interno. Luego se pueden crear issues secundarios solo si el trabajo crece o si quieren repartir responsabilidades.

## 11.1 Issue principal sugerido

### Issue: Definir contratos de datos y endpoints del MVP

**Labels sugeridos:** `architecture`, `data-contracts`, `mvp`
**Responsable:** Mish
**Prioridad:** Alta

```markdown
## Objetivo

Definir los contratos iniciales de datos y endpoints para el MVP de GYMTEC, de modo que el pipeline de datos, el modelo y la app puedan integrarse bajo una misma estructura.

## Alcance

- Contrato de logs diarios.
- Contrato de horarios/currícula.
- Contratos de tablas BigQuery por capas RAW, SILVER, GOLD y LOGS.
- Contrato de endpoints para Student App y Admin Web.
- Reglas mínimas de validación.
- Formato estándar de errores API.

## Checklist

- [ ] Documentar contrato de `logs_yyyy_mm_dd.csv`.
- [ ] Documentar contrato de `curricula_2026-1.csv`.
- [ ] Definir tablas `gymtec_raw`.
- [ ] Definir tablas `gymtec_silver`.
- [ ] Definir tablas `gymtec_gold`.
- [ ] Definir tabla `gymtec_logs.pipeline_runs`.
- [ ] Definir endpoints iniciales.
- [ ] Definir respuestas JSON esperadas.
- [ ] Definir criterios de aceptación.
- [ ] Revisar con el equipo.
```

## 11.2 Issues secundarios opcionales

| Issue | Responsable sugerido | Prioridad | ¿Bloquea implementación? |
|---|---|---:|---|
| Definir contrato de logs diarios | Mish | Alta | Sí |
| Definir contrato de horarios/currícula | Mish | Alta | Sí |
| Definir contratos de tablas BigQuery | Mish | Alta | Sí |
| Definir contrato de endpoints API | Mish | Alta | Sí |
| Validar features esperadas con modelo | Mish + Bihonda | Media | No al inicio |
| Validar campos necesarios para pantallas | Mish + Fátima | Media | No al inicio |

## 11.3 Recomendación final

Para este momento del proyecto:

```text
Crear 1 issue principal con checklist interno.
Crear issues secundarios solo si el equipo quiere repartir responsabilidades o usar GitHub Projects con más detalle.
```

Como Mish lidera la arquitectura, puede empezar con un solo issue principal y luego convertir los puntos más grandes en issues independientes si el trabajo crece.

---

# 12. Commit sugerido

```bash
git checkout -b chore/data-api-contracts

mkdir -p docs/contracts
# Guardar este archivo como docs/contracts/data_and_api_contracts.md

git add docs/contracts/data_and_api_contracts.md
git commit -m "docs: define data and API contracts for GYMTEC MVP"
git push origin chore/data-api-contracts
```

---

# 13. Próximo paso recomendado

Después de aprobar este documento, el siguiente paso es crear los archivos técnicos de esquema:

```text
configs/schemas/logs_raw_schema.json
configs/schemas/horarios_raw_schema.json
configs/tables/bigquery_tables.yml
```

Estos archivos serán usados por el pipeline para crear tablas, validar datos y mantener consistencia entre ambientes.
