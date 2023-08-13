USE spider;
CREATE TABLE  party_host.party (
[Party_ID] int,
[Party_Theme] VARCHAR(400),
[Location] VARCHAR(400),
[First_year] VARCHAR(400),
[Last_year] VARCHAR(400),
[Number_of_hosts] int,
PRIMARY KEY ([Party_ID])
);

CREATE TABLE  party_host.host (
[Host_ID] int,
[Name] VARCHAR(400),
[Nationality] VARCHAR(400),
[Age] VARCHAR(400),
PRIMARY KEY ([Host_ID])
);

CREATE TABLE  party_host.party_host (
[Party_ID] int,
[Host_ID] int,
[Is_Main_in_Charge] CHAR(1),
PRIMARY KEY ([Party_ID],[Host_ID]),
FOREIGN KEY ([Host_ID]) REFERENCES  party_host.host([Host_ID]),
FOREIGN KEY ([Party_ID]) REFERENCES  party_host.party([Party_ID]),
CONSTRAINT CHK_Is_Main_in_Charge CHECK ([Is_Main_in_Charge] IN ('T', 'F'))
);
