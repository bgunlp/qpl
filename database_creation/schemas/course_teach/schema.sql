USE spider;
CREATE TABLE  course_teach.course (
[Course_ID] int,
[Staring_Date] VARCHAR(400),
[Course] VARCHAR(400),
PRIMARY KEY ([Course_ID])
);

CREATE TABLE  course_teach.teacher (
[Teacher_ID] int,
[Name] VARCHAR(400),
[Age] VARCHAR(400),
[Hometown] VARCHAR(400),
PRIMARY KEY ([Teacher_ID])
);

CREATE TABLE  course_teach.course_arrange (
[Course_ID] int,
[Teacher_ID] int,
[Grade] int,
PRIMARY KEY ([Course_ID],[Teacher_ID],[Grade]),
FOREIGN KEY ([Course_ID]) REFERENCES  course_teach.course([Course_ID]),
FOREIGN KEY ([Teacher_ID]) REFERENCES  course_teach.teacher([Teacher_ID])
);