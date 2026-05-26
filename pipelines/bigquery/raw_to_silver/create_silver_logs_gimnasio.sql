-- Total de filas en SILVER:
SELECT COUNT(*) AS total_filas
FROM `gymtec-dpd-mvp.gymtec_silver.silver_logs_gimnasio`;

-- Distribución de la calidad de los datos:
SELECT
    flag_calidad,
    COUNT(*) AS total
FROM `gymtec-dpd-mvp.gymtec_silver.silver_logs_gimnasio`
GROUP BY flag_calidad;

-- Motivos de error, si existen:
SELECT
    motivo_error,
    COUNT(*) AS total
FROM `gymtec-dpd-mvp.gymtec_silver.silver_logs_gimnasio`
WHERE flag_calidad = 'observado'
GROUP BY motivo_error
ORDER BY total DESC;

-- Validar si hay ocupación negativa:
--SELECT *
--FROM `gymtec-dpd-mvp.gymtec_silver.silver_logs_gimnasio`
--WHERE ocupacion_acumulada < 0
--ORDER BY fecha, timestamp_evento
--LIMIT 50;
