USE spider;
CREATE TABLE  farm.city (
[City_ID] int,
[Official_Name] VARCHAR(400),
[Status] VARCHAR(400),
[Area_km_2] real,
[Population] real,
[Census_Ranking] VARCHAR(400),
PRIMARY KEY ([City_ID])
);

CREATE TABLE  farm.farm (
[Farm_ID] int,
[Year] int,
[Total_Horses] real,
[Working_Horses] real,
[Total_Cattle] real,
[Oxen] real,
[Bulls] real,
[Cows] real,
[Pigs] real,
[Sheep_and_Goats] real,
PRIMARY KEY ([Farm_ID])
);

CREATE TABLE  farm.farm_competition (
[Competition_ID] int,
[Year] int,
[Theme] VARCHAR(400),
[Host_city_ID] int,
[Hosts] VARCHAR(400),
PRIMARY KEY ([Competition_ID]),
FOREIGN KEY (Host_city_ID) REFERENCES  farm.city(City_ID)
);


CREATE TABLE  farm.competition_record (
[Competition_ID] int,
[Farm_ID] int,
[Rank] int,
PRIMARY KEY ([Competition_ID],[Farm_ID]),
FOREIGN KEY (Competition_ID) REFERENCES  farm.farm_competition(Competition_ID),
FOREIGN KEY (Farm_ID) REFERENCES  farm.farm(Farm_ID)
);

