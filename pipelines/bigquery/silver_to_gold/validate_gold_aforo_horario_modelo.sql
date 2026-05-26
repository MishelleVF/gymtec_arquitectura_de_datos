-- ============================================================
-- GYMTEC - VALIDACIONES GOLD
-- Tabla: gymtec_gold.gold_aforo_horario_modelo
-- Objetivo: validar calidad, granularidad y consistencia de GOLD
-- ============================================================

-- 1. Resumen general de la tabla GOLD
SELECT
    COUNT(*) AS total_filas,
    COUNT(DISTINCT fecha_date) AS total_fechas,
    MIN(fecha_date) AS fecha_min,
    MAX(fecha_date) AS fecha_max,
    MIN(hora_num) AS hora_min,
    MAX(hora_num) AS hora_max,
    SUM(n_ingresos) AS total_ingresos,
    MAX(ocupacion_max) AS ocupacion_max_global,
    AVG(ocupacion_media) AS ocupacion_media_promedio
FROM `gymtec-dpd-mvp.gymtec_gold.gold_aforo_horario_modelo`;


-- 2. Validar que no haya duplicados por fecha y hora
SELECT
    fecha_date,
    hora_num,
    COUNT(*) AS filas_por_grupo
FROM `gymtec-dpd-mvp.gymtec_gold.gold_aforo_horario_modelo`
GROUP BY fecha_date, hora_num
HAVING COUNT(*) > 1;


-- 3. Validar nulos y valores fuera de rango
SELECT
    COUNT(*) AS total_filas,

    COUNTIF(fecha_date IS NULL) AS nulos_fecha,
    COUNTIF(hora_num IS NULL) AS nulos_hora,
    COUNTIF(dia_semana IS NULL) AS nulos_dia_semana,
    COUNTIF(dia_nombre IS NULL) AS nulos_dia_nombre,
    COUNTIF(bloque_horario IS NULL) AS nulos_bloque_horario,

    COUNTIF(ocupacion_max IS NULL) AS nulos_ocupacion_max,
    COUNTIF(ocupacion_media IS NULL) AS nulos_ocupacion_media,
    COUNTIF(n_ingresos IS NULL) AS nulos_ingresos,

    COUNTIF(ocupacion_max < 0) AS ocupacion_max_negativa,
    COUNTIF(ocupacion_media < 0) AS ocupacion_media_negativa,
    COUNTIF(n_ingresos < 0) AS ingresos_negativos,
    COUNTIF(hora_num < 0 OR hora_num > 23) AS horas_fuera_de_rango
FROM `gymtec-dpd-mvp.gymtec_gold.gold_aforo_horario_modelo`;


-- 4. Vista ordenada de la tabla GOLD
SELECT
    fecha_date,
    hora_num,
    dia_semana,
    dia_nombre,
    es_fin_de_semana,
    mes,
    bloque_horario,
    n_ingresos,
    ocupacion_max,
    ROUND(ocupacion_media, 2) AS ocupacion_media
FROM `gymtec-dpd-mvp.gymtec_gold.gold_aforo_horario_modelo`
ORDER BY fecha_date, hora_num;
