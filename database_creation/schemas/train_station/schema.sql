USE spider;
CREATE TABLE  train_station.station (
[Station_ID] int,
[Name] VARCHAR(400),
[Annual_entry_exit] real,
[Annual_interchanges] real,
[Total_Passengers] real,
[Location] VARCHAR(400),
[Main_Services] VARCHAR(400),
[Number_of_Platforms] int,
PRIMARY KEY ([Station_ID])
);

CREATE TABLE  train_station.train (
[Train_ID] int,
[Name] VARCHAR(400),
[Time] VARCHAR(400),
[Service] VARCHAR(400),
PRIMARY KEY ([Train_ID])
);





CREATE TABLE  train_station.train_station (
[Train_ID] int,
[Station_ID] int,
PRIMARY KEY ([Train_ID],[Station_ID]),
FOREIGN KEY ([Train_ID]) REFERENCES  train_station.train([Train_ID]),
FOREIGN KEY ([Station_ID]) REFERENCES  train_station.station([Station_ID])
);



