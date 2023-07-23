USE spider;
CREATE TABLE  csu_1.Campuses (
[Id] INTEGER PRIMARY KEY,
[Campus] VARCHAR(400),
[Location] VARCHAR(400),
[County] VARCHAR(400),
[Year] INTEGER
);

CREATE TABLE  csu_1.csu_fees (
[Campus] INTEGER NOT NULL,
[Year] INTEGER NOT NULL,
[CampusFee] INTEGER,
CONSTRAINT PK_Fees PRIMARY KEY (Campus, Year),
FOREIGN KEY (Campus) REFERENCES  csu_1.Campuses(Id)
);

CREATE TABLE  csu_1.degrees (
[Year] INTEGER,
[Campus] INTEGER,
[Degrees] INTEGER,
PRIMARY KEY (Year, Campus),
FOREIGN KEY (Campus) REFERENCES  csu_1.Campuses(Id)
);



CREATE TABLE  csu_1.discipline_enrollments (
[Campus] INTEGER,
[Discipline] INTEGER,
[Year] INTEGER,
[Undergraduate] INTEGER,
[Graduate] INTEGER,
PRIMARY KEY (Campus, Discipline),
FOREIGN KEY (Campus) REFERENCES  csu_1.Campuses(Id)
);



CREATE TABLE  csu_1.enrollments (
[Campus] INTEGER,
[Year] INTEGER,
[TotalEnrollment_AY] INTEGER,
[FTE_AY] INTEGER,
PRIMARY KEY(Campus, Year),
FOREIGN KEY (Campus) REFERENCES  csu_1.Campuses(Id)
);

CREATE TABLE  csu_1.faculty (
[Campus] INTEGER,
[Year] INTEGER,
[Faculty] REAL,
FOREIGN KEY (Campus) REFERENCES  csu_1.Campuses(Id)
);


