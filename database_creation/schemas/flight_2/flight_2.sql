USE spider;
CREATE TABLE flight_2.[airlines] (
uid INTEGER PRIMARY KEY,
Airline VARCHAR(400),
Abbreviation VARCHAR(400),
Country VARCHAR(400)
);
CREATE TABLE flight_2.[airports] (
City VARCHAR(400),
AirportCode VARCHAR(400) PRIMARY KEY,
AirportName VARCHAR(400),
Country VARCHAR(400),
CountryAbbrev VARCHAR(400)
);
CREATE TABLE flight_2.[flights] (
Airline INTEGER,
FlightNo INTEGER,
SourceAirport VARCHAR(400),
DestAirport VARCHAR(400),
PRIMARY KEY(Airline, FlightNo),
FOREIGN KEY (SourceAirport) REFERENCES  flight_2.airports(AirportCode),
FOREIGN KEY (DestAirport) REFERENCES  flight_2.airports(AirportCode)
);
