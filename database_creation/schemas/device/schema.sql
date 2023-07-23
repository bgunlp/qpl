USE spider;
CREATE TABLE  device.device (
[Device_ID] int,
[Device] VARCHAR(400),
[Carrier] VARCHAR(400),
[Package_Version] VARCHAR(400),
[Applications] VARCHAR(400),
[Software_Platform] VARCHAR(400),
PRIMARY KEY ([Device_ID])
);

CREATE TABLE  device.shop (
[Shop_ID] int,
[Shop_Name] VARCHAR(400),
[Location] VARCHAR(400),
[Open_Date] VARCHAR(400),
[Open_Year] int,
PRIMARY KEY ([Shop_ID])
);


CREATE TABLE  device.stock (
[Shop_ID] int,
[Device_ID] int,
[Quantity] int,
PRIMARY KEY ([Shop_ID],[Device_ID]),
FOREIGN KEY (Shop_ID) REFERENCES  device.shop(Shop_ID),
FOREIGN KEY (Device_ID) REFERENCES  device.device(Device_ID)
);


