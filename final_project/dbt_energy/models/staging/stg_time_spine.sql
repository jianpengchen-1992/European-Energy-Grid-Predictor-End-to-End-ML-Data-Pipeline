{{ config(
    materialized='table' 
) }}

WITH table_bounds AS (
    SELECT 
        -- Find the absolute earliest date (e.g., from your oldest historical table)
        (SELECT MIN(timestamp_15min) FROM {{ ref('stg_energy__actual_consumption15_min') }}) AS start_time,
        
        -- Find the absolute latest date (e.g., from your forecast table)
        (SELECT MAX(timestamp_15min) FROM {{ ref('intermediate_weather__actual_15min') }}) AS end_time
),

raw_spine AS (
    SELECT generated_timestamp AS timestamp_15m
    FROM table_bounds,
    UNNEST(
        GENERATE_TIMESTAMP_ARRAY(
            table_bounds.start_time, 
            table_bounds.end_time, 
            INTERVAL 15 MINUTE
        )
    ) AS generated_timestamp
)

SELECT * FROM raw_spine