USE spider;
CREATE TABLE  decoration_competition.college (
[College_ID] int,
[Name] VARCHAR(400),
[Leader_Name] VARCHAR(400),
[College_Location] VARCHAR(400),
PRIMARY KEY ([College_ID])
);



CREATE TABLE  decoration_competition.member (
[Member_ID] int,
[Name] VARCHAR(400),
[Country] VARCHAR(400),
[College_ID] int,
PRIMARY KEY ([Member_ID]),
FOREIGN KEY ([College_ID]) REFERENCES  decoration_competition.college([College_ID])
);

CREATE TABLE  decoration_competition.round (
[Round_ID] int,
[Member_ID] int,
[Decoration_Theme] VARCHAR(400),
[Rank_in_Round] int,
PRIMARY KEY ([Member_ID],[Round_ID]),
FOREIGN KEY ([Member_ID]) REFERENCES  decoration_competition.member([Member_ID])
);
