USE spider;
CREATE TABLE  customers_and_invoices.Customers (
customer_id INTEGER PRIMARY KEY,
customer_first_name VARCHAR(50),
customer_middle_initial VARCHAR(1),
customer_last_name VARCHAR(50),
gender VARCHAR(1),
email_address VARCHAR(255),
login_name VARCHAR(80),
login_password VARCHAR(20),
phone_number VARCHAR(255),
town_city VARCHAR(50),
state_county_province VARCHAR(50),
country VARCHAR(50)
);

CREATE TABLE  customers_and_invoices.Orders (
order_id INTEGER PRIMARY KEY,
customer_id INTEGER NOT NULL,
date_order_placed DATETIME NOT NULL,
order_details VARCHAR(255),
FOREIGN KEY (customer_id ) REFERENCES  customers_and_invoices.Customers(customer_id )
);

CREATE TABLE  customers_and_invoices.Invoices (
invoice_number INTEGER PRIMARY KEY,
order_id INTEGER NOT NULL,
invoice_date DATETIME,
FOREIGN KEY (order_id ) REFERENCES  customers_and_invoices.Orders(order_id )
);

CREATE TABLE  customers_and_invoices.Accounts (
account_id INTEGER PRIMARY KEY,
customer_id INTEGER NOT NULL,
date_account_opened DATETIME,
account_name VARCHAR(50),
other_account_details VARCHAR(255),
FOREIGN KEY (customer_id ) REFERENCES  customers_and_invoices.Customers(customer_id )
);

CREATE TABLE  customers_and_invoices.Product_Categories (
production_type_code VARCHAR(15) PRIMARY KEY,
product_type_description VARCHAR(80),
vat_rating DECIMAL(19,4)
);
CREATE TABLE  customers_and_invoices.Products (
product_id INTEGER PRIMARY KEY,
parent_product_id INTEGER,
production_type_code VARCHAR(15) NOT NULL,
unit_price DECIMAL(19,4),
product_name VARCHAR(80),
product_color VARCHAR(20),
product_size VARCHAR(20),
FOREIGN KEY (production_type_code ) REFERENCES  customers_and_invoices.Product_Categories(production_type_code )
);

CREATE TABLE  customers_and_invoices.Financial_Transactions (
transaction_id INTEGER NOT NULL ,
account_id INTEGER NOT NULL,
invoice_number INTEGER,
transaction_type VARCHAR(15) NOT NULL,
transaction_date DATETIME,
transaction_amount DECIMAL(19,4),
transaction_comment VARCHAR(255),
other_transaction_details VARCHAR(255),
FOREIGN KEY (invoice_number ) REFERENCES  customers_and_invoices.Invoices(invoice_number ),
FOREIGN KEY (account_id ) REFERENCES  customers_and_invoices.Accounts(account_id )
);
CREATE TABLE  customers_and_invoices.Order_Items (
order_item_id INTEGER PRIMARY KEY,
order_id INTEGER NOT NULL,
product_id INTEGER NOT NULL,
product_quantity INTEGER,
other_order_item_details VARCHAR(255),
FOREIGN KEY (product_id ) REFERENCES  customers_and_invoices.Products(product_id ),
FOREIGN KEY (order_id ) REFERENCES  customers_and_invoices.Orders(order_id )
);

CREATE TABLE  customers_and_invoices.Invoice_Line_Items (
order_item_id INTEGER NOT NULL,
invoice_number INTEGER NOT NULL,
product_id INTEGER NOT NULL,
product_title VARCHAR(80),
product_quantity VARCHAR(50),
product_price DECIMAL(19,4),
derived_product_cost DECIMAL(19,4),
derived_vat_payable DECIMAL(19,4),
derived_total_cost DECIMAL(19,4),
FOREIGN KEY (order_item_id ) REFERENCES  customers_and_invoices.Order_Items(order_item_id ),
FOREIGN KEY (invoice_number ) REFERENCES  customers_and_invoices.Invoices(invoice_number ),
FOREIGN KEY (product_id ) REFERENCES  customers_and_invoices.Products(product_id )
);
