{% macro train_wind_onshore_model() %}
    {% set train_query %}
        CREATE OR REPLACE MODEL `{{ target.database }}.{{ target.schema }}.wind_onshore_model`
        OPTIONS(
            model_type='BOOSTED_TREE_REGRESSOR',
            input_label_cols=['gen_wind_onshore']
        ) AS
        SELECT
            energy__actual_generation_wind_onshore AS gen_wind_onshore,
            weather__actual_wind_speed_100m_hamburg,
            weather__actual_wind_direction_100m_hamburg,
            weather__actual_temperature_2m_hamburg,
            weather__actual_wind_speed_100m_rostock,
            weather__actual_wind_direction_100m_rostock,
            weather__actual_temperature_2m_rostock,
            weather__actual_wind_speed_100m_kiel,
            weather__actual_wind_direction_100m_kiel,
            weather__actual_temperature_2m_kiel,
            weather__actual_wind_speed_100m_berlin,
            weather__actual_wind_direction_100m_berlin,
            weather__actual_temperature_2m_berlin,
            weather__actual_wind_speed_100m_muenchen,
            weather__actual_wind_direction_100m_muenchen,
            weather__actual_temperature_2m_muenchen,
            weather__actual_wind_speed_100m_freiburg_im_breisgau,
            weather__actual_wind_direction_100m_freiburg_im_breisgau,
            weather__actual_temperature_2m_freiburg_im_breisgau
        FROM {{ ref('intermediate_energy_weather_joined') }}
        WHERE energy__actual_generation_wind_onshore IS NOT NULL
    {% endset %}

    {% do run_query(train_query) %}
    {{ log("Successfully trained Onshore ML Model!", info=True) }}
{% endmacro %}