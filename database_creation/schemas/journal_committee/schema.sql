USE spider;
CREATE TABLE  journal_committee.[journal] (
[Journal_ID] int,
[Date] VARCHAR(400),
[Theme] VARCHAR(400),
[Sales] int,
PRIMARY KEY ([Journal_ID])
);
CREATE TABLE  journal_committee.[editor] (
[Editor_ID] int,
[Name] VARCHAR(400),
[Age] real,
PRIMARY KEY ([Editor_ID])
);
CREATE TABLE  journal_committee.[journal_committee] (
[Editor_ID] int,
[Journal_ID] int,
[Work_Type] VARCHAR(400),
PRIMARY KEY ([Editor_ID],[Journal_ID]),
FOREIGN KEY ([Editor_ID]) REFERENCES  journal_committee.editor([Editor_ID]),
FOREIGN KEY ([Journal_ID]) REFERENCES  journal_committee.journal([Journal_ID])
);
