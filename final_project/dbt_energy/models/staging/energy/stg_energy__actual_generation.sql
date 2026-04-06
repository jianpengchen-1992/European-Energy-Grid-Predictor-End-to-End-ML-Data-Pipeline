{{ config(
    materialized='view',
    schema='staging'
) }}

with source as (
    select * from {{ source('energy_data', 'actual_energy_generation') }}
),

renamed as (
    select
        -- Renaming happens here using standard SQL aliases
        DATETIME(Datum_von, 'Europe/Berlin') as `datum_von`,
        DATETIME(Datum_bis, 'Europe/Berlin') as `datum_bis`,

        -- 2. Renaming a field (using standard snake_case without backticks for safety)
        cast(Biomasse_MWh_Originalaufloesungen as float64) as `biomasse`,
        cast(Wasserkraft_MWh_Originalaufloesungen as float64) as `wasserkraft`,
        cast(Wind_Offshore_MWh_Originalaufloesungen as float64) as `wind_offshore`,
        cast(Wind_Onshore_MWh_Originalaufloesungen as float64) as `wind_onshore`,
        cast(Photovoltaik_MWh_Originalaufloesungen as float64) as `photovoltaik`,
        cast(Sonstige_Erneuerbare_MWh_Originalaufloesungen as float64) as `sonstige_erneuerbare`,
        cast(Kernenergie_MWh_Originalaufloesungen as float64) as `kernenergie`,
        cast(Braunkohle_MWh_Originalaufloesungen as float64) as `braunkohle`,
        cast(Steinkohle_MWh_Originalaufloesungen as float64) as `steinkohle`,
        cast(Erdgas_MWh_Originalaufloesungen as float64) as `erdgas`,
        cast(Pumpspeicher_MWh_Originalaufloesungen as float64) as `pumpspeicher`,
        cast(Sonstige_Konventionelle_MWh_Originalaufloesungen as float64) as `sonstige_konventionelle`

    from source
)

select * from renamed