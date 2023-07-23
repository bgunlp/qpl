USE spider;
CREATE TABLE  station_weather.train (
[id] int,
[train_number] int,
[name] VARCHAR(400),
[origin] VARCHAR(400),
[destination] VARCHAR(400),
[time] VARCHAR(400),
[interval] VARCHAR(400),
primary key ([id])
);

CREATE TABLE  station_weather.station (
[id] int,
[network_name] VARCHAR(400),
[services] VARCHAR(400),
[local_authority] VARCHAR(400),
primary key ([id])
);

CREATE TABLE  station_weather.route (
[train_id] int,
[station_id] int,
primary key ([train_id], [station_id]),
foreign key ([train_id]) references  station_weather.train([id]),
foreign key ([station_id]) references  station_weather.station([id])
);

CREATE TABLE  station_weather.weekly_weather (
[station_id] int,
[day_of_week] VARCHAR(400),
[high_temperature] int,
[low_temperature] int,
[precipitation] real,
[wind_speed_mph] int,
primary key ([station_id], [day_of_week]),
foreign key ([station_id]) references  station_weather.station([id])
);





