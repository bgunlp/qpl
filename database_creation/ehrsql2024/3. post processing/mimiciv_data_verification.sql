USE [mimic_iv]
go

Select 'patients'           as [Table Name], count(*) as [Rows in Table], 94     as [Expected Rows], count(*)-94     as [Difference] from dbo.patients           UNION ALL 
Select 'admissions'         as [Table Name], count(*) as [Rows in Table], 119    as [Expected Rows], count(*)-119    as [Difference] from dbo.admissions         UNION ALL 
Select 'icustays'           as [Table Name], count(*) as [Rows in Table], 88     as [Expected Rows], count(*)-88     as [Difference] from dbo.icustays           UNION ALL    
Select 'd_icd_diagnoses'    as [Table Name], count(*) as [Rows in Table], 106308 as [Expected Rows], count(*)-106308 as [Difference] from dbo.d_icd_diagnoses    UNION ALL  
Select 'd_icd_procedures'   as [Table Name], count(*) as [Rows in Table], 85254  as [Expected Rows], count(*)-85254  as [Difference] from dbo.d_icd_procedures   UNION ALL   
Select 'd_labitems'         as [Table Name], count(*) as [Rows in Table], 1594   as [Expected Rows], count(*)-1594   as [Difference] from dbo.d_labitems         UNION ALL   
Select 'd_items'            as [Table Name], count(*) as [Rows in Table], 3522   as [Expected Rows], count(*)-3522   as [Difference] from dbo.d_items            UNION ALL   
Select 'diagnoses_icd'      as [Table Name], count(*) as [Rows in Table], 1561   as [Expected Rows], count(*)-1561   as [Difference] from dbo.diagnoses_icd      UNION ALL   
Select 'procedures_icd'     as [Table Name], count(*) as [Rows in Table], 379    as [Expected Rows], count(*)-379    as [Difference] from dbo.procedures_icd     UNION ALL   
Select 'labevents'          as [Table Name], count(*) as [Rows in Table], 26426  as [Expected Rows], count(*)-26426  as [Difference] from dbo.labevents          UNION ALL   
Select 'prescriptions'      as [Table Name], count(*) as [Rows in Table], 5354   as [Expected Rows], count(*)-5354   as [Difference] from dbo.prescriptions      UNION ALL   
Select 'cost'               as [Table Name], count(*) as [Rows in Table], 33720  as [Expected Rows], count(*)-33720  as [Difference] from dbo.cost               UNION ALL   
Select 'chartevents'        as [Table Name], count(*) as [Rows in Table], 31926  as [Expected Rows], count(*)-31926  as [Difference] from dbo.chartevents        UNION ALL   
Select 'inputevents'        as [Table Name], count(*) as [Rows in Table], 5730   as [Expected Rows], count(*)-5730   as [Difference] from dbo.inputevents        UNION ALL   
Select 'outputevents'       as [Table Name], count(*) as [Rows in Table], 5292   as [Expected Rows], count(*)-5292   as [Difference] from dbo.outputevents       UNION ALL   
Select 'microbiologyevents' as [Table Name], count(*) as [Rows in Table], 1060   as [Expected Rows], count(*)-1060   as [Difference] from dbo.microbiologyevents UNION ALL   
Select 'transfers'          as [Table Name], count(*) as [Rows in Table], 515    as [Expected Rows], count(*)-515    as [Difference] from dbo.transfers 
 
order by [Table Name] asc