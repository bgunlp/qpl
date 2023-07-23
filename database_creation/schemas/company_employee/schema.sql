USE spider;
CREATE TABLE  company_employee.people (
[People_ID] int,
[Age] int,
[Name] VARCHAR(400),
[Nationality] VARCHAR(400),
[Graduation_College] VARCHAR(400),
PRIMARY KEY ([People_ID])
);




CREATE TABLE  company_employee.company (
[Company_ID] real,
[Name] VARCHAR(400),
[Headquarters] VARCHAR(400),
[Industry] VARCHAR(400),
[Sales_in_Billion] real,
[Profits_in_Billion] real,
[Assets_in_Billion] real,
[Market_Value_in_Billion] real,
PRIMARY KEY ([Company_ID])
);


CREATE TABLE  company_employee.employment (
[Company_ID] real,
[People_ID] int,
[Year_working] int,
PRIMARY KEY ([Company_ID],[People_ID]),
FOREIGN KEY ([Company_ID]) REFERENCES  company_employee.company([Company_ID]),
FOREIGN KEY ([People_ID]) REFERENCES  company_employee.people([People_ID])
);
