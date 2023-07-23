USE spider;
CREATE TABLE  department_store.Addresses (
address_id INTEGER PRIMARY KEY,
address_details VARCHAR(255)
);

CREATE TABLE  department_store.Staff (
staff_id INTEGER PRIMARY KEY,
staff_gender VARCHAR(1),
staff_name VARCHAR(80)
);

CREATE TABLE  department_store.Suppliers (
supplier_id INTEGER PRIMARY KEY,
supplier_name VARCHAR(80),
supplier_phone VARCHAR(80)
);

CREATE TABLE  department_store.Department_Store_Chain (
dept_store_chain_id INTEGER PRIMARY KEY,
dept_store_chain_name VARCHAR(80)
);


CREATE TABLE  department_store.Customers (
customer_id INTEGER PRIMARY KEY,
payment_method_code VARCHAR(12) NOT NULL,
customer_code VARCHAR(20),
customer_name VARCHAR(80),
customer_address VARCHAR(255),
customer_phone VARCHAR(80),
customer_email VARCHAR(80)
);

CREATE TABLE  department_store.Products (
product_id INTEGER PRIMARY KEY,
product_type_code VARCHAR(10) NOT NULL,
product_name VARCHAR(80),
product_price DECIMAL(19,4)
);

CREATE TABLE  department_store.Supplier_Addresses (
supplier_id INTEGER NOT NULL,
address_id INTEGER NOT NULL,
date_from DATETIME NOT NULL,
date_to DATETIME,
PRIMARY KEY (supplier_id, address_id),
FOREIGN KEY (address_id ) REFERENCES  department_store.Addresses(address_id ),
FOREIGN KEY (supplier_id ) REFERENCES  department_store.Suppliers(supplier_id )
);

CREATE TABLE  department_store.Customer_Addresses (
customer_id INTEGER NOT NULL,
address_id INTEGER NOT NULL,
date_from DATETIME NOT NULL,
date_to DATETIME,
PRIMARY KEY (customer_id, address_id),
FOREIGN KEY (address_id ) REFERENCES  department_store.Addresses(address_id ),
FOREIGN KEY (customer_id ) REFERENCES  department_store.Customers(customer_id )
);


CREATE TABLE  department_store.Customer_Orders (
order_id INTEGER PRIMARY KEY,
customer_id INTEGER NOT NULL,
order_status_code VARCHAR(10) NOT NULL,
order_date DATETIME NOT NULL,
FOREIGN KEY (customer_id ) REFERENCES  department_store.Customers(customer_id )
);


CREATE TABLE  department_store.Department_Stores (
dept_store_id INTEGER PRIMARY KEY,
dept_store_chain_id INTEGER,
store_name VARCHAR(80),
store_address VARCHAR(255),
store_phone VARCHAR(80),
store_email VARCHAR(80),
FOREIGN KEY (dept_store_chain_id ) REFERENCES  department_store.Department_Store_Chain(dept_store_chain_id )
);



CREATE TABLE  department_store.Departments (
department_id INTEGER PRIMARY KEY,
dept_store_id INTEGER NOT NULL,
department_name VARCHAR(80),
FOREIGN KEY (dept_store_id ) REFERENCES  department_store.Department_Stores(dept_store_id )
);

CREATE TABLE  department_store.Order_Items (
order_item_id INTEGER PRIMARY KEY,
order_id INTEGER NOT NULL,
product_id INTEGER NOT NULL,
FOREIGN KEY (order_id ) REFERENCES  department_store.Customer_Orders(order_id ),
FOREIGN KEY (product_id ) REFERENCES  department_store.Products(product_id )
);
CREATE TABLE  department_store.Product_Suppliers (
product_id INTEGER NOT NULL,
supplier_id INTEGER NOT NULL,
date_supplied_from DATETIME NOT NULL,
date_supplied_to DATETIME,
total_amount_purchased REAL,
total_value_purchased DECIMAL(19,4),
PRIMARY KEY (product_id, supplier_id),
FOREIGN KEY (supplier_id ) REFERENCES  department_store.Suppliers(supplier_id ),
FOREIGN KEY (product_id ) REFERENCES  department_store.Products(product_id )
);


CREATE TABLE  department_store.Staff_Department_Assignments (
staff_id INTEGER NOT NULL,
department_id INTEGER NOT NULL,
date_assigned_from DATETIME NOT NULL,
job_title_code VARCHAR(18) NOT NULL,
date_assigned_to DATETIME,
PRIMARY KEY (staff_id, department_id),
FOREIGN KEY (department_id ) REFERENCES  department_store.Departments(department_id ),
FOREIGN KEY (staff_id ) REFERENCES  department_store.Staff(staff_id )
);
