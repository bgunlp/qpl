USE spider;
CREATE TABLE  driving_school.Addresses (
address_id INTEGER PRIMARY KEY,
line_1_number_building VARCHAR(80),
city VARCHAR(50),
zip_postcode VARCHAR(20),
state_province_county VARCHAR(50),
country VARCHAR(50)
);


CREATE TABLE  driving_school.Staff (
staff_id INTEGER PRIMARY KEY,
staff_address_id INTEGER NOT NULL,
nickname VARCHAR(80),
first_name VARCHAR(80),
middle_name VARCHAR(80),
last_name VARCHAR(80),
date_of_birth DATETIME,
date_joined_staff DATETIME,
date_left_staff DATETIME,
FOREIGN KEY (staff_address_id ) REFERENCES  driving_school.Addresses(address_id )
);


CREATE TABLE  driving_school.Vehicles (
vehicle_id INTEGER PRIMARY KEY,
vehicle_details VARCHAR(255)
);
CREATE TABLE  driving_school.Customers (
customer_id INTEGER PRIMARY KEY,
customer_address_id INTEGER NOT NULL,
customer_status_code VARCHAR(15) NOT NULL,
date_became_customer DATETIME,
date_of_birth DATETIME,
first_name VARCHAR(80),
last_name VARCHAR(80),
amount_outstanding REAL NULL,
email_address VARCHAR(250),
phone_number VARCHAR(255),
cell_mobile_phone_number VARCHAR(255),
FOREIGN KEY (customer_address_id ) REFERENCES  driving_school.Addresses(address_id )
);
CREATE TABLE  driving_school.Customer_Payments (
customer_id INTEGER NOT NULL,
datetime_payment DATETIME NOT NULL,
payment_method_code VARCHAR(20) NOT NULL,
amount_payment REAL NULL,
PRIMARY KEY (customer_id,datetime_payment),
FOREIGN KEY (customer_id ) REFERENCES  driving_school.Customers(customer_id )
);
CREATE TABLE  driving_school.Lessons (
lesson_id INTEGER PRIMARY KEY,
customer_id INTEGER NOT NULL,
lesson_status_code VARCHAR(15) NOT NULL,
staff_id INTEGER,
vehicle_id INTEGER NOT NULL,
lesson_date DATETIME,
lesson_time INTEGER,
price REAL NULL,
FOREIGN KEY (vehicle_id ) REFERENCES  driving_school.Vehicles(vehicle_id ),
FOREIGN KEY (staff_id ) REFERENCES  driving_school.Staff(staff_id ),
FOREIGN KEY (customer_id ) REFERENCES  driving_school.Customers(customer_id )
);