USE spider;
CREATE TABLE  cre_Drama_Workshop_Groups.Ref_Payment_Methods (
payment_method_code CHAR(10) NOT NULL,
payment_method_description VARCHAR(80),
PRIMARY KEY (payment_method_code),
UNIQUE (payment_method_code)
);

CREATE TABLE  cre_Drama_Workshop_Groups.Ref_Service_Types (
Service_Type_Code CHAR(15) NOT NULL,
Parent_Service_Type_Code CHAR(15),
Service_Type_Description VARCHAR(255),
PRIMARY KEY (Service_Type_Code),
UNIQUE (Service_Type_Code)
);


CREATE TABLE  cre_Drama_Workshop_Groups.Addresses (
Address_ID INTEGER NOT NULL,
Line_1 VARCHAR(255),
Line_2 VARCHAR(255),
City_Town VARCHAR(255),
State_County VARCHAR(255),
Other_Details VARCHAR(255),
PRIMARY KEY (Address_ID),
UNIQUE (Address_ID)
);

CREATE TABLE  cre_Drama_Workshop_Groups.Products (
Product_ID INTEGER NOT NULL,
Product_Name VARCHAR(255),
Product_Price DECIMAL(20,4),
Product_Description VARCHAR(255),
Other_Product_Service_Details VARCHAR(255),
PRIMARY KEY (Product_ID),
UNIQUE (Product_ID)
);


CREATE TABLE  cre_Drama_Workshop_Groups.Marketing_Regions (
Marketing_Region_Code CHAR(15) NOT NULL,
Marketing_Region_Name VARCHAR(255) NOT NULL,
Marketing_Region_Descriptrion VARCHAR(255) NOT NULL,
Other_Details VARCHAR(255),
PRIMARY KEY (Marketing_Region_Code),
UNIQUE (Marketing_Region_Code)
);


CREATE TABLE  cre_Drama_Workshop_Groups.Clients (
Client_ID INTEGER NOT NULL,
Address_ID INTEGER NOT NULL,
Customer_Email_Address VARCHAR(255),
Customer_Name VARCHAR(255),
Customer_Phone VARCHAR(255),
Other_Details VARCHAR(255),
PRIMARY KEY (Client_ID),
UNIQUE (Client_ID),
FOREIGN KEY (Address_ID) REFERENCES  cre_Drama_Workshop_Groups.Addresses (Address_ID)
);


CREATE TABLE  cre_Drama_Workshop_Groups.Drama_Workshop_Groups (
Workshop_Group_ID INTEGER NOT NULL,
Address_ID INTEGER NOT NULL,
Currency_Code CHAR(15) NOT NULL,
Marketing_Region_Code CHAR(15) NOT NULL,
Store_Name VARCHAR(255),
Store_Phone VARCHAR(255),
Store_Email_Address VARCHAR(255),
Other_Details VARCHAR(255),
PRIMARY KEY (Workshop_Group_ID),
UNIQUE (Workshop_Group_ID),
FOREIGN KEY (Address_ID) REFERENCES  cre_Drama_Workshop_Groups.Addresses (Address_ID)
);


CREATE TABLE  cre_Drama_Workshop_Groups.Performers (
Performer_ID INTEGER NOT NULL,
Address_ID INTEGER NOT NULL,
Customer_Name VARCHAR(255),
Customer_Phone VARCHAR(255),
Customer_Email_Address VARCHAR(255),
Other_Details VARCHAR(255),
PRIMARY KEY (Performer_ID),
UNIQUE (Performer_ID),
FOREIGN KEY (Address_ID) REFERENCES  cre_Drama_Workshop_Groups.Addresses (Address_ID)
);


CREATE TABLE  cre_Drama_Workshop_Groups.Customers (
Customer_ID INTEGER NOT NULL,
Address_ID INTEGER NOT NULL,
Customer_Name VARCHAR(255),
Customer_Phone VARCHAR(255),
Customer_Email_Address VARCHAR(255),
Other_Details VARCHAR(255),
PRIMARY KEY (Customer_ID),
UNIQUE (Customer_ID),
FOREIGN KEY (Address_ID) REFERENCES  cre_Drama_Workshop_Groups.Addresses (Address_ID)
);

CREATE TABLE  cre_Drama_Workshop_Groups.Stores (
Store_ID INTEGER NOT NULL,
Address_ID INTEGER NOT NULL,
Marketing_Region_Code CHAR(15) NOT NULL,
Store_Name VARCHAR(255),
Store_Phone VARCHAR(255),
Store_Email_Address VARCHAR(255),
Other_Details VARCHAR(255),
PRIMARY KEY (Store_ID),
UNIQUE (Store_ID),
FOREIGN KEY (Address_ID) REFERENCES  cre_Drama_Workshop_Groups.Addresses (Address_ID),
FOREIGN KEY (Marketing_Region_Code) REFERENCES  cre_Drama_Workshop_Groups.Marketing_Regions (Marketing_Region_Code)
);

CREATE TABLE  cre_Drama_Workshop_Groups.Bookings (
Booking_ID INTEGER NOT NULL ,
Customer_ID INTEGER NOT NULL,
Workshop_Group_ID INTEGER NOT NULL,
Status_Code CHAR(15) NOT NULL,
Store_ID INTEGER NOT NULL,
Order_Date DATETIME NOT NULL,
Planned_Delivery_Date DATETIME NOT NULL,
Actual_Delivery_Date DATETIME NOT NULL,
Other_Order_Details VARCHAR(255),
PRIMARY KEY (Booking_ID),
UNIQUE (Booking_ID),
FOREIGN KEY (Customer_ID) REFERENCES  cre_Drama_Workshop_Groups.Clients (Client_ID),
FOREIGN KEY (Workshop_Group_ID) REFERENCES  cre_Drama_Workshop_Groups.Drama_Workshop_Groups (Workshop_Group_ID)
);


