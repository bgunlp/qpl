USE spider;
CREATE TABLE  culture_company.book_club (
[book_club_id] int,
[Year] int,
[Author_or_Editor] VARCHAR(400),
[Book_Title] VARCHAR(400),
[Publisher] VARCHAR(400),
[Category] VARCHAR(400),
[Result] VARCHAR(400),
PRIMARY KEY ([book_club_id])
);

CREATE TABLE  culture_company.movie (
[movie_id] int,
[Title] VARCHAR(400),
[Year] int,
[Director] VARCHAR(400),
[Budget_million] real,
[Gross_worldwide] int,
PRIMARY KEY([movie_id])
);

CREATE TABLE  culture_company.culture_company (
[Company_name] VARCHAR(400),
[Type] VARCHAR(400),
[Incorporated_in] VARCHAR(400),
[Group_Equity_Shareholding] real,
[book_club_id] int,
[movie_id] int,
PRIMARY KEY([Company_name]),
FOREIGN KEY ([book_club_id]) REFERENCES  culture_company.book_club([book_club_id]),
FOREIGN KEY ([movie_id]) REFERENCES  culture_company.movie([movie_id])
);
