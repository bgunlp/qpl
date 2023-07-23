USE spider;
CREATE TABLE  pilot_record.aircraft (
[Aircraft_ID] int,
[Order_Year] int,
[Manufacturer] VARCHAR(400),
[Model] VARCHAR(400),
[Fleet_Series] VARCHAR(400),
[Powertrain] VARCHAR(400),
[Fuel_Propulsion] VARCHAR(400),
PRIMARY KEY ([Aircraft_ID])
);


CREATE TABLE  pilot_record.pilot (
[Pilot_ID] int,
[Pilot_name] VARCHAR(400),
[Rank] int,
[Age] int,
[Nationality] VARCHAR(400),
[Position] VARCHAR(400),
[Join_Year] int,
[Team] VARCHAR(400),
PRIMARY KEY ([Pilot_ID])
);

CREATE TABLE  pilot_record.pilot_record (
[Record_ID] int,
[Pilot_ID] int,
[Aircraft_ID] int,
[Date] VARCHAR(400),
PRIMARY KEY ([Pilot_ID], [Aircraft_ID], [Date]),
FOREIGN KEY (Pilot_ID) REFERENCES  pilot_record.pilot(Pilot_ID),
FOREIGN KEY (Aircraft_ID) REFERENCES  pilot_record.aircraft(Aircraft_ID)
);
