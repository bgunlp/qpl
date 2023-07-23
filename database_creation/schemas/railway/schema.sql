USE spider;
CREATE TABLE  railway.railway (
[Railway_ID] int,
[Railway] VARCHAR(400),
[Builder] VARCHAR(400),
[Built] VARCHAR(400),
[Wheels] VARCHAR(400),
[Location] VARCHAR(400),
[ObjectNumber] VARCHAR(400),
PRIMARY KEY ([Railway_ID])
);

CREATE TABLE  railway.train (
[Train_ID] int,
[Train_Num] VARCHAR(400),
[Name] VARCHAR(400),
[From] VARCHAR(400),
[Arrival] VARCHAR(400),
[Railway_ID] int,
PRIMARY KEY ([Train_ID]),
FOREIGN KEY ([Railway_ID]) REFERENCES  railway.railway([Railway_ID])
);

CREATE TABLE  railway.manager (
[Manager_ID] int,
[Name] VARCHAR(400),
[Country] VARCHAR(400),
[Working_year_starts] VARCHAR(400),
[Age] int,
[Level] int,
PRIMARY KEY ([Manager_ID])
);


CREATE TABLE  railway.railway_manage (
[Railway_ID] int,
[Manager_ID] int,
[From_Year] VARCHAR(400),
PRIMARY KEY ([Railway_ID],[Manager_ID]),
FOREIGN KEY ([Manager_ID]) REFERENCES  railway.manager([Manager_ID]),
FOREIGN KEY ([Railway_ID]) REFERENCES  railway.railway([Railway_ID])
);
