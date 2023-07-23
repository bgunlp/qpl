USE spider;
CREATE TABLE  store_product.product (
[product_id] int,
[product] VARCHAR(400),
[dimensions] VARCHAR(400),
[dpi] real,
[pages_per_minute_color] real,
[max_page_size] VARCHAR(400),
[interface] VARCHAR(400),
PRIMARY KEY ([product_id])
);

CREATE TABLE  store_product.store (
[Store_ID] int,
[Store_Name] VARCHAR(400),
[Type] VARCHAR(400),
[Area_size] real,
[Number_of_product_category] real,
[Ranking] int,
PRIMARY KEY ([Store_ID])
);

CREATE TABLE  store_product.district (
[District_ID] int,
[District_name] VARCHAR(400),
[Headquartered_City] VARCHAR(400),
[City_Population] real,
[City_Area] real,
PRIMARY KEY ([District_ID])
);





CREATE TABLE  store_product.store_product (
[Store_ID] int,
[Product_ID] int,
PRIMARY KEY ([Store_ID],[Product_ID]),
FOREIGN KEY (Store_ID) REFERENCES  store_product.store(Store_ID),
FOREIGN KEY (Product_ID) REFERENCES  store_product.product(Product_ID)
);







CREATE TABLE  store_product.store_district (
[Store_ID] int,
[District_ID] int,
PRIMARY KEY ([Store_ID]),
FOREIGN KEY (Store_ID) REFERENCES  store_product.store(Store_ID),
FOREIGN KEY (District_ID) REFERENCES  store_product.district(District_ID)
);

