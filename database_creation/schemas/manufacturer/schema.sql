USE spider;
CREATE TABLE  manufacturer.manufacturer (
[Manufacturer_ID] int,
[Open_Year] real,
[Name] VARCHAR(400),
[Num_of_Factories] int,
[Num_of_Shops] int,
PRIMARY KEY ([Manufacturer_ID])
);

CREATE TABLE  manufacturer.furniture (
[Furniture_ID] int,
[Name] VARCHAR(400),
[Num_of_Component] int,
[Market_Rate] real,
PRIMARY KEY ([Furniture_ID])
);


CREATE TABLE  manufacturer.furniture_manufacte (
[Manufacturer_ID] int,
[Furniture_ID] int,
[Price_in_Dollar] real,
PRIMARY KEY ([Manufacturer_ID],[Furniture_ID]),
FOREIGN KEY ([Manufacturer_ID]) REFERENCES  manufacturer.manufacturer([Manufacturer_ID]),
FOREIGN KEY ([Furniture_ID]) REFERENCES  manufacturer.furniture([Furniture_ID])
);
