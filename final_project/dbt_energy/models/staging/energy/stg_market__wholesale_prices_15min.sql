{{ config(
    materialized='view',
    schema='staging'

) }}

with source as (
    select * from {{ source('energy_data', 'market_prices_whole_sale') }}
),

renamed as (
    select
        -- Renaming happens here using standard SQL aliases
        cast(Datum_von as timestamp) as `datum_von`,
        cast(Datum_bis as timestamp) as `datum_bis`,

        -- 2. Renaming a field (using standard snake_case without backticks for safety)
        cast(round(Deutschland_Luxemburg_MWh_Originalaufloesungen, 1) as NUMERIC) as `de_lu`,
        cast(round(Anrainer_DE_LU_MWh_Originalaufloesungen, 1) as NUMERIC) as `anrainer_de_lu`,
        cast(round(Belgien_MWh_Originalaufloesungen, 1) as NUMERIC) as `belgien`,
        cast(round(Daenemark_1_MWh_Originalaufloesungen, 1) as NUMERIC) as `daenemark_1`,
        cast(round(Daenemark_2_MWh_Originalaufloesungen, 1) as NUMERIC) as `daenemark_2`,
        cast(round(Frankreich_MWh_Originalaufloesungen, 1) as NUMERIC) as `frankreich`,
        cast(round(Niederlande_MWh_Originalaufloesungen, 1) as NUMERIC) as `niederlande`,
        cast(round(Norwegen_2_MWh_Originalaufloesungen, 1) as NUMERIC) as `norwegen_2`,
        cast(round(Oesterreich_MWh_Originalaufloesungen, 1) as NUMERIC) as `oesterreich`,
        cast(round(Polen_MWh_Originalaufloesungen, 1) as NUMERIC) as `polen`,
        cast(round(Schweden_4_MWh_Originalaufloesungen, 1) as NUMERIC) as `schweden_4`,
        cast(round(Schweiz_MWh_Originalaufloesungen, 1) as NUMERIC) as `schweiz`,
        cast(round(Tschechien_MWh_Originalaufloesungen, 1) as NUMERIC) as `tschechien`,
        cast(round(DE_AT_LU_MWh_Originalaufloesungen, 1) as NUMERIC) as `de_at_lu`,
        cast(round(Italien_Nord_MWh_Originalaufloesungen, 1) as NUMERIC) as `italien_nord`,
        cast(round(Slowenien_MWh_Originalaufloesungen, 1) as NUMERIC) as `slowenien`,
        cast(round(Ungarn_MWh_Originalaufloesungen, 1) as NUMERIC) as `ungarn`

    from source
)

select * from renamed