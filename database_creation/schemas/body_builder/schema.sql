USE spider;
CREATE TABLE  body_builder.people (
[People_ID] int,
[Name] VARCHAR(400),
[Height] real,
[Weight] real,
[Birth_Date] VARCHAR(400),
[Birth_Place] VARCHAR(400),
PRIMARY KEY ([People_ID])
);

CREATE TABLE  body_builder.body_builder (
[Body_Builder_ID] int,
[People_ID] int,
[Snatch] real,
[Clean_Jerk] real,
[Total] real,
PRIMARY KEY ([Body_Builder_ID]),
FOREIGN KEY ([People_ID]) REFERENCES  body_builder.people([People_ID])
);
