USE spider;
CREATE TABLE  wedding.people (
[People_ID] int,
[Name] VARCHAR(400),
[Country] VARCHAR(400),
[Is_Male] VARCHAR(400),
[Age] int,
PRIMARY KEY ([People_ID])
);





CREATE TABLE  wedding.church (
[Church_ID] int,
[Name] VARCHAR(400),
[Organized_by] VARCHAR(400),
[Open_Date] int,
[Continuation_of] VARCHAR(400),
PRIMARY KEY ([Church_ID])
);




CREATE TABLE  wedding.wedding (
[Church_ID] int,
[Male_ID] int,
[Female_ID] int,
[Year] int,
PRIMARY KEY ([Church_ID],[Male_ID],[Female_ID]),
FOREIGN KEY ([Church_ID]) REFERENCES  wedding.church([Church_ID]),
FOREIGN KEY ([Male_ID]) REFERENCES  wedding.people([People_ID]),
FOREIGN KEY ([Female_ID]) REFERENCES  wedding.people([People_ID])
);


