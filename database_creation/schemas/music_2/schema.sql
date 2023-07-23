USE spider;
CREATE TABLE  music_2.Songs (
[SongId] INTEGER PRIMARY KEY,
[Title] VARCHAR(400)
);
CREATE TABLE  music_2.Albums (
[AId] INTEGER PRIMARY KEY,
[Title] VARCHAR(400),
[Year] INTEGER,
[Label] VARCHAR(400),
[Type] VARCHAR(400) );
CREATE TABLE  music_2.Band (
[Id] INTEGER PRIMARY KEY,
[Firstname] VARCHAR(400),
[Lastname] VARCHAR(400) );
CREATE TABLE  music_2.Instruments (
[SongId] INTEGER,
[BandmateId] INTEGER,
[Instrument] VARCHAR(400) ,
PRIMARY KEY(SongId, BandmateId, Instrument),
FOREIGN KEY (SongId) REFERENCES  music_2.Songs(SongId),
FOREIGN KEY (BandmateId) REFERENCES  music_2.Band(Id)
);
CREATE TABLE  music_2.Performance (
[SongId] INTEGER,
[Bandmate] INTEGER,
[StagePosition] VARCHAR(400),
PRIMARY KEY(SongId, Bandmate),
FOREIGN KEY (SongId) REFERENCES  music_2.Songs(SongId),
FOREIGN KEY (Bandmate) REFERENCES  music_2.Band(Id)
);
CREATE TABLE  music_2.Tracklists (
[AlbumId] INTEGER,
[Position] INTEGER,
[SongId] INTEGER ,
PRIMARY KEY(AlbumId, Position),
FOREIGN KEY (SongId) REFERENCES  music_2.Songs(SongId),
FOREIGN KEY (AlbumId) REFERENCES  music_2.Albums(AId)
);
CREATE TABLE  music_2.Vocals (
[SongId] INTEGER,
[Bandmate] INTEGER,
[Type] VARCHAR(400),
PRIMARY KEY(SongId, Bandmate),
FOREIGN KEY (SongId) REFERENCES  music_2.Songs(SongId),
FOREIGN KEY (Bandmate) REFERENCES  music_2.Band(Id)
);

