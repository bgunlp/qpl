USE spider;
CREATE TABLE  shop_membership.member (
[Member_ID] int,
[Card_Number] VARCHAR(400),
[Name] VARCHAR(400),
[Hometown] VARCHAR(400),
[Level] int,
PRIMARY KEY ([Member_ID])
);


CREATE TABLE  shop_membership.branch (
[Branch_ID] int,
[Name] VARCHAR(400),
[Open_year] VARCHAR(400),
[Address_road] VARCHAR(400),
[City] VARCHAR(400),
[membership_amount] int,
PRIMARY KEY ([Branch_ID])
);

CREATE TABLE  shop_membership.membership_register_branch (
[Member_ID] int,
[Branch_ID] int,
[Register_Year] VARCHAR(400),
PRIMARY KEY ([Member_ID]),
FOREIGN KEY ([Member_ID]) REFERENCES  shop_membership.member([Member_ID]),
FOREIGN KEY ([Branch_ID]) REFERENCES  shop_membership.branch([Branch_ID])
);


CREATE TABLE  shop_membership.purchase (
[Member_ID] int,
[Branch_ID] int,
[Year] VARCHAR(400),
[Total_pounds] real,
PRIMARY KEY ([Member_ID],[Branch_ID],[Year]),
FOREIGN KEY ([Member_ID]) REFERENCES  shop_membership.member([Member_ID]),
FOREIGN KEY ([Branch_ID]) REFERENCES  shop_membership.branch([Branch_ID])
);

