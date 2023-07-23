BEGIN TRANSACTION;
USE spider;
CREATE TABLE icfp_1.Inst (
  instID INTEGER,
  name VARCHAR(MAX),
  country VARCHAR(MAX), -- the home country of the institution (this is obviously an impoverished model)
  PRIMARY KEY (instID)
);
CREATE TABLE icfp_1.Authors (
  authID INTEGER,
  lname VARCHAR(MAX),
  fname VARCHAR(MAX),
  PRIMARY KEY (authID)
);
CREATE TABLE icfp_1.Papers (
  paperID INTEGER,
  title VARCHAR(MAX),
  PRIMARY KEY (paperID)
);
CREATE TABLE icfp_1.Authorship (
  authID INTEGER,
  instID INTEGER,
  paperID INTEGER,
  authOrder INTEGER,
  PRIMARY KEY (authID, instID, paperID),
  FOREIGN KEY (authID) REFERENCES icfp_1.Authors (authID),
  FOREIGN KEY (instID) REFERENCES icfp_1.Inst (instID),
  FOREIGN KEY (paperID) REFERENCES icfp_1.Papers (paperID)
);
COMMIT;
