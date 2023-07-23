USE spider;
CREATE TABLE  dog_kennels.Breeds (
breed_code VARCHAR(10) PRIMARY KEY ,
breed_name VARCHAR(80)
);
CREATE TABLE  dog_kennels.Charges (
charge_id INTEGER PRIMARY KEY ,
charge_type VARCHAR(20),
charge_amount DECIMAL(19,4)
);

CREATE TABLE  dog_kennels.Sizes (
size_code VARCHAR(10) PRIMARY KEY ,
size_description VARCHAR(80)
);

CREATE TABLE  dog_kennels.Treatment_Types (
treatment_type_code VARCHAR(10) PRIMARY KEY ,
treatment_type_description VARCHAR(80)
);

CREATE TABLE  dog_kennels.Owners (
owner_id INTEGER PRIMARY KEY ,
first_name VARCHAR(50),
last_name VARCHAR(50),
street VARCHAR(50),
city VARCHAR(50),
state VARCHAR(20),
zip_code VARCHAR(20),
email_address VARCHAR(50),
home_phone VARCHAR(20),
cell_number VARCHAR(20)
);
CREATE TABLE  dog_kennels.Dogs (
dog_id INTEGER PRIMARY KEY ,
owner_id INTEGER NOT NULL,
abandoned_yn VARCHAR(1),
breed_code VARCHAR(10) NOT NULL,
size_code VARCHAR(10) NOT NULL,
name VARCHAR(50),
age REAL,
date_of_birth DATETIME,
gender VARCHAR(1),
weight VARCHAR(20),
date_arrived DATETIME,
date_adopted DATETIME,
date_departed DATETIME,
FOREIGN KEY (breed_code ) REFERENCES  dog_kennels.Breeds(breed_code ),
FOREIGN KEY (size_code ) REFERENCES  dog_kennels.Sizes(size_code ),
FOREIGN KEY (owner_id ) REFERENCES  dog_kennels.Owners(owner_id ),
FOREIGN KEY (owner_id ) REFERENCES  dog_kennels.Owners(owner_id )
);

CREATE TABLE  dog_kennels.Professionals (
professional_id INTEGER PRIMARY KEY ,
role_code VARCHAR(255) NOT NULL,
first_name VARCHAR(50),
street VARCHAR(255),
city VARCHAR(50),
state VARCHAR(20),
zip_code VARCHAR(20),
last_name VARCHAR(50),
email_address VARCHAR(50),
home_phone VARCHAR(20),
cell_number VARCHAR(20)
);

CREATE TABLE  dog_kennels.Treatments (
treatment_id INTEGER PRIMARY KEY ,
dog_id INTEGER NOT NULL,
professional_id INTEGER NOT NULL,
treatment_type_code VARCHAR(10) NOT NULL,
date_of_treatment DATETIME,
cost_of_treatment DECIMAL(19,4),
FOREIGN KEY (treatment_type_code ) REFERENCES  dog_kennels.Treatment_Types(treatment_type_code ),
FOREIGN KEY (professional_id ) REFERENCES  dog_kennels.Professionals(professional_id ),
FOREIGN KEY (dog_id ) REFERENCES  dog_kennels.Dogs(dog_id )
);
