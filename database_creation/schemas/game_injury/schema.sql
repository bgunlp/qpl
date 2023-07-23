USE spider;
CREATE TABLE  game_injury.stadium (
[id] int,
[name] VARCHAR(400),
[Home_Games] int,
[Average_Attendance] real,
[Total_Attendance] real,
[Capacity_Percentage] real,
primary key ([id])
);

CREATE TABLE  game_injury.game (
[stadium_id] int,
[id] int,
[Season] int,
[Date] VARCHAR(400),
[Home_team] VARCHAR(400),
[Away_team] VARCHAR(400),
[Score] VARCHAR(400),
[Competition] VARCHAR(400),
primary key ([id]),
foreign key ([stadium_id]) references  game_injury.stadium([id])
);

CREATE TABLE  game_injury.injury_accident (
[game_id] int,
[id] int,
[Player] VARCHAR(400),
[Injury] VARCHAR(400),
[Number_of_matches] VARCHAR(400),
[Source] VARCHAR(400),
primary key ([id]),
foreign key ([game_id]) references  game_injury.game([id])
);
