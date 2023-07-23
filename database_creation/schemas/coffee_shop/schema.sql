USE spider;
CREATE TABLE  coffee_shop.shop (
[Shop_ID] int,
[Address] VARCHAR(400),
[Num_of_staff] int,
[Score] real,
[Open_Year] int,
PRIMARY KEY ([Shop_ID])
);

CREATE TABLE  coffee_shop.member (
[Member_ID] int,
[Name] VARCHAR(400),
[Membership_card] VARCHAR(400),
[Age] int,
[Time_of_purchase] int,
[Level_of_membership] int,
[Address] VARCHAR(400),
PRIMARY KEY ([Member_ID])
);


CREATE TABLE  coffee_shop.happy_hour (
[HH_ID] int,
[Shop_ID] int,
[Month] VARCHAR(400),
[Num_of_shaff_in_charge] int,
PRIMARY KEY ([HH_ID],[Shop_ID],[Month]),
FOREIGN KEY ([Shop_ID]) REFERENCES  coffee_shop.shop([Shop_ID])
);

CREATE TABLE  coffee_shop.happy_hour_member (
[HH_ID] int,
[Member_ID] int,
[Total_amount] real,
PRIMARY KEY ([HH_ID],[Member_ID]),
FOREIGN KEY ([Member_ID]) REFERENCES  coffee_shop.member([Member_ID])
);
