USE spider;
CREATE TABLE  protein_institute.building (
[building_id] VARCHAR(400),
[Name] VARCHAR(400),
[Street_address] VARCHAR(400),
[Years_as_tallest] VARCHAR(400),
[Height_feet] int,
[Floors] int,
PRIMARY KEY([building_id])
);

CREATE TABLE  protein_institute.Institution (
[Institution_id]  VARCHAR(400),
[Institution] VARCHAR(400),
[Location] VARCHAR(400),
[Founded] real,
[Type] VARCHAR(400),
[Enrollment] int,
[Team] VARCHAR(400),
[Primary_Conference] VARCHAR(400),
[building_id] VARCHAR(400),
PRIMARY KEY([Institution_id]),
FOREIGN  KEY ([building_id]) REFERENCES  protein_institute.building([building_id])
);

CREATE TABLE  protein_institute.protein (
[common_name] VARCHAR(400),
[protein_name] VARCHAR(400),
[divergence_from_human_lineage] real,
[accession_number] VARCHAR(400),
[sequence_length] real,
[sequence_identity_to_human_protein] VARCHAR(400),
[Institution_id] VARCHAR(400),
PRIMARY KEY([common_name]),
FOREIGN KEY([Institution_id]) REFERENCES  protein_institute.Institution([Institution_id])
);

