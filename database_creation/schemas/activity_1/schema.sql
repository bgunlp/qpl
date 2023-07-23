USE spider;
create table  activity_1.Activity (
actid INTEGER PRIMARY KEY,
activity_name varchar(25)
);

create table  activity_1.Student (
StuID        INTEGER PRIMARY KEY,
LName        VARCHAR(12),
Fname        VARCHAR(12),
Age      INTEGER,
Sex      VARCHAR(1),
Major        INTEGER,
Advisor      INTEGER,
city_code    VARCHAR(3)
);

create table  activity_1.Participates_in (
stuid INTEGER,
actid INTEGER,
FOREIGN KEY(stuid) REFERENCES  activity_1.Student(StuID),
FOREIGN KEY(actid) REFERENCES  activity_1.Activity(actid)
);

create table  activity_1.Faculty (
FacID 	       INTEGER PRIMARY KEY,
Lname		VARCHAR(15),
Fname		VARCHAR(15),
Rank		VARCHAR(15),
Sex		VARCHAR(1),
Phone		INTEGER,
Room		VARCHAR(5),
Building		VARCHAR(13)
);

create table  activity_1.Faculty_Participates_in (
FacID INTEGER,
actid INTEGER,
FOREIGN KEY(FacID) REFERENCES  activity_1.Faculty(FacID),
FOREIGN KEY(actid) REFERENCES  activity_1.Activity(actid)
);