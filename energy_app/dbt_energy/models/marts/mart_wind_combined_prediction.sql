{{ config(
    materialized='table',
    schema='marts'
) }}

-- Step 1: Feed the base table to the Offshore AI
WITH predicted_offshore AS (
    SELECT * 
    FROM ML.PREDICT(
        MODEL `{{ target.database }}.{{ target.schema }}.wind_offshore_model`, 
        (SELECT * FROM {{ ref('intermediate_energy_weather_joined') }})
    )
),

-- Step 2: Feed the output of Step 1 to the Onshore AI
-- (It will predict onshore generation AND pass through the offshore predictions)
predicted_onshore_and_offshore AS (
    SELECT * 
    FROM ML.PREDICT(
        MODEL `{{ target.database }}.{{ target.schema }}.wind_onshore_model`, 
        (SELECT * FROM predicted_offshore)
    )
)

-- Step 3: Do the final math
SELECT 
    timestamp_15min,
    energy__actual_generation_wind_offshore + energy__actual_generation_wind_onshore AS gen_wind_actual, 
    predicted_gen_wind_offshore,
    predicted_gen_wind_onshore,
    
    -- Adding them together (ignoring the NULL safeguard per your request!)
    (predicted_gen_wind_offshore + predicted_gen_wind_onshore) AS gen_wind_ml_predicted

FROM predicted_onshore_and_offshore