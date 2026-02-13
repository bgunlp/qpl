----------------------------------------------------------------------------------------------
--  SQLite equivalent of temporal_operators.sql (T-SQL)
--
--  SQLite does not support CREATE FUNCTION in SQL. Each T-SQL UDF is documented below
--  with its equivalent SQLite expression. These expressions can be used inline in queries,
--  or within CTEs.
----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
--                                      Public
----------------------------------------------------------------------------------------------

---------------------------------- Relation operators: ---------------------------------------

-- MEETS(event, interval) -> int
-- T-SQL: dbo.MEETS(@event, @interval)
-- SQLite equivalent expression:
--   CASE WHEN event <= json_extract(interval, '$.date_start') THEN 1 ELSE 0 END


-- MET_BY(event, interval) -> int
-- T-SQL: dbo.MET_BY(@event, @interval)
-- SQLite equivalent expression:
--   CASE WHEN json_extract(interval, '$.date_end') <= event THEN 1 ELSE 0 END


-- DURING(event, interval) -> int
-- T-SQL: dbo.DURING(@event, @interval)
-- SQLite equivalent expression:
--   CASE WHEN event >= json_extract(interval, '$.date_start')
--         AND event <= json_extract(interval, '$.date_end') THEN 1 ELSE 0 END


------------------------------------ Time intervals: -----------------------------------------

-- TIME_INTERVAL(datetime_start, datetime_end) -> JSON string
-- T-SQL: dbo.TIME_INTERVAL(@datetime_start, @datetime_end)
-- SQLite equivalent expression:
--   json_object(
--       'date_start', strftime('%Y-%m-%dT%H:%M:%S', datetime_start),
--       'date_end',   strftime('%Y-%m-%dT%H:%M:%S', datetime_end)
--   )


-- TIME_POINT(dt) -> JSON string
-- T-SQL: dbo.TIME_POINT(@datetime)
-- SQLite equivalent expression (TIME_INTERVAL with same start and end):
--   json_object(
--       'date_start', strftime('%Y-%m-%dT%H:%M:%S', dt),
--       'date_end',   strftime('%Y-%m-%dT%H:%M:%S', dt)
--   )


-- START_OF_YMDHMS(year, month, day, hour, min, sec) -> datetime string
-- T-SQL: dbo.START_OF_YMDHMS(@year, @month, @day, @hour, @min, @sec)
-- Defaults: month=1, day=1, hour=0, min=0, sec=0
-- SQLite equivalent expression:
--   printf('%04d-%02d-%02d %02d:%02d:%02d',
--       year,
--       COALESCE(month, 1),
--       COALESCE(day, 1),
--       COALESCE(hour, 0),
--       COALESCE(min, 0),
--       COALESCE(sec, 0)
--   )


-- START_OF_YMD(year, month, day) -> datetime string
-- T-SQL: dbo.START_OF_YMD(@year, @month, @day)
-- SQLite equivalent expression (calls START_OF_YMDHMS with NULL time parts):
--   printf('%04d-%02d-%02d 00:00:00',
--       year,
--       COALESCE(month, 1),
--       COALESCE(day, 1)
--   )


-- END_OF_YMD(year, month, day) -> datetime string
-- T-SQL: dbo.END_OF_YMD(@year, @month, @day)
-- Defaults: month=12, day=last day of the resulting month
-- SQLite equivalent expression:
--   printf('%04d-%02d-%02d 23:59:59',
--       year,
--       COALESCE(month, 12),
--       COALESCE(day,
--           CAST(strftime('%d',
--               date(printf('%04d-%02d-01', year, COALESCE(month, 12)), '+1 month', '-1 day')
--           ) AS INTEGER)
--       )
--   )


-- START_OF_DT(dt, datepart) -> datetime string
-- T-SQL: dbo.START_OF_DT(@date, @datepart)
-- datepart is 'year', 'month', or 'day'
-- SQLite equivalent expression:
--   CASE datepart
--       WHEN 'year'  THEN printf('%04d-01-01 00:00:00', CAST(strftime('%Y', dt) AS INTEGER))
--       WHEN 'month' THEN printf('%04d-%02d-01 00:00:00',
--                            CAST(strftime('%Y', dt) AS INTEGER),
--                            CAST(strftime('%m', dt) AS INTEGER))
--       WHEN 'day'   THEN printf('%04d-%02d-%02d 00:00:00',
--                            CAST(strftime('%Y', dt) AS INTEGER),
--                            CAST(strftime('%m', dt) AS INTEGER),
--                            CAST(strftime('%d', dt) AS INTEGER))
--   END


