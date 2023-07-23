USE spider;
CREATE TABLE  swimming.swimmer (
[ID] int,
[name] VARCHAR(400),
[Nationality] VARCHAR(400),
[meter_100] real,
[meter_200] VARCHAR(400),
[meter_300] VARCHAR(400),
[meter_400] VARCHAR(400),
[meter_500] VARCHAR(400),
[meter_600] VARCHAR(400),
[meter_700] VARCHAR(400),
[Time] VARCHAR(400),
PRIMARY KEY ([ID])
);






CREATE TABLE  swimming.stadium (
[ID] int,
[name] VARCHAR(400),
[Capacity] int,
[City] VARCHAR(400),
[Country] VARCHAR(400),
[Opening_year] int,
PRIMARY KEY ([ID])
);





CREATE TABLE  swimming.event (
[ID] int,
[Name] VARCHAR(400),
[Stadium_ID] int,
[Year] VARCHAR(400),
PRIMARY KEY ([ID]),
FOREIGN KEY (Stadium_ID) REFERENCES  swimming.stadium(ID)
);

CREATE TABLE  swimming.record (
[ID] int,
[Result] VARCHAR(400),
[Swimmer_ID] int,
[Event_ID] int,
PRIMARY KEY ([Swimmer_ID],[Event_ID]),
FOREIGN KEY (Event_ID) REFERENCES  swimming.event(ID),
FOREIGN KEY (Swimmer_ID) REFERENCES  swimming.swimmer(ID)
);



