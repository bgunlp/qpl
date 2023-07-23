USE spider;
CREATE TABLE  store_1.artists
(
id INTEGER IDENTITY PRIMARY KEY ,
name VARCHAR(120)
);

CREATE TABLE  store_1.albums
(
id INTEGER IDENTITY PRIMARY KEY ,
title VARCHAR(160)  NOT NULL,
artist_id INTEGER  NOT NULL,
FOREIGN KEY (artist_id) REFERENCES  store_1.artists (id)
ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE  store_1.employees
(
id INTEGER IDENTITY PRIMARY KEY ,
last_name VARCHAR(20)  NOT NULL,
first_name VARCHAR(20)  NOT NULL,
title VARCHAR(30),
reports_to INTEGER,
birth_date DATETIME,
hire_date DATETIME,
address VARCHAR(70),
city VARCHAR(40),
state VARCHAR(40),
country VARCHAR(40),
postal_code VARCHAR(10),
phone VARCHAR(24),
fax VARCHAR(24),
email VARCHAR(60),
FOREIGN KEY (reports_to) REFERENCES  store_1.employees (id)
ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE  store_1.customers
(
id INTEGER IDENTITY PRIMARY KEY ,
first_name VARCHAR(40)  NOT NULL,
last_name VARCHAR(20)  NOT NULL,
company VARCHAR(80),
address VARCHAR(70),
city VARCHAR(40),
state VARCHAR(40),
country VARCHAR(40),
postal_code VARCHAR(10),
phone VARCHAR(24),
fax VARCHAR(24),
email VARCHAR(60)  NOT NULL,
support_rep_id INTEGER,
FOREIGN KEY (support_rep_id) REFERENCES  store_1.employees (id)
ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE  store_1.genres
(
id INTEGER IDENTITY PRIMARY KEY ,
name VARCHAR(120)
);

CREATE TABLE  store_1.invoices
(
id INTEGER IDENTITY PRIMARY KEY ,
customer_id INTEGER  NOT NULL,
invoice_date DATETIME NOT NULL,
billing_address VARCHAR(70),
billing_city VARCHAR(40),
billing_state VARCHAR(40),
billing_country VARCHAR(40),
billing_postal_code VARCHAR(10),
total NUMERIC(10,2)  NOT NULL,
FOREIGN KEY (customer_id) REFERENCES  store_1.customers (id)
ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE  store_1.media_types
(
id INTEGER IDENTITY PRIMARY KEY ,
name VARCHAR(120)
);

CREATE TABLE  store_1.tracks
(
id INTEGER IDENTITY PRIMARY KEY ,
name VARCHAR(200)  NOT NULL,
album_id INTEGER,
media_type_id INTEGER  NOT NULL,
genre_id INTEGER,
composer VARCHAR(220),
milliseconds INTEGER  NOT NULL,
bytes INTEGER,
unit_price NUMERIC(10,2)  NOT NULL,
FOREIGN KEY (album_id) REFERENCES  store_1.albums (id)
ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY (genre_id) REFERENCES  store_1.genres (id)
ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY (media_type_id) REFERENCES  store_1.media_types (id)
ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE  store_1.invoice_lines
(
id INTEGER IDENTITY PRIMARY KEY ,
invoice_id INTEGER  NOT NULL,
track_id INTEGER  NOT NULL,
unit_price NUMERIC(10,2)  NOT NULL,
quantity INTEGER  NOT NULL,
FOREIGN KEY (invoice_id) REFERENCES  store_1.invoices (id)
ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY (track_id) REFERENCES  store_1.tracks (id)
ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE  store_1.playlists
(
id INTEGER IDENTITY PRIMARY KEY ,
name VARCHAR(120)
);

CREATE TABLE  store_1.playlist_tracks
(
playlist_id INTEGER  NOT NULL,
track_id INTEGER  NOT NULL,
CONSTRAINT PK_PlaylistTrack PRIMARY KEY  (playlist_id, track_id),
FOREIGN KEY (playlist_id) REFERENCES  store_1.playlists (id)
ON DELETE NO ACTION ON UPDATE NO ACTION,
FOREIGN KEY (track_id) REFERENCES  store_1.tracks (id)
ON DELETE NO ACTION ON UPDATE NO ACTION
);
