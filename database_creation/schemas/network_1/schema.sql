USE spider;
create table  network_1.Highschooler(
ID int primary key,
name VARCHAR(400),
grade int);
create table  network_1.Friend(
student_id int,
friend_id int,
primary key (student_id,friend_id),
foreign key(student_id) references  network_1.Highschooler(ID),
foreign key (friend_id) references  network_1.Highschooler(ID)
);
create table  network_1.Likes(
student_id int,
liked_id int,
primary key (student_id, liked_id),
foreign key (liked_id) references  network_1.Highschooler(ID),
foreign key (student_id) references  network_1.Highschooler(ID)
);
