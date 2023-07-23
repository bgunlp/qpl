USE spider;
CREATE TABLE  performance_attendance.member (
[Member_ID] int,
[Name] VARCHAR(400),
[Nationality] VARCHAR(400),
[Role] VARCHAR(400),
PRIMARY KEY ([Member_ID])
);
CREATE TABLE  performance_attendance.performance (
[Performance_ID] int,
[Date] VARCHAR(400),
[Host] VARCHAR(400),
[Location] VARCHAR(400),
[Attendance] int,
PRIMARY KEY ([Performance_ID])
);



CREATE TABLE  performance_attendance.member_attendance (
[Member_ID] int,
[Performance_ID] int,
[Num_of_Pieces] int,
PRIMARY KEY ([Member_ID],[Performance_ID]),
FOREIGN KEY ([Member_ID]) REFERENCES  performance_attendance.member([Member_ID]),
FOREIGN KEY ([Performance_ID]) REFERENCES  performance_attendance.performance([Performance_ID])
);
