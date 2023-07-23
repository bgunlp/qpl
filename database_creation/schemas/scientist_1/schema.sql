USE spider;
create table  scientist_1.Scientists (
SSN int,
Name Char(30) not null,
Primary Key (SSN)
);

Create table  scientist_1.Projects (
Code Char(4),
Name Char(50) not null,
Hours int,
Primary Key (Code)
);

create table  scientist_1.AssignedTo (
Scientist int not null,
Project char(4) not null,
Primary Key (Scientist, Project),
Foreign Key (Scientist) references  scientist_1.Scientists (SSN),
Foreign Key (Project) references  scientist_1.Projects (Code)
);
