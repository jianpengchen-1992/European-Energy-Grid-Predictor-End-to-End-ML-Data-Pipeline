{% macro train_wind_offshore_model() %}

    {% set train_query %}
        CREATE OR REPLACE MODEL `{{ target.database }}.{{ target.schema }}.wind_offshore_model`
        OPTIONS(
            model_type='BOOSTED_TREE_REGRESSOR',
            input_label_cols=['gen_wind_offshore']
        ) AS
        SELECT
            energy__actual_generation_wind_offshore AS gen_wind_offshore,
            -- Coastal Cities Only
            weather__actual_wind_speed_100m_hamburg,
            weather__actual_wind_direction_100m_hamburg,
            weather__actual_temperature_2m_hamburg,
            weather__actual_wind_speed_100m_rostock,
            weather__actual_wind_direction_100m_rostock,
            weather__actual_temperature_2m_rostock,
            weather__actual_wind_speed_100m_kiel,
            weather__actual_wind_direction_100m_kiel,
            weather__actual_temperature_2m_kiel
        FROM {{ ref('intermediate_energy_weather_joined') }} 
        WHERE energy__actual_generation_wind_offshore IS NOT NULL
    {% endset %}

    {% do run_query(train_query) %}
    {{ log("Successfully trained Offshore ML Model!", info=True) }}

{% endmacro %}