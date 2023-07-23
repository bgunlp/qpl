BEGIN TRANSACTION;
USE spider;
CREATE TABLE company_1.works_on(
Essn INTEGER,
Pno INTEGER,
Hours REAL,
PRIMARY KEY(Essn, Pno));
CREATE TABLE company_1.employee(
Fname VARCHAR(MAX),
Minit VARCHAR(MAX),
Lname VARCHAR(MAX),
Ssn INTEGER PRIMARY KEY,
Bdate VARCHAR(MAX),
Address VARCHAR(MAX),
Sex VARCHAR(MAX),
Salary INTEGER,
Super_ssn INTEGER, 
Dno INTEGER);
CREATE TABLE company_1.department(
Dname VARCHAR(MAX),
Dnumber INTEGER PRIMARY KEY,
Mgr_ssn INTEGER,
Mgr_start_date VARCHAR(MAX));
CREATE TABLE company_1.project(
Pname VARCHAR(MAX),
Pnumber INTEGER PRIMARY KEY,
Plocation VARCHAR(MAX),
Dnum INTEGER);
CREATE TABLE company_1.[dependent](
Essn INTEGER,
Dependent_name VARCHAR(400),
Sex VARCHAR(MAX),
Bdate VARCHAR(MAX),
Relationship VARCHAR(MAX),
PRIMARY KEY(Essn, Dependent_name));
CREATE TABLE company_1.dept_locations(
Dnumber INTEGER,
Dlocation VARCHAR(400),
PRIMARY KEY(Dnumber, Dlocation));
COMMIT;
