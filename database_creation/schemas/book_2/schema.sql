USE spider;
CREATE TABLE  book_2.book (
[Book_ID] int,
[Title] VARCHAR(400),
[Issues] real,
[Writer] VARCHAR(400),
PRIMARY KEY ([Book_ID])
);

CREATE TABLE  book_2.publication (
[Publication_ID] int,
[Book_ID] int,
[Publisher] VARCHAR(400),
[Publication_Date] VARCHAR(400),
[Price] real,
PRIMARY KEY ([Publication_ID]),
FOREIGN KEY ([Book_ID]) REFERENCES  book_2.book([Book_ID])
);
