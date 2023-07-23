USE spider;
CREATE TABLE  geo.state (
state_name VARCHAR(400)
,  population integer DEFAULT NULL
,  area real DEFAULT NULL
,  country_name varchar(3) NOT NULL DEFAULT ''
,  capital VARCHAR(400)
,  density real DEFAULT NULL
,  PRIMARY KEY (state_name)
);

CREATE TABLE  geo.city (
city_name VARCHAR(400)
,  population integer DEFAULT NULL
,  country_name varchar(3) NOT NULL DEFAULT ''
,  state_name VARCHAR(400)
,  PRIMARY KEY (city_name,state_name)
,  FOREIGN KEY(state_name) REFERENCES  geo.state(state_name)
);
CREATE TABLE  geo.border_info (
state_name VARCHAR(400)
,  border VARCHAR(400)
,  PRIMARY KEY (border,state_name)
,  FOREIGN KEY(state_name) REFERENCES  geo.state(state_name)
,  FOREIGN KEY(border) REFERENCES  geo.state(state_name)
);
CREATE TABLE  geo.highlow (
state_name VARCHAR(400)
,  highest_elevation VARCHAR(400)
,  lowest_point VARCHAR(400)
,  highest_point VARCHAR(400)
,  lowest_elevation VARCHAR(400)
,  PRIMARY KEY (state_name)
,  FOREIGN KEY(state_name) REFERENCES  geo.state(state_name)
);
CREATE TABLE  geo.lake (
lake_name VARCHAR(400)
,  area real DEFAULT NULL
,  country_name varchar(3) NOT NULL DEFAULT ''
,  state_name VARCHAR(400)
);
CREATE TABLE  geo.mountain (
mountain_name VARCHAR(400)
,  mountain_altitude integer DEFAULT NULL
,  country_name varchar(3) NOT NULL DEFAULT ''
,  state_name VARCHAR(400)
,  PRIMARY KEY (mountain_name, state_name)
,  FOREIGN KEY(state_name) REFERENCES  geo.state(state_name)
);
CREATE TABLE  geo.river (
river_name VARCHAR(400)
,  length integer DEFAULT NULL
,  country_name varchar(3) NOT NULL DEFAULT ''
,  traverse VARCHAR(400)
,  PRIMARY KEY (river_name)
,  FOREIGN KEY(traverse) REFERENCES  geo.state(state_name)
);
