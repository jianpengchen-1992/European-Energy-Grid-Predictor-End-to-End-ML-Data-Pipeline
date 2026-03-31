with source as (
    select * from {{ source('energy_data', 'actual_consumption') }}
),

renamed as (
    select
        -- Renaming happens here using standard SQL aliases
        record_id as reading_id,
        kw_h as kilowatt_hours,
        
        -- Casting data types also happens here
        cast(read_timestamp as timestamp) as reading_time
    from source
)

select * from renamed