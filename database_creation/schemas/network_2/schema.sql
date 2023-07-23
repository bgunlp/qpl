USE spider;
CREATE TABLE  network_2.Person (
name varchar(20) PRIMARY KEY,
age INTEGER,
city VARCHAR(400),
gender VARCHAR(400),
job VARCHAR(400)
);

CREATE TABLE  network_2.PersonFriend (
name varchar(20),
friend varchar(20),
year INTEGER,
FOREIGN KEY (name) REFERENCES  network_2.Person(name),
FOREIGN KEY (friend) REFERENCES  network_2.Person(name)
);
