USE spider;
CREATE TABLE  school_finance.School (
[School_id] int,
[School_name] VARCHAR(400),
[Location] VARCHAR(400),
[Mascot] VARCHAR(400),
[Enrollment] int,
[IHSAA_Class] VARCHAR(400),
[IHSAA_Football_Class] VARCHAR(400),
[County] VARCHAR(400),
PRIMARY KEY ([School_id])
);

CREATE TABLE  school_finance.budget (
[School_id] int,
[Year] int,
[Budgeted] int,
[total_budget_percent_budgeted] real,
[Invested] int,
[total_budget_percent_invested] real,
[Budget_invested_percent] VARCHAR(400),
PRIMARY KEY([School_id],[YEAR]),
FOREIGN KEY([School_id]) REFERENCES  school_finance.School([School_id])

);

CREATE TABLE  school_finance.endowment (
[endowment_id] int,
[School_id] int,
[donator_name] VARCHAR(400),
[amount] real,
PRIMARY KEY([endowment_id]),
FOREIGN KEY([School_id]) REFERENCES  school_finance.School([School_id])
);
