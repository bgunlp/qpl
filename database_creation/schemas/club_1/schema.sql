USE spider;
create table  club_1.Student (
StuID        INTEGER PRIMARY KEY,
LName        VARCHAR(12),
Fname        VARCHAR(12),
Age      INTEGER,
Sex      VARCHAR(1),
Major        INTEGER,
Advisor      INTEGER,
city_code    VARCHAR(3)
);


create table  club_1.Club (
ClubID           INTEGER PRIMARY KEY,
ClubName         VARCHAR(40),
ClubDesc         VARCHAR(1024),
ClubLocation VARCHAR(40)
);

create table  club_1.Member_of_club (
StuID            INTEGER,
ClubID           INTEGER,
Position     VARCHAR(40),
FOREIGN KEY(StuID) REFERENCES  club_1.Student(StuID),
FOREIGN KEY(ClubID) REFERENCES  club_1.Club(ClubID)
);


