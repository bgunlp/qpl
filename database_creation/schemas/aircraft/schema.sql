USE spider;
CREATE TABLE  aircraft.pilot (
Pilot_Id int NOT NULL,
Name varchar(50) NOT NULL,
Age int NOT NULL,
PRIMARY KEY (Pilot_Id)
);

CREATE TABLE  aircraft.aircraft (
[Aircraft_ID] int NOT NULL,
[Aircraft] varchar(50) NOT NULL,
[Description] varchar(50) NOT NULL,
[Max_Gross_Weight] varchar(50) NOT NULL,
[Total_disk_area] varchar(50) NOT NULL,
[Max_disk_Loading] varchar(50) NOT NULL,
PRIMARY KEY (Aircraft_ID)
);


CREATE TABLE  aircraft.match (
[Round] real,
[Location] VARCHAR(400),
[Country] VARCHAR(400),
[Date] VARCHAR(400),
[Fastest_Qualifying] VARCHAR(400),
[Winning_Pilot] int,
[Winning_Aircraft] int,
PRIMARY KEY ([Round]),
FOREIGN KEY (Winning_Aircraft) REFERENCES  aircraft.aircraft(Aircraft_ID),
FOREIGN KEY (Winning_Pilot) REFERENCES  aircraft.pilot(Pilot_Id)
);

CREATE TABLE  aircraft.airport (
[Airport_ID] int,
[Airport_Name] VARCHAR(400),
[Total_Passengers] real,
[%_Change_2007] VARCHAR(400),
[International_Passengers] real,
[Domestic_Passengers] real,
[Transit_Passengers] real,
[Aircraft_Movements] real,
[Freight_Metric_Tonnes] real,
PRIMARY KEY ([Airport_ID])
);

CREATE TABLE  aircraft.airport_aircraft (
[ID] int,
[Airport_ID] int,
[Aircraft_ID] int,
PRIMARY KEY ([Airport_ID],[Aircraft_ID]),
FOREIGN KEY ([Airport_ID]) REFERENCES  aircraft.airport(Airport_ID),
FOREIGN KEY ([Aircraft_ID]) REFERENCES  aircraft.aircraft(Aircraft_ID)
);
