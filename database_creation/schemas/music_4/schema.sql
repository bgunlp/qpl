USE spider;
CREATE TABLE  music_4.artist (
[Artist_ID] int,
[Artist] VARCHAR(400),
[Age] int,
[Famous_Title] VARCHAR(400),
[Famous_Release_date] VARCHAR(400),
PRIMARY KEY ([Artist_ID])
);



CREATE TABLE  music_4.volume (
[Volume_ID] int,
[Volume_Issue] VARCHAR(400),
[Issue_Date] VARCHAR(400),
[Weeks_on_Top] real,
[Song] VARCHAR(400),
[Artist_ID] int,
PRIMARY KEY ([Volume_ID]),
FOREIGN KEY (Artist_ID) REFERENCES  music_4.artist(Artist_ID)
);


CREATE TABLE  music_4.music_festival (
[ID] int,
[Music_Festival] VARCHAR(400),
[Date_of_ceremony] VARCHAR(400),
[Category] VARCHAR(400),
[Volume] int,
[Result] VARCHAR(400),
PRIMARY KEY (ID),
FOREIGN KEY (Volume) REFERENCES  music_4.volume(Volume_ID)
);
