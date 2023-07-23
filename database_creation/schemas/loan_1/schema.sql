USE spider;
CREATE TABLE  loan_1.bank (
branch_ID int PRIMARY KEY,
bname varchar(20),
no_of_customers int,
city varchar(15),
state varchar(20));


CREATE TABLE  loan_1.customer (
cust_ID varchar(3) PRIMARY KEY,
cust_name varchar(20),
acc_type char(8),
acc_bal int,
no_of_loans int,
credit_score int,
branch_ID int,
state varchar(20),
FOREIGN KEY(branch_ID) REFERENCES  loan_1.bank(branch_ID));


CREATE TABLE  loan_1.loan (
loan_ID varchar(3) PRIMARY KEY,
loan_type varchar(15),
cust_ID varchar(3),
branch_ID int,
amount int,
FOREIGN KEY(branch_ID) REFERENCES  loan_1.bank(branch_ID),
FOREIGN KEY(Cust_ID) REFERENCES  loan_1.customer(Cust_ID));
