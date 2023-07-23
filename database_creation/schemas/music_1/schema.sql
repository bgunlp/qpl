USE spider;
create table  music_1.genre(
g_name varchar(20) not null,
rating varchar(10),
most_popular_in varchar(50),
primary key(g_name)
);

create table  music_1.artist(
artist_name varchar(50) not null,
country varchar(20),
gender varchar(20),
preferred_genre varchar(20),
constraint a_name primary key(artist_name),
foreign key(preferred_genre) references  music_1.genre(g_name)
);

create table  music_1.files(
f_id int not null,
artist_name varchar(50),
file_size varchar(20),
duration varchar(4),
formats varchar(20),
primary key(f_id),
foreign key(artist_name) references  music_1.artist(artist_name)
);


create table  music_1.song(
song_name varchar(50),
artist_name varchar(50),
country varchar(20),
f_id int,
genre_is varchar(20),
rating int check(rating>0 and rating<11),
languages varchar(20),
releasedate Date,
resolution int not null,
constraint s_name primary key(song_name),
foreign key(artist_name) references  music_1.artist(artist_name),
foreign key(f_id) references  music_1.files(f_id),
foreign key(genre_is) references  music_1.genre(g_name)
);
