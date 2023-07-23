USE spider;
CREATE TABLE  entertainment_awards.festival_detail (
[Festival_ID] int,
[Festival_Name] VARCHAR(400),
[Chair_Name] VARCHAR(400),
[Location] VARCHAR(400),
[Year] int,
[Num_of_Audience] int,
PRIMARY KEY ([Festival_ID])
);

CREATE TABLE  entertainment_awards.artwork (
[Artwork_ID] int,
[Type] VARCHAR(400),
[Name] VARCHAR(400),
PRIMARY KEY ([Artwork_ID])
);

CREATE TABLE  entertainment_awards.nomination (
[Artwork_ID] int,
[Festival_ID] int,
[Result] VARCHAR(400),
PRIMARY KEY ([Artwork_ID],[Festival_ID]),
FOREIGN KEY ([Artwork_ID]) REFERENCES  entertainment_awards.artwork([Artwork_ID]),
FOREIGN KEY ([Festival_ID]) REFERENCES  entertainment_awards.festival_detail([Festival_ID])
);
