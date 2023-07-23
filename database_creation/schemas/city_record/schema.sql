USE spider;
CREATE TABLE  city_record.city (
[City_ID] int,
[City] VARCHAR(400),
[Hanzi] VARCHAR(400),
[Hanyu_Pinyin] VARCHAR(400),
[Regional_Population] int,
[GDP] real,
PRIMARY KEY ([City_ID])
);

CREATE TABLE  city_record.match (
[Match_ID] int,
[Date] VARCHAR(400),
[Venue] VARCHAR(400),
[Score] VARCHAR(400),
[Result] VARCHAR(400),
[Competition] VARCHAR(400),
PRIMARY KEY ([Match_ID])
);



CREATE TABLE  city_record.temperature (
[City_ID] int,
[Jan] real,
[Feb] real,
[Mar] real,
[Apr] real,
[Jun] real,
[Jul] real,
[Aug] real,
[Sep] real,
[Oct] real,
[Nov] real,
[Dec] real,
PRIMARY KEY ([City_ID]),
FOREIGN KEY (City_ID) REFERENCES  city_record.city(City_ID)
);

CREATE TABLE  city_record.hosting_city (
[Year] int,
[Match_ID] int,
[Host_City] int,
PRIMARY KEY ([Year]),
FOREIGN KEY (Host_City) REFERENCES  city_record.city(City_ID),
FOREIGN KEY (Match_ID) REFERENCES  city_record.match(Match_ID)
);

