{% macro train_solar_model() %}

  {% set query %}
    CREATE OR REPLACE MODEL `{{ target.database }}.{{ target.schema }}.solar_capacity_model`
    OPTIONS(
        model_type='linear_reg', 
        input_label_cols=['actual_solar_generation']
    ) AS
    
    SELECT 
        -- Target
        COALESCE(energy__actual_generation_photovoltaik, 0) AS actual_solar_generation,
        
        -- The Features (Only Total Solar Radiation, NO direct/diffuse!)
        weather__actual_solar_radiation_muenchen,
        weather__actual_solar_radiation_freiburg_im_breisgau,
        weather__actual_solar_radiation_berlin,
        weather__actual_solar_radiation_hamburg,
        weather__actual_solar_radiation_rostock,
        weather__actual_solar_radiation_kiel
        
    FROM {{ ref('intermediate_energy_weather_joined') }}
    -- Filter out the night time so the math doesn't get skewed by zeroes
    WHERE COALESCE(energy__actual_generation_photovoltaik, 0) > 0
  {% endset %}

  {% do run_query(query) %}

{% endmacro %}