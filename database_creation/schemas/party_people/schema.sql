USE spider;
CREATE TABLE  party_people.region (
[Region_ID] int,
[Region_name] VARCHAR(400),
[Date] VARCHAR(400),
[Label] VARCHAR(400),
[Format] VARCHAR(400),
[Catalogue] VARCHAR(400),
PRIMARY KEY ([Region_ID])
);

CREATE TABLE  party_people.party (
[Party_ID] int,
[Minister] VARCHAR(400),
[Took_office] VARCHAR(400),
[Left_office] VARCHAR(400),
[Region_ID] int,
[Party_name] VARCHAR(400),
PRIMARY KEY ([Party_ID]),
FOREIGN KEY (Region_ID) REFERENCES  party_people.region(Region_ID)
);

CREATE TABLE  party_people.member (
[Member_ID] int,
[Member_Name] VARCHAR(400),
[Party_ID] int,
[In_office] VARCHAR(400),
PRIMARY KEY ([Member_ID]),
FOREIGN KEY (Party_ID) REFERENCES  party_people.party(Party_ID)
);

CREATE TABLE  party_people.party_events (
[Event_ID] int,
[Event_Name] VARCHAR(400),
[Party_ID] int,
[Member_in_charge_ID] int,
PRIMARY KEY ([Event_ID]),
FOREIGN KEY (Party_ID) REFERENCES  party_people.party(Party_ID),
FOREIGN KEY (Member_in_charge_ID) REFERENCES  party_people.member(Member_ID)
);