-- END_OF_DT(dt, datepart) -> datetime string
-- T-SQL: dbo.END_OF_DT(@date, @datepart)
-- datepart is 'year', 'month', or 'day'
-- SQLite equivalent expression:
--   CASE datepart
--       WHEN 'year'  THEN printf('%04d-12-31 23:59:59', CAST(strftime('%Y', dt) AS INTEGER))
--       WHEN 'month' THEN printf('%04d-%02d-%02d 23:59:59',
--                            CAST(strftime('%Y', dt) AS INTEGER),
--                            CAST(strftime('%m', dt) AS INTEGER),
--                            CAST(strftime('%d',
--                                date(printf('%04d-%02d-01',
--                                    CAST(strftime('%Y', dt) AS INTEGER),
--                                    CAST(strftime('%m', dt) AS INTEGER)),
--                                '+1 month', '-1 day')
--                            ) AS INTEGER))
--       WHEN 'day'   THEN printf('%04d-%02d-%02d 23:59:59',
--                            CAST(strftime('%Y', dt) AS INTEGER),
--                            CAST(strftime('%m', dt) AS INTEGER),
--                            CAST(strftime('%d', dt) AS INTEGER))
--   END


-- TIME_POINT_START_OF_YMD(year, month, day) -> JSON string
-- T-SQL: dbo.TIME_POINT_START_OF_YMD(@year, @month, @day)
-- Equivalent to TIME_POINT(START_OF_YMD(year, month, day))
-- SQLite equivalent expression:
--   json_object(
--       'date_start', strftime('%Y-%m-%dT%H:%M:%S',
--           printf('%04d-%02d-%02d 00:00:00', year, COALESCE(month, 1), COALESCE(day, 1))),
--       'date_end',   strftime('%Y-%m-%dT%H:%M:%S',
--           printf('%04d-%02d-%02d 00:00:00', year, COALESCE(month, 1), COALESCE(day, 1)))
--   )


-- TIME_POINT_YMDHMS(year, month, day, hour, min, sec) -> JSON string
-- T-SQL: dbo.TIME_POINT_YMDHMS(@year, @month, @day, @hour, @min, @sec)
-- Equivalent to TIME_POINT(START_OF_YMDHMS(year, month, day, hour, min, sec))
-- SQLite equivalent expression:
--   json_object(
--       'date_start', strftime('%Y-%m-%dT%H:%M:%S',
--           printf('%04d-%02d-%02d %02d:%02d:%02d',
--               year, COALESCE(month,1), COALESCE(day,1),
--               COALESCE(hour,0), COALESCE(min,0), COALESCE(sec,0))),
--       'date_end',   strftime('%Y-%m-%dT%H:%M:%S',
--           printf('%04d-%02d-%02d %02d:%02d:%02d',
--               year, COALESCE(month,1), COALESCE(day,1),
--               COALESCE(hour,0), COALESCE(min,0), COALESCE(sec,0)))
--   )


-- TIME_POINT_REL(dt, description) -> JSON string
-- T-SQL: dbo.TIME_POINT_REL(@datetime, @description)
-- description is 'start-of year/month/day' or 'end-of year/month/day'
-- desc_prefix = GET_PREFIX(description) -> 'start-of' or 'end-of'
-- desc_suffix = GET_SUFFIX(description) -> 'year', 'month', or 'day'
-- If desc_prefix = 'start-of': result = START_OF_DT(dt, desc_suffix)
-- If desc_prefix = 'end-of':   result = END_OF_DT(dt, desc_suffix)
-- Then: TIME_POINT(result)
--
-- SQLite equivalent expression (for 'start-of <unit>'):
--   json_object(
--       'date_start', strftime('%Y-%m-%dT%H:%M:%S', START_OF_DT(dt, unit)),
--       'date_end',   strftime('%Y-%m-%dT%H:%M:%S', START_OF_DT(dt, unit))
--   )
--
-- SQLite equivalent expression (for 'end-of <unit>'):
--   json_object(
--       'date_start', strftime('%Y-%m-%dT%H:%M:%S', END_OF_DT(dt, unit)),
--       'date_end',   strftime('%Y-%m-%dT%H:%M:%S', END_OF_DT(dt, unit))
--   )


