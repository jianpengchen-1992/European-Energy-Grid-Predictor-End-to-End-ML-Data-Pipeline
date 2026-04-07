{{ config(
    materialized='view',
    schema='staging'
) }}

with source as (
    select * from {{ source('weather_data', 'forecasted_weather') }}
),

renamed as (
    select
        -- Renaming happens here using standard SQL aliases
        cast(city as string) as `city`,
        cast(`date` as timestamp) as `weather_timestamp`, -- Renaming to avoid reserved keyword issues
        -- 2. Renaming a field (using standard snake_case without backticks for safety)
        
        cast(temperature_2m as float64) as `temperature_2m`,
        cast(wind_speed_80m as float64) as `wind_speed_80m`,
        cast(wind_direction_80m as integer) as `wind_direction_80m`,
        cast(snowfall as float64) as `snowfall`,
        cast(precipitation as float64) as `precipitation`,
        cast(shortwave_radiation as float64) as `solar_radiation`,
        cast(direct_radiation as float64) as `direct_radiation`,
        cast(diffuse_radiation as float64) as `diffuse_radiation`        

    from source
)

select * from renamed