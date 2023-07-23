USE spider;
BEGIN TRANSACTION;

CREATE TABLE  tvshow.[TV_Channel] (
[id] VARCHAR(400),
[series_name] VARCHAR(400),
[Country] VARCHAR(400),
[Language] VARCHAR(400),
[Content] VARCHAR(400),
[Pixel_aspect_ratio_PAR] VARCHAR(400),
[Hight_definition_TV] VARCHAR(400),
[Pay_per_view_PPV] VARCHAR(400),
[Package_Option] VARCHAR(400),
PRIMARY KEY ([id])
);

CREATE TABLE  tvshow.[TV_series] (
[id] real,
[Episode] VARCHAR(400),
[Air_Date] VARCHAR(400),
[Rating] VARCHAR(400),
[Share] real,
[18_49_Rating_Share] VARCHAR(400),
[Viewers_m] VARCHAR(400),
[Weekly_Rank] real,
[Channel] VARCHAR(400),
PRIMARY KEY ([id]),
FOREIGN KEY (Channel) REFERENCES  tvshow.TV_Channel(id)
);

CREATE TABLE  tvshow.[Cartoon] (
[id] real,
[Title] VARCHAR(400),
[Directed_by] VARCHAR(400),
[Written_by] VARCHAR(400),
[Original_air_date] VARCHAR(400),
[Production_code] real,
[Channel] VARCHAR(400),
PRIMARY KEY ([id]),
FOREIGN KEY (Channel) REFERENCES  tvshow.TV_Channel(id)
);










COMMIT;
