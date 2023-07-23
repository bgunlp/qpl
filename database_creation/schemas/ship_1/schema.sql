USE spider;
CREATE TABLE  ship_1.Ship (
[Ship_ID] int,
[Name] VARCHAR(400),
[Type] VARCHAR(400),
[Built_Year] real,
[Class] VARCHAR(400),
[Flag] VARCHAR(400),
PRIMARY KEY ([Ship_ID])
);

CREATE TABLE  ship_1.captain (
[Captain_ID] int,
[Name] VARCHAR(400),
[Ship_ID] int,
[age] int,
[Class] VARCHAR(400),
[Rank] VARCHAR(400),
PRIMARY KEY ([Captain_ID]),
FOREIGN KEY ([Ship_ID]) REFERENCES  ship_1.Ship([Ship_ID])
);
