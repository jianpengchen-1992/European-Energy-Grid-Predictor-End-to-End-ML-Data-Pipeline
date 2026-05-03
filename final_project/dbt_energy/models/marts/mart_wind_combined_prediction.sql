{{ config(
    materialized='table',
    schema='marts'
) }}

-- Step 1: Ask the Offshore AI for its prediction
WITH predicted_offshore AS (
    SELECT 
        timestamp_15min, 
        predicted_gen_wind_offshore
    FROM ML.PREDICT(
        MODEL `{{ target.database }}.{{ target.schema }}.wind_offshore_model`, 
        (SELECT * FROM {{ ref('stg_weather_generation_joined') }})
    )
),

-- Step 2: Ask the Onshore AI for its prediction
predicted_onshore AS (
    SELECT 
        timestamp_15min, 
        predicted_gen_wind_onshore
    FROM ML.PREDICT(
        MODEL `{{ target.database }}.{{ target.schema }}.wind_onshore_model`, 
        (SELECT * FROM {{ ref('stg_weather_generation_joined') }})
    )
)

-- Step 3: Join them together and do the final math
SELECT 
    base.timestamp_15min,
    base.gen_wind_actual, -- This is your old, blurry "Frankenstein" target
    off.predicted_gen_wind_offshore,
    on.predicted_gen_wind_onshore,
    
    -- Here is the magic: We add the two smart predictions together
    (off.predicted_gen_wind_offshore + on.predicted_gen_wind_onshore) AS gen_wind_ml_predicted

FROM {{ ref('stg_weather_generation_joined') }} base
LEFT JOIN predicted_offshore off ON base.timestamp_15min = off.timestamp_15min
LEFT JOIN predicted_onshore on ON base.timestamp_15min = on.timestamp_15min