USE spider;
CREATE TABLE  roller_coaster.country (
[Country_ID] int,
[Name] VARCHAR(400),
[Population] int,
[Area] int,
[Languages] VARCHAR(400),
PRIMARY KEY ([Country_ID])
);

CREATE TABLE  roller_coaster.roller_coaster (
[Roller_Coaster_ID] int,
[Name] VARCHAR(400),
[Park] VARCHAR(400),
[Country_ID] int,
[Length] real,
[Height] real,
[Speed] real,
[Opened] VARCHAR(400),
[Status] VARCHAR(400),
PRIMARY KEY ([Roller_Coaster_ID]),
FOREIGN KEY ([Country_ID]) REFERENCES  roller_coaster.country([Country_ID])
);
