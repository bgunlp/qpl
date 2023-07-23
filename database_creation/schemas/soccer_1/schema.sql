BEGIN TRANSACTION;
GO
USE spider;
GO
CREATE TABLE [soccer_1].[Player] (
    [id]	INTEGER PRIMARY KEY,
    [player_api_id]	INTEGER UNIQUE,
    [player_name]	TEXT,
    [player_fifa_api_id]	INTEGER UNIQUE,
    [birthday]	TEXT,
    [height]	INTEGER,
    [weight]	INTEGER
);
GO
CREATE TABLE [soccer_1].[Player_Attributes] (
    [id]	INTEGER PRIMARY KEY,
    [player_fifa_api_id]	INTEGER,
    [player_api_id]	INTEGER,
    [date]	TEXT,
    [overall_rating]	INTEGER,
    [potential]	INTEGER,
    [preferred_foot]	TEXT,
    [attacking_work_rate]	TEXT,
    [defensive_work_rate]	TEXT,
    [crossing]	INTEGER,
    [finishing]	INTEGER,
    [heading_accuracy]	INTEGER,
    [short_passing]	INTEGER,
    [volleys]	INTEGER,
    [dribbling]	INTEGER,
    [curve]	INTEGER,
    [free_kick_accuracy]	INTEGER,
    [long_passing]	INTEGER,
    [ball_control]	INTEGER,
    [acceleration]	INTEGER,
    [sprint_speed]	INTEGER,
    [agility]	INTEGER,
    [reactions]	INTEGER,
    [balance]	INTEGER,
    [shot_power]	INTEGER,
    [jumping]	INTEGER,
    [stamina]	INTEGER,
    [strength]	INTEGER,
    [long_shots]	INTEGER,
    [aggression]	INTEGER,
    [interceptions]	INTEGER,
    [positioning]	INTEGER,
    [vision]	INTEGER,
    [penalties]	INTEGER,
    [marking]	INTEGER,
    [standing_tackle]	INTEGER,
    [sliding_tackle]	INTEGER,
    [gk_diving]	INTEGER,
    [gk_handling]	INTEGER,
    [gk_kicking]	INTEGER,
    [gk_positioning]	INTEGER,
    [gk_reflexes]	INTEGER,
    FOREIGN KEY([player_fifa_api_id]) REFERENCES [soccer_1].[Player]([player_fifa_api_id]),
    FOREIGN KEY([player_api_id]) REFERENCES [soccer_1].[Player]([player_api_id])
);
GO
CREATE TABLE [soccer_1].[Country] (
    [id]	INTEGER PRIMARY KEY,
    [name]	VARCHAR(255) UNIQUE
);
GO
CREATE TABLE [soccer_1].[League] (
    [id]	INTEGER PRIMARY KEY,
    [country_id]	INTEGER,
    [name]	VARCHAR(255) UNIQUE,
    FOREIGN KEY([country_id]) REFERENCES [soccer_1].[Country]([id])
);
GO
CREATE TABLE [soccer_1].[Team] (
    [id]	INTEGER PRIMARY KEY,
    [team_api_id]	INTEGER UNIQUE,
    [team_fifa_api_id]	INTEGER UNIQUE,
    [team_long_name]	TEXT,
    [team_short_name]	TEXT
);
GO
CREATE TABLE [soccer_1].[Match] (
    [id]	INTEGER PRIMARY KEY,
    [country_id]	INTEGER,
    [league_id]	INTEGER,
    [season]	TEXT,
    [stage]	INTEGER,
    [date]	TEXT,
    [match_api_id]	INTEGER UNIQUE,
    [home_team_api_id]	INTEGER,
    [away_team_api_id]	INTEGER,
    [home_team_goal]	INTEGER,
    [away_team_goal]	INTEGER,
    [home_player_X1]	INTEGER,
    [home_player_X2]	INTEGER,
    [home_player_X3]	INTEGER,
    [home_player_X4]	INTEGER,
    [home_player_X5]	INTEGER,
    [home_player_X6]	INTEGER,
    [home_player_X7]	INTEGER,
    [home_player_X8]	INTEGER,
    [home_player_X9]	INTEGER,
    [home_player_X10]	INTEGER,
    [home_player_X11]	INTEGER,
    [away_player_X1]	INTEGER,
    [away_player_X2]	INTEGER,
    [away_player_X3]	INTEGER,
    [away_player_X4]	INTEGER,
    [away_player_X5]	INTEGER,
    [away_player_X6]	INTEGER,
    [away_player_X7]	INTEGER,
    [away_player_X8]	INTEGER,
    [away_player_X9]	INTEGER,
    [away_player_X10]	INTEGER,
    [away_player_X11]	INTEGER,
    [home_player_Y1]	INTEGER,
    [home_player_Y2]	INTEGER,
    [home_player_Y3]	INTEGER,
    [home_player_Y4]	INTEGER,
    [home_player_Y5]	INTEGER,
    [home_player_Y6]	INTEGER,
    [home_player_Y7]	INTEGER,
    [home_player_Y8]	INTEGER,
    [home_player_Y9]	INTEGER,
    [home_player_Y10]	INTEGER,
    [home_player_Y11]	INTEGER,
    [away_player_Y1]	INTEGER,
    [away_player_Y2]	INTEGER,
    [away_player_Y3]	INTEGER,
    [away_player_Y4]	INTEGER,
    [away_player_Y5]	INTEGER,
    [away_player_Y6]	INTEGER,
    [away_player_Y7]	INTEGER,
    [away_player_Y8]	INTEGER,
    [away_player_Y9]	INTEGER,
    [away_player_Y10]	INTEGER,
    [away_player_Y11]	INTEGER,
    [home_player_1]	INTEGER,
    [home_player_2]	INTEGER,
    [home_player_3]	INTEGER,
    [home_player_4]	INTEGER,
    [home_player_5]	INTEGER,
    [home_player_6]	INTEGER,
    [home_player_7]	INTEGER,
    [home_player_8]	INTEGER,
    [home_player_9]	INTEGER,
    [home_player_10]	INTEGER,
    [home_player_11]	INTEGER,
    [away_player_1]	INTEGER,
    [away_player_2]	INTEGER,
    [away_player_3]	INTEGER,
    [away_player_4]	INTEGER,
    [away_player_5]	INTEGER,
    [away_player_6]	INTEGER,
    [away_player_7]	INTEGER,
    [away_player_8]	INTEGER,
    [away_player_9]	INTEGER,
    [away_player_10]	INTEGER,
    [away_player_11]	INTEGER,
    [goal]	TEXT,
    [shoton]	TEXT,
    [shotoff]	TEXT,
    [foulcommit]	TEXT,
    [card]	TEXT,
    [cross]	TEXT,
    [corner]	TEXT,
    [possession]	TEXT,
    [B365H]	NUMERIC,
    [B365D]	NUMERIC,
    [B365A]	NUMERIC,
    [BWH]	NUMERIC,
    [BWD]	NUMERIC,
    [BWA]	NUMERIC,
    [IWH]	NUMERIC,
    [IWD]	NUMERIC,
    [IWA]	NUMERIC,
    [LBH]	NUMERIC,
    [LBD]	NUMERIC,
    [LBA]	NUMERIC,
    [PSH]	NUMERIC,
    [PSD]	NUMERIC,
    [PSA]	NUMERIC,
    [WHH]	NUMERIC,
    [WHD]	NUMERIC,
    [WHA]	NUMERIC,
    [SJH]	NUMERIC,
    [SJD]	NUMERIC,
    [SJA]	NUMERIC,
    [VCH]	NUMERIC,
    [VCD]	NUMERIC,
    [VCA]	NUMERIC,
    [GBH]	NUMERIC,
    [GBD]	NUMERIC,
    [GBA]	NUMERIC,
    [BSH]	NUMERIC,
    [BSD]	NUMERIC,
    [BSA]	NUMERIC,
    FOREIGN KEY([country_id]) REFERENCES [soccer_1].[Country]([id]),
    FOREIGN KEY([league_id]) REFERENCES [soccer_1].[League]([id]),
    FOREIGN KEY([home_team_api_id]) REFERENCES [soccer_1].[Team]([team_api_id]),
    FOREIGN KEY([away_team_api_id]) REFERENCES [soccer_1].[Team]([team_api_id]),
    FOREIGN KEY([home_player_1]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([home_player_2]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([home_player_3]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([home_player_4]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([home_player_5]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([home_player_6]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([home_player_7]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([home_player_8]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([home_player_9]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([home_player_10]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([home_player_11]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([away_player_1]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([away_player_2]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([away_player_3]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([away_player_4]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([away_player_5]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([away_player_6]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([away_player_7]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([away_player_8]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([away_player_9]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([away_player_10]) REFERENCES [soccer_1].[Player]([player_api_id]),
    FOREIGN KEY([away_player_11]) REFERENCES [soccer_1].[Player]([player_api_id])
);
GO
CREATE TABLE [soccer_1].[Team_Attributes] (
    [id]	INTEGER PRIMARY KEY,
    [team_fifa_api_id]	INTEGER,
    [team_api_id]	INTEGER,
    [date]	TEXT,
    [buildUpPlaySpeed]	INTEGER,
    [buildUpPlaySpeedClass]	TEXT,
    [buildUpPlayDribbling]	INTEGER,
    [buildUpPlayDribblingClass]	TEXT,
    [buildUpPlayPassing]	INTEGER,
    [buildUpPlayPassingClass]	TEXT,
    [buildUpPlayPositioningClass]	TEXT,
    [chanceCreationPassing]	INTEGER,
    [chanceCreationPassingClass]	TEXT,
    [chanceCreationCrossing]	INTEGER,
    [chanceCreationCrossingClass]	TEXT,
    [chanceCreationShooting]	INTEGER,
    [chanceCreationShootingClass]	TEXT,
    [chanceCreationPositioningClass]	TEXT,
    [defencePressure]	INTEGER,
    [defencePressureClass]	TEXT,
    [defenceAggression]	INTEGER,
    [defenceAggressionClass]	TEXT,
    [defenceTeamWidth]	INTEGER,
    [defenceTeamWidthClass]	TEXT,
    [defenceDefenderLineClass]	TEXT,
    FOREIGN KEY([team_fifa_api_id]) REFERENCES [soccer_1].[Team]([team_fifa_api_id]),
    FOREIGN KEY([team_api_id]) REFERENCES [soccer_1].[Team]([team_api_id])
);
GO
COMMIT;