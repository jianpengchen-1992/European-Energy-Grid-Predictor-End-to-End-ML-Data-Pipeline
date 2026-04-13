WITH time_spine AS (
    -- You can generate this using the dbt_utils package!
    SELECT timestamp_utc_15m FROM {{ ref('stg_time_spine') }}
),

energy AS (
    SELECT * FROM {{ ref('stg_energy') }}
),

weather AS (
    SELECT * FROM {{ ref('stg_weather') }}
)

SELECT
    spine.timestamp_utc_15m,
    
    -- Energy Data
    energy.actual_consumption_mwh,
    energy.actual_generation_mwh,
    
    -- Weather Data
    weather.actual_temp_celsius

FROM time_spine AS spine
LEFT JOIN energy 
    ON spine.timestamp_utc_15m = energy.timestamp_utc_15m
LEFT JOIN weather 
    ON spine.timestamp_utc_15m = weather.timestamp_utc_15m

-- Optionally filter out the future/past where you have NO data at all
WHERE spine.timestamp_utc_15m >= '2023-01-01'