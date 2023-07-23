BEGIN TRANSACTION;
USE spider;
CREATE TABLE epinions_1.item (
   i_id integer NOT NULL
,  title varchar(20) DEFAULT NULL
,  PRIMARY KEY (i_id)
);

CREATE TABLE epinions_1.useracct (
  u_id integer NOT NULL
,  name varchar(128) DEFAULT NULL
,  PRIMARY KEY (u_id)
);

CREATE TABLE epinions_1.review (
  a_id integer NOT NULL PRIMARY KEY
,  u_id integer NOT NULL
,  i_id integer NOT NULL
,  rating integer DEFAULT NULL
,  rank integer DEFAULT NULL
, 	FOREIGN KEY (u_id) REFERENCES epinions_1.useracct(u_id)
, 	FOREIGN KEY (i_id) REFERENCES epinions_1.item(i_id)
);

CREATE TABLE epinions_1.trust (source_u_id integer NOT NULL, target_u_id integer NOT NULL, trust integer NOT NULL, FOREIGN KEY (source_u_id) REFERENCES epinions_1.useracct(u_id), FOREIGN KEY (target_u_id) REFERENCES epinions_1.useracct(u_id));
COMMIT;
