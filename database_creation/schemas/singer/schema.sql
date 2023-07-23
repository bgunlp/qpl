USE spider;
CREATE TABLE  singer.singer (
[Singer_ID] int,
[Name] VARCHAR(400),
[Birth_Year] real,
[Net_Worth_Millions] real,
[Citizenship] VARCHAR(400),
PRIMARY KEY ([Singer_ID])
);

CREATE TABLE  singer.song (
[Song_ID] int,
[Title] VARCHAR(400),
[Singer_ID] int,
[Sales] real,
[Highest_Position] real,
PRIMARY KEY ([Song_ID]),
FOREIGN KEY ([Singer_ID]) REFERENCES  singer.singer([Singer_ID])
);
