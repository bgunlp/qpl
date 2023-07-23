BEGIN TRANSACTION;
USE spider;
CREATE TABLE chinook_1.Artist (
  ArtistId integer NOT NULL
,  Name varchar(120) DEFAULT NULL
,  PRIMARY KEY (ArtistId)
);

CREATE TABLE chinook_1.Album (
  AlbumId integer NOT NULL
,  Title varchar(160) NOT NULL
,  ArtistId integer NOT NULL
,  PRIMARY KEY (AlbumId)
,  CONSTRAINT FK_AlbumArtistId FOREIGN KEY (ArtistId) REFERENCES chinook_1.Artist (ArtistId) ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE TABLE chinook_1.Employee (
  EmployeeId integer NOT NULL
,  LastName varchar(20) NOT NULL
,  FirstName varchar(20) NOT NULL
,  Title varchar(30) DEFAULT NULL
,  ReportsTo integer DEFAULT NULL
,  BirthDate datetime DEFAULT NULL
,  HireDate datetime DEFAULT NULL
,  Address varchar(70) DEFAULT NULL
,  City varchar(40) DEFAULT NULL
,  State varchar(40) DEFAULT NULL
,  Country varchar(40) DEFAULT NULL
,  PostalCode varchar(10) DEFAULT NULL
,  Phone varchar(24) DEFAULT NULL
,  Fax varchar(24) DEFAULT NULL
,  Email varchar(60) DEFAULT NULL
,  PRIMARY KEY (EmployeeId)
,  CONSTRAINT FK_EmployeeReportsTo FOREIGN KEY (ReportsTo) REFERENCES chinook_1.Employee (EmployeeId) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE chinook_1.Customer (
  CustomerId integer NOT NULL
,  FirstName varchar(40) NOT NULL
,  LastName varchar(20) NOT NULL
,  Company varchar(80) DEFAULT NULL
,  Address varchar(70) DEFAULT NULL
,  City varchar(40) DEFAULT NULL
,  State varchar(40) DEFAULT NULL
,  Country varchar(40) DEFAULT NULL
,  PostalCode varchar(10) DEFAULT NULL
,  Phone varchar(24) DEFAULT NULL
,  Fax varchar(24) DEFAULT NULL
,  Email varchar(60) NOT NULL
,  SupportRepId integer DEFAULT NULL
,  PRIMARY KEY (CustomerId)
,  CONSTRAINT FK_CustomerSupportRepId FOREIGN KEY (SupportRepId) REFERENCES chinook_1.Employee (EmployeeId) ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE TABLE chinook_1.Genre (
  GenreId integer NOT NULL
,  Name varchar(120) DEFAULT NULL
,  PRIMARY KEY (GenreId)
);

CREATE TABLE chinook_1.Invoice (
  InvoiceId integer NOT NULL
,  CustomerId integer NOT NULL
,  InvoiceDate datetime NOT NULL
,  BillingAddress varchar(70) DEFAULT NULL
,  BillingCity varchar(40) DEFAULT NULL
,  BillingState varchar(40) DEFAULT NULL
,  BillingCountry varchar(40) DEFAULT NULL
,  BillingPostalCode varchar(10) DEFAULT NULL
,  Total decimal(10,2) NOT NULL
,  PRIMARY KEY (InvoiceId)
,  CONSTRAINT FK_InvoiceCustomerId FOREIGN KEY (CustomerId) REFERENCES chinook_1.Customer (CustomerId) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE chinook_1.MediaType (
  MediaTypeId integer NOT NULL
,  Name varchar(120) DEFAULT NULL
,  PRIMARY KEY (MediaTypeId)
);

CREATE TABLE chinook_1.Track (
  TrackId integer NOT NULL
,  Name varchar(200) NOT NULL
,  AlbumId integer DEFAULT NULL
,  MediaTypeId integer NOT NULL
,  GenreId integer DEFAULT NULL
,  Composer varchar(220) DEFAULT NULL
,  Milliseconds integer NOT NULL
,  Bytes integer DEFAULT NULL
,  UnitPrice decimal(10,2) NOT NULL
,  PRIMARY KEY (TrackId)
,  CONSTRAINT FK_TrackAlbumId FOREIGN KEY (AlbumId) REFERENCES chinook_1.Album (AlbumId) ON DELETE NO ACTION ON UPDATE NO ACTION
,  CONSTRAINT FK_TrackGenreId FOREIGN KEY (GenreId) REFERENCES chinook_1.Genre (GenreId) ON DELETE NO ACTION ON UPDATE NO ACTION
,  CONSTRAINT FK_TrackMediaTypeId FOREIGN KEY (MediaTypeId) REFERENCES chinook_1.MediaType (MediaTypeId) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE chinook_1.InvoiceLine (
  InvoiceLineId integer NOT NULL
,  InvoiceId integer NOT NULL
,  TrackId integer NOT NULL
,  UnitPrice decimal(10,2) NOT NULL
,  Quantity integer NOT NULL
,  PRIMARY KEY (InvoiceLineId)
,  CONSTRAINT FK_InvoiceLineInvoiceId FOREIGN KEY (InvoiceId) REFERENCES chinook_1.Invoice (InvoiceId) ON DELETE NO ACTION ON UPDATE NO ACTION
,  CONSTRAINT FK_InvoiceLineTrackId FOREIGN KEY (TrackId) REFERENCES chinook_1.Track (TrackId) ON DELETE NO ACTION ON UPDATE NO ACTION
);


CREATE TABLE chinook_1.Playlist (
  PlaylistId integer NOT NULL
,  Name varchar(120) DEFAULT NULL
,  PRIMARY KEY (PlaylistId)
);

CREATE TABLE chinook_1.PlaylistTrack (
  PlaylistId integer NOT NULL
,  TrackId integer NOT NULL
,  PRIMARY KEY (PlaylistId,TrackId)
,  CONSTRAINT FK_PlaylistTrackPlaylistId FOREIGN KEY (PlaylistId) REFERENCES chinook_1.Playlist (PlaylistId) ON DELETE NO ACTION ON UPDATE NO ACTION
,  CONSTRAINT FK_PlaylistTrackTrackId FOREIGN KEY (TrackId) REFERENCES chinook_1.Track (TrackId) ON DELETE NO ACTION ON UPDATE NO ACTION
);
COMMIT;
