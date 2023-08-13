USE spider;
CREATE TABLE  debate.people (
[People_ID] int,
[District] VARCHAR(400),
[Name] VARCHAR(400),
[Party] VARCHAR(400),
[Age] int,
PRIMARY KEY ([People_ID])
);

CREATE TABLE  debate.debate (
[Debate_ID] int,
[Date] VARCHAR(400),
[Venue] VARCHAR(400),
[Num_of_Audience] int,
PRIMARY KEY ([Debate_ID])
);




CREATE TABLE  debate.debate_people (
[Debate_ID] int,
[Affirmative] int,
[Negative] int,
[If_Affirmative_Win] CHAR(1),
PRIMARY KEY ([Debate_ID],[Affirmative],[Negative]),
FOREIGN KEY ([Debate_ID]) REFERENCES  debate.debate([Debate_ID]),
FOREIGN KEY ([Affirmative]) REFERENCES  debate.people([People_ID]),
FOREIGN KEY ([Negative]) REFERENCES  debate.people([People_ID]), 
CONSTRAINT CHK_If_Affirmative_Win CHECK ([If_Affirmative_Win] IN ('T', 'F'))
);