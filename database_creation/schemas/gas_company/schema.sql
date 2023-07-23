USE spider;
CREATE TABLE  gas_company.company (
[Company_ID] int,
[Rank] int,
[Company] VARCHAR(400),
[Headquarters] VARCHAR(400),
[Main_Industry] VARCHAR(400),
[Sales_billion] real,
[Profits_billion] real,
[Assets_billion] real,
[Market_Value] real,
PRIMARY KEY ([Company_ID])
);

CREATE TABLE  gas_company.gas_station (
[Station_ID] int,
[Open_Year] int,
[Location] VARCHAR(400),
[Manager_Name] VARCHAR(400),
[Vice_Manager_Name] VARCHAR(400),
[Representative_Name] VARCHAR(400),
PRIMARY KEY ([Station_ID])
);

CREATE TABLE  gas_company.station_company (
[Station_ID] int,
[Company_ID] int,
[Rank_of_the_Year] int,
PRIMARY KEY ([Station_ID],[Company_ID]),
FOREIGN KEY (Station_ID) REFERENCES  gas_company.gas_station(Station_ID),
FOREIGN KEY (Company_ID) REFERENCES  gas_company.company(Company_ID)
);
