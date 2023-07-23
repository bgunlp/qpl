USE spider;
CREATE TABLE  museum_visit.museum (
[Museum_ID] int,
[Name] VARCHAR(400),
[Num_of_Staff] int,
[Open_Year] VARCHAR(400),
PRIMARY KEY ([Museum_ID])
);

CREATE TABLE  museum_visit.visitor (
[ID] int,
[Name] VARCHAR(400),
[Level_of_membership] int,
[Age] int,
PRIMARY KEY ([ID])
);

CREATE TABLE  museum_visit.visit (
[Museum_ID] int,
[visitor_ID] int,
[Num_of_Ticket] int,
[Total_spent] real,
PRIMARY KEY ([Museum_ID],[visitor_ID]),
FOREIGN KEY ([Museum_ID]) REFERENCES  museum_visit.museum([Museum_ID]),
FOREIGN KEY ([visitor_ID]) REFERENCES  museum_visit.visitor([ID])
);
