{{ config(
    materialized='table',
    schema='intermediate',
    unique_key='timestamp_15min',
    partition_by={
      "field": "timestamp_15min",
      "data_type": "timestamp",
      "granularity": "day"
    },
    cluster_by=['timestamp_15min']
) }}

WITH time_spine AS (
    SELECT timestamp_15min FROM {{ ref('stg_time_spine') }}
),

energy__actual_consumption AS (
    SELECT * FROM {{ ref('stg_energy__actual_consumption_15min') }}
),
energy__actual_generation AS (
    SELECT * FROM {{ ref('stg_energy__actual_generation_15min') }}
),
energy__forecast_generation_day_ahead AS (
    SELECT * FROM {{ ref('stg_energy__forecast_generation_day_ahead_15min') }}
),
market__wholesale_prices AS (
    SELECT * FROM {{ ref('stg_market__wholesale_prices_15min') }}
),

weather__actual AS (
    SELECT * FROM {{ ref('intermediate_weather__actual_15min') }}
),
weather__forecast AS (
    SELECT * FROM {{ ref('intermediate_weather__forecast_15min') }}
)


SELECT
    -- 1. Take the one true timestamp from the spine
    spine.timestamp_15min,
    
    -- Consumption Data
    {{ dbt_utils.star(
        from=ref('stg_energy__actual_consumption_15min'), 
        except=["timestamp_15min"], 
        relation_alias='energy__actual_consumption',
        prefix='energy__actual_consumption_'
    ) }},
    
    -- Generation Data
    {{ dbt_utils.star(
        from=ref('stg_energy__actual_generation_15min'), 
        except=["timestamp_15min"], 
        relation_alias='energy__actual_generation',
        prefix='energy__actual_generation_'
    ) }},
    
    {{ dbt_utils.star(
        from=ref('stg_energy__forecast_generation_day_ahead_15min'), 
        except=["timestamp_15min"], 
        relation_alias='energy__forecast_generation_day_ahead',
        prefix='energy__forecast_generation_day_ahead_'
    ) }},
    {{ dbt_utils.star(
        from=ref('stg_market__wholesale_prices_15min'), 
        except=["timestamp_15min"], 
        relation_alias='market__wholesale_prices',
        prefix='market__wholesale_prices_' 
    ) }},
    {{ dbt_utils.star(
        from=ref('intermediate_weather__actual_15min'), 
        except=["timestamp_15min"], 
        relation_alias='weather__actual',
        prefix='weather__actual_' 
    ) }},
    {{ dbt_utils.star(
        from=ref('intermediate_weather__forecast_15min'), 
        except=["timestamp_15min"], 
        relation_alias='weather__forecast',
        prefix='weather__forecast_' 
    ) }}

FROM time_spine AS spine
-- Note: Make sure the column names match exactly in your ON clauses!
LEFT JOIN energy__actual_consumption 
    ON spine.timestamp_15min = energy__actual_consumption.timestamp_15min
LEFT JOIN energy__actual_generation 
    ON spine.timestamp_15min = energy__actual_generation.timestamp_15min
LEFT JOIN energy__forecast_generation_day_ahead
    ON spine.timestamp_15min = energy__forecast_generation_day_ahead.timestamp_15min
LEFT JOIN market__wholesale_prices
    ON spine.timestamp_15min = market__wholesale_prices.timestamp_15min
LEFT JOIN weather__actual
    ON spine.timestamp_15min = weather__actual.timestamp_15min
LEFT JOIN weather__forecast
    ON spine.timestamp_15min = weather__forecast.timestamp_15min