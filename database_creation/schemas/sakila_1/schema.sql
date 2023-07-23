BEGIN TRANSACTION;
GO
USE spider;
GO
CREATE TABLE [sakila_1].actor (
  actor_id SMALLINT NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  last_update DATETIME NOT NULL DEFAULT GETDATE(),
  PRIMARY KEY  (actor_id)
);
GO
CREATE TABLE [sakila_1].country (
  country_id SMALLINT NOT NULL,
  country VARCHAR(50) NOT NULL,
  last_update DATETIME NOT NULL DEFAULT GETDATE(),
  PRIMARY KEY  (country_id)
);
GO
CREATE TABLE [sakila_1].city (
  city_id SMALLINT NOT NULL,
  city VARCHAR(50) NOT NULL,
  country_id SMALLINT NOT NULL,
  last_update DATETIME NOT NULL DEFAULT GETDATE(),
  PRIMARY KEY  (city_id),
  FOREIGN KEY (country_id) REFERENCES [sakila_1].country (country_id)
);
GO
CREATE TABLE [sakila_1].address (
  address_id SMALLINT NOT NULL,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50) DEFAULT NULL,
  district VARCHAR(20) NOT NULL,
  city_id SMALLINT NOT NULL,
  postal_code VARCHAR(10) DEFAULT NULL,
  phone VARCHAR(20) NOT NULL,
  last_update DATETIME NOT NULL DEFAULT GETDATE(),
  PRIMARY KEY  (address_id),
  FOREIGN KEY (city_id) REFERENCES [sakila_1].city (city_id)
);
GO
CREATE TABLE [sakila_1].category (
  category_id TINYINT NOT NULL,
  name VARCHAR(25) NOT NULL,
  last_update DATETIME NOT NULL DEFAULT GETDATE(),
  PRIMARY KEY  (category_id)
);
GO
CREATE TABLE [sakila_1].staff (
  staff_id TINYINT NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  address_id SMALLINT NOT NULL,
  picture VARBINARY(MAX) DEFAULT NULL,
  email VARCHAR(50) DEFAULT NULL,
  store_id TINYINT NOT NULL,
  active BIT NOT NULL DEFAULT 1,
  username VARCHAR(16) NOT NULL,
  password VARCHAR(40) DEFAULT NULL,
  last_update DATETIME NOT NULL DEFAULT GETDATE(),
  PRIMARY KEY  (staff_id),
  --FOREIGN KEY (store_id) REFERENCES [sakila_1].store (store_id),
  FOREIGN KEY (address_id) REFERENCES [sakila_1].address (address_id)
);
GO
CREATE TABLE [sakila_1].store (
  store_id TINYINT NOT NULL,
  manager_staff_id TINYINT NOT NULL,
  address_id SMALLINT NOT NULL,
  last_update DATETIME NOT NULL DEFAULT GETDATE(),
  PRIMARY KEY  (store_id),
  FOREIGN KEY (manager_staff_id) REFERENCES [sakila_1].staff (staff_id),
  FOREIGN KEY (address_id) REFERENCES [sakila_1].address (address_id)
);
GO
CREATE TABLE [sakila_1].customer (
  customer_id SMALLINT NOT NULL,
  store_id TINYINT NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  email VARCHAR(50) DEFAULT NULL,
  address_id SMALLINT NOT NULL,
  active BIT NOT NULL DEFAULT 1,
  create_date DATETIME NOT NULL,
  last_update DATETIME DEFAULT GETDATE(),
  PRIMARY KEY  (customer_id),
  FOREIGN KEY (address_id) REFERENCES [sakila_1].address (address_id),
  FOREIGN KEY (store_id) REFERENCES [sakila_1].store (store_id)
);
GO
CREATE TABLE [sakila_1].language (
  language_id TINYINT NOT NULL,
  name CHAR(20) NOT NULL,
  last_update DATETIME NOT NULL DEFAULT GETDATE(),
  PRIMARY KEY (language_id)
);
GO
CREATE TABLE [sakila_1].film (
  film_id SMALLINT NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT DEFAULT NULL,
  release_year SMALLINT DEFAULT NULL,
  language_id TINYINT NOT NULL,
  original_language_id TINYINT DEFAULT NULL,
  rental_duration TINYINT NOT NULL DEFAULT 3,
  rental_rate DECIMAL(4,2) NOT NULL DEFAULT 4.99,
  length SMALLINT DEFAULT NULL,
  replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 19.99,
  rating TEXT DEFAULT 'G',
  special_features TEXT DEFAULT NULL,
  last_update DATETIME NOT NULL DEFAULT GETDATE(),
  PRIMARY KEY  (film_id),
  FOREIGN KEY (language_id) REFERENCES [sakila_1].language (language_id),
  FOREIGN KEY (original_language_id) REFERENCES [sakila_1].language (language_id)
);
GO
CREATE TABLE [sakila_1].film_actor (
  actor_id SMALLINT NOT NULL,
  film_id SMALLINT NOT NULL,
  last_update DATETIME NOT NULL DEFAULT GETDATE(),
  PRIMARY KEY  (actor_id,film_id),
  FOREIGN KEY (actor_id) REFERENCES [sakila_1].actor (actor_id),
  FOREIGN KEY (film_id) REFERENCES [sakila_1].film (film_id)
);
GO
CREATE TABLE [sakila_1].film_category (
  film_id SMALLINT NOT NULL,
  category_id TINYINT NOT NULL,
  last_update DATETIME NOT NULL DEFAULT GETDATE(),
  PRIMARY KEY (film_id, category_id),
  FOREIGN KEY (film_id) REFERENCES [sakila_1].film (film_id),
  FOREIGN KEY (category_id) REFERENCES [sakila_1].category (category_id)
);
GO
CREATE TABLE [sakila_1].film_text (
  film_id SMALLINT NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  PRIMARY KEY  (film_id)
);
GO
CREATE TABLE [sakila_1].inventory (
  inventory_id INT NOT NULL,
  film_id SMALLINT NOT NULL,
  store_id TINYINT NOT NULL,
  last_update DATETIME NOT NULL DEFAULT GETDATE(),
  PRIMARY KEY  (inventory_id),
  FOREIGN KEY (store_id) REFERENCES [sakila_1].store (store_id),
  FOREIGN KEY (film_id) REFERENCES [sakila_1].film (film_id)
);
GO
CREATE TABLE [sakila_1].rental (
  rental_id INT NOT NULL,
  rental_date DATETIME NOT NULL,
  inventory_id INT NOT NULL,
  customer_id SMALLINT NOT NULL,
  return_date DATETIME DEFAULT NULL,
  staff_id TINYINT NOT NULL,
  last_update DATETIME NOT NULL DEFAULT GETDATE(),
  PRIMARY KEY (rental_id),
  FOREIGN KEY (staff_id) REFERENCES [sakila_1].staff (staff_id),
  FOREIGN KEY (inventory_id) REFERENCES [sakila_1].inventory (inventory_id),
  FOREIGN KEY (customer_id) REFERENCES [sakila_1].customer (customer_id)
);
GO
CREATE TABLE [sakila_1].payment (
  payment_id SMALLINT NOT NULL,
  customer_id SMALLINT NOT NULL,
  staff_id TINYINT NOT NULL,
  rental_id INT DEFAULT NULL,
  amount DECIMAL(5,2) NOT NULL,
  payment_date DATETIME NOT NULL,
  last_update DATETIME DEFAULT GETDATE(),
  PRIMARY KEY  (payment_id),
  FOREIGN KEY (rental_id) REFERENCES [sakila_1].rental (rental_id),
  FOREIGN KEY (customer_id) REFERENCES [sakila_1].customer (customer_id),
  FOREIGN KEY (staff_id) REFERENCES [sakila_1].staff (staff_id)
);
GO
COMMIT;
