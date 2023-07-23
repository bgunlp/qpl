USE spider;
BEGIN TRANSACTION;
CREATE TABLE world_1.country (
  Code char(3) NOT NULL DEFAULT ''
,  Name char(52) NOT NULL DEFAULT ''
,  Continent varchar(max)  NOT NULL DEFAULT 'Asia'
,  Region char(26) NOT NULL DEFAULT ''
,  SurfaceArea real NOT NULL DEFAULT '0.00'
,  IndepYear integer DEFAULT NULL
,  Population bigint NOT NULL DEFAULT '0'
,  LifeExpectancy real DEFAULT NULL
,  GNP real DEFAULT NULL
,  GNPOld real DEFAULT NULL
,  LocalName char(45) NOT NULL DEFAULT ''
,  GovernmentForm char(45) NOT NULL DEFAULT ''
,  HeadOfState char(60) DEFAULT NULL
,  Capital integer DEFAULT NULL
,  Code2 char(2) NOT NULL DEFAULT ''
,  PRIMARY KEY (Code)
);

CREATE TABLE world_1.city (
  ID integer NOT NULL PRIMARY KEY
,  Name char(35) NOT NULL DEFAULT ''
,  CountryCode char(3) NOT NULL DEFAULT ''
,  District char(20) NOT NULL DEFAULT ''
,  Population integer NOT NULL DEFAULT '0'
,  CONSTRAINT city_ibfk_1 FOREIGN KEY (CountryCode) REFERENCES world_1.country (Code)
);

CREATE TABLE world_1.countrylanguage (
  CountryCode char(3) NOT NULL DEFAULT ''
,  Language char(30) NOT NULL DEFAULT ''
,  IsOfficial varchar(max)  NOT NULL DEFAULT 'F'
,  Percentage real NOT NULL DEFAULT '0.0'
,  PRIMARY KEY (CountryCode,Language)
,  CONSTRAINT countryLanguage_ibfk_1 FOREIGN KEY (CountryCode) REFERENCES world_1.country (Code)
);
COMMIT;
