{{ config(
    materialized='view',
    schema='staging'
) }}

with source as (
    select * from {{ source('energy_data', 'forecasted_energy_generation_day_ahead') }}
),

renamed as (
    select
        -- Renaming happens here using standard SQL aliases
        cast(Datum_von as timestamp) as `datum_von`,
        cast(Datum_bis as timestamp) as `datum_bis`,

        -- 2. Renaming a field (using standard snake_case without backticks for safety)
        cast(Gesamt_MWh_Originalaufloesungen as NUMERIC) as `gesamt`,
        cast(Photovoltaik_und_Wind_MWh_Originalaufloesungen as NUMERIC) as `photovoltaik_und_wind`,
        cast(Wind_Offshore_MWh_Originalaufloesungen as NUMERIC) as `wind_offshore`,
        cast(Wind_Onshore_MWh_Originalaufloesungen as NUMERIC) as `wind_onshore`,
        cast(Photovoltaik_MWh_Originalaufloesungen as NUMERIC) as `photovoltaik`,
        cast(Sonstige_MWh_Originalaufloesungen as NUMERIC) as `sonstige`

    from source
)

select * from renamed