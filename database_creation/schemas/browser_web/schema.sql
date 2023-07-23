USE spider;
BEGIN TRANSACTION;
CREATE TABLE  browser_web.[Web_client_accelerator] (
[id] int,
[name] VARCHAR(400),
[Operating_system] VARCHAR(400),
[Client] VARCHAR(400),
[Connection] VARCHAR(400),
primary key([id])
);
CREATE TABLE  browser_web.[browser] (
[id] int,
[name] VARCHAR(400),
[market_share] real,
primary key([id])
);
CREATE TABLE  browser_web.[accelerator_compatible_browser] (
[accelerator_id] int,
[browser_id] int,
[compatible_since_year] int,
primary key([accelerator_id], [browser_id]),
foreign key ([accelerator_id]) references  browser_web.Web_client_accelerator([id]),
foreign key ([browser_id]) references  browser_web.browser([id])
);
COMMIT;

