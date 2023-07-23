USE spider;
CREATE TABLE  car_1.continents (
[ContId] INTEGER PRIMARY KEY,
[Continent] VARCHAR(400)
);

CREATE TABLE  car_1.countries (
[CountryId] INTEGER PRIMARY KEY,
[CountryName] VARCHAR(400),
[Continent] INTEGER,
FOREIGN KEY (Continent) REFERENCES  car_1.continents(ContId)
);


CREATE TABLE  car_1.car_makers (
[Id] INTEGER PRIMARY KEY,
[Maker] VARCHAR(400),
[FullName] VARCHAR(400),
[Country] INTEGER,
FOREIGN KEY (Country) REFERENCES  car_1.countries(CountryId)
);


CREATE TABLE  car_1.model_list (
[ModelId] INTEGER PRIMARY KEY,
[Maker] INTEGER,
[Model] VARCHAR(400) UNIQUE,
FOREIGN KEY (Maker) REFERENCES  car_1.car_makers (Id)

);



CREATE TABLE  car_1.car_names (
[MakeId] INTEGER PRIMARY KEY,
[Model] VARCHAR(400),
[Make] VARCHAR(400),
FOREIGN KEY (Model) REFERENCES  car_1.model_list (Model)
);

CREATE TABLE  car_1.cars_data (
[Id] INTEGER PRIMARY KEY,
[MPG] DECIMAL,
[Cylinders] INTEGER,
[Edispl] REAL,
[Horsepower] DECIMAL,
[Weight] INTEGER,
[Accelerate] REAL,
[Year] INTEGER,
FOREIGN KEY (Id) REFERENCES  car_1.car_names (MakeId)
);


