USE spider;
CREATE TABLE  tracking_orders.Customers (
customer_id INTEGER PRIMARY KEY,
customer_name VARCHAR(80),
customer_details VARCHAR(255)
);
CREATE TABLE  tracking_orders.Invoices (
invoice_number INTEGER PRIMARY KEY,
invoice_date DATETIME,
invoice_details VARCHAR(255)
);

CREATE TABLE  tracking_orders.Orders (
order_id INTEGER PRIMARY KEY,
customer_id INTEGER NOT NULL,
order_status VARCHAR(10) NOT NULL,
date_order_placed DATETIME NOT NULL,
order_details VARCHAR(255),
FOREIGN KEY (customer_id ) REFERENCES  tracking_orders.Customers(customer_id )
);

CREATE TABLE  tracking_orders.Products (
product_id INTEGER PRIMARY KEY,
product_name VARCHAR(80),
product_details VARCHAR(255)
);

CREATE TABLE  tracking_orders.Order_Items (
order_item_id INTEGER PRIMARY KEY,
product_id INTEGER NOT NULL,
order_id INTEGER NOT NULL,
order_item_status VARCHAR(10) NOT NULL,
order_item_details VARCHAR(255),
FOREIGN KEY (order_id ) REFERENCES  tracking_orders.Orders(order_id ),
FOREIGN KEY (product_id ) REFERENCES  tracking_orders.Products(product_id )
);

CREATE TABLE  tracking_orders.Shipments (
shipment_id INTEGER PRIMARY KEY,
order_id INTEGER NOT NULL,
invoice_number INTEGER NOT NULL,
shipment_tracking_number VARCHAR(80),
shipment_date DATETIME,
other_shipment_details VARCHAR(255),
FOREIGN KEY (order_id ) REFERENCES  tracking_orders.Orders(order_id ),
FOREIGN KEY (invoice_number ) REFERENCES  tracking_orders.Invoices(invoice_number )
);

CREATE TABLE  tracking_orders.Shipment_Items (
shipment_id INTEGER NOT NULL,
order_item_id INTEGER NOT NULL,
FOREIGN KEY (order_item_id ) REFERENCES  tracking_orders.Order_Items(order_item_id ),
FOREIGN KEY (shipment_id ) REFERENCES  tracking_orders.Shipments(shipment_id )
);






