USE spider;
CREATE TABLE  flight_company.airport (
[id] int,
[City] VARCHAR(400),
[Country] VARCHAR(400),
[IATA] VARCHAR(400),
[ICAO] VARCHAR(400),
[name] VARCHAR(400),
primary key([id])
);


CREATE TABLE  flight_company.operate_company (
[id] int,
[name] VARCHAR(400),
[Type] VARCHAR(400),
[Principal_activities] VARCHAR(400),
[Incorporated_in] VARCHAR(400),
[Group_Equity_Shareholding] real,
primary key ([id])
);

CREATE TABLE  flight_company.flight (
[id] int,
[Vehicle_Flight_number] VARCHAR(400),
[Date] VARCHAR(400),
[Pilot] VARCHAR(400),
[Velocity] real,
[Altitude] real,
[airport_id] int,
[company_id] int,
primary key ([id]),
foreign key ([airport_id]) references  flight_company.airport([id]),
foreign key ([company_id]) references  flight_company.operate_company([id])
);
