USE spider;
CREATE TABLE  musical.musical (
[Musical_ID] int,
[Name] VARCHAR(400),
[Year] int,
[Award] VARCHAR(400),
[Category] VARCHAR(400),
[Nominee] VARCHAR(400),
[Result] VARCHAR(400),
PRIMARY KEY ([Musical_ID])
);

CREATE TABLE  musical.actor (
[Actor_ID] int,
[Name] VARCHAR(400),
[Musical_ID] int,
[Character] VARCHAR(400),
[Duration] VARCHAR(400),
[age] int,
PRIMARY KEY ([Actor_ID]),
FOREIGN KEY ([Musical_ID]) REFERENCES  musical.actor([Actor_ID])
);
