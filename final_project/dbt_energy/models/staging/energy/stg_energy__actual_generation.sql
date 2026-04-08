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
        cast(Datum_von as timestamp) as `datum_von`,
        cast(Datum_bis as timestamp) as `datum_bis`,

        -- 2. Renaming a field (using standard snake_case without backticks for safety)
        cast(Biomasse_MWh_Originalaufloesungen as NUMERIC) as `biomasse`,
        cast(Wasserkraft_MWh_Originalaufloesungen as NUMERIC) as `wasserkraft`,
        cast(Wind_Offshore_MWh_Originalaufloesungen as NUMERIC) as `wind_offshore`,
        cast(Wind_Onshore_MWh_Originalaufloesungen as NUMERIC) as `wind_onshore`,
        cast(Photovoltaik_MWh_Originalaufloesungen as NUMERIC) as `photovoltaik`,
        cast(Sonstige_Erneuerbare_MWh_Originalaufloesungen as NUMERIC) as `sonstige_erneuerbare`,
        cast(Kernenergie_MWh_Originalaufloesungen as NUMERIC) as `kernenergie`,
        cast(Braunkohle_MWh_Originalaufloesungen as NUMERIC) as `braunkohle`,
        cast(Steinkohle_MWh_Originalaufloesungen as NUMERIC) as `steinkohle`,
        cast(Erdgas_MWh_Originalaufloesungen as NUMERIC) as `erdgas`,
        cast(Pumpspeicher_MWh_Originalaufloesungen as NUMERIC) as `pumpspeicher`,
        cast(Sonstige_Konventionelle_MWh_Originalaufloesungen as NUMERIC) as `sonstige_konventionelle`

    from source
)

select * from renamed