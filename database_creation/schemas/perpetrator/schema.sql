USE spider;
CREATE TABLE  perpetrator.people (
[People_ID] int,
[Name] VARCHAR(400),
[Height] real,
[Weight] real,
[Home Town] VARCHAR(400),
PRIMARY KEY ([People_ID])
);

CREATE TABLE  perpetrator.perpetrator (
[Perpetrator_ID] int,
[People_ID] int,
[Date] VARCHAR(400),
[Year] real,
[Location] VARCHAR(400),
[Country] VARCHAR(400),
[Killed] int,
[Injured] int,
PRIMARY KEY ([Perpetrator_ID]),
FOREIGN KEY ([People_ID]) REFERENCES  perpetrator.people([People_ID])
);
