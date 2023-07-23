USE spider;
CREATE TABLE  architecture.architect (
[id] int,
[name] VARCHAR(400),
[nationality] VARCHAR(400),
[gender] VARCHAR(400),
primary key([id])
);

CREATE TABLE  architecture.bridge (
[architect_id] int,
[id] int,
[name] VARCHAR(400),
[location] VARCHAR(400),
[length_meters] real,
[length_feet] real,
primary key([id]),
foreign key ([architect_id] ) references  architecture.architect([id])
);

CREATE TABLE  architecture.mill (
[architect_id] int,
[id] int,
[location] VARCHAR(400),
[name] VARCHAR(400),
[type] VARCHAR(400),
[built_year] int,
[notes] VARCHAR(400),
primary key ([id]),
foreign key ([architect_id] ) references  architecture.architect([id])
);
