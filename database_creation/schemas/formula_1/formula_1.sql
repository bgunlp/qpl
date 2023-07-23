USE spider;
BEGIN TRANSACTION;
CREATE TABLE  formula_1.[circuits] (
[circuitId] INTEGER PRIMARY KEY,
[circuitRef] VARCHAR(400),
[name] VARCHAR(400),
[location] VARCHAR(400),
[country] VARCHAR(400),
[lat] REAL,
[lng] REAL,
[alt] INTEGER,
[url] VARCHAR(400)
);
CREATE TABLE  formula_1.[races] (
[raceId] INTEGER PRIMARY KEY,
[year] INTEGER,
[round] INTEGER,
[circuitId] INTEGER,
[name] VARCHAR(400),
[date] VARCHAR(400),
[time] VARCHAR(400),
[url] VARCHAR(400),
FOREIGN KEY ([circuitId]) REFERENCES  formula_1.circuits([circuitId])
);

CREATE TABLE  formula_1.[drivers] (
[driverId] INTEGER PRIMARY KEY,
[driverRef] VARCHAR(400),
[number] INTEGER,
[code] VARCHAR(400),
[forename] VARCHAR(400),
[surname] VARCHAR(400),
[dob] VARCHAR(400),
[nationality] VARCHAR(400),
[url] VARCHAR(400)
);
CREATE TABLE  formula_1.[status] (
[statusId] INTEGER PRIMARY KEY,
[status] VARCHAR(400)
);
CREATE TABLE  formula_1.[seasons] (
[year] INTEGER PRIMARY KEY,
[url] VARCHAR(400)
);
CREATE TABLE  formula_1.[constructors] (
[constructorId] INTEGER PRIMARY KEY,
[constructorRef] VARCHAR(400),
[name] VARCHAR(400),
[nationality] VARCHAR(400),
[url] VARCHAR(400)
);
CREATE TABLE  formula_1.[constructorStandings] (
[constructorStandingsId] INTEGER PRIMARY KEY,
[raceId] INTEGER,
[constructorId] INTEGER,
[points] REAL,
[position] INTEGER,
[positionText] VARCHAR(400),
[wins] INTEGER,
FOREIGN KEY([constructorId]) REFERENCES  formula_1.constructors([constructorId]),
FOREIGN KEY([raceId]) REFERENCES  formula_1.races([raceId])
);
CREATE TABLE  formula_1.[results] (
[resultId] INTEGER PRIMARY KEY,
[raceId] INTEGER,
[driverId] INTEGER,
[constructorId] INTEGER,
[number] INTEGER,
[grid] INTEGER,
[position] INT,
[positionText] VARCHAR(400),
[positionOrder] INTEGER,
[points] REAL,
[laps] INT,
[time] VARCHAR(400),
[milliseconds] INT,
[fastestLap] INT,
[rank] INT,
[fastestLapTime] VARCHAR(400),
[fastestLapSpeed] VARCHAR(400),
[statusId] INTEGER,
FOREIGN KEY([constructorId]) REFERENCES  formula_1.constructors([constructorId]),
FOREIGN KEY([raceId]) REFERENCES  formula_1.races([raceId]),
FOREIGN KEY ([driverId]) REFERENCES  formula_1.drivers([driverId])
);
CREATE TABLE  formula_1.[driverStandings] (
[driverStandingsId] INTEGER PRIMARY KEY,
[raceId] INTEGER,
[driverId] INTEGER,
[points] REAL,
[position] INTEGER,
[positionText] VARCHAR(400),
[wins] INTEGER,
FOREIGN KEY([raceId]) REFERENCES  formula_1.races([raceId]),
FOREIGN KEY ([driverId]) REFERENCES  formula_1.drivers([driverId])
);
CREATE TABLE  formula_1.[constructorResults] (
[constructorResultsId] INTEGER PRIMARY KEY,
[raceId] INTEGER,
[constructorId] INTEGER,
[points] REAL,
[status] VARCHAR(4),
FOREIGN KEY([constructorId]) REFERENCES  formula_1.constructors([constructorId]),
FOREIGN KEY([raceId]) REFERENCES  formula_1.races([raceId])
);
CREATE TABLE  formula_1.[qualifying] (
[qualifyId] INTEGER PRIMARY KEY,
[raceId] INTEGER,
[driverId] INTEGER,
[constructorId] INTEGER,
[number] INTEGER,
[position] INTEGER,
[q1] VARCHAR(400),
[q2] VARCHAR(400),
[q3] VARCHAR(400),
FOREIGN KEY([constructorId]) REFERENCES  formula_1.constructors([constructorId]),
FOREIGN KEY([raceId]) REFERENCES  formula_1.races([raceId]),
FOREIGN KEY ([driverId]) REFERENCES  formula_1.drivers([driverId])
);
CREATE TABLE  formula_1.[pitStops] (
[raceId] INTEGER,
[driverId] INTEGER,
[stop] INTEGER,
[lap] INTEGER,
[time] VARCHAR(400),
[duration] VARCHAR(400),
[milliseconds] INTEGER,
PRIMARY KEY ([raceId], [driverId], [stop]),
FOREIGN KEY([raceId]) REFERENCES  formula_1.races([raceId]),
FOREIGN KEY ([driverId]) REFERENCES  formula_1.drivers([driverId])
);
CREATE TABLE  formula_1.[lapTimes] (
[raceId] INTEGER,
[driverId] INTEGER,
[lap] INTEGER,
[position] INTEGER,
[time] VARCHAR(400),
[milliseconds] INTEGER,
PRIMARY KEY([raceId], [driverId], [lap]),
FOREIGN KEY([raceId]) REFERENCES  formula_1.races([raceId]),
FOREIGN KEY ([driverId]) REFERENCES  formula_1.drivers([driverId])
);COMMIT;
