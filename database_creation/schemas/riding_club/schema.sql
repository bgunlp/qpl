USE spider;
BEGIN TRANSACTION;
CREATE TABLE  riding_club.[player] (
[Player_ID] int,
[Sponsor_name] VARCHAR(400),
[Player_name] VARCHAR(400),
[Gender] VARCHAR(400),
[Residence] VARCHAR(400),
[Occupation] VARCHAR(400),
[Votes] int,
[Rank] VARCHAR(400),
PRIMARY KEY ([Player_ID])
);
CREATE TABLE  riding_club.[club] (
[Club_ID] int,
[Club_name] VARCHAR(400),
[Region] VARCHAR(400),
[Start_year] int,
PRIMARY KEY ([Club_ID])
);
CREATE TABLE  riding_club.[coach] (
[Coach_ID] int,
[Coach_name] VARCHAR(400),
[Gender] VARCHAR(400),
[Club_ID] int,
[Rank] int,
PRIMARY KEY ([Coach_ID]),
FOREIGN KEY (Club_ID) REFERENCES  riding_club.club(Club_ID)
);
CREATE TABLE  riding_club.[player_coach] (
[Player_ID] int,
[Coach_ID] int,
[Starting_year] int,
PRIMARY KEY ([Player_ID],[Coach_ID]),
FOREIGN KEY (Player_ID) REFERENCES  riding_club.player(Player_ID),
FOREIGN KEY (Coach_ID) REFERENCES  riding_club.coach(Coach_ID)
);
CREATE TABLE  riding_club.[match_result] (
[Rank] int,
[Club_ID] int,
[Gold] int,
[Big_Silver] int,
[Small_Silver] int,
[Bronze] int,
[Points] int,
PRIMARY KEY ([Rank],[Club_ID]),
FOREIGN KEY (Club_ID) REFERENCES  riding_club.club(Club_ID)
);
COMMIT;