CREATE TABLE  cre_Drama_Workshop_Groups.Performers_in_Bookings (
Order_ID INTEGER NOT NULL,
Performer_ID INTEGER NOT NULL,
PRIMARY KEY (Order_ID, Performer_ID),
FOREIGN KEY (Performer_ID) REFERENCES  cre_Drama_Workshop_Groups.Performers (Performer_ID),
FOREIGN KEY (Order_ID) REFERENCES  cre_Drama_Workshop_Groups.Bookings (Booking_ID)
);


CREATE TABLE  cre_Drama_Workshop_Groups.Customer_Orders (
Order_ID INTEGER NOT NULL ,
Customer_ID INTEGER NOT NULL,
Store_ID INTEGER NOT NULL,
Order_Date DATETIME NOT NULL,
Planned_Delivery_Date DATETIME NOT NULL,
Actual_Delivery_Date DATETIME NOT NULL,
Other_Order_Details VARCHAR(255),
PRIMARY KEY (Order_ID),
UNIQUE (Order_ID),
FOREIGN KEY (Customer_ID) REFERENCES  cre_Drama_Workshop_Groups.Customers (Customer_ID),
FOREIGN KEY (Store_ID) REFERENCES  cre_Drama_Workshop_Groups.Stores (Store_ID)
);

CREATE TABLE  cre_Drama_Workshop_Groups.Order_Items (
Order_Item_ID INTEGER NOT NULL ,
Order_ID INTEGER NOT NULL,
Product_ID INTEGER NOT NULL,
Order_Quantity INTEGER,
Other_Item_Details VARCHAR(255),
PRIMARY KEY (Order_Item_ID),
FOREIGN KEY (Order_ID) REFERENCES  cre_Drama_Workshop_Groups.Customer_Orders (Order_ID),
FOREIGN KEY (Product_ID) REFERENCES  cre_Drama_Workshop_Groups.Products (Product_ID)
);

CREATE TABLE  cre_Drama_Workshop_Groups.Invoices (
Invoice_ID INTEGER NOT NULL,
Order_ID INTEGER NOT NULL,
payment_method_code CHAR(10),
Product_ID INTEGER NOT NULL,
Order_Quantity INTEGER,
Other_Item_Details VARCHAR(255),
Order_Item_ID INTEGER NOT NULL,
PRIMARY KEY (Invoice_ID),
FOREIGN KEY (Order_ID) REFERENCES  cre_Drama_Workshop_Groups.Customer_Orders (Order_ID),
FOREIGN KEY (Order_ID) REFERENCES  cre_Drama_Workshop_Groups.Bookings (Booking_ID),
FOREIGN KEY (payment_method_code) REFERENCES  cre_Drama_Workshop_Groups.Ref_Payment_Methods (payment_method_code)
);


CREATE TABLE  cre_Drama_Workshop_Groups.Services (
Service_ID INTEGER NOT NULL,
Service_Type_Code CHAR(15),
Workshop_Group_ID INTEGER NOT NULL,
Product_Description VARCHAR(255),
Product_Name VARCHAR(255),
Product_Price DECIMAL(20,4),
Other_Product_Service_Details VARCHAR(255),
PRIMARY KEY (Service_ID),
UNIQUE (Service_ID),
FOREIGN KEY (Workshop_Group_ID) REFERENCES  cre_Drama_Workshop_Groups.Drama_Workshop_Groups (Workshop_Group_ID),
FOREIGN KEY (Service_Type_Code) REFERENCES  cre_Drama_Workshop_Groups.Ref_Service_Types (Service_Type_Code)
);


CREATE TABLE  cre_Drama_Workshop_Groups.Bookings_Services (
Order_ID INTEGER NOT NULL,
Product_ID INTEGER NOT NULL,
PRIMARY KEY (Order_ID, Product_ID),
FOREIGN KEY (Order_ID) REFERENCES  cre_Drama_Workshop_Groups.Bookings (Booking_ID),
FOREIGN KEY (Product_ID) REFERENCES  cre_Drama_Workshop_Groups.Services (Service_ID)
);



CREATE TABLE  cre_Drama_Workshop_Groups.Invoice_Items (
Invoice_Item_ID INTEGER NOT NULL ,
Invoice_ID INTEGER NOT NULL,
Order_ID INTEGER NOT NULL,
Order_Item_ID INTEGER NOT NULL,
Product_ID INTEGER NOT NULL,
Order_Quantity INTEGER,
Other_Item_Details VARCHAR(255),
PRIMARY KEY (Invoice_Item_ID),
FOREIGN KEY (Order_Item_ID) REFERENCES  cre_Drama_Workshop_Groups.Order_Items (Order_Item_ID),
FOREIGN KEY (Invoice_ID) REFERENCES  cre_Drama_Workshop_Groups.Invoices (Invoice_ID),
FOREIGN KEY (Order_ID, Product_ID) REFERENCES  cre_Drama_Workshop_Groups.Bookings_Services (Order_ID,Product_ID)
);
