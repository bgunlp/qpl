USE spider;
CREATE TABLE  local_govt_in_alabama.Services (
Service_ID INTEGER NOT NULL,
Service_Type_Code CHAR(15) NOT NULL,
PRIMARY KEY (Service_ID)
);

CREATE TABLE  local_govt_in_alabama.Participants (
Participant_ID INTEGER NOT NULL,
Participant_Type_Code CHAR(15) NOT NULL,
Participant_Details VARCHAR(255),
PRIMARY KEY (Participant_ID)
);


CREATE TABLE  local_govt_in_alabama.Events (
Event_ID INTEGER NOT NULL,
Service_ID INTEGER NOT NULL,
Event_Details VARCHAR(255),
PRIMARY KEY (Event_ID),
FOREIGN KEY (Service_ID) REFERENCES  local_govt_in_alabama.Services (Service_ID)
);

CREATE TABLE  local_govt_in_alabama.Participants_in_Events (
Event_ID INTEGER NOT NULL,
Participant_ID INTEGER NOT NULL,
PRIMARY KEY (Event_ID, Participant_ID),
FOREIGN KEY (Participant_ID) REFERENCES  local_govt_in_alabama.Participants (Participant_ID),
FOREIGN KEY (Event_ID) REFERENCES  local_govt_in_alabama.Events (Event_ID)
);