-- TIME_INTERVAL_YMD(year, month, day) -> JSON string
-- T-SQL: dbo.TIME_INTERVAL_YMD(@year, @month, @day)
-- desc = 'day' if day not null, else 'month' if month not null, else 'year'
-- result = TIME_INTERVAL_REL(START_OF_YMD(year, month, day), desc)
-- SQLite equivalent: see TIME_INTERVAL_REL below, with appropriate desc


-- TIME_INTERVAL_REL(dt, description) -> JSON string
-- T-SQL: dbo.TIME_INTERVAL_REL(@datetime, @description)
--
-- Case 1: description has no space (e.g., 'year', 'month', 'day')
--   start = START_OF_DT(dt, description)
--   end   = END_OF_DT(dt, description)
--   result = TIME_INTERVAL(start, end)
--
-- Case 2: description = 'within <offset> <unit>' (e.g., 'within +1 year')
--   offset = integer part (e.g., +1, -2)
--   unit   = datepart (e.g., 'year', 'month', 'day')
--   end_dt = datetime(dt, '<offset> <unit>s')   -- SQLite date arithmetic
--   If offset >= 0: start = dt, end = end_dt
--   If offset <  0: start = end_dt, end = dt
--   result = TIME_INTERVAL(start, end)


------------------------------------ Aux: -----------------------------------------

----------------------------------------------------------------------------------------------
--                                      Private utility methods:
----------------------------------------------------------------------------------------------

-- DATE_ADD(dt, offset, datepart) -> datetime string
-- T-SQL: dbo.DATE_ADD(@date, @offset, @datepart)
-- datepart is 'year', 'month', or 'day'
-- SQLite equivalent expression:
--   datetime(dt, offset || ' ' || datepart || 's')
-- Examples:
--   datetime(dt, '+1 years')
--   datetime(dt, '-2 months')
--   datetime(dt, '+3 days')


-- GET_PREFIX(str) -> string
-- Returns substring before first space, or the whole string if no space.
-- T-SQL: dbo.GET_PREFIX(@str)
-- SQLite equivalent expression:
--   CASE WHEN instr(str, ' ') > 0
--       THEN substr(str, 1, instr(str, ' ') - 1)
--       ELSE str
--   END


-- GET_SUFFIX(str) -> string or NULL
-- Returns substring after first space (trimmed), or NULL if no space.
-- T-SQL: dbo.GET_SUFFIX(@str)
-- SQLite equivalent expression:
--   CASE WHEN instr(str, ' ') > 0
--       THEN ltrim(substr(str, instr(str, ' ')))
--       ELSE NULL
--   END


----------------------------------------------------------------------------------------------
--   For value comparison between SQLite and T-SQL,
--
--   specifically to replicate the behavior of SQLite's:
--          strftime('%J', datetime_to) - strftime('%J', datetime_from)
--
--   (see also ehrsql_to_tsql_execution_plans.py -->
--            func_name_translate, date_diff_tests+date_diff_replacer, finalize_translation, tsql_modify_for_translation_validation)
----------------------------------------------------------------------------------------------

-- JULIAN_DAY_DIFF(dt_from, dt_to) -> float
-- T-SQL: dbo.JULIAN_DAY_DIFF(@dt_from, @dt_to)
-- T-SQL implementation: DATEDIFF(MINUTE, @dt_from, @dt_to) / (24.0 * 60)
-- SQLite equivalent expression (matches T-SQL DATEDIFF(MINUTE) precision):
--   ROUND((julianday(dt_to) - julianday(dt_from)) * 24 * 60, 0) / (24.0 * 60)


----------------------------------------------------------------------------------------------
--                              Unused/obsolete:
----------------------------------------------------------------------------------------------

-- OVERRIDE_DT(dt, year, month, day) -> datetime string
-- T-SQL: dbo.OVERRIDE_DT(@date, @year, @month, @day)
-- Replaces year/month/day components of dt, keeping time unchanged.
-- SQLite equivalent expression:
--   printf('%04d-%02d-%02d %02d:%02d:%02d',
--       COALESCE(year,  CAST(strftime('%Y', dt) AS INTEGER)),
--       COALESCE(month, CAST(strftime('%m', dt) AS INTEGER)),
--       COALESCE(day,   CAST(strftime('%d', dt) AS INTEGER)),
--       CAST(strftime('%H', dt) AS INTEGER),
--       CAST(strftime('%M', dt) AS INTEGER),
--       CAST(strftime('%S', dt) AS INTEGER)
--   )
