USE spider;
BEGIN TRANSACTION;
CREATE TABLE  bike_1.station (
id INTEGER PRIMARY KEY,
name VARCHAR(400),
lat NUMERIC,
long NUMERIC,
dock_count INTEGER,
city VARCHAR(400),
installation_date VARCHAR(400));
CREATE TABLE  bike_1.status (
station_id INTEGER,
bikes_available INTEGER,
docks_available INTEGER,
time VARCHAR(400),
FOREIGN KEY (station_id) REFERENCES  bike_1.station(id)
);
CREATE TABLE  bike_1.trip (
id INTEGER PRIMARY KEY,
duration INTEGER,
start_date VARCHAR(400),
start_station_name VARCHAR(400), -- this should be removed
start_station_id INTEGER,
end_date VARCHAR(400),
end_station_name VARCHAR(400), -- this should be removed
end_station_id INTEGER,
bike_id INTEGER,
subscription_type VARCHAR(400),
zip_code INTEGER);
CREATE TABLE  bike_1.weather (
date VARCHAR(400),
max_temperature_f INTEGER,
mean_temperature_f INTEGER,
min_temperature_f INTEGER,
max_dew_point_f INTEGER,
mean_dew_point_f INTEGER,
min_dew_point_f INTEGER,
max_humidity INTEGER,
mean_humidity INTEGER,
min_humidity INTEGER,
max_sea_level_pressure_inches NUMERIC,
mean_sea_level_pressure_inches NUMERIC,
min_sea_level_pressure_inches NUMERIC,
max_visibility_miles INTEGER,
mean_visibility_miles INTEGER,
min_visibility_miles INTEGER,
max_wind_Speed_mph INTEGER,
mean_wind_speed_mph INTEGER,
max_gust_speed_mph INTEGER,
precipitation_inches REAL,
cloud_cover INTEGER,
events VARCHAR(400),
wind_dir_degrees INTEGER,
zip_code INTEGER);
COMMIT;
