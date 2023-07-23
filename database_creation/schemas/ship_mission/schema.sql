USE spider;
CREATE TABLE  ship_mission.ship (
[Ship_ID] int,
[Name] VARCHAR(400),
[Type] VARCHAR(400),
[Nationality] VARCHAR(400),
[Tonnage] int,
PRIMARY KEY ([Ship_ID])
);

CREATE TABLE  ship_mission.mission (
[Mission_ID] int,
[Ship_ID] int,
[Code] VARCHAR(400),
[Launched_Year] int,
[Location] VARCHAR(400),
[Speed_knots] int,
[Fate] VARCHAR(400),
PRIMARY KEY ([Mission_ID]),
FOREIGN KEY ([Ship_ID]) REFERENCES  ship_mission.ship([Ship_ID])
);
