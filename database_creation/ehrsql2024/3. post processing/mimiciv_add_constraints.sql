USE [mimic_iv]
GO

ALTER TABLE admissions DROP CONSTRAINT IF EXISTS admissions_fk_subject_id;
ALTER TABLE admissions ADD CONSTRAINT admissions_fk_subject_id FOREIGN KEY(subject_id) REFERENCES patients(subject_id);


ALTER TABLE icustays DROP CONSTRAINT IF EXISTS icustays_fk_hadm_id;
ALTER TABLE icustays ADD CONSTRAINT icustays_fk_hadm_id FOREIGN KEY(hadm_id) REFERENCES admissions(hadm_id);


ALTER TABLE diagnoses_icd DROP CONSTRAINT IF EXISTS diagnoses_icd_fk_hadm_id;
ALTER TABLE diagnoses_icd ADD CONSTRAINT diagnoses_icd_fk_hadm_id FOREIGN KEY(hadm_id) REFERENCES admissions(hadm_id);

ALTER TABLE diagnoses_icd DROP CONSTRAINT IF EXISTS diagnoses_icd_fk_icd_code;
ALTER TABLE diagnoses_icd ADD CONSTRAINT diagnoses_icd_fk_icd_code FOREIGN KEY(icd_code) REFERENCES d_icd_diagnoses(icd_code);


ALTER TABLE procedures_icd DROP CONSTRAINT IF EXISTS procedures_icd_fk_hadm_id;
ALTER TABLE procedures_icd ADD CONSTRAINT procedures_icd_fk_hadm_id FOREIGN KEY(hadm_id) REFERENCES admissions(hadm_id);

ALTER TABLE procedures_icd DROP CONSTRAINT IF EXISTS procedures_icd_fk_icd_code;
ALTER TABLE procedures_icd ADD CONSTRAINT procedures_icd_fk_icd_code FOREIGN KEY(icd_code) REFERENCES d_icd_procedures(icd_code);


ALTER TABLE labevents DROP CONSTRAINT IF EXISTS labevents_fk_hadm_id;
ALTER TABLE labevents ADD CONSTRAINT labevents_fk_hadm_id FOREIGN KEY(hadm_id) REFERENCES admissions(hadm_id);

ALTER TABLE labevents DROP CONSTRAINT IF EXISTS labevents_fk_itemid;
ALTER TABLE labevents ADD CONSTRAINT labevents_fk_itemid FOREIGN KEY(itemid) REFERENCES d_labitems(itemid);


ALTER TABLE prescriptions DROP CONSTRAINT IF EXISTS prescriptions_fk_hadm_id;
ALTER TABLE prescriptions ADD CONSTRAINT prescriptions_fk_hadm_id FOREIGN KEY(hadm_id) REFERENCES admissions(hadm_id);


ALTER TABLE cost DROP CONSTRAINT IF EXISTS cost_fk_hadm_id;
ALTER TABLE cost ADD CONSTRAINT cost_fk_hadm_id FOREIGN KEY(hadm_id) REFERENCES admissions(hadm_id);

--ALTER TABLE cost DROP CONSTRAINT IF EXISTS cost_fk_diagnoses_icd;
--ALTER TABLE cost ADD CONSTRAINT cost_fk_diagnoses_icd FOREIGN KEY(event_id) REFERENCES diagnoses_icd(row_id);

--ALTER TABLE cost DROP CONSTRAINT IF EXISTS cost_fk_procedures_icd;
--ALTER TABLE cost ADD CONSTRAINT cost_fk_procedures_icd FOREIGN KEY(event_id) REFERENCES procedures_icd(row_id);

ALTER TABLE cost DROP CONSTRAINT IF EXISTS cost_fk_labevents;
ALTER TABLE cost ADD CONSTRAINT cost_fk_labevents FOREIGN KEY(event_id) REFERENCES labevents(row_id);

--ALTER TABLE cost DROP CONSTRAINT IF EXISTS cost_fk_prescriptions;
--ALTER TABLE cost ADD CONSTRAINT cost_fk_prescriptions FOREIGN KEY(event_id) REFERENCES prescriptions(row_id);


ALTER TABLE chartevents DROP CONSTRAINT IF EXISTS chartevents_fk_hadm_id;
ALTER TABLE chartevents ADD CONSTRAINT chartevents_fk_hadm_id FOREIGN KEY(hadm_id) REFERENCES admissions(hadm_id);

ALTER TABLE chartevents DROP CONSTRAINT IF EXISTS chartevents_fk_stay_id;
ALTER TABLE chartevents ADD CONSTRAINT chartevents_fk_stay_id FOREIGN KEY(stay_id) REFERENCES icustays(stay_id);

ALTER TABLE chartevents DROP CONSTRAINT IF EXISTS chartevents_fk_itemid;
ALTER TABLE chartevents ADD CONSTRAINT chartevents_fk_itemid FOREIGN KEY(itemid) REFERENCES d_items(itemid);


ALTER TABLE inputevents DROP CONSTRAINT IF EXISTS inputevents_fk_hadm_id;
ALTER TABLE inputevents ADD CONSTRAINT inputevents_fk_hadm_id FOREIGN KEY(hadm_id) REFERENCES admissions(hadm_id);

ALTER TABLE inputevents DROP CONSTRAINT IF EXISTS inputevents_fk_stay_id;
ALTER TABLE inputevents ADD CONSTRAINT inputevents_fk_stay_id FOREIGN KEY(stay_id) REFERENCES icustays(stay_id);

ALTER TABLE inputevents DROP CONSTRAINT IF EXISTS inputevents_fk_itemid;
ALTER TABLE inputevents ADD CONSTRAINT inputevents_fk_itemid FOREIGN KEY(itemid) REFERENCES d_items(itemid);


ALTER TABLE outputevents DROP CONSTRAINT IF EXISTS outputevents_fk_hadm_id;
ALTER TABLE outputevents ADD CONSTRAINT outputevents_fk_hadm_id FOREIGN KEY(hadm_id) REFERENCES admissions(hadm_id);

ALTER TABLE outputevents DROP CONSTRAINT IF EXISTS outputevents_fk_stay_id;
ALTER TABLE outputevents ADD CONSTRAINT outputevents_fk_stay_id FOREIGN KEY(stay_id) REFERENCES icustays(stay_id);

ALTER TABLE outputevents DROP CONSTRAINT IF EXISTS outputevents_fk_itemid;
ALTER TABLE outputevents ADD CONSTRAINT outputevents_fk_itemid FOREIGN KEY(itemid) REFERENCES d_items(itemid);


ALTER TABLE microbiologyevents DROP CONSTRAINT IF EXISTS microbiologyevents_fk_hadm_id;
ALTER TABLE microbiologyevents ADD CONSTRAINT microbiologyevents_fk_hadm_id FOREIGN KEY(hadm_id) REFERENCES admissions(hadm_id);


ALTER TABLE transfers DROP CONSTRAINT IF EXISTS transfers_fk_hadm_id;
ALTER TABLE transfers ADD CONSTRAINT transfers_fk_hadm_id FOREIGN KEY(hadm_id) REFERENCES admissions(hadm_id);

