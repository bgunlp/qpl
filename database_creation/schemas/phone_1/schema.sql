USE spider;
BEGIN TRANSACTION;
CREATE TABLE  phone_1.[chip_model] (
[Model_name] VARCHAR(400),
[Launch_year] real,
[RAM_MiB] real,
[ROM_MiB] real,
[Slots] VARCHAR(400),
[WiFi] VARCHAR(400),
[Bluetooth] VARCHAR(400),
PRIMARY KEY ([Model_name])
);
CREATE TABLE  phone_1.[screen_mode] (
[Graphics_mode] real,
[Char_cells] VARCHAR(400),
[Pixels] VARCHAR(400),
[Hardware_colours] real,
[used_kb] real,
[map] VARCHAR(400),
[Type] VARCHAR(400),
PRIMARY KEY ([Graphics_mode])
);

CREATE TABLE  phone_1.[phone] (
[Company_name] VARCHAR(400),
[Hardware_Model_name] VARCHAR(400),
[Accreditation_type] VARCHAR(400),
[Accreditation_level] VARCHAR(400),
[Date] VARCHAR(400),
[chip_model] VARCHAR(400),
[screen_mode] real,
PRIMARY KEY([Hardware_Model_name]),
FOREIGN KEY (screen_mode) REFERENCES  phone_1.screen_mode(Graphics_mode),
FOREIGN KEY (chip_model) REFERENCES  phone_1.chip_model(Model_name)
);
COMMIT;
