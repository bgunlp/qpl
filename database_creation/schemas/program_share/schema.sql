USE spider;
CREATE TABLE  program_share.program (
[Program_ID] int,
[Name] VARCHAR(400),
[Origin] VARCHAR(400),
[Launch] real,
[Owner] VARCHAR(400),
PRIMARY KEY ([Program_ID])
);


CREATE TABLE  program_share.channel (
[Channel_ID] int,
[Name] VARCHAR(400),
[Owner] VARCHAR(400),
[Share_in_percent] real,
[Rating_in_percent] real,
PRIMARY KEY ([Channel_ID])
);


CREATE TABLE  program_share.broadcast (
[Channel_ID] int,
[Program_ID] int,
[Time_of_day] VARCHAR(400),
PRIMARY KEY ([Channel_ID],[Program_ID]),
FOREIGN KEY (Channel_ID) REFERENCES  program_share.channel(Channel_ID),
FOREIGN KEY (Program_ID) REFERENCES  program_share.program(Program_ID)
);


CREATE TABLE  program_share.broadcast_share (
[Channel_ID] int,
[Program_ID] int,
[Date] VARCHAR(400),
[Share_in_percent] real,
PRIMARY KEY ([Channel_ID],[Program_ID]),
FOREIGN KEY (Channel_ID) REFERENCES  program_share.channel(Channel_ID),
FOREIGN KEY (Program_ID) REFERENCES  program_share.program(Program_ID)
);

