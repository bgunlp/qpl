USE spider;
CREATE TABLE  restaurants.GEOGRAPHIC (
[CITY_NAME] VARCHAR(400),
[COUNTY] VARCHAR(400),
[REGION] VARCHAR(400),
primary key([CITY_NAME])
);
CREATE TABLE  restaurants.RESTAURANT (
[ID] int,
[NAME] VARCHAR(400),
[FOOD_TYPE] VARCHAR(400),
[CITY_NAME] VARCHAR(400),
[RATING] real,
primary key([ID]),
foreign key ([CITY_NAME]) references  restaurants.GEOGRAPHIC([CITY_NAME])
);
CREATE TABLE  restaurants.LOCATION (
[RESTAURANT_ID] int,
[HOUSE_NUMBER] int,
[STREET_NAME] VARCHAR(400),
[CITY_NAME] VARCHAR(400),
primary key([RESTAURANT_ID]),
foreign key ([CITY_NAME]) references  restaurants.GEOGRAPHIC([CITY_NAME]),
foreign key ([RESTAURANT_ID]) references  restaurants.RESTAURANT([ID])
);
