USE spider;
CREATE TABLE  hospital_1.Physician (
EmployeeID INTEGER NOT NULL,
Name VARCHAR(30) NOT NULL,
Position VARCHAR(30) NOT NULL,
SSN INTEGER NOT NULL,
CONSTRAINT pk_physician PRIMARY KEY(EmployeeID)
);

DROP TABLE IF EXISTS Department;
CREATE TABLE  hospital_1.Department (
DepartmentID INTEGER NOT NULL,
Name VARCHAR(30) NOT NULL,
Head INTEGER NOT NULL,
CONSTRAINT pk_Department PRIMARY KEY(DepartmentID),
CONSTRAINT fk_Department_Physician_EmployeeID FOREIGN KEY(Head) REFERENCES  hospital_1.Physician(EmployeeID)
);


DROP TABLE IF EXISTS Affiliated_With;
CREATE TABLE  hospital_1.Affiliated_With (
Physician INTEGER NOT NULL,
Department INTEGER NOT NULL,
PrimaryAffiliation BIT NOT NULL,
CONSTRAINT fk_Affiliated_With_Physician_EmployeeID FOREIGN KEY(Physician) REFERENCES  hospital_1.Physician(EmployeeID),
CONSTRAINT fk_Affiliated_With_Department_DepartmentID FOREIGN KEY(Department) REFERENCES  hospital_1.Department(DepartmentID),
PRIMARY KEY(Physician, Department)
);

DROP TABLE IF EXISTS Procedures;
CREATE TABLE  hospital_1.Procedures (
Code INTEGER PRIMARY KEY NOT NULL,
Name VARCHAR(30) NOT NULL,
Cost REAL NOT NULL
);

DROP TABLE IF EXISTS Trained_In;
CREATE TABLE  hospital_1.Trained_In (
Physician INTEGER NOT NULL,
Treatment INTEGER NOT NULL,
CertificationDate DATETIME NOT NULL,
CertificationExpires DATETIME NOT NULL,
CONSTRAINT fk_Trained_In_Physician_EmployeeID FOREIGN KEY(Physician) REFERENCES  hospital_1.Physician(EmployeeID),
CONSTRAINT fk_Trained_In_Procedures_Code FOREIGN KEY(Treatment) REFERENCES  hospital_1.Procedures(Code),
PRIMARY KEY(Physician, Treatment)
);

DROP TABLE IF EXISTS Patient;
CREATE TABLE  hospital_1.Patient (
SSN INTEGER PRIMARY KEY NOT NULL,
Name VARCHAR(30) NOT NULL,
Address VARCHAR(30) NOT NULL,
Phone VARCHAR(30) NOT NULL,
InsuranceID INTEGER NOT NULL,
PCP INTEGER NOT NULL,
CONSTRAINT fk_Patient_Physician_EmployeeID FOREIGN KEY(PCP) REFERENCES  hospital_1.Physician(EmployeeID)
);

DROP TABLE IF EXISTS Nurse;
CREATE TABLE  hospital_1.Nurse (
EmployeeID INTEGER PRIMARY KEY NOT NULL,
Name VARCHAR(30) NOT NULL,
Position VARCHAR(30) NOT NULL,
Registered BIT NOT NULL,
SSN INTEGER NOT NULL
);

DROP TABLE IF EXISTS Appointment;
CREATE TABLE  hospital_1.Appointment (
AppointmentID INTEGER PRIMARY KEY NOT NULL,
Patient INTEGER NOT NULL,
PrepNurse INTEGER,
Physician INTEGER NOT NULL,
Start DATETIME NOT NULL,
[End] DATETIME NOT NULL,
ExaminationRoom VARCHAR(400) NOT NULL,
CONSTRAINT fk_Appointment_Patient_SSN FOREIGN KEY(Patient) REFERENCES  hospital_1.Patient(SSN),
CONSTRAINT fk_Appointment_Nurse_EmployeeID FOREIGN KEY(PrepNurse) REFERENCES  hospital_1.Nurse(EmployeeID),
CONSTRAINT fk_Appointment_Physician_EmployeeID FOREIGN KEY(Physician) REFERENCES  hospital_1.Physician(EmployeeID)
);

DROP TABLE IF EXISTS Medication;
CREATE TABLE  hospital_1.Medication (
Code INTEGER PRIMARY KEY NOT NULL,
Name VARCHAR(30) NOT NULL,
Brand VARCHAR(30) NOT NULL,
Description VARCHAR(30) NOT NULL
);


