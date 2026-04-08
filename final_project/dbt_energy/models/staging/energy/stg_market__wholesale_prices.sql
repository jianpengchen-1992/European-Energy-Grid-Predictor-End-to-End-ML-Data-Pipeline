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
        cast(Deutschland_Luxemburg_MWh_Originalaufloesungen as NUMERIC) as `de_lu`,
        cast(Anrainer_DE_LU_MWh_Originalaufloesungen as NUMERIC) as `anrainer_de_lu`,
        cast(Belgien_MWh_Originalaufloesungen as NUMERIC) as `belgien`,
        cast(Daenemark_1_MWh_Originalaufloesungen as NUMERIC) as `daenemark_1`,
        cast(Daenemark_2_MWh_Originalaufloesungen as NUMERIC) as `daenemark_2`,
        cast(Frankreich_MWh_Originalaufloesungen as NUMERIC) as `frankreich`,
        cast(Niederlande_MWh_Originalaufloesungen as NUMERIC) as `niederlande`,
        cast(Norwegen_2_MWh_Originalaufloesungen as NUMERIC) as `norwegen_2`,
        cast(Oesterreich_MWh_Originalaufloesungen as NUMERIC) as `oesterreich`,
        cast(Polen_MWh_Originalaufloesungen as NUMERIC) as `polen`,
        cast(Schweden_4_MWh_Originalaufloesungen as NUMERIC) as `schweden_4`,
        cast(Schweiz_MWh_Originalaufloesungen as NUMERIC) as `schweiz`,
        cast(Tschechien_MWh_Originalaufloesungen as NUMERIC) as `tschechien`,
        cast(DE_AT_LU_MWh_Originalaufloesungen as NUMERIC) as `de_at_lu`,
        cast(Italien_Nord_MWh_Originalaufloesungen as NUMERIC) as `italien_nord`,
        cast(Slowenien_MWh_Originalaufloesungen as NUMERIC) as `slowenien`,
        cast(Ungarn_MWh_Originalaufloesungen as NUMERIC) as `ungarn`

    from source
)

select * from renamed