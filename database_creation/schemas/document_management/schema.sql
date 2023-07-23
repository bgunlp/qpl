USE spider;
CREATE TABLE  document_management.Roles (
role_code VARCHAR(15) PRIMARY KEY,
role_description VARCHAR(80)
);

CREATE TABLE  document_management.Users (
user_id INTEGER PRIMARY KEY,
role_code VARCHAR(15) NOT NULL,
user_name VARCHAR(40),
user_login VARCHAR(40),
password VARCHAR(40),
FOREIGN KEY (role_code ) REFERENCES  document_management.Roles(role_code )
);

CREATE TABLE  document_management.Document_Structures (
document_structure_code VARCHAR(15) PRIMARY KEY,
parent_document_structure_code VARCHAR(15),
document_structure_description VARCHAR(80)
);

CREATE TABLE  document_management.Functional_Areas (
functional_area_code VARCHAR(15) PRIMARY KEY,
parent_functional_area_code VARCHAR(15),
functional_area_description VARCHAR(80) NOT NULL
);


CREATE TABLE  document_management.Images (
image_id INTEGER PRIMARY KEY,
image_alt_text VARCHAR(80),
image_name VARCHAR(40),
image_url VARCHAR(255)
);
CREATE TABLE  document_management.Documents (
document_code VARCHAR(15) PRIMARY KEY,
document_structure_code VARCHAR(15) NOT NULL,
document_type_code VARCHAR(15) NOT NULL,
access_count INTEGER,
document_name VARCHAR(80),
FOREIGN KEY (document_structure_code ) REFERENCES  document_management.Document_Structures(document_structure_code )
);
CREATE TABLE  document_management.Document_Functional_Areas (
document_code VARCHAR(15) NOT NULL,
functional_area_code VARCHAR(15) NOT NULL,
FOREIGN KEY (document_code ) REFERENCES  document_management.Documents(document_code ),
FOREIGN KEY (functional_area_code ) REFERENCES  document_management.Functional_Areas(functional_area_code )
);
CREATE TABLE  document_management.Document_Sections (
section_id INTEGER PRIMARY KEY,
document_code VARCHAR(15) NOT NULL,
section_sequence INTEGER,
section_code VARCHAR(20),
section_title VARCHAR(80),
FOREIGN KEY (document_code ) REFERENCES  document_management.Documents(document_code )
);
CREATE TABLE  document_management.Document_Sections_Images (
section_id INTEGER NOT NULL,
image_id INTEGER NOT NULL,
PRIMARY KEY (section_id,image_id),
FOREIGN KEY (section_id ) REFERENCES  document_management.Document_Sections(section_id ),
FOREIGN KEY (image_id ) REFERENCES  document_management.Images(image_id )
);
