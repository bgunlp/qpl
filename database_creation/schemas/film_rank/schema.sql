USE spider;
CREATE TABLE  film_rank.film (
[Film_ID] int,
[Title] VARCHAR(400),
[Studio] VARCHAR(400),
[Director] VARCHAR(400),
[Gross_in_dollar] int,
PRIMARY KEY ([Film_ID])
);


CREATE TABLE  film_rank.market (
[Market_ID] int,
[Country] VARCHAR(400),
[Number_cities] int,
PRIMARY KEY ([Market_ID])
);


CREATE TABLE  film_rank.film_market_estimation (
[Estimation_ID] int,
[Low_Estimate] real,
[High_Estimate] real,
[Film_ID] int,
[Type] VARCHAR(400),
[Market_ID] int,
[Year] int,
PRIMARY KEY ([Estimation_ID]),
FOREIGN KEY ([Film_ID]) REFERENCES  film_rank.film([Film_ID]),
FOREIGN KEY ([Market_ID]) REFERENCES  film_rank.market([Market_ID])
);

