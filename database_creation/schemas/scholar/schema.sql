USE spider;
CREATE TABLE  scholar.venue (
venueId integer NOT NULL
,  venueName varchar(100) DEFAULT NULL
,  PRIMARY KEY (venueId)
);



CREATE TABLE  scholar.author (
authorId integer NOT NULL
,  authorName varchar(50) DEFAULT NULL
,  PRIMARY KEY (authorId)
);


CREATE TABLE  scholar.dataset (
datasetId integer NOT NULL
,  datasetName varchar(50) DEFAULT NULL
,  PRIMARY KEY (datasetId)
);


CREATE TABLE  scholar.journal (
journalId integer NOT NULL
,  journalName varchar(100) DEFAULT NULL
,  PRIMARY KEY (journalId)
);

CREATE TABLE  scholar.keyphrase (
keyphraseId integer NOT NULL
,  keyphraseName varchar(50) DEFAULT NULL
,  PRIMARY KEY (keyphraseId)
);


CREATE TABLE  scholar.paper (
paperId integer NOT NULL
,  title varchar(300) DEFAULT NULL
,  venueId integer DEFAULT NULL
,  year integer DEFAULT NULL
,  numCiting integer DEFAULT NULL
,  numCitedBy integer DEFAULT NULL
,  journalId integer DEFAULT NULL
,  PRIMARY KEY (paperId)
,  FOREIGN KEY(journalId) REFERENCES  scholar.journal(journalId)
,  FOREIGN KEY(venueId) REFERENCES  scholar.venue(venueId)
);



CREATE TABLE  scholar.cite (
citingPaperId integer NOT NULL
,  citedPaperId integer NOT NULL
,  PRIMARY KEY (citingPaperId,citedPaperId)
,  FOREIGN KEY(citedpaperId) REFERENCES  scholar.paper(paperId)
,  FOREIGN KEY(citingpaperId) REFERENCES  scholar.paper(paperId)
);


CREATE TABLE  scholar.paperDataset (
paperId integer DEFAULT NULL
,  datasetId integer DEFAULT NULL
,  PRIMARY KEY (datasetId, paperId)
);



CREATE TABLE  scholar.paperKeyphrase (
paperId integer DEFAULT NULL
,  keyphraseId integer DEFAULT NULL
,  PRIMARY KEY (keyphraseId,paperId)
,  FOREIGN KEY(paperId) REFERENCES  scholar.paper(paperId)
,  FOREIGN KEY(keyphraseId) REFERENCES  scholar.keyphrase(keyphraseId)
);


CREATE TABLE  scholar.writes (
paperId integer DEFAULT NULL
,  authorId integer DEFAULT NULL
,  PRIMARY KEY (paperId,authorId)
,  FOREIGN KEY(paperId) REFERENCES  scholar.paper(paperId)
,  FOREIGN KEY(authorId) REFERENCES  scholar.author(authorId)
);

