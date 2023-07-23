USE spider;
create table  pets_1.Student (
StuID    	INTEGER PRIMARY KEY,
LName		VARCHAR(12),
Fname		VARCHAR(12),
Age		INTEGER,
Sex		VARCHAR(1),
Major		INTEGER,
Advisor		INTEGER,
city_code	VARCHAR(3)
);

create table  pets_1.Pets (
PetID		INTEGER PRIMARY KEY,
PetType		VARCHAR(20),
pet_age INTEGER,
weight REAL
);

create table  pets_1.Has_Pet (
StuID		INTEGER,
PetID		INTEGER,
FOREIGN KEY(PetID) REFERENCES  pets_1.Pets(PetID),
FOREIGN KEY(StuID) REFERENCES  pets_1.Student(StuID)
);

