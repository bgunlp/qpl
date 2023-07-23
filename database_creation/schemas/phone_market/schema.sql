USE spider;
CREATE TABLE  phone_market.phone (
[Name] VARCHAR(400),
[Phone_ID] int,
[Memory_in_G] int,
[Carrier] VARCHAR(400),
[Price] real,
PRIMARY KEY ([Phone_ID])
);

CREATE TABLE  phone_market.market (
[Market_ID] int,
[District] VARCHAR(400),
[Num_of_employees] int,
[Num_of_shops] real,
[Ranking] int,
PRIMARY KEY ([Market_ID])
);

CREATE TABLE  phone_market.phone_market (
[Market_ID] int,
[Phone_ID] int,
[Num_of_stock] int,
PRIMARY KEY ([Market_ID],[Phone_ID]),
FOREIGN KEY ([Market_ID]) REFERENCES  phone_market.market([Market_ID]),
FOREIGN KEY ([Phone_ID]) REFERENCES  phone_market.phone([Phone_ID])
);

