USE spider;
CREATE TABLE  candidate_poll.people (
[People_ID] int,
[Sex] VARCHAR(400),
[Name] VARCHAR(400),
[Date_of_Birth] VARCHAR(400),
[Height] real,
[Weight] real,
PRIMARY KEY ([People_ID])
);

CREATE TABLE  candidate_poll.candidate (
[Candidate_ID] int,
[People_ID] int,
[Poll_Source] VARCHAR(400),
[Date] VARCHAR(400),
[Support_rate] real,
[Consider_rate] real,
[Oppose_rate] real,
[Unsure_rate] real,
PRIMARY KEY ([Candidate_ID]),
FOREIGN KEY ([People_ID]) REFERENCES  candidate_poll.people([People_ID])
);
