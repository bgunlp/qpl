BEGIN TRANSACTION;
USE spider;
CREATE TABLE small_bank_1.ACCOUNTS (
    custid      BIGINT      NOT NULL PRIMARY KEY,
    name        VARCHAR(64) NOT NULL
);
CREATE TABLE small_bank_1.SAVINGS (
    custid      BIGINT      NOT NULL PRIMARY KEY,
    balance        FLOAT       NOT NULL,
    FOREIGN KEY (custid) REFERENCES small_bank_1.ACCOUNTS (custid)
);
CREATE TABLE small_bank_1.CHECKING (
    custid      BIGINT      NOT NULL PRIMARY KEY,
    balance        FLOAT       NOT NULL,
    FOREIGN KEY (custid) REFERENCES small_bank_1.ACCOUNTS (custid)
);
COMMIT;
