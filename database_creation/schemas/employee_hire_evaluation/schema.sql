USE spider;
CREATE TABLE  employee_hire_evaluation.employee (
[Employee_ID] int,
[Name] VARCHAR(400),
[Age] int,
[City] VARCHAR(400),
PRIMARY KEY ([Employee_ID])
);

CREATE TABLE  employee_hire_evaluation.shop (
[Shop_ID] int,
[Name] VARCHAR(400),
[Location] VARCHAR(400),
[District] VARCHAR(400),
[Number_products] int,
[Manager_name] VARCHAR(400),
PRIMARY KEY ([Shop_ID])
);

CREATE TABLE  employee_hire_evaluation.hiring (
[Shop_ID] int,
[Employee_ID] int,
[Start_from] VARCHAR(400),
[Is_full_time] CHAR(1),
PRIMARY KEY ([Employee_ID]),
FOREIGN KEY (Shop_ID) REFERENCES  employee_hire_evaluation.shop(Shop_ID),
FOREIGN KEY (Employee_ID) REFERENCES  employee_hire_evaluation.employee(Employee_ID),
CONSTRAINT CHK_Is_full_time CHECK ([Is_full_time] IN ('T', 'F'))
);

CREATE TABLE  employee_hire_evaluation.evaluation (
[Employee_ID] int,
[Year_awarded] VARCHAR(400),
[Bonus] real,
PRIMARY KEY ([Employee_ID],[Year_awarded]),
FOREIGN KEY (Employee_ID) REFERENCES  employee_hire_evaluation.employee(Employee_ID)
);
