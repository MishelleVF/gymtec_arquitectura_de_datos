-- Resumen general:
SELECT
    COUNT(*) AS total_filas,
    MIN(fecha_date) AS fecha_min,
    MAX(fecha_date) AS fecha_max,
    MIN(hora_num) AS hora_min,
    MAX(hora_num) AS hora_max
FROM `gymtec-dpd-mvp.gymtec_gold.gold_aforo_horario_modelo`;


-- Validar que no haya duplicados por fecha y hora:
SELECT
    fecha_date,
    hora_num,
    COUNT(*) AS total
FROM `gymtec-dpd-mvp.gymtec_gold.gold_aforo_horario_modelo`
GROUP BY fecha_date, hora_num
HAVING COUNT(*) > 1;

-- Ver ocupación máxima por día
SELECT
    fecha_date,
    MAX(ocupacion_max) AS max_ocupacion_dia,
    AVG(ocupacion_media) AS promedio_ocupacion_dia,
    SUM(n_ingresos) AS ingresos_dia
FROM `gymtec-dpd-mvp.gymtec_gold.gold_aforo_horario_modelo`
GROUP BY fecha_date
ORDER BY fecha_date;
