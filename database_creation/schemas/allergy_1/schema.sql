USE spider;
create table  allergy_1.Allergy_Type (
Allergy 		  VARCHAR(20) PRIMARY KEY,
AllergyType 	  VARCHAR(20)
);

create table  allergy_1.Student (
StuID        INTEGER PRIMARY KEY,
LName        VARCHAR(12),
Fname        VARCHAR(12),
Age      INTEGER,
Sex      VARCHAR(1),
Major        INTEGER,
Advisor      INTEGER,
city_code    VARCHAR(3)
);

create table  allergy_1.Has_Allergy (
StuID 		 INTEGER,
Allergy 		 VARCHAR(20),
FOREIGN KEY(StuID) REFERENCES  allergy_1.Student(StuID),
FOREIGN KEY(Allergy) REFERENCES  allergy_1.Allergy_Type(Allergy)
);
