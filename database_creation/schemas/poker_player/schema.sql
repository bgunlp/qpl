USE spider;
CREATE TABLE  poker_player.people (
[People_ID] int,
[Nationality] VARCHAR(400),
[Name] VARCHAR(400),
[Birth_Date] VARCHAR(400),
[Height] real,
PRIMARY KEY ([People_ID])
);

CREATE TABLE  poker_player.poker_player (
[Poker_Player_ID] int,
[People_ID] int,
[Final_Table_Made] real,
[Best_Finish] real,
[Money_Rank] real,
[Earnings] real,
PRIMARY KEY ([Poker_Player_ID]),
FOREIGN KEY ([People_ID]) REFERENCES  poker_player.people([People_ID])
);
