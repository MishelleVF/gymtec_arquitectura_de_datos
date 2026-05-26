# Pipeline RAW Ingestion — GYMTEC

## Objetivo

Implementar la primera etapa del pipeline de datos de GYMTEC para almacenar y centralizar los registros diarios de ingreso y salida del gimnasio utilizando Google Cloud Platform.

El flujo actual permite mover archivos CSV desde Google Drive hacia Google Cloud Storage (GCS) y posteriormente cargarlos en BigQuery dentro de la capa RAW.

---

# Arquitectura actual

```text
Google Drive
    ↓
Google Cloud Storage (RAW Layer)
    ↓
BigQuery RAW Dataset
```

---

# Flujo actual

```text
Drive → GCS → BigQuery RAW
```

---

# Proyecto GCP

```text
gymtec-dpd-mvp
```

---

# Bucket principal

```text
gymtec-dpd-dev-raw
```

Este bucket funciona como almacenamiento central del pipeline de datos.

---

# Dataset RAW

```text
gymtec_raw
```

Ubicación:

```text
us-central1
```

---

# Tabla RAW

```text
raw_logs_gimnasio
```

---

# Fuente de datos

Archivos CSV diarios de ingreso/salida del gimnasio.

Cada archivo representa los registros de un día específico.

Formato esperado:

```csv
student_id,facultad,carrera,genero,fecha,hora,accion
```

Ejemplo:

```csv
2022B72E2,Ingeniería,Industrial,Femenino,2026-03-30,09:14:00,ingreso
```

---

# Estructura de Google Drive

```text
GYMTEC/
└── 01_raw/
    ├── feedback_usuarios/
    ├── horarios/
    └── logs_gimnasio/
        ├── incoming/
        └── archive_weekly/
```

---

# incoming/

La carpeta:

```text
logs_gimnasio/incoming/
```

recibe los archivos CSV diarios de lunes a sábado.

Ejemplo:

```text
logs_gimnasio_2026-03-30.csv
logs_gimnasio_2026-03-31.csv
logs_gimnasio_2026-04-01.csv
```

Características:

- contiene archivos recientes
- archivos aún no archivados
- máximo una semana de datos operativos

---

# archive_weekly/

La carpeta:

```text
logs_gimnasio/archive_weekly/
```

almacena archivos ZIP históricos semanales.

Ejemplo:

```text
logs_gimnasio_week_2026-W22.zip
```

Objetivo:

- conservar respaldo histórico
- evitar saturación de la carpeta operativa
- mantener trazabilidad del pipeline

---

# Estructura RAW en GCS

```text
gs://gymtec-dpd-dev-raw/raw/logs_gimnasio/incoming/
```

---

# Ingesta hacia BigQuery

La tabla RAW se construyó utilizando:

```text
Google Cloud Storage → BigQuery
```

Configuración utilizada:

| Configuración | Valor |
|---|---|
| Formato | CSV |
| Detección automática | Sí |
| Skip header rows | 1 |
| Write preference | Write if empty |
| Región | us-central1 |

---

# Validaciones actuales

Actualmente la validación se realiza manualmente antes de cargar los archivos.

Checklist actual:

- nombres correctos
- columnas obligatorias
- formato de fecha válido
- formato de hora válido
- acción ingreso/salida válida
- delimitador CSV correcto
- headers consistentes

---

# Validación automática futura

Más adelante se implementará un script de validación automática:

```text
scripts/validate_logs_csv.py
```

El script validará:

1. nombre correcto del archivo
2. columnas obligatorias
3. fecha válida
4. hora válida
5. acción solo ingreso/salida
6. consistencia entre fecha del archivo y columna fecha
7. ausencia de student_id vacío

---

# APIs habilitadas en GCP

- BigQuery API
- Cloud Storage API
- Cloud Build API
- Artifact Registry API
- IAM Service Account Credentials API

---

# Service Account del pipeline

```text
gymtec-data-pipeline-sa@gymtec-dpd-mvp.iam.gserviceaccount.com
```

Roles asignados:

- Storage Object Admin
- BigQuery Data Editor
- BigQuery Job User
- Artifact Registry Reader
- Cloud Run Invoker
- Logs Writer

---

# Estado actual

## Completado

- estructura RAW en Drive
- bucket GCS
- dataset RAW
- carga de CSV a GCS
- carga de CSV a BigQuery
- validación inicial del pipeline

---

# Estado del pipeline

```text
Pipeline funcionando correctamente ✅
```

---

# Próximos pasos

## RAW → SILVER

Próxima etapa del pipeline:

- limpieza
- tipado
- deduplicación
- validaciones automáticas
- normalización
- generación de features iniciales

Destino futuro:

```text
gymtec_staging
```
