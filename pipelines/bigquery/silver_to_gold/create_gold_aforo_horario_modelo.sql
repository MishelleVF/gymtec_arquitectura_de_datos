-- ============================================================
-- GYMTEC - SILVER TO GOLD
-- Tabla GOLD para modelo de predicción de aforo por hora
-- Fuente: gymtec_silver.silver_logs_gimnasio
-- Destino: gymtec_gold.gold_aforo_horario_modelo
-- Granularidad: fecha_date + hora_num
-- ============================================================

CREATE OR REPLACE TABLE `gymtec-dpd-mvp.gymtec_gold.gold_aforo_horario_modelo`
PARTITION BY fecha_date
CLUSTER BY hora_num, dia_semana
AS

WITH eventos_validos AS (
    SELECT
        fecha AS fecha_date,
        CAST(FLOOR(hora_num) AS INT64) AS hora_num,
        accion,
        ocupacion_acumulada
    FROM `gymtec-dpd-mvp.gymtec_silver.silver_logs_gimnasio`
    WHERE
        flag_calidad = 'valido'
        AND fecha IS NOT NULL
        AND hora_num IS NOT NULL
),

agregado_horario AS (
    SELECT
        fecha_date,
        hora_num,
        MAX(ocupacion_acumulada) AS ocupacion_max,
        AVG(ocupacion_acumulada) AS ocupacion_media,
        COUNTIF(LOWER(accion) = 'ingreso') AS n_ingresos,
        MOD(EXTRACT(DAYOFWEEK FROM fecha_date) + 5, 7) AS dia_semana,
        CASE MOD(EXTRACT(DAYOFWEEK FROM fecha_date) + 5, 7)
            WHEN 0 THEN 'Lunes'
            WHEN 1 THEN 'Martes'
            WHEN 2 THEN 'Miércoles'
            WHEN 3 THEN 'Jueves'
            WHEN 4 THEN 'Viernes'
            WHEN 5 THEN 'Sábado'
            WHEN 6 THEN 'Domingo'
        END AS dia_nombre,
        CASE
            WHEN MOD(EXTRACT(DAYOFWEEK FROM fecha_date) + 5, 7) IN (5, 6)
                THEN 1
            ELSE 0
        END AS es_fin_de_semana,
        EXTRACT(MONTH FROM fecha_date) AS mes,
        CASE
            WHEN hora_num BETWEEN 6 AND 11 THEN 'Mañana'
            WHEN hora_num BETWEEN 12 AND 17 THEN 'Tarde'
            ELSE 'Noche'
        END AS bloque_horario
    FROM eventos_validos
    GROUP BY
        fecha_date,
        hora_num
)

SELECT
    fecha_date,
    hora_num,
    CAST(ocupacion_max AS INT64) AS ocupacion_max,
    CAST(ocupacion_media AS FLOAT64) AS ocupacion_media,
    CAST(n_ingresos AS INT64) AS n_ingresos,
    CAST(dia_semana AS INT64) AS dia_semana,
    dia_nombre,
    CAST(es_fin_de_semana AS INT64) AS es_fin_de_semana,
    CAST(mes AS INT64) AS mes,
    bloque_horario,
    CURRENT_TIMESTAMP() AS timestamp_procesamiento
FROM agregado_horario;

-- ============================================================
-- Ordenarlo
-- ============================================================

--SELECT *
--FROM `gymtec-dpd-mvp.gymtec_gold.gold_aforo_horario_modelo`
--ORDER BY fecha_date, hora_num;
