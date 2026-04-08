{{ config(
    materialized='view',
    schema='staging'
) }}

with source as (
    select * from {{ source('weather_data', 'historical_weather') }}
),

renamed as (
    select
        -- Renaming happens here using standard SQL aliases
        cast(city as string) as `city`,
        cast(`date` as timestamp) as `weather_timestamp`, -- Renaming to avoid reserved keyword issues
        -- 2. Renaming a field (using standard snake_case without backticks for safety)
        
        cast(temperature_2m as NUMERIC) as `temperature_2m`,
        cast(wind_speed_100m as NUMERIC) as `wind_speed_100m`,
        cast(wind_direction_100m as INT64) as `wind_direction_100m`,
        cast(snowfall as NUMERIC) as `snowfall`,
        cast(precipitation as NUMERIC) as `precipitation`,
        cast(shortwave_radiation as NUMERIC) as `solar_radiation`,
        cast(direct_radiation as NUMERIC) as `direct_radiation`,
        cast(diffuse_radiation as NUMERIC) as `diffuse_radiation`        

    from source
)

select * from renamed