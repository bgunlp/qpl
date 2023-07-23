USE spider;
create table  college_3.Student (
StuID        INTEGER PRIMARY KEY,
LName        VARCHAR(12),
Fname        VARCHAR(12),
Age      INTEGER,
Sex      VARCHAR(1),
Major        INTEGER,
Advisor      INTEGER,
city_code    VARCHAR(3)
);

create table  college_3.Faculty (
FacID 	       INTEGER PRIMARY KEY,
Lname		VARCHAR(15),
Fname		VARCHAR(15),
Rank		VARCHAR(15),
Sex		VARCHAR(1),
Phone		INTEGER,
Room		VARCHAR(5),
Building		VARCHAR(13)
);

create table  college_3.Department (
DNO   		INTEGER PRIMARY KEY,
Division		VARCHAR(2),
DName		VARCHAR(25),
Room		VARCHAR(5),
Building		VARCHAR(13),
DPhone		INTEGER
);

create table  college_3.Member_of (
FacID 	       INTEGER,
DNO	       INTEGER,
Appt_Type       VARCHAR(15),
FOREIGN KEY(FacID) REFERENCES  college_3.Faculty(FacID),
FOREIGN KEY(DNO) REFERENCES  college_3.Department(DNO)
);

create table  college_3.Course (
CID   	    	VARCHAR(7) PRIMARY KEY,
CName		VARCHAR(40),
Credits		INTEGER,
Instructor	INTEGER,
Days		VARCHAR(5),
Hours		VARCHAR(11),
DNO		INTEGER,
FOREIGN KEY(Instructor) REFERENCES  college_3.Faculty(FacID),
FOREIGN KEY(DNO) REFERENCES  college_3.Department(DNO)
);

create table  college_3.Minor_in (
StuID 	      INTEGER,
DNO		INTEGER,
FOREIGN KEY(StuID) REFERENCES  college_3.Student(StuID),
FOREIGN KEY(DNO) REFERENCES  college_3.Department(DNO)
);

create table  college_3.Gradeconversion (
lettergrade	     VARCHAR(2) PRIMARY KEY,
gradepoint	     FLOAT
);

create table  college_3.Enrolled_in (
StuID 		 INTEGER,
CID		VARCHAR(7),
Grade		VARCHAR(2),
FOREIGN KEY(StuID) REFERENCES  college_3.Student(StuID),
FOREIGN KEY(CID) REFERENCES  college_3.Course(CID),
FOREIGN KEY(Grade) REFERENCES  college_3.Gradeconversion(lettergrade)
);

