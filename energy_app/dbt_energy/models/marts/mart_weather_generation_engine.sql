{{ config(
    materialized='view',
    schema='marts'
) }}

SELECT 
    timestamp_15min,
    DATE(timestamp_15min) AS energy_date,

    -- 1. The Wind Engine (Powered by BQML)
    -- We map the predicted column that BigQuery ML automatically generates
    energy__actual_generation_wind_onshore,
    energy__actual_generation_wind_offshore,
    weather__actual_wind_speed_100m_rostock,
    weather__actual_wind_speed_100m_muenchen,
    weather__actual_wind_speed_100m_freiburg_im_breisgau,
    weather__actual_wind_speed_100m_hamburg,
    weather__actual_wind_speed_100m_kiel,
    weather__actual_wind_speed_100m_berlin,
    predicted_actual_wind_generation AS gen_wind_ml_predicted,

    -- 2. The Solar Engine (Powered by Geographic Weighting)
    -- We pass the solar data straight through the subquery below
        gen_solar_actual,
    (
        (COALESCE(weather__actual_solar_radiation_berlin, 0) * 0.32) + 
        (COALESCE(weather__actual_solar_radiation_muenchen, 0) * 0.27) + 
        (COALESCE(weather__actual_solar_radiation_hamburg, 0) * 0.21) +
        (COALESCE(weather__actual_solar_radiation_freiburg_im_breisgau, 0) * 0.17) 
    ) AS ai_weighted_national_solar_index,

FROM ML.PREDICT(
    MODEL `{{ target.database }}.{{ target.schema }}.wind_capacity_model`,
    (
        SELECT 
            timestamp_15min,
            -- Target
            energy__actual_generation_wind_onshore,
            energy__actual_generation_wind_offshore,
            
            -- Solar Passthrough
            COALESCE(energy__actual_generation_photovoltaik, 0) AS gen_solar_actual,
            weather__actual_solar_radiation_muenchen,
            weather__actual_solar_radiation_freiburg_im_breisgau,
            weather__actual_solar_radiation_berlin,
            weather__actual_solar_radiation_hamburg,

            -- The Kitchen Sink (All your Wind Features from the macro go here)
            weather__actual_wind_speed_100m_rostock,
            weather__actual_wind_speed_100m_muenchen,
            weather__actual_wind_speed_100m_freiburg_im_breisgau,
            weather__actual_wind_speed_100m_hamburg,
            weather__actual_wind_speed_100m_kiel,
            weather__actual_wind_speed_100m_berlin,
            weather__actual_wind_direction_100m_rostock,
            weather__actual_wind_direction_100m_muenchen,
            weather__actual_wind_direction_100m_freiburg_im_breisgau,
            weather__actual_wind_direction_100m_hamburg,
            weather__actual_wind_direction_100m_kiel,
            weather__actual_wind_direction_100m_berlin,
            weather__actual_temperature_2m_rostock,
            weather__actual_temperature_2m_muenchen,
            weather__actual_temperature_2m_freiburg_im_breisgau,
            weather__actual_temperature_2m_hamburg,
            weather__actual_temperature_2m_kiel,
            weather__actual_temperature_2m_berlin

        FROM {{ ref('intermediate_energy_weather_joined') }}
    )
    
)
