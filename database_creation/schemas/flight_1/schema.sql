USE spider;
create table  flight_1.aircraft(
aid int primary key,
name varchar(30),
distance int);

create table  flight_1.flight(
flno int primary key,
origin varchar(20),
destination varchar(20),
distance int,
departure_date date,
arrival_date date,
price int,
aid int,
foreign key([aid]) references  flight_1.aircraft([aid]));

create table  flight_1.employee(
eid int primary key,
name varchar(30),
salary int);

create table  flight_1.certificate(
eid int,
aid int,
primary key(eid,aid),
foreign key([eid]) references  flight_1.employee([eid]),
foreign key([aid]) references  flight_1.aircraft([aid]));
