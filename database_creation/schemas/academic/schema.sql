USE spider;
CREATE TABLE  academic.author (
[aid] int,
[homepage] VARCHAR(400),
[name] VARCHAR(400),
[oid] int,
primary key([aid])
);
CREATE TABLE  academic.conference (
[cid] int,
[homepage] VARCHAR(400),
[name] VARCHAR(400),
primary key ([cid])
);
CREATE TABLE  academic.domain (
[did] int,
[name] VARCHAR(400),
primary key ([did])
);
CREATE TABLE  academic.domain_author (
[aid] int,
[did] int,
primary key ([did], [aid]),
foreign key([aid]) references  academic.author([aid]),
foreign key([did]) references  academic.domain([did])
);

CREATE TABLE  academic.domain_conference (
[cid] int,
[did] int,
primary key ([did], [cid]),
foreign key([cid]) references  academic.conference([cid]),
foreign key([did]) references  academic.domain([did])
);
CREATE TABLE  academic.journal (
[homepage] VARCHAR(400),
[jid] int,
[name] VARCHAR(400),
primary key([jid])
);
CREATE TABLE  academic.domain_journal (
[did] int,
[jid] int,
primary key ([did], [jid]),
foreign key([jid]) references  academic.journal([jid]),
foreign key([did]) references  academic.domain([did])
);
CREATE TABLE  academic.keyword (
[keyword] VARCHAR(400),
[kid] int,
primary key([kid])
);
CREATE TABLE  academic.domain_keyword (
[did] int,
[kid] int,
primary key ([did], [kid]),
foreign key([kid]) references  academic.keyword([kid]),
foreign key([did]) references  academic.domain([did])
);
CREATE TABLE  academic.publication (
[abstract] VARCHAR(400),
[cid] int,
[citation_num] int,
[jid] int,
[pid] int,
[reference_num] int,
[title] VARCHAR(400),
[year] int,
primary key([pid]),
foreign key([jid]) references  academic.journal([jid]),
foreign key([cid]) references  academic.conference([cid])
);
CREATE TABLE  academic.domain_publication (
[did] int,
[pid] int,
primary key ([did], [pid]),
foreign key([pid]) references  academic.publication([pid]),
foreign key([did]) references  academic.domain([did])
);

CREATE TABLE  academic.organization (
[continent] VARCHAR(400),
[homepage] VARCHAR(400),
[name] VARCHAR(400),
[oid] int,
primary key([oid])
);

CREATE TABLE  academic.publication_keyword (
[pid] int,
[kid] int,
primary key ([kid], [pid]),
foreign key([pid]) references  academic.publication([pid]),
foreign key([kid]) references  academic.keyword([kid])
);
CREATE TABLE  academic.writes (
[aid] int,
[pid] int,
primary key ([aid], [pid]),
foreign key([pid]) references  academic.publication([pid]),
foreign key([aid]) references  academic.author([aid])
);
CREATE TABLE  academic.cite (
[cited] int,
[citing]  int,
foreign key([cited]) references  academic.publication([pid]),
foreign key([citing]) references  academic.publication([pid])
);
