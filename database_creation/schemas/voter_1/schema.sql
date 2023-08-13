BEGIN TRANSACTION;
USE spider;
CREATE TABLE voter_1.AREA_CODE_STATE (
  area_code integer NOT NULL
,  state varchar(3) NOT NULL UNIQUE
,  PRIMARY KEY (area_code)
);
CREATE TABLE voter_1.CONTESTANTS (
  contestant_number integer
,  contestant_name varchar(50) NOT NULL
,  PRIMARY KEY (contestant_number)
);
CREATE TABLE voter_1.VOTES (
  vote_id integer NOT NULL PRIMARY KEY
,  phone_number bigint NOT NULL
,  state varchar(3) NOT NULL
,  contestant_number integer NOT NULL
,  created datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
, 	FOREIGN KEY (state) REFERENCES voter_1.AREA_CODE_STATE(state)
, 	FOREIGN KEY (contestant_number) REFERENCES voter_1.CONTESTANTS(contestant_number)
);
COMMIT;
