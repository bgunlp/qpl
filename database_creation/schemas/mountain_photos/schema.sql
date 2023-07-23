USE spider;
BEGIN TRANSACTION;
CREATE TABLE  mountain_photos.[mountain] (
[id] int,
[name] VARCHAR(400),
[Height] real,
[Prominence] real,
[Range] VARCHAR(400),
[Country] VARCHAR(400),
primary key([id])
);
CREATE TABLE  mountain_photos.[camera_lens] (
[id] int,
[brand] VARCHAR(400),
[name] VARCHAR(400),
[focal_length_mm] real,
[max_aperture] real,
primary key([id])
);
CREATE TABLE  mountain_photos.[photos] (
[id] int,
[camera_lens_id] int,
[mountain_id] int,
[color] VARCHAR(400),
[name] VARCHAR(400),
primary key([id]),
foreign key([camera_lens_id]) references  mountain_photos.camera_lens([id]),
foreign key([mountain_id]) references  mountain_photos.mountain([id])
);
COMMIT;

