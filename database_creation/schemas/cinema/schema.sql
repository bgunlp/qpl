USE spider;
CREATE TABLE  cinema.film (
[Film_ID] int,
[Rank_in_series] int,
[Number_in_season] int,
[Title] VARCHAR(400),
[Directed_by] VARCHAR(400),
[Original_air_date] VARCHAR(400),
[Production_code] VARCHAR(400),
PRIMARY KEY ([Film_ID])
);

CREATE TABLE  cinema.cinema (
[Cinema_ID] int,
[Name] VARCHAR(400),
[Openning_year] int,
[Capacity] int,
[Location] VARCHAR(400),
PRIMARY KEY ([Cinema_ID]));


CREATE TABLE  cinema.schedule (
[Cinema_ID] int,
[Film_ID] int,
[Date] VARCHAR(400),
[Show_times_per_day] int,
[Price] float,
PRIMARY KEY ([Cinema_ID],[Film_ID]),
FOREIGN KEY (Film_ID) REFERENCES  cinema.film(Film_ID),
FOREIGN KEY (Cinema_ID) REFERENCES  cinema.cinema(Cinema_ID)
);


