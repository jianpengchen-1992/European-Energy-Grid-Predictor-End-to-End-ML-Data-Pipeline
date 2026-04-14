{{ config(
    materialized='table',
    partition_by={
      "field": "timestamp_utc_15m",
      "data_type": "timestamp",
      "granularity": "day"
    }
) }}

WITH time_spine AS (
    SELECT timestamp_15min FROM {{ ref('stg_time_spine') }}
),

energy_consumption AS (
    SELECT * FROM {{ ref('stg_energy_consumption') }}
),

weather_data AS (
    SELECT * FROM {{ ref('stg_weather_all_cities') }}
)

SELECT
    -- 1. Take the one true timestamp from the spine
    spine.timestamp_utc_15m,
    
    -- Consumption Data
    {{ dbt_utils.star(
        from=ref('stg_energy_consumption'), 
        except=["timestamp_utc_15m"], 
        relation_alias='energy_consumption',
        prefix='consumption_' -- <--- ADD THIS
    ) }},
    
    -- Generation Data
    {{ dbt_utils.star(
        from=ref('stg_energy_generation'), 
        except=["timestamp_utc_15m"], 
        relation_alias='energy_generation',
        prefix='generation_' -- <--- ADD THIS
    ) }}

FROM time_spine AS spine
-- Note: Make sure the column names match exactly in your ON clauses!
LEFT JOIN energy_consumption 
    ON spine.timestamp_utc_15m = energy_consumption.timestamp_utc_15m
LEFT JOIN weather_data 
    ON spine.timestamp_utc_15m = weather_data.timestamp_utc_15m