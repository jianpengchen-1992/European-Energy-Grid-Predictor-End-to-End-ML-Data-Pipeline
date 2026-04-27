{{ config(materialized='view', schema='marts') }}

WITH price_stack AS (
    SELECT timestamp_15min, 'Germany/Lux' AS country, market__wholesale_prices_de_lu AS price FROM {{ ref('intermediate_energy_weather_joined') }}
    UNION ALL
    SELECT timestamp_15min, 'Austria' AS country, market__wholesale_prices_oesterreich AS price FROM {{ ref('intermediate_energy_weather_joined') }}
    UNION ALL
    SELECT timestamp_15min, 'France' AS country, market__wholesale_prices_frankreich AS price FROM {{ ref('intermediate_energy_weather_joined') }}
    UNION ALL
    SELECT timestamp_15min, 'Belgium' AS country, market__wholesale_prices_belgien AS price FROM {{ ref('intermediate_energy_weather_joined') }}
    UNION ALL
    SELECT timestamp_15min, 'Switzerland' AS country, market__wholesale_prices_schweiz AS price FROM {{ ref('intermediate_energy_weather_joined') }}
)

SELECT 
    timestamp_15min,
    DATE(timestamp_15min) AS energy_date,
    EXTRACT(HOUR FROM timestamp_15min) AS hour_of_day,
    country,
    price
FROM price_stack
WHERE price IS NOT NULL