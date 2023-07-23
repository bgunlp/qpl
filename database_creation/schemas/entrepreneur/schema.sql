USE spider;
CREATE TABLE  entrepreneur.people (
[People_ID] int,
[Name] VARCHAR(400),
[Height] real,
[Weight] real,
[Date_of_Birth] VARCHAR(400),
PRIMARY KEY ([People_ID])
);

CREATE TABLE  entrepreneur.entrepreneur (
[Entrepreneur_ID] int,
[People_ID] int,
[Company] VARCHAR(400),
[Money_Requested] real,
[Investor] VARCHAR(400),
PRIMARY KEY ([Entrepreneur_ID]),
FOREIGN KEY ([People_ID]) REFERENCES  entrepreneur.people([People_ID])
);

