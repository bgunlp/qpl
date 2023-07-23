USE spider;
CREATE TABLE  company_office.buildings (
[id] int,
[name] VARCHAR(400),
[City] VARCHAR(400),
[Height] int,
[Stories] int,
[Status] VARCHAR(400),
PRIMARY KEY([id])
);

CREATE TABLE  company_office.Companies (
[id] int,
[name] VARCHAR(400),
[Headquarters] VARCHAR(400),
[Industry] VARCHAR(400),
[Sales_billion] real,
[Profits_billion] real,
[Assets_billion] real,
[Market_Value_billion] VARCHAR(400),
PRIMARY KEY ([id])
);

CREATE TABLE  company_office.Office_locations (
[building_id] int,
[company_id] int,
[move_in_year] int,
PRIMARY KEY ([building_id], [company_id]),
FOREIGN KEY ([building_id]) REFERENCES  company_office.buildings([id]),
FOREIGN KEY ([company_id]) REFERENCES  company_office.Companies([id])
);
