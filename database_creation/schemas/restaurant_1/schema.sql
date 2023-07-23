USE spider;
create table  restaurant_1.Student (
StuID        INTEGER PRIMARY KEY,
LName        VARCHAR(12),
Fname        VARCHAR(12),
Age      INTEGER,
Sex      VARCHAR(1),
Major        INTEGER,
Advisor      INTEGER,
city_code    VARCHAR(3)
);

create table  restaurant_1.Restaurant (
ResID       INTEGER PRIMARY KEY,
ResName     VARCHAR(100),
Address     VARCHAR(100),
Rating INTEGER
);

create table  restaurant_1.Restaurant_Type (
ResTypeID            INTEGER PRIMARY KEY,
ResTypeName          VARCHAR(40),
ResTypeDescription   VARCHAR(100)
);

create table  restaurant_1.Type_Of_Restaurant (
ResID       INTEGER,
ResTypeID   INTEGER,
FOREIGN KEY(ResID) REFERENCES  restaurant_1.Restaurant(ResID),
FOREIGN KEY(ResTypeID) REFERENCES  restaurant_1.Restaurant_Type(ResTypeID)
);

create table  restaurant_1.Visits_Restaurant (
StuID      INTEGER,
ResID      INTEGER,
Time       DATETIME,
Spent      FLOAT,
FOREIGN KEY(StuID) REFERENCES  restaurant_1.Student(StuID),
FOREIGN KEY(ResID) REFERENCES  restaurant_1.Restaurant(ResID)
);
