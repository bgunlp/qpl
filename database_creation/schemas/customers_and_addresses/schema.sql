USE spider;
CREATE TABLE  customers_and_addresses.Addresses (
address_id INTEGER PRIMARY KEY,
address_content VARCHAR(80),
city VARCHAR(50),
zip_postcode VARCHAR(20),
state_province_county VARCHAR(50),
country VARCHAR(50),
other_address_details VARCHAR(255)
);

CREATE TABLE  customers_and_addresses.Products (
product_id INTEGER PRIMARY KEY,
product_details VARCHAR(255)
);


CREATE TABLE  customers_and_addresses.Customers (
customer_id INTEGER PRIMARY KEY,
payment_method VARCHAR(15) NOT NULL,
customer_name VARCHAR(80),
date_became_customer DATETIME,
other_customer_details VARCHAR(255)
);

CREATE TABLE  customers_and_addresses.Customer_Addresses (
customer_id INTEGER NOT NULL,
address_id INTEGER NOT NULL,
date_address_from DATETIME NOT NULL,
address_type VARCHAR(15) NOT NULL,
date_address_to DATETIME,
FOREIGN KEY (address_id ) REFERENCES  customers_and_addresses.Addresses(address_id ),
FOREIGN KEY (customer_id ) REFERENCES  customers_and_addresses.Customers(customer_id )
);
CREATE TABLE  customers_and_addresses.Customer_Contact_Channels (
customer_id INTEGER NOT NULL,
channel_code VARCHAR(15) NOT NULL,
active_from_date DATETIME NOT NULL,
active_to_date DATETIME,
contact_number VARCHAR(50) NOT NULL,
FOREIGN KEY (customer_id ) REFERENCES  customers_and_addresses.Customers(customer_id )
);
CREATE TABLE  customers_and_addresses.Customer_Orders (
order_id INTEGER PRIMARY KEY,
customer_id INTEGER NOT NULL,
order_status VARCHAR(15) NOT NULL,
order_date DATETIME,
order_details VARCHAR(255),
FOREIGN KEY (customer_id ) REFERENCES  customers_and_addresses.Customers(customer_id )
);

CREATE TABLE  customers_and_addresses.Order_Items (
order_id INTEGER NOT NULL,
product_id INTEGER NOT NULL,
order_quantity INTEGER,
FOREIGN KEY (product_id ) REFERENCES  customers_and_addresses.Products(product_id ),
FOREIGN KEY (order_id ) REFERENCES  customers_and_addresses.Customer_Orders(order_id )
);
