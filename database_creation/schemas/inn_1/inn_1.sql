USE spider;
CREATE TABLE  inn_1.Rooms (
[RoomId] VARCHAR(400) PRIMARY KEY,
[roomName] VARCHAR(400),
[beds] INTEGER,
[bedType] VARCHAR(400),
[maxOccupancy] INTEGER,
[basePrice] INTEGER,
[decor] VARCHAR(400)

);

CREATE TABLE  inn_1.Reservations (
[Code] INTEGER PRIMARY KEY,
[Room] VARCHAR(400),
[CheckIn] VARCHAR(400),
[CheckOut] VARCHAR(400),
[Rate] REAL,
[LastName] VARCHAR(400),
[FirstName] VARCHAR(400),
[Adults] INTEGER,
[Kids] INTEGER,
FOREIGN KEY (Room) REFERENCES  inn_1.Rooms(RoomId)
);

