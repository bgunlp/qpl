USE spider;
CREATE TABLE  cre_Docs_and_Epenses.Ref_Document_Types (
Document_Type_Code CHAR(15) NOT NULL,
Document_Type_Name VARCHAR(255) NOT NULL,
Document_Type_Description VARCHAR(255) NOT NULL,
PRIMARY KEY (Document_Type_Code)
);
CREATE TABLE  cre_Docs_and_Epenses.Ref_Budget_Codes (
Budget_Type_Code CHAR(15) NOT NULL,
Budget_Type_Description VARCHAR(255) NOT NULL,
PRIMARY KEY (Budget_Type_Code)
);


CREATE TABLE  cre_Docs_and_Epenses.Projects (
Project_ID INTEGER NOT NULL,
Project_Details VARCHAR(255),
PRIMARY KEY (Project_ID)
);

CREATE TABLE  cre_Docs_and_Epenses.Documents (
Document_ID INTEGER NOT NULL,
Document_Type_Code CHAR(15) NOT NULL,
Project_ID INTEGER NOT NULL,
Document_Date DATETIME,
Document_Name VARCHAR(255),
Document_Description VARCHAR(255),
Other_Details VARCHAR(255),
PRIMARY KEY (Document_ID),
FOREIGN KEY (Document_Type_Code) REFERENCES  cre_Docs_and_Epenses.Ref_Document_Types (Document_Type_Code),
FOREIGN KEY (Project_ID) REFERENCES  cre_Docs_and_Epenses.Projects (Project_ID)
);

CREATE TABLE  cre_Docs_and_Epenses.Statements (
Statement_ID INTEGER NOT NULL,
Statement_Details VARCHAR(255),
PRIMARY KEY (Statement_ID),
FOREIGN KEY (Statement_ID) REFERENCES  cre_Docs_and_Epenses.Documents (Document_ID)
);



CREATE TABLE  cre_Docs_and_Epenses.Documents_with_Expenses (
Document_ID INTEGER NOT NULL,
Budget_Type_Code CHAR(15) NOT NULL,
Document_Details VARCHAR(255),
PRIMARY KEY (Document_ID),
FOREIGN KEY (Budget_Type_Code) REFERENCES  cre_Docs_and_Epenses.Ref_Budget_Codes (Budget_Type_Code),
FOREIGN KEY (Document_ID) REFERENCES  cre_Docs_and_Epenses.Documents (Document_ID)
);

CREATE TABLE  cre_Docs_and_Epenses.Accounts (
Account_ID INTEGER NOT NULL,
Statement_ID INTEGER NOT NULL,
Account_Details VARCHAR(255),
PRIMARY KEY (Account_ID),
FOREIGN KEY (Statement_ID) REFERENCES  cre_Docs_and_Epenses.Statements (Statement_ID)
);
