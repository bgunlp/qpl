USE spider;
CREATE TABLE  cre_Theme_park.Ref_Hotel_Star_Ratings (
star_rating_code CHAR(15) NOT NULL,
star_rating_description VARCHAR(80),
PRIMARY KEY (star_rating_code),
UNIQUE (star_rating_code)
);


CREATE TABLE  cre_Theme_park.Locations (
Location_ID INTEGER NOT NULL,
Location_Name VARCHAR(255),
Address VARCHAR(255),
Other_Details VARCHAR(255),
PRIMARY KEY (Location_ID)
);

CREATE TABLE  cre_Theme_park.Ref_Attraction_Types (
Attraction_Type_Code CHAR(15) NOT NULL,
Attraction_Type_Description VARCHAR(255),
PRIMARY KEY (Attraction_Type_Code),
UNIQUE (Attraction_Type_Code)
);



CREATE TABLE  cre_Theme_park.Visitors (
Tourist_ID INTEGER NOT NULL,
Tourist_Details VARCHAR(255),
PRIMARY KEY (Tourist_ID),
UNIQUE (Tourist_ID)
);
CREATE TABLE  cre_Theme_park.Features (
Feature_ID INTEGER NOT NULL,
Feature_Details VARCHAR(255),
PRIMARY KEY (Feature_ID)
);


CREATE TABLE  cre_Theme_park.Hotels (
hotel_id INTEGER NOT NULL,
star_rating_code CHAR(15) NOT NULL,
pets_allowed_yn CHAR(1),
price_range real,
other_hotel_details VARCHAR(255),
PRIMARY KEY (hotel_id),
FOREIGN KEY (star_rating_code) REFERENCES  cre_Theme_park.Ref_Hotel_Star_Ratings (star_rating_code)
);

CREATE TABLE  cre_Theme_park.Tourist_Attractions (
Tourist_Attraction_ID INTEGER NOT NULL,
Attraction_Type_Code CHAR(15) NOT NULL,
Location_ID INTEGER NOT NULL,
How_to_Get_There VARCHAR(255),
Name VARCHAR(255),
Description VARCHAR(255),
Opening_Hours VARCHAR(255),
Other_Details VARCHAR(255),
PRIMARY KEY (Tourist_Attraction_ID),
FOREIGN KEY (Location_ID) REFERENCES  cre_Theme_park.Locations (Location_ID),
FOREIGN KEY (Attraction_Type_Code) REFERENCES  cre_Theme_park.Ref_Attraction_Types (Attraction_Type_Code)
);

CREATE TABLE  cre_Theme_park.Street_Markets (
Market_ID INTEGER NOT NULL,
Market_Details VARCHAR(255),
PRIMARY KEY (Market_ID),
FOREIGN KEY (Market_ID) REFERENCES  cre_Theme_park.Tourist_Attractions (Tourist_Attraction_ID)
);
CREATE TABLE  cre_Theme_park.Shops (
Shop_ID INTEGER NOT NULL,
Shop_Details VARCHAR(255),
PRIMARY KEY (Shop_ID),
FOREIGN KEY (Shop_ID) REFERENCES  cre_Theme_park.Tourist_Attractions (Tourist_Attraction_ID)
);
CREATE TABLE  cre_Theme_park.Museums (
Museum_ID INTEGER NOT NULL,
Museum_Details VARCHAR(255),
PRIMARY KEY (Museum_ID),
FOREIGN KEY (Museum_ID) REFERENCES  cre_Theme_park.Tourist_Attractions (Tourist_Attraction_ID)
);
CREATE TABLE  cre_Theme_park.Royal_Family (
Royal_Family_ID INTEGER NOT NULL,
Royal_Family_Details VARCHAR(255),
PRIMARY KEY (Royal_Family_ID),
FOREIGN KEY (Royal_Family_ID) REFERENCES  cre_Theme_park.Tourist_Attractions (Tourist_Attraction_ID)
);
CREATE TABLE  cre_Theme_park.Theme_Parks (
Theme_Park_ID INTEGER NOT NULL,
Theme_Park_Details VARCHAR(255),
PRIMARY KEY (Theme_Park_ID),
FOREIGN KEY (Theme_Park_ID) REFERENCES  cre_Theme_park.Tourist_Attractions (Tourist_Attraction_ID)
);



CREATE TABLE  cre_Theme_park.Visits (
Visit_ID INTEGER NOT NULL,
Tourist_Attraction_ID INTEGER NOT NULL,
Tourist_ID INTEGER NOT NULL,
Visit_Date DATETIME NOT NULL,
Visit_Details VARCHAR(40) NOT NULL,
PRIMARY KEY (Visit_ID),
FOREIGN KEY (Tourist_Attraction_ID) REFERENCES  cre_Theme_park.Tourist_Attractions (Tourist_Attraction_ID),
FOREIGN KEY (Tourist_ID) REFERENCES  cre_Theme_park.Visitors (Tourist_ID)
);




CREATE TABLE  cre_Theme_park.Photos (
Photo_ID INTEGER NOT NULL,
Tourist_Attraction_ID INTEGER NOT NULL,
Name VARCHAR(255),
Description VARCHAR(255),
Filename VARCHAR(255),
Other_Details VARCHAR(255),
PRIMARY KEY (Photo_ID),
FOREIGN KEY (Tourist_Attraction_ID) REFERENCES  cre_Theme_park.Tourist_Attractions (Tourist_Attraction_ID)
);

CREATE TABLE  cre_Theme_park.Staff (
Staff_ID INTEGER NOT NULL,
Tourist_Attraction_ID INTEGER NOT NULL,
Name VARCHAR(40),
Other_Details VARCHAR(255),
PRIMARY KEY (Staff_ID),
FOREIGN KEY (Tourist_Attraction_ID) REFERENCES  cre_Theme_park.Tourist_Attractions (Tourist_Attraction_ID)
);



CREATE TABLE  cre_Theme_park.Tourist_Attraction_Features (
Tourist_Attraction_ID INTEGER NOT NULL,
Feature_ID INTEGER NOT NULL,
PRIMARY KEY (Tourist_Attraction_ID, Feature_ID),
FOREIGN KEY (Tourist_Attraction_ID) REFERENCES  cre_Theme_park.Tourist_Attractions (Tourist_Attraction_ID),
FOREIGN KEY (Feature_ID) REFERENCES  cre_Theme_park.Features (Feature_ID)
);