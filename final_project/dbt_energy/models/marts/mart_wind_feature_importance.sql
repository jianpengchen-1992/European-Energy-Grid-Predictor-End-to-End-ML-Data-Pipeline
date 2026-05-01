{{ config(
    materialized='table',
    schema='marts'
) }}

WITH raw_explain AS (
    SELECT 
        feature AS weather_column,
        attribution AS raw_score
    FROM ML.GLOBAL_EXPLAIN(MODEL `{{ target.database }}.{{ target.schema }}.wind_capacity_model`)
),

-- NEW STEP: Group the raw scores by geographic region before doing the math
grouped_regions AS (
    SELECT 
        CASE 
            WHEN weather_column LIKE '%hamburg%' THEN '1 | Hamburg Region'
            WHEN weather_column LIKE '%rostock%' THEN '2 | Rostock Region'
            WHEN weather_column LIKE '%kiel%' THEN '3 | Kiel Region'
            WHEN weather_column LIKE '%berlin%' THEN '4 | Berlin Region'
            WHEN weather_column LIKE '%freiburg%' THEN '5 | Freiburg Region'
            WHEN weather_column LIKE '%muenchen%' THEN '6 | Munich Region'
            ELSE '7 | Unknown/Other' 
        END AS regional_driver,
        SUM(raw_score) AS regional_raw_score
    FROM raw_explain
    GROUP BY 1
)

-- FINAL STEP: Calculate the clean percentage based on the entire region
SELECT 
    regional_driver,
    ROUND((regional_raw_score / SUM(regional_raw_score) OVER()) * 100, 2) AS importance_percentage
FROM grouped_regions
ORDER BY importance_percentage DESC