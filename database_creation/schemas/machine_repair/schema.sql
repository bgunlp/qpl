USE spider;
CREATE TABLE  machine_repair.repair (
[repair_ID] int,
[name] VARCHAR(400),
[Launch_Date] VARCHAR(400),
[Notes] VARCHAR(400),
PRIMARY KEY ([repair_ID])
);

CREATE TABLE  machine_repair.machine (
[Machine_ID] int,
[Making_Year] int,
[Class] VARCHAR(400),
[Team] VARCHAR(400),
[Machine_series] VARCHAR(400),
[value_points] real,
[quality_rank] int,
PRIMARY KEY ([Machine_ID])
);


CREATE TABLE  machine_repair.technician (
[technician_id] int,
[Name] VARCHAR(400),
[Team] VARCHAR(400),
[Starting_Year] real,
[Age] int,
PRIMARY Key ([technician_id])
);


CREATE TABLE  machine_repair.repair_assignment (
[technician_id] int,
[repair_ID] int,
[Machine_ID] int,
PRIMARY Key ([technician_id],[repair_ID],[Machine_ID]),
FOREIGN KEY (technician_id) REFERENCES  machine_repair.technician(technician_id),
FOREIGN KEY (repair_ID) REFERENCES  machine_repair.repair(repair_ID),
FOREIGN KEY (Machine_ID) REFERENCES  machine_repair.machine(Machine_ID)
);