USE spider;
CREATE TABLE  school_bus.driver (
[Driver_ID] int,
[Name] VARCHAR(400),
[Party] VARCHAR(400),
[Home_city] VARCHAR(400),
[Age] int,
PRIMARY KEY ([Driver_ID])
);

CREATE TABLE  school_bus.school (
[School_ID] int,
[Grade] VARCHAR(400),
[School] VARCHAR(400),
[Location] VARCHAR(400),
[Type] VARCHAR(400),
PRIMARY KEY ([School_ID])
);

CREATE TABLE  school_bus.school_bus (
[School_ID] int,
[Driver_ID] int,
[Years_Working] int,
[If_full_time] CHAR(1),
PRIMARY KEY ([School_ID],[Driver_ID]),
FOREIGN KEY ([School_ID]) REFERENCES  school_bus.school([School_ID]),
FOREIGN KEY ([Driver_ID]) REFERENCES  school_bus.driver([Driver_ID]),
CONSTRAINT CHK_If_full_time CHECK ([If_full_time] IN ('T', 'F'))
);