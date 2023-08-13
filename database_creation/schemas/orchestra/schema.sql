USE spider;
CREATE TABLE  orchestra.conductor (
[Conductor_ID] int,
[Name] VARCHAR(400),
[Age] int,
[Nationality] VARCHAR(400),
[Year_of_Work] int,
PRIMARY KEY ([Conductor_ID])
);

CREATE TABLE  orchestra.orchestra (
[Orchestra_ID] int,
[Orchestra] VARCHAR(400),
[Conductor_ID] int,
[Record_Company] VARCHAR(400),
[Year_of_Founded] real,
[Major_Record_Format] VARCHAR(400),
PRIMARY KEY ([Orchestra_ID]),
FOREIGN KEY (Conductor_ID) REFERENCES  orchestra.conductor(Conductor_ID)
);

CREATE TABLE  orchestra.performance (
[Performance_ID] int,
[Orchestra_ID] int,
[Type] VARCHAR(400),
[Date] VARCHAR(400),
[Official_ratings_(millions)] real,
[Weekly_rank] VARCHAR(400),
[Share] VARCHAR(400),
PRIMARY KEY ([Performance_ID]),
FOREIGN KEY (Orchestra_ID) REFERENCES  orchestra.orchestra(Orchestra_ID)
);

CREATE TABLE  orchestra.show (
[Show_ID] int,
[Performance_ID] int,
[If_first_show] CHAR(1),
[Result] VARCHAR(15),
[Attendance] real,
FOREIGN KEY (Performance_ID) REFERENCES  orchestra.performance(Performance_ID),
CONSTRAINT CHK_If_first_show CHECK ([If_first_show] IN ('T', 'F'))
);
