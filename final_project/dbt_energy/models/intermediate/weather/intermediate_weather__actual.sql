{{ config(
    materialized='table',
    schema='intermediate' 
) }}

WITH spine AS (
    -- 1. Create the 15-minute intervals. 
    -- (Adjust these start/end dates to match the range of your actual data)
    SELECT timestamp_15m 
    FROM UNNEST(GENERATE_TIMESTAMP_ARRAY(
        '2022-01-01 00:00:00', 
        '2025-01-01 00:00:00', 
        INTERVAL 15 MINUTE
    )) AS timestamp_15m
),

hourly_data AS (
    -- 2. Get the current and next hour's data using the invisible "city walls"
    SELECT 
        measurement_time,
        city,
        temperature,
        LEAD(temperature) OVER (PARTITION BY city ORDER BY measurement_time) AS next_temperature,
        
        wind_speed_80m,
        LEAD(wind_speed_80m) OVER (PARTITION BY city ORDER BY measurement_time) AS next_wind_speed
    FROM {{ ref('stg_weather_1h') }}
),

interpolated_data AS (
    -- 3. Join the spine and calculate the 15-minute fractions
    SELECT
        s.timestamp_15m,
        h.city,
        
        -- Interpolate Temperature
        h.temperature + (
            (h.next_temperature - h.temperature) * (EXTRACT(MINUTE FROM s.timestamp_15m) / 60.0)
        ) AS temp_15m,

        -- Interpolate Wind Speed AND convert to 100m height (multiplying by 1.05)
        (h.wind_speed_80m + (
            (h.next_wind_speed - h.wind_speed_80m) * (EXTRACT(MINUTE FROM s.timestamp_15m) / 60.0)
        )) * 1.05 AS wind_100m_15m

    FROM spine s
    LEFT JOIN hourly_data h
        -- Join the 15-min timestamp to the start of its respective hour
        ON DATE_TRUNC(s.timestamp_15m, HOUR) = h.measurement_time
    
    -- This ensures we don't generate spine rows for times where we have no weather data at all
    WHERE h.city IS NOT NULL 
)

-- 4. Pivot the cities into their own columns
SELECT * FROM interpolated_data
PIVOT (
    MAX(temp_15m) AS temp,
    MAX(wind_100m_15m) AS wind_100m
    -- Replace these with your actual city names in lowercase
    FOR city IN ('berlin', 'hamburg', 'munich', 'frankfurt', 'stuttgart') 
)
ORDER BY timestamp_15m