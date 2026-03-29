import openmeteo_requests

import pandas as pd
import requests_cache
from retry_requests import retry

# Setup the Open-Meteo API client with cache and retry on error
cache_session = requests_cache.CachedSession('.cache', expire_after = 3600)
retry_session = retry(cache_session, retries = 5, backoff_factor = 0.2)
openmeteo = openmeteo_requests.Client(session = retry_session)

# Make sure all required weather variables are listed here
# The order of variables in hourly or daily is important to assign them correctly below
url = "https://customer-historical-forecast-api.open-meteo.com/v1/forecast"
params = {
	"latitude": 52.52,
	"longitude": 13.41,
	"start_date": "2022-01-01",
	"end_date": "2022-12-31",
	"minutely_15": ["temperature_2m", "wind_speed_80m", "snowfall", "wind_direction_80m", "precipitation", "shortwave_radiation", "direct_radiation", "diffuse_radiation"],
}
responses = openmeteo.weather_api(url, params = params)

# Process first location. Add a for-loop for multiple locations or weather models
response = responses[0]
print(f"Coordinates: {response.Latitude()}°N {response.Longitude()}°E")
print(f"Elevation: {response.Elevation()} m asl")
print(f"Timezone difference to GMT+0: {response.UtcOffsetSeconds()}s")

# Process minutely_15 data. The order of variables needs to be the same as requested.
minutely_15 = response.Minutely15()
minutely_15_temperature_2m = minutely_15.Variables(0).ValuesAsNumpy()
minutely_15_wind_speed_80m = minutely_15.Variables(1).ValuesAsNumpy()
minutely_15_snowfall = minutely_15.Variables(2).ValuesAsNumpy()
minutely_15_wind_direction_80m = minutely_15.Variables(3).ValuesAsNumpy()
minutely_15_precipitation = minutely_15.Variables(4).ValuesAsNumpy()
minutely_15_shortwave_radiation = minutely_15.Variables(5).ValuesAsNumpy()
minutely_15_direct_radiation = minutely_15.Variables(6).ValuesAsNumpy()
minutely_15_diffuse_radiation = minutely_15.Variables(7).ValuesAsNumpy()

minutely_15_data = {"date": pd.date_range(
	start = pd.to_datetime(minutely_15.Time(), unit = "s", utc = True),
	end =  pd.to_datetime(minutely_15.TimeEnd(), unit = "s", utc = True),
	freq = pd.Timedelta(seconds = minutely_15.Interval()),
	inclusive = "left"
)}

minutely_15_data["temperature_2m"] = minutely_15_temperature_2m
minutely_15_data["wind_speed_80m"] = minutely_15_wind_speed_80m
minutely_15_data["snowfall"] = minutely_15_snowfall
minutely_15_data["wind_direction_80m"] = minutely_15_wind_direction_80m
minutely_15_data["precipitation"] = minutely_15_precipitation
minutely_15_data["shortwave_radiation"] = minutely_15_shortwave_radiation
minutely_15_data["direct_radiation"] = minutely_15_direct_radiation
minutely_15_data["diffuse_radiation"] = minutely_15_diffuse_radiation

minutely_15_dataframe = pd.DataFrame(data = minutely_15_data)
print("\nMinutely15 data\n", minutely_15_dataframe)
