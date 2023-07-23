USE spider;
CREATE TABLE  manufactory_1.Manufacturers (
Code INTEGER,
Name VARCHAR(255) NOT NULL,
Headquarter VARCHAR(255) NOT NULL,
Founder VARCHAR(255) NOT NULL,
Revenue REAL,
PRIMARY KEY (Code)
);

CREATE TABLE  manufactory_1.Products (
Code INTEGER,
Name VARCHAR(255) NOT NULL ,
Price DECIMAL NOT NULL ,
Manufacturer INTEGER NOT NULL,
PRIMARY KEY (Code),
FOREIGN KEY (Manufacturer) REFERENCES  manufactory_1.Manufacturers(Code)
);
