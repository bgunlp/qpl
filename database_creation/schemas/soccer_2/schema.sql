USE spider;
CREATE TABLE 	 soccer_2.College
( cName   	varchar(20) NOT NULL,
state   	varchar(2),
enr     	numeric(5,0),
PRIMARY KEY (cName)
);

CREATE TABLE 	 soccer_2.Player
( pID			numeric(5,0) NOT NULL,
pName   	varchar(20),
yCard   	varchar(3),
HS      	numeric(5,0),
PRIMARY KEY (pID)
);

CREATE TABLE 	 soccer_2.Tryout
( pID			numeric(5,0),
cName   	varchar(20),
pPos    	varchar(8),
decision    varchar(3),
PRIMARY KEY (pID, cName),
FOREIGN KEY (pID) REFERENCES  soccer_2.Player(pID),
FOREIGN KEY (cName) REFERENCES  soccer_2.College(cName)
);
