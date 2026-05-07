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
        cast(Datum_von as timestamp) as `timestamp_15min`,

        -- 2. Renaming a field (using standard snake_case without backticks for safety)
        cast(round(coalesce(Biomasse_MWh_Originalaufloesungen, 0), 1) as NUMERIC) as `biomasse`,
        cast(round(coalesce(Wasserkraft_MWh_Originalaufloesungen, 0), 1) as NUMERIC) as `wasserkraft`,
        cast(round(coalesce(Wind_Offshore_MWh_Originalaufloesungen, 0), 1) as NUMERIC) as `wind_offshore`,
        cast(round(coalesce(Wind_Onshore_MWh_Originalaufloesungen, 0), 1) as NUMERIC) as `wind_onshore`,
        cast(round(coalesce(Photovoltaik_MWh_Originalaufloesungen, 0), 1) as NUMERIC) as `photovoltaik`,
        cast(round(coalesce(Sonstige_Erneuerbare_MWh_Originalaufloesungen, 0), 1) as NUMERIC) as `sonstige_erneuerbare`,
        cast(round(coalesce(Kernenergie_MWh_Originalaufloesungen, 0), 1) as NUMERIC) as `kernenergie`,
        cast(round(coalesce(Braunkohle_MWh_Originalaufloesungen, 0), 1) as NUMERIC) as `braunkohle`,
        cast(round(coalesce(Steinkohle_MWh_Originalaufloesungen, 0), 1) as NUMERIC) as `steinkohle`,
        cast(round(coalesce(Erdgas_MWh_Originalaufloesungen, 0), 1) as NUMERIC) as `erdgas`,
        cast(round(coalesce(Pumpspeicher_MWh_Originalaufloesungen, 0), 1) as NUMERIC) as `pumpspeicher`,
        cast(round(coalesce(Sonstige_Konventionelle_MWh_Originalaufloesungen, 0), 1) as NUMERIC) as `sonstige_konventionelle`,

        -- combine wind offshore and onshore into a total wind column
        (
            cast(round((coalesce(Wind_Offshore_MWh_Originalaufloesungen, 0) + 
            coalesce(Wind_Onshore_MWh_Originalaufloesungen, 0)), 1) as NUMERIC)
        ) as total_wind_energy,

        -- combine all the fossil fuels into a total fossil generation column
        (
            cast(round(( coalesce(Braunkohle_MWh_Originalaufloesungen, 0) + 
            coalesce(Steinkohle_MWh_Originalaufloesungen, 0) + 
            coalesce(Erdgas_MWh_Originalaufloesungen, 0)+ 
            coalesce(Pumpspeicher_MWh_Originalaufloesungen, 0)+ 
            coalesce(Sonstige_Konventionelle_MWh_Originalaufloesungen, 0)), 1) as NUMERIC)
        ) as total_fossil_energy,
        -- Calculate total generation by adding up all sources (or use an existing total if it's in your data)
        (
            cast(round((coalesce(Biomasse_MWh_Originalaufloesungen, 0) + 
            coalesce(Wasserkraft_MWh_Originalaufloesungen, 0) + 
            coalesce(Wind_Offshore_MWh_Originalaufloesungen, 0) + 
            coalesce(Wind_Onshore_MWh_Originalaufloesungen, 0) + 
            coalesce(Photovoltaik_MWh_Originalaufloesungen, 0) + 
            coalesce(Sonstige_Erneuerbare_MWh_Originalaufloesungen, 0)), 1) as NUMERIC)
        ) as total_renewable_energy,
        (
            cast(round((coalesce(Wind_Offshore_MWh_Originalaufloesungen, 0) + 
            coalesce(Wind_Onshore_MWh_Originalaufloesungen, 0) + 
            coalesce(Photovoltaik_MWh_Originalaufloesungen, 0) + 
            coalesce(Biomasse_MWh_Originalaufloesungen, 0) +
            coalesce(Wasserkraft_MWh_Originalaufloesungen, 0) + 
            coalesce(Sonstige_Erneuerbare_MWh_Originalaufloesungen, 0) + 
            coalesce(Kernenergie_MWh_Originalaufloesungen, 0) + 
            coalesce(Braunkohle_MWh_Originalaufloesungen, 0) + 
            coalesce(Steinkohle_MWh_Originalaufloesungen, 0) + 
            coalesce(Erdgas_MWh_Originalaufloesungen, 0)+ 
            coalesce(Pumpspeicher_MWh_Originalaufloesungen, 0)+ 
            coalesce(Sonstige_Konventionelle_MWh_Originalaufloesungen, 0)), 1) as NUMERIC)
        ) as total_generation

    from source
)

select * from renamed