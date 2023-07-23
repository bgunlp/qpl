USE spider;
CREATE TABLE  student_1.list (
[LastName] VARCHAR(400),
[FirstName] VARCHAR(400),
[Grade] INTEGER,
[Classroom] INTEGER,
PRIMARY KEY(LastName, FirstName)
);
CREATE TABLE  student_1.teachers (
[LastName] VARCHAR(400),
[FirstName] VARCHAR(400),
[Classroom] INTEGER,
PRIMARY KEY(LastName, FirstName)
);
