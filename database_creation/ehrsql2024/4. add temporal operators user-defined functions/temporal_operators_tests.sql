use mimic_iv;


IF OBJECT_ID (N'dbo.CHECK_RESULT', N'FN') IS NOT NULL
    DROP FUNCTION dbo.CHECK_RESULT;
GO  
CREATE FUNCTION dbo.CHECK_RESULT(@result varchar(MAX), @expected varchar(MAX))
RETURNS varchar(10)
AS 
BEGIN
	IF @result = @expected
		RETURN 'OK'
	RETURN 'FAILED'
END
GO

DECLARE @event datetime = CAST('2100-05-17 12:53:00' AS DATETIME);  

---------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--                                                       Interval and aux methods tests:
----------------------------------------------------------------------------------------------------------------------------------------------------------------
select r as interval_and_aux_results
from (
select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_YMD(2020, NULL, NULL),                  '{"date_start":"2020-01-01T00:00:00","date_end":"2020-12-31T23:59:59"}') r union all
select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_YMD(2020, 2,   NULL),                   '{"date_start":"2020-02-01T00:00:00","date_end":"2020-02-29T23:59:59"}') r union all
select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_YMD(2020, 02,  03),                     '{"date_start":"2020-02-03T00:00:00","date_end":"2020-02-03T23:59:59"}') r union all
select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_YMD(2020, NULL, 3),                     '{"date_start":"2020-01-03T00:00:00","date_end":"2020-01-03T23:59:59"}') r union all -- TODO: should support?

select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_YMD(YEAR(@event), 3,           NULL),   '{"date_start":"2100-03-01T00:00:00","date_end":"2100-03-31T23:59:59"}') r union all    -- dbo.TIME_INTERVAL_REL(dbo.OVERRIDE_DT(@event, NULL, 3,    NULL), 'month')  
select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_YMD(YEAR(@event), 3,             05),   '{"date_start":"2100-03-05T00:00:00","date_end":"2100-03-05T23:59:59"}') r union all    -- dbo.TIME_INTERVAL_REL(dbo.OVERRIDE_DT(@event, NULL, 3,   05),    'day') 
select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_YMD(YEAR(@event), MONTH(@event), 5),    '{"date_start":"2100-05-05T00:00:00","date_end":"2100-05-05T23:59:59"}') r union all    -- dbo.TIME_INTERVAL_REL(dbo.OVERRIDE_DT(@event, NULL, NULL, 5),    'day')     

select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_REL(@event, 'year'),                    '{"date_start":"2100-01-01T00:00:00","date_end":"2100-12-31T23:59:59"}') r union all
select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_REL(@event, 'month'),                   '{"date_start":"2100-05-01T00:00:00","date_end":"2100-05-31T23:59:59"}') r union all
select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_REL(@event, 'day'),                     '{"date_start":"2100-05-17T00:00:00","date_end":"2100-05-17T23:59:59"}') r union all

select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_REL(@event, 'within +1 year'),         '{"date_start":"2100-05-17T12:53:00","date_end":"2101-05-17T12:53:00"}') r union all 
select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_REL(@event, 'within +2 month'),        '{"date_start":"2100-05-17T12:53:00","date_end":"2100-07-17T12:53:00"}') r union all 
select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_REL(@event, 'within +3 day'),          '{"date_start":"2100-05-17T12:53:00","date_end":"2100-05-20T12:53:00"}') r union all 
select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_REL(@event, 'within -1 year'),         '{"date_start":"2099-05-17T12:53:00","date_end":"2100-05-17T12:53:00"}') r union all 
select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_REL(@event, 'within -2 month'),        '{"date_start":"2100-03-17T12:53:00","date_end":"2100-05-17T12:53:00"}') r union all 
select dbo.CHECK_RESULT(dbo.TIME_INTERVAL_REL(@event, 'within -3 day'),          '{"date_start":"2100-05-14T12:53:00","date_end":"2100-05-17T12:53:00"}') r union all  

select dbo.CHECK_RESULT(dbo.TIME_POINT_START_OF_YMD(2020, 02,   03),              '{"date_start":"2020-02-03T00:00:00","date_end":"2020-02-03T00:00:00"}') r union all
select dbo.CHECK_RESULT(dbo.TIME_POINT_START_OF_YMD(2020, 2,    NULL),            '{"date_start":"2020-02-01T00:00:00","date_end":"2020-02-01T00:00:00"}') r union all
select dbo.CHECK_RESULT(dbo.TIME_POINT_START_OF_YMD(2020, NULL, NULL),            '{"date_start":"2020-01-01T00:00:00","date_end":"2020-01-01T00:00:00"}') r union all
select dbo.CHECK_RESULT(dbo.TIME_POINT_START_OF_YMD(2020, NULL, 3),               '{"date_start":"2020-01-03T00:00:00","date_end":"2020-01-03T00:00:00"}') r union all  -- TODO: should support?

select dbo.CHECK_RESULT(dbo.TIME_POINT_REL(@event, 'start-of year'),              '{"date_start":"2100-01-01T00:00:00","date_end":"2100-01-01T00:00:00"}') r union all
select dbo.CHECK_RESULT(dbo.TIME_POINT_REL(@event, 'start-of month'),             '{"date_start":"2100-05-01T00:00:00","date_end":"2100-05-01T00:00:00"}') r union all
select dbo.CHECK_RESULT(dbo.TIME_POINT_REL(@event, 'start-of day'),               '{"date_start":"2100-05-17T00:00:00","date_end":"2100-05-17T00:00:00"}') r union all
select dbo.CHECK_RESULT(dbo.TIME_POINT_REL(@event, 'end-of year'),                '{"date_start":"2100-12-31T23:59:59","date_end":"2100-12-31T23:59:59"}') r union all
select dbo.CHECK_RESULT(dbo.TIME_POINT_REL(@event, 'end-of month'),               '{"date_start":"2100-05-31T23:59:59","date_end":"2100-05-31T23:59:59"}') r union all
select dbo.CHECK_RESULT(dbo.TIME_POINT_REL(@event, 'end-of day'),                 '{"date_start":"2100-05-17T23:59:59","date_end":"2100-05-17T23:59:59"}') r union all

select dbo.CHECK_RESULT(dbo.TIME_POINT_YMDHMS(2005, 03, 02, 22, 23, 57),          '{"date_start":"2005-03-02T22:23:57","date_end":"2005-03-02T22:23:57"}') r union all

select dbo.CHECK_RESULT(STR(dbo.JULIAN_DAY_DIFF(CAST('2100-07-11 13:26:17' AS DATETIME), CAST('2100-12-31 23:59:00' AS DATETIME)), 14, 10),  '173.4395833000')) as rs  -- '173.4393865740'


---------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--                                               Relation operators tests:
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DECLARE @event datetime = CAST('2100-05-17 12:53:00' AS DATETIME);  

--select diagnoses_icd.charttime
--from diagnoses_icd
--where dbo.DURING(charttime, dbo.INTERVAL(DATEADD(YEAR, -1, @event), 'year', NULL, NULL, NULL)) = 1

--select diagnoses_icd.charttime
--from diagnoses_icd
--where dbo.MEETS(charttime, dbo.INTERVAL(@event,                     'desc2', NULL, NULL, NULL)) = 1
 
--select diagnoses_icd.charttime
--from diagnoses_icd
--where dbo.MET_BY(charttime, dbo.INTERVAL(@event,                    'desc2', NULL, NULL, NULL)) = 1
--------------------------------------------------------------------------------


