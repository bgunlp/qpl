USE spider;
CREATE TABLE  workshop_paper.workshop (
[Workshop_ID] int,
[Date] VARCHAR(400),
[Venue] VARCHAR(400),
[Name] VARCHAR(400),
PRIMARY KEY ([Workshop_ID])
);

CREATE TABLE  workshop_paper.submission (
[Submission_ID] int,
[Scores] real,
[Author] VARCHAR(400),
[College] VARCHAR(400),
PRIMARY KEY ([Submission_ID])
);





CREATE TABLE  workshop_paper.Acceptance (
[Submission_ID] int,
[Workshop_ID] int,
[Result] VARCHAR(400),
PRIMARY KEY ([Submission_ID],[Workshop_ID]),
FOREIGN KEY ([Submission_ID]) REFERENCES  workshop_paper.submission([Submission_ID]),
FOREIGN KEY ([Workshop_ID]) REFERENCES  workshop_paper.workshop([Workshop_ID])
);


