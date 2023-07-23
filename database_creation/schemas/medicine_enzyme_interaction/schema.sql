USE spider;
CREATE TABLE  medicine_enzyme_interaction.medicine (
[id] int,
[name] VARCHAR(400),
[Trade_Name] VARCHAR(400),
[FDA_approved] VARCHAR(400),
primary key ([id])
);

CREATE TABLE  medicine_enzyme_interaction.enzyme (
[id] int,
[name] VARCHAR(400),
[Location] VARCHAR(400),
[Product] VARCHAR(400),
[Chromosome] VARCHAR(400),
[OMIM] int,
[Porphyria] VARCHAR(400),
primary key ([id])
);


CREATE TABLE  medicine_enzyme_interaction.medicine_enzyme_interaction (
[enzyme_id] int,
[medicine_id] int,
[interaction_type] VARCHAR(400),
primary key ([enzyme_id], [medicine_id]),
foreign key ([enzyme_id]) references  medicine_enzyme_interaction.enzyme([id]),
foreign key ([medicine_id]) references  medicine_enzyme_interaction.medicine([id])
);





