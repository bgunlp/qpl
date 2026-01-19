use  mimic_iv;

UPDATE admissions
SET dischtime = NULL
WHERE YEAR(dischtime) < 2100

UPDATE icustays
SET outtime = NULL
WHERE YEAR(outtime) < 2100 

----------------------------------------------------

UPDATE microbiologyevents
SET org_name = NULL
WHERE org_name = ''

UPDATE transfers
SET careunit = NULL
WHERE careunit = ''


----------------- TEMP: -----------------------------

-----------------------------------------------------
SELECT dose_val_rx
FROM prescriptions
WHERE TRY_CAST(dose_val_rx AS FLOAT) IS NULL
  AND dose_val_rx IS NOT NULL;

ALTER TABLE prescriptions
ALTER COLUMN dose_val_rx FLOAT;
-----------------------------------------------------


-- ALTER INDEX UQ__d_items__56A22C93E99760DC ON d_items DISABLE;
-- ALTER INDEX UQ__d_items__56A22C93E99760DC ON d_items REBUILD




ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 1;