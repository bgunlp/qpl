USE spider;
CREATE TABLE  battle_death.battle (
[id] int,
[name] VARCHAR(400),
[date] VARCHAR(400),
[bulgarian_commander] VARCHAR(400),
[latin_commander] VARCHAR(400),
[result] VARCHAR(400),
primary key([id])
);

CREATE TABLE  battle_death.ship (
[lost_in_battle] int,
[id] int,
[name] VARCHAR(400),
[tonnage] VARCHAR(400),
[ship_type] VARCHAR(400),
[location] VARCHAR(400),
[disposition_of_ship] VARCHAR(400),
primary key([id]),
foreign key (lost_in_battle) references  battle_death.battle([id])
);


CREATE TABLE  battle_death.death (
[caused_by_ship_id] int,
[id] int,
[note] VARCHAR(400),
[killed] int,
[injured] int,
primary key([id]),
foreign key ([caused_by_ship_id]) references  battle_death.ship([id])
);