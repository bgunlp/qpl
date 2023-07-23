USE spider;
CREATE TABLE  news_report.event (
[Event_ID] int,
[Date] VARCHAR(400),
[Venue] VARCHAR(400),
[Name] VARCHAR(400),
[Event_Attendance] int,
PRIMARY KEY ([Event_ID])
);

CREATE TABLE  news_report.journalist (
[journalist_ID] int,
[Name] VARCHAR(400),
[Nationality] VARCHAR(400),
[Age] int,
[Years_working] int,
PRIMARY KEY ([journalist_ID])
);


CREATE TABLE  news_report.news_report (
[journalist_ID] int,
[Event_ID] int,
[Work_Type] VARCHAR(400),
PRIMARY KEY ([journalist_ID],[Event_ID]),
FOREIGN KEY ([journalist_ID]) REFERENCES  news_report.journalist([journalist_ID]),
FOREIGN KEY ([Event_ID]) REFERENCES  news_report.event([Event_ID])
);
