BEGIN TRANSACTION;
USE spider;
CREATE TABLE flight_4.airports (
   apid integer PRIMARY KEY,      -- Id of the airport
   name varchar(max) NOT NULL,            -- Name of airport
   city varchar(max),                     -- Main city served by airport
   country varchar(max),                  -- Country or territory where airport is located
   x real,                        -- Latitude of airport: Decimal degrees, usually to six
                                  -- significant digits. Negative is South, positive is North
   y real,                        -- Longitude of airport: Decimal degrees, usually to six 
                                  -- significant digits. Negative is West, positive is East
   elevation bigint,              -- Altitude of airport measured in feets
   iata varchar(4),     -- 3-letter IATA code. empty or null if not assigned/unknown
   icao varchar(4)      -- 4-letter ICAO code. empty or null if not assigned
   
);

CREATE TABLE flight_4.airlines (
   alid integer PRIMARY KEY,      -- Id of the airline
   name varchar(max),                     -- Name of the airline
   iata varchar(3),               -- 2-letter IATA code. empty or null if not assigned/unknown 
   icao varchar(5),               -- 3-letter ICAO code. empty or null if not assigned
   callsign varchar(max),                 -- Airline callsign
   country varchar(max),                  -- Country or territory where airline is incorporated
   active varchar(2)              -- "Y" if the airline is or has until recently been operational,
);

CREATE TABLE flight_4.routes (
   rid integer PRIMARY KEY,
   dst_apid integer,              -- Id of destination airport
   dst_ap varchar(4),             -- 3-letter (IATA) or 4-letter (ICAO) code of the destination airport
   src_apid integer,               -- Id of source airport
   src_ap varchar(4),             -- 3-letter (IATA) or 4-letter (ICAO) code of the source airport
   alid integer,                   -- Id of airline
   airline varchar(4),            -- 2-letter (IATA) or 3-letter (ICAO) code of the airline
   codeshare varchar(max),                -- "Y" if this flight is a codeshare (that is, not operated by 
                                  -- Airline, but another carrier), empty otherwise
   FOREIGN KEY(dst_apid) REFERENCES flight_4.airports(apid),
   FOREIGN KEY(src_apid) REFERENCES flight_4.airports(apid),
   FOREIGN KEY(alid)     REFERENCES flight_4.airlines(alid)
);

COMMIT;
