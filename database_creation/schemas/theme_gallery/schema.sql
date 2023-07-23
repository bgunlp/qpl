USE spider;
CREATE TABLE  theme_gallery.artist (
[Artist_ID] int,
[Name] VARCHAR(400),
[Country] VARCHAR(400),
[Year_Join] int,
[Age] int,
PRIMARY KEY ([Artist_ID])
);


CREATE TABLE  theme_gallery.exhibition (
[Exhibition_ID] int,
[Year] int,
[Theme] VARCHAR(400),
[Artist_ID] int,
[Ticket_Price] real,
PRIMARY KEY ([Exhibition_ID]),
FOREIGN KEY (Artist_ID) REFERENCES  theme_gallery.artist(Artist_ID)
);

CREATE TABLE  theme_gallery.exhibition_record (
[Exhibition_ID] int,
[Date] VARCHAR(400),
[Attendance] int,
PRIMARY KEY ([Exhibition_ID],[Date]),
FOREIGN KEY (Exhibition_ID) REFERENCES  theme_gallery.exhibition(Exhibition_ID)
);
