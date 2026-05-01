{{ config(
    materialized='table',
    schema='marts'
) }}

WITH raw_weights AS (
    SELECT 
        processed_input AS city_weather_station,
        weight AS raw_weight
    FROM ML.WEIGHTS(MODEL `{{ target.database }}.{{ target.schema }}.solar_capacity_model`)
    WHERE processed_input != '__INTERCEPT__' -- Hides the baseline offset
)

SELECT 
    city_weather_station,
    -- We calculate the percentage based on the total sum of all weights
    ROUND((raw_weight / SUM(raw_weight) OVER()) * 100, 2) AS importance_percentage
FROM raw_weights
ORDER BY importance_percentage DESC