USE spider;
CREATE TABLE  concert_singer.stadium (
[Stadium_ID] int,
[Location] VARCHAR(400),
[Name] VARCHAR(400),
[Capacity] int,
[Highest] int,
[Lowest] int,
[Average] int,
PRIMARY KEY ([Stadium_ID])
);


CREATE TABLE  concert_singer.singer (
[Singer_ID] int,
[Name] VARCHAR(400),
[Country] VARCHAR(400),
[Song_Name] VARCHAR(400),
[Song_release_year] VARCHAR(400),
[Age] int,
[Is_male] CHAR(1),
PRIMARY KEY ([Singer_ID]),
CONSTRAINT CHK_Is_male CHECK ([Is_male] IN ('T', 'F'))
);


CREATE TABLE  concert_singer.concert (
[concert_ID] int,
[concert_Name] VARCHAR(400),
[Theme] VARCHAR(400),
[Stadium_ID] int,
[Year] VARCHAR(400),
PRIMARY KEY ([concert_ID]),
FOREIGN KEY ([Stadium_ID]) REFERENCES  concert_singer.stadium([Stadium_ID])
);


CREATE TABLE  concert_singer.singer_in_concert (
[concert_ID] int,
[Singer_ID] int,
PRIMARY KEY ([concert_ID],[Singer_ID]),
FOREIGN KEY ([concert_ID]) REFERENCES  concert_singer.concert([concert_ID]),
FOREIGN KEY ([Singer_ID]) REFERENCES  concert_singer.singer([Singer_ID])
);
