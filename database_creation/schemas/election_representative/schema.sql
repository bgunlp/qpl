USE spider;
CREATE TABLE  election_representative.representative (
[Representative_ID] int,
[Name] VARCHAR(400),
[State] VARCHAR(400),
[Party] VARCHAR(400),
[Lifespan] VARCHAR(400),
PRIMARY KEY ([Representative_ID])
);

CREATE TABLE  election_representative.election (
[Election_ID] int,
[Representative_ID] int,
[Date] VARCHAR(400),
[Votes] real,
[Vote_Percent] real,
[Seats] real,
[Place] real,
PRIMARY KEY ([Election_ID]),
FOREIGN KEY ([Representative_ID]) REFERENCES  election_representative.representative([Representative_ID])
);
