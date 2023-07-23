USE spider;
CREATE TABLE  storm_record.storm (
[Storm_ID] int,
[Name] VARCHAR(400),
[Dates_active] VARCHAR(400),
[Max_speed] int,
[Damage_millions_USD] real,
[Number_Deaths] int,
PRIMARY KEY ([Storm_ID])
);


CREATE TABLE  storm_record.region (
Region_id int,
Region_code VARCHAR(400),
Region_name VARCHAR(400),
PRIMARY KEY ([Region_id])
);



CREATE TABLE  storm_record.affected_region (
Region_id int,
Storm_ID int,
Number_city_affected real,
PRIMARY KEY (Region_id,Storm_ID),
FOREIGN KEY (Region_id) REFERENCES  storm_record.region(Region_id),
FOREIGN KEY (Storm_ID) REFERENCES  storm_record.storm(Storm_ID)
);


