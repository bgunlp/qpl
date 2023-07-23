USE spider;
CREATE TABLE  university_basketball.university (
[School_ID] int,
[School] VARCHAR(400),
[Location] VARCHAR(400),
[Founded] real,
[Affiliation] VARCHAR(400),
[Enrollment] real,
[Nickname] VARCHAR(400),
[Primary_conference] VARCHAR(400),
PRIMARY KEY ([School_ID])
);

CREATE TABLE  university_basketball.basketball_match (
[Team_ID] int,
[School_ID] int,
[Team_Name] VARCHAR(400),
[ACC_Regular_Season] VARCHAR(400),
[ACC_Percent] REAL,
[ACC_Home] VARCHAR(400),
[ACC_Road] VARCHAR(400),
[All_Games] VARCHAR(400),
[All_Games_Percent] REAL,
[All_Home] VARCHAR(400),
[All_Road] VARCHAR(400),
[All_Neutral] VARCHAR(400),
PRIMARY KEY ([Team_ID]),
FOREIGN KEY (School_ID) REFERENCES  university_basketball.university(School_ID)
);



