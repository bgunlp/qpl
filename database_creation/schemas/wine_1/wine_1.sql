USE spider;
CREATE TABLE  wine_1.grapes (
[ID] INTEGER PRIMARY KEY,
[Grape] VARCHAR(400) UNIQUE,
[Color] VARCHAR(400)
);

CREATE TABLE  wine_1.appellations (
[No] INTEGER PRIMARY KEY,
[Appelation] VARCHAR(400) UNIQUE,
[County] VARCHAR(400),
[State] VARCHAR(400),
[Area] VARCHAR(400),
[isAVA] VARCHAR(400)
);

CREATE TABLE  wine_1.wine (
[No] INTEGER,
[Grape] VARCHAR(400),
[Winery] VARCHAR(400),
[Appelation] VARCHAR(400),
[State] VARCHAR(400),
[Name] VARCHAR(400),
[Year] INTEGER,
[Price] INTEGER,
[Score] INTEGER,
[Cases] INTEGER,
[Drink] VARCHAR(400),
FOREIGN KEY (Grape) REFERENCES  wine_1.grapes(Grape),
FOREIGN KEY (Appelation) REFERENCES  wine_1.appellations(Appelation)
);
