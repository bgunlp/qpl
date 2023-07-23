USE spider;
create table  movie_1.Movie(
mID int primary key,
title VARCHAR(400),
year int,
director VARCHAR(400)
);
create table  movie_1.Reviewer(
rID int primary key,
name VARCHAR(400));

create table  movie_1.Rating(
rID int,
mID int,
stars int,
ratingDate date,
FOREIGN KEY (mID) references  movie_1.Movie(mID),
FOREIGN KEY (rID) references  movie_1.Reviewer(rID)
);

