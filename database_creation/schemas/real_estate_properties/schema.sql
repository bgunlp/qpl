USE spider;
CREATE TABLE  real_estate_properties.Ref_Feature_Types (
feature_type_code VARCHAR(20) PRIMARY KEY,
feature_type_name VARCHAR(80)
);
CREATE TABLE  real_estate_properties.Ref_Property_Types (
property_type_code VARCHAR(20) PRIMARY KEY,
property_type_description VARCHAR(80)
);

CREATE TABLE  real_estate_properties.Other_Available_Features (
feature_id INTEGER PRIMARY KEY,
feature_type_code VARCHAR(20) NOT NULL,
feature_name VARCHAR(80),
feature_description VARCHAR(80),
FOREIGN KEY (feature_type_code ) REFERENCES  real_estate_properties.Ref_Feature_Types(feature_type_code )
);

CREATE TABLE  real_estate_properties.Properties (
property_id INTEGER PRIMARY KEY,
property_type_code VARCHAR(20) NOT NULL,
date_on_market DATETIME,
date_sold DATETIME,
property_name VARCHAR(80),
property_address VARCHAR(255),
room_count INTEGER,
vendor_requested_price DECIMAL(19,4),
buyer_offered_price DECIMAL(19,4),
agreed_selling_price DECIMAL(19,4),
apt_feature_1 VARCHAR(255),
apt_feature_2 VARCHAR(255),
apt_feature_3 VARCHAR(255),
fld_feature_1 VARCHAR(255),
fld_feature_2 VARCHAR(255),
fld_feature_3 VARCHAR(255),
hse_feature_1 VARCHAR(255),
hse_feature_2 VARCHAR(255),
hse_feature_3 VARCHAR(255),
oth_feature_1 VARCHAR(255),
oth_feature_2 VARCHAR(255),
oth_feature_3 VARCHAR(255),
shp_feature_1 VARCHAR(255),
shp_feature_2 VARCHAR(255),
shp_feature_3 VARCHAR(255),
other_property_details VARCHAR(255),
FOREIGN KEY (property_type_code ) REFERENCES  real_estate_properties.Ref_Property_Types(property_type_code )
);

CREATE TABLE  real_estate_properties.Other_Property_Features (
property_id INTEGER NOT NULL,
feature_id INTEGER NOT NULL,
property_feature_description VARCHAR(80),
FOREIGN KEY (feature_id ) REFERENCES  real_estate_properties.Other_Available_Features(feature_id ),
FOREIGN KEY (property_id ) REFERENCES  real_estate_properties.Properties(property_id )
);
