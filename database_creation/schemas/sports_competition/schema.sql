USE spider;
CREATE TABLE  sports_competition.club (
[Club_ID] int,
[name] VARCHAR(400),
[Region] VARCHAR(400),
[Start_year] VARCHAR(400),
PRIMARY KEY ([Club_ID])
);



CREATE TABLE  sports_competition.club_rank (
[Rank] real,
[Club_ID] int,
[Gold] real,
[Silver] real,
[Bronze] real,
[Total] real,
PRIMARY KEY ([Rank],[Club_ID]),
FOREIGN KEY (Club_ID) REFERENCES  sports_competition.club(Club_ID)
);

CREATE TABLE  sports_competition.player (
[Player_ID] int,
[name] VARCHAR(400),
[Position] VARCHAR(400),
[Club_ID] int,
[Apps] real,
[Tries] real,
[Goals] VARCHAR(400),
[Points] real,
PRIMARY KEY ([Player_ID]),
FOREIGN KEY (Club_ID) REFERENCES  sports_competition.club(Club_ID)
);

CREATE TABLE  sports_competition.competition (
[Competition_ID] int,
[Year] real,
[Competition_type] VARCHAR(400),
[Country] VARCHAR(400),
PRIMARY KEY ([Competition_ID])
);




CREATE TABLE  sports_competition.competition_result (
[Competition_ID] int,
[Club_ID_1] int,
[Club_ID_2] int,
[Score] VARCHAR(400),
PRIMARY KEY ([Competition_ID],[Club_ID_1],[Club_ID_2]),
FOREIGN KEY (Club_ID_1) REFERENCES  sports_competition.club(Club_ID),
FOREIGN KEY (Club_ID_2) REFERENCES  sports_competition.club(Club_ID),
FOREIGN KEY (Competition_ID) REFERENCES  sports_competition.competition(Competition_ID)
);


