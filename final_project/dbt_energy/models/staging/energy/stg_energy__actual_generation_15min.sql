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
        cast(round(Biomasse_MWh_Originalaufloesungen, 1) as NUMERIC) as `biomasse`,
        cast(round(Wasserkraft_MWh_Originalaufloesungen, 1) as NUMERIC) as `wasserkraft`,
        cast(round(Wind_Offshore_MWh_Originalaufloesungen, 1) as NUMERIC) as `wind_offshore`,
        cast(round(Wind_Onshore_MWh_Originalaufloesungen, 1) as NUMERIC) as `wind_onshore`,
        cast(round(Photovoltaik_MWh_Originalaufloesungen, 1) as NUMERIC) as `photovoltaik`,
        cast(round(Sonstige_Erneuerbare_MWh_Originalaufloesungen, 1) as NUMERIC) as `sonstige_erneuerbare`,
        cast(round(Kernenergie_MWh_Originalaufloesungen, 1) as NUMERIC) as `kernenergie`,
        cast(round(Braunkohle_MWh_Originalaufloesungen, 1) as NUMERIC) as `braunkohle`,
        cast(round(Steinkohle_MWh_Originalaufloesungen, 1) as NUMERIC) as `steinkohle`,
        cast(round(Erdgas_MWh_Originalaufloesungen, 1) as NUMERIC) as `erdgas`,
        cast(round(Pumpspeicher_MWh_Originalaufloesungen, 1) as NUMERIC) as `pumpspeicher`,
        cast(round(Sonstige_Konventionelle_MWh_Originalaufloesungen, 1) as NUMERIC) as `sonstige_konventionelle`

    from source
)

select * from renamed