USE spider;
CREATE TABLE  race_track.track (
[Track_ID] int,
[Name] VARCHAR(400),
[Location] VARCHAR(400),
[Seating] real,
[Year_Opened] real,
PRIMARY KEY ([Track_ID])
);

CREATE TABLE  race_track.race (
[Race_ID] int,
[Name] VARCHAR(400),
[Class] VARCHAR(400),
[Date] VARCHAR(400),
[Track_ID] int,
PRIMARY KEY ([Race_ID]),
FOREIGN KEY ([Track_ID]) REFERENCES  race_track.track([Track_ID])
);
