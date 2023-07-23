USE spider;
BEGIN TRANSACTION;
CREATE TABLE  department_management.[department] (
[Department_ID] int,
[Name] VARCHAR(400),
[Creation] VARCHAR(400),
[Ranking] int,
[Budget_in_Billions] real,
[Num_Employees] real,
PRIMARY KEY ([Department_ID])
);
CREATE TABLE  department_management.[head] (
[head_ID] int,
[name] VARCHAR(400),
[born_state] VARCHAR(400),
[age] real,
PRIMARY KEY ([head_ID])
);
CREATE TABLE  department_management.[management] (
[department_ID] int,
[head_ID] int,
[temporary_acting] VARCHAR(400),
PRIMARY KEY ([Department_ID],[head_ID]),
FOREIGN KEY ([Department_ID]) REFERENCES  department_management.department([Department_ID]),
FOREIGN KEY ([head_ID]) REFERENCES  department_management.head([head_ID])
);
COMMIT;

