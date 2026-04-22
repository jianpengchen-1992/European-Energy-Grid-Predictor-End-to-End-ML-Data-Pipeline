{{ config(materialized='view',
    schema='marts') }}

WITH daily_aggregations AS (
    SELECT 
        -- 1. Truncate your timestamp to just the date
        DATE(timestamp_15min) AS energy_date,

        -- 2. Average Wholesale Price (Germany)
        AVG(market__wholesale_prices_de_lu) AS avg_price_de_lu,

        -- 3. Peak Residual Load (coming straight from the consumption data!)
        MAX(energy__actual_consumption_residuallast) AS peak_residual_load,

        -- Helper aggregates for generation types
        SUM(energy__actual_generation_total_renewable_energy) AS total_renewable_gen,
        
        -- New: Let's group the fossil fuels that have to cover the residual load
        SUM(energy__actual_generation_total_fossil_energy) AS total_fossil_gen,
        
        -- Make sure you have a total generation column, or calculate it by adding everything up
        SUM(energy__actual_generation_total_generation) AS total_daily_gen

    FROM {{ ref('intermediate_energy_weather_joined') }} -- Your OBT
    GROUP BY DATE(timestamp_15min)
)

SELECT 
    energy_date,
    total_renewable_gen,
    total_daily_gen,
    
    -- Rounding to 2 decimals makes it cleaner for the dashboard
    ROUND(avg_price_de_lu, 2) AS avg_price_de_lu,
    
    ROUND(peak_residual_load, 2) AS peak_residual_load,
    
    -- 4. Renewable Share (%)
    -- We use NULLIF to prevent "divide by zero" errors if data is missing
    ROUND(
        total_renewable_gen / NULLIF(total_daily_gen, 0), 4
    ) AS renewable_share_pct,

    -- PRO TIP: Create a helper column for your BI tool's color logic!
    CASE 
        WHEN avg_price_de_lu < 0 THEN 'Negative'
        WHEN avg_price_de_lu > 150 THEN 'High Spike' -- Adjust this threshold to your market
        ELSE 'Normal'
    END AS price_status_flag

FROM daily_aggregations