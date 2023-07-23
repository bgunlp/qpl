USE spider;

CREATE TABLE  gymnast.people (
[People_ID] int,
[Name] VARCHAR(400),
[Age] real,
[Height] real,
[Hometown] VARCHAR(400),
PRIMARY KEY ([People_ID])
);

CREATE TABLE  gymnast.gymnast (
[Gymnast_ID] int,
[Floor_Exercise_Points] real,
[Pommel_Horse_Points] real,
[Rings_Points] real,
[Vault_Points] real,
[Parallel_Bars_Points] real,
[Horizontal_Bar_Points] real,
[Total_Points] real,
PRIMARY KEY ([Gymnast_ID]),
FOREIGN KEY ([Gymnast_ID]) REFERENCES  gymnast.people([People_ID])
);
