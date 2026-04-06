{{ config(
    materialized='view',
    schema='staging'
) }}

with source as (
    select * from {{ source('energy_data', 'actual_consumption') }}
),

renamed as (
    select
        -- Renaming happens here using standard SQL aliases
        DATETIME(Datum_von, 'Europe/Berlin') as `datum_von`,
        DATETIME(Datum_bis, 'Europe/Berlin') as `datum_bis`,

        -- 2. Renaming a field (using standard snake_case without backticks for safety)
        cast(Netzlast_MWh_Originalaufloesungen as float64) as `netzlast`,
        cast(Netzlast_inkl_Pumpspeicher_MWh_Originalaufloesungen as float64) as `netzlast_inkl_pumpspeicher`,
        cast(Residuallast_MWh_Originalaufloesungen as float64) as `residuallast`        

    from source
)

select * from renamed