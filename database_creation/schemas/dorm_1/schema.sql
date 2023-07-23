USE spider;
create table  dorm_1.Student (
StuID        INTEGER PRIMARY KEY,
LName        VARCHAR(12),
Fname        VARCHAR(12),
Age      INTEGER,
Sex      VARCHAR(1),
Major        INTEGER,
Advisor      INTEGER,
city_code    VARCHAR(3)
);


create table  dorm_1.Dorm (
dormid		INTEGER PRIMARY KEY,
dorm_name	VARCHAR(20),
student_capacity	INTEGER,
gender			VARCHAR(1)
) ;

create table  dorm_1.Dorm_amenity (
amenid			INTEGER PRIMARY KEY,
amenity_name		VARCHAR(25)
) ;

create table  dorm_1.Has_amenity (
dormid			INTEGER,
amenid				INTEGER,
FOREIGN KEY (dormid) REFERENCES  dorm_1.Dorm(dormid),
FOREIGN KEY (amenid) REFERENCES  dorm_1.Dorm_amenity(amenid)
);

create table  dorm_1.Lives_in (
stuid 	      INTEGER,
dormid		INTEGER,
room_number	INTEGER,
FOREIGN KEY (stuid) REFERENCES  dorm_1.Student(StuID),
FOREIGN KEY (dormid) REFERENCES  dorm_1.Dorm(dormid)
);
