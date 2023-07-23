USE spider;
CREATE TABLE  county_public_safety.county_public_safety (
[County_ID] int,
[Name] VARCHAR(400),
[Population] int,
[Police_officers] int,
[Residents_per_officer] int,
[Case_burden] int,
[Crime_rate] real,
[Police_force] VARCHAR(400),
[Location] VARCHAR(400),
PRIMARY KEY ([County_ID])
);

CREATE TABLE  county_public_safety.city (
[City_ID] int,
[County_ID] int,
[Name] VARCHAR(400),
[White] real,
[Black] real,
[Amerindian] real,
[Asian] real,
[Multiracial] real,
[Hispanic] real,
PRIMARY KEY ([City_ID]),
FOREIGN KEY ([County_ID]) REFERENCES  county_public_safety.county_public_safety([County_ID])
);
