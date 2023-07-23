USE spider;
CREATE TABLE  election.county (
[County_Id] int,
[County_name] VARCHAR(400),
[Population] real,
[Zip_code] VARCHAR(400),
PRIMARY KEY ([County_Id])
);

CREATE TABLE  election.party (
[Party_ID] int,
[Year] real,
[Party] VARCHAR(400),
[Governor] VARCHAR(400),
[Lieutenant_Governor] VARCHAR(400),
[Comptroller] VARCHAR(400),
[Attorney_General] VARCHAR(400),
[US_Senate] VARCHAR(400),
PRIMARY KEY ([Party_ID])
);


CREATE TABLE  election.election (
[Election_ID] int,
[Counties_Represented] VARCHAR(400),
[District] int,
[Delegate] VARCHAR(400),
[Party] int,
[First_Elected] real,
[Committee] VARCHAR(400),
PRIMARY KEY ([Election_ID]),
FOREIGN KEY (Party) REFERENCES  election.party(Party_ID),
FOREIGN KEY (District) REFERENCES  election.county(County_Id)
);
