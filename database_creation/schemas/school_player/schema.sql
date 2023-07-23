USE spider;
CREATE TABLE  school_player.school (
[School_ID] int,
[School] VARCHAR(400),
[Location] VARCHAR(400),
[Enrollment] real,
[Founded] real,
[Denomination] VARCHAR(400),
[Boys_or_Girls] VARCHAR(400),
[Day_or_Boarding] VARCHAR(400),
[Year_Entered_Competition] real,
[School_Colors] VARCHAR(400),
PRIMARY KEY ([School_Id])
);

CREATE TABLE  school_player.school_details (
[School_ID] int,
[Nickname] VARCHAR(400),
[Colors] VARCHAR(400),
[League] VARCHAR(400),
[Class] VARCHAR(400),
[Division] VARCHAR(400),
PRIMARY KEY ([School_Id]),
FOREIGN KEY (School_ID) REFERENCES  school_player.school(School_ID)
);

CREATE TABLE  school_player.school_performance (
[School_Id] int,
[School_Year] VARCHAR(400),
[Class_A] VARCHAR(400),
[Class_AA] VARCHAR(400),
PRIMARY KEY ([School_Id],[School_Year]),
FOREIGN KEY (School_ID) REFERENCES  school_player.school(School_ID)
);


CREATE TABLE  school_player.player (
[Player_ID] int,
[Player] VARCHAR(400),
[Team] VARCHAR(400),
[Age] int,
[Position] VARCHAR(400),
[School_ID] int,
PRIMARY KEY ([Player_ID]),
FOREIGN KEY (School_ID) REFERENCES  school_player.school(School_ID)
);
