USE spider;
BEGIN TRANSACTION;
CREATE TABLE twitter_1.user_profiles (
	uid int NOT NULL,
	name varchar(255) DEFAULT NULL,
	email varchar(255) DEFAULT NULL,
	partitionid int DEFAULT NULL,
	followers int DEFAULT NULL,
	PRIMARY KEY (uid)
);

CREATE TABLE twitter_1.follows (
  f1 int NOT NULL,
  f2 int NOT NULL,
  PRIMARY KEY (f1,f2),
  FOREIGN KEY (f1) REFERENCES twitter_1.user_profiles(uid),
  FOREIGN KEY (f2) REFERENCES twitter_1.user_profiles(uid)
);
CREATE TABLE twitter_1.tweets (
  id bigint NOT NULL,
  uid int NOT NULL,
  text char(140) NOT NULL,
  createdate datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  FOREIGN KEY (uid) REFERENCES twitter_1.user_profiles(uid)
);
COMMIT;