DROP TABLE IF EXISTS Prescribes;
CREATE TABLE  hospital_1.Prescribes (
Physician INTEGER NOT NULL,
Patient INTEGER NOT NULL,
Medication INTEGER NOT NULL,
Date DATETIME NOT NULL,
Appointment INTEGER,
Dose VARCHAR(30) NOT NULL,
PRIMARY KEY(Physician, Patient, Medication, Date),
CONSTRAINT fk_Prescribes_Physician_EmployeeID FOREIGN KEY(Physician) REFERENCES  hospital_1.Physician(EmployeeID),
CONSTRAINT fk_Prescribes_Patient_SSN FOREIGN KEY(Patient) REFERENCES  hospital_1.Patient(SSN),
CONSTRAINT fk_Prescribes_Medication_Code FOREIGN KEY(Medication) REFERENCES  hospital_1.Medication(Code),
CONSTRAINT fk_Prescribes_Appointment_AppointmentID FOREIGN KEY(Appointment) REFERENCES  hospital_1.Appointment(AppointmentID)
);

DROP TABLE IF EXISTS Block;
CREATE TABLE  hospital_1.Block (
BlockFloor INTEGER NOT NULL,
BlockCode INTEGER NOT NULL,
PRIMARY KEY(BlockFloor, BlockCode)
);

DROP TABLE IF EXISTS Room;
CREATE TABLE  hospital_1.Room (
RoomNumber INTEGER PRIMARY KEY NOT NULL,
RoomType VARCHAR(30) NOT NULL,
BlockFloor INTEGER NOT NULL,
BlockCode INTEGER NOT NULL,
Unavailable BIT NOT NULL,
CONSTRAINT fk_Room_Block_PK FOREIGN KEY(BlockFloor, BlockCode) REFERENCES  hospital_1.Block(BlockFloor, BlockCode)
);

DROP TABLE IF EXISTS On_Call;
CREATE TABLE  hospital_1.On_Call (
Nurse INTEGER NOT NULL,
BlockFloor INTEGER NOT NULL,
BlockCode INTEGER NOT NULL,
OnCallStart DATETIME NOT NULL,
OnCallEnd DATETIME NOT NULL,
PRIMARY KEY(Nurse, BlockFloor, BlockCode, OnCallStart, OnCallEnd),
CONSTRAINT fk_OnCall_Nurse_EmployeeID FOREIGN KEY(Nurse) REFERENCES  hospital_1.Nurse(EmployeeID),
CONSTRAINT fk_OnCall_Block_Floor FOREIGN KEY(BlockFloor, BlockCode) REFERENCES  hospital_1.Block(BlockFloor, BlockCode)
);

DROP TABLE IF EXISTS Stay;
CREATE TABLE  hospital_1.Stay (
StayID INTEGER PRIMARY KEY NOT NULL,
Patient INTEGER NOT NULL,
Room INTEGER NOT NULL,
StayStart DATETIME NOT NULL,
StayEnd DATETIME NOT NULL,
CONSTRAINT fk_Stay_Patient_SSN FOREIGN KEY(Patient) REFERENCES  hospital_1.Patient(SSN),
CONSTRAINT fk_Stay_Room_Number FOREIGN KEY(Room) REFERENCES  hospital_1.Room(RoomNumber)
);

DROP TABLE IF EXISTS Undergoes;
CREATE TABLE  hospital_1.Undergoes (
Patient INTEGER NOT NULL,
Procedures INTEGER NOT NULL,
Stay INTEGER NOT NULL,
DateUndergoes DATETIME NOT NULL,
Physician INTEGER NOT NULL,
AssistingNurse INTEGER,
PRIMARY KEY(Patient, Procedures, Stay, DateUndergoes),
CONSTRAINT fk_Undergoes_Patient_SSN FOREIGN KEY(Patient) REFERENCES  hospital_1.Patient(SSN),
CONSTRAINT fk_Undergoes_Procedures_Code FOREIGN KEY(Procedures) REFERENCES  hospital_1.Procedures(Code),
CONSTRAINT fk_Undergoes_Stay_StayID FOREIGN KEY(Stay) REFERENCES  hospital_1.Stay(StayID),
CONSTRAINT fk_Undergoes_Physician_EmployeeID FOREIGN KEY(Physician) REFERENCES  hospital_1.Physician(EmployeeID),
CONSTRAINT fk_Undergoes_Nurse_EmployeeID FOREIGN KEY(AssistingNurse) REFERENCES  hospital_1.Nurse(EmployeeID)
);
