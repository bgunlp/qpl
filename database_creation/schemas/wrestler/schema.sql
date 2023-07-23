USE spider;
CREATE TABLE  wrestler.wrestler (
[Wrestler_ID] int,
[Name] VARCHAR(400),
[Reign] VARCHAR(400),
[Days_held] VARCHAR(400),
[Location] VARCHAR(400),
[Event] VARCHAR(400),
PRIMARY KEY ([Wrestler_ID])
);

CREATE TABLE  wrestler.Elimination (
[Elimination_ID] VARCHAR(400),
[Wrestler_ID] int,
[Team] VARCHAR(400),
[Eliminated_By] VARCHAR(400),
[Elimination_Move] VARCHAR(400),
[Time] VARCHAR(400),
PRIMARY KEY ([Elimination_ID]),
FOREIGN KEY ([Wrestler_ID]) REFERENCES  wrestler.wrestler([Wrestler_ID])
);





