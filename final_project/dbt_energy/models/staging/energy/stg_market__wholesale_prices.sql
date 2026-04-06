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
        DATETIME(Datum_von, 'Europe/Berlin') as `datum_von`,
        DATETIME(Datum_bis, 'Europe/Berlin') as `datum_bis`,

        -- 2. Renaming a field (using standard snake_case without backticks for safety)
        cast(Deutschland_Luxemburg_MWh_Originalaufloesungen as float64) as `de_lu`,
        cast(Anrainer_DE_LU_MWh_Originalaufloesungen as float64) as `anrainer_de_lu`,
        cast(Belgien_MWh_Originalaufloesungen as float64) as `belgien`,
        cast(Daenemark_1_MWh_Originalaufloesungen as float64) as `daenemark_1`,
        cast(Daenemark_2_MWh_Originalaufloesungen as float64) as `daenemark_2`,
        cast(Frankreich_MWh_Originalaufloesungen as float64) as `frankreich`,
        cast(Niederlande_MWh_Originalaufloesungen as float64) as `niederlande`,
        cast(Norwegen_2_MWh_Originalaufloesungen as float64) as `norwegen_2`,
        cast(Oesterreich_MWh_Originalaufloesungen as float64) as `oesterreich`,
        cast(Polen_MWh_Originalaufloesungen as float64) as `polen`,
        cast(Schweden_4_MWh_Originalaufloesungen as float64) as `schweden_4`,
        cast(Schweiz_MWh_Originalaufloesungen as float64) as `schweiz`,
        cast(Tschechien_MWh_Originalaufloesungen as float64) as `tschechien`,
        cast(DE_AT_LU_MWh_Originalaufloesungen as float64) as `de_at_lu`,
        cast(Italien_Nord_MWh_Originalaufloesungen as float64) as `italien_nord`,
        cast(Slowenien_MWh_Originalaufloesungen as float64) as `slowenien`,
        cast(Ungarn_MWh_Originalaufloesungen as float64) as `ungarn`

    from source
)

select * from renamed