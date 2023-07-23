USE spider;
CREATE TABLE  imdb.actor (
[aid] int,
[gender] VARCHAR(400),
[name] VARCHAR(400),
[nationality] VARCHAR(400),
[birth_city] VARCHAR(400),
[birth_year] int,
primary key([aid])
);


CREATE TABLE  imdb.copyright (
[id] int,
[msid] int,
[cid] int,
primary key([msid])
);
CREATE TABLE  imdb.cast (
[id] int,
[msid] int,
[aid] int,
[role] int,
primary key([id]),
foreign key([aid]) references  imdb.actor([aid]),
foreign key([msid]) references  imdb.copyright([msid])
);

CREATE TABLE  imdb.genre (
[gid] int,
[genre] VARCHAR(400),
primary key([gid])
);

CREATE TABLE  imdb.classification (
[id] int,
[msid] int,
[gid] int,
primary key([id]),
foreign key([gid]) references  imdb.genre([gid]),
foreign key([msid]) references  imdb.copyright([msid])
);

CREATE TABLE  imdb.company (
[id] int,
[name] VARCHAR(400),
[country_code] VARCHAR(400),
primary key([id])
);


CREATE TABLE  imdb.director (
[did] int,
[gender] VARCHAR(400),
[name] VARCHAR(400),
[nationality] VARCHAR(400),
[birth_city] VARCHAR(400),
[birth_year] int,
primary key([did])
);

CREATE TABLE  imdb.producer (
[pid] int,
[gender] VARCHAR(400),
[name] VARCHAR(400),
[nationality] VARCHAR(400),
[birth_city] VARCHAR(400),
[birth_year] int,
primary key([pid])
);

CREATE TABLE  imdb.directed_by (
[id] int,
[msid] int,
[did] int,
primary key([id]),
foreign key([msid]) references  imdb.copyright([msid]),
foreign key([did]) references  imdb.director([did])
);

CREATE TABLE  imdb.keyword (
[id] int,
[keyword] VARCHAR(400),
primary key([id])
);

CREATE TABLE  imdb.made_by (
[id] int,
[msid] int,
[pid] int,
primary key([id]),
foreign key([msid]) references  imdb.copyright([msid]),
foreign key([pid]) references  imdb.producer([pid])
);

CREATE TABLE  imdb.movie (
[mid] int,
[title] VARCHAR(400),
[release_year] int,
[title_aka] VARCHAR(400),
[budget] VARCHAR(400),
primary key([mid])
);
CREATE TABLE  imdb.tags (
[id] int,
[msid] int,
[kid] int,
primary key([id]),
foreign key([msid]) references  imdb.copyright([msid]),
foreign key([kid]) references  imdb.keyword([id])
);
CREATE TABLE  imdb.tv_series (
[sid] int,
[title] VARCHAR(400),
[release_year] int,
[num_of_seasons] int,
[num_of_episodes] int,
[title_aka] VARCHAR(400),
[budget] VARCHAR(400),
primary key([sid])
);
CREATE TABLE  imdb.writer (
[wid] int,
[gender] VARCHAR(400),
[name] int,
[nationality] int,
[num_of_episodes] int,
[birth_city] VARCHAR(400),
[birth_year] int,
primary key([wid])
);
CREATE TABLE  imdb.written_by (
[id] int,
[msid] int,
[wid] int,
foreign key([msid]) references  imdb.copyright([msid]),
foreign key([wid]) references  imdb.writer([wid])
);
