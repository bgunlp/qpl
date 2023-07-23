USE spider;
CREATE TABLE  climbing.mountain (
[Mountain_ID] int,
[Name] VARCHAR(400),
[Height] real,
[Prominence] real,
[Range] VARCHAR(400),
[Country] VARCHAR(400),
PRIMARY KEY ([Mountain_ID])
);

CREATE TABLE  climbing.climber (
[Climber_ID] int,
[Name] VARCHAR(400),
[Country] VARCHAR(400),
[Time] VARCHAR(400),
[Points] real,
[Mountain_ID] int,
PRIMARY KEY ([Climber_ID]),
FOREIGN KEY ([Mountain_ID]) REFERENCES  climbing.mountain([Mountain_ID])
);


