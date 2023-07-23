USE spider;
CREATE TABLE  match_season.country (
[Country_id] int,
[Country_name] VARCHAR(400),
[Capital] VARCHAR(400),
[Official_native_language] VARCHAR(400),
PRIMARY KEY ([Country_id])
);


CREATE TABLE  match_season.team (
Team_id int,
Name VARCHAR(400),
PRIMARY KEY (Team_id)
) ;

CREATE TABLE  match_season.match_season (
[Season] real,
[Player] VARCHAR(400),
[Position] VARCHAR(400),
[Country] int,
[Team] int,
[Draft_Pick_Number] int,
[Draft_Class] VARCHAR(400),
[College] VARCHAR(400),
PRIMARY KEY ([Season]),
FOREIGN KEY (Country) REFERENCES  match_season.country(Country_id),
FOREIGN KEY (Team) REFERENCES  match_season.team(Team_id)
);


CREATE TABLE  match_season.player (
[Player_ID] int,
[Player] VARCHAR(400),
[Years_Played] VARCHAR(400),
[Total_WL] VARCHAR(400),
[Singles_WL] VARCHAR(400),
[Doubles_WL] VARCHAR(400),
[Team] int,
PRIMARY KEY ([Player_ID]),
FOREIGN KEY (Team) REFERENCES  match_season.team(Team_id)
);

