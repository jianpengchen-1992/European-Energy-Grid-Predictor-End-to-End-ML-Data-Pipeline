{{ config(
    materialized='table',
    partition_by={
      "field": "datum_von", -- Must be a clean, snake_case timestamp/date column
      "data_type": "datetime",
      "granularity": "day"
    }
) }}

with source as (
    select * from {{ source('energy_data', 'actual_consumption') }}
),

renamed as (
    select
        -- Renaming happens here using standard SQL aliases
        DATETIME(Datum_von, 'Europe/Berlin') as `Datum von`,
        DATETIME(Datum_bis, 'Europe/Berlin') as `Datum bis`,

        -- 2. Renaming a field (using standard snake_case without backticks for safety)
        cast(Netzlast_MWh_Originalaufloesungen as float64) as `Netzlast`,
        cast(Netzlast_inkl_Pumpspeicher_MWh_Originalaufloesungen as float64) as `Netzlast inkl Pumpspeicher`,
        cast(Residuallast_MWh_Originalaufloesungen as float64) as `Residuallast`        

    from source
)

select * from renamed