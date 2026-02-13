----------------------------------------------------------------------------------------------
--  SQLite equivalent of temporal_operators_tests.sql (T-SQL)
--
--  Each T-SQL UDF call is replaced by the equivalent inline SQLite expression.
--  CHECK_RESULT is: CASE WHEN result = expected THEN 'OK' ELSE 'FAILED' END
--  @event is provided via a CTE.
----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                       Interval and aux methods tests:
----------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH event AS (SELECT '2100-05-17 12:53:00' AS dt)

SELECT r AS interval_and_aux_results
FROM (

-- TIME_INTERVAL_YMD(2020, NULL, NULL) -> desc='year', START_OF_YMD(2020,NULL,NULL)='2020-01-01 00:00:00'
-- TIME_INTERVAL_REL('2020-01-01 00:00:00', 'year') -> START_OF_DT='2020-01-01 00:00:00', END_OF_DT='2020-12-31 23:59:59'
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', '2020-01-01 00:00:00'),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S', '2020-12-31 23:59:59'))
    = '{"date_start":"2020-01-01T00:00:00","date_end":"2020-12-31T23:59:59"}'
    THEN 'OK' ELSE 'FAILED' END AS r

UNION ALL

-- TIME_INTERVAL_YMD(2020, 2, NULL) -> desc='month', START_OF_YMD(2020,2,NULL)='2020-02-01 00:00:00'
-- TIME_INTERVAL_REL('2020-02-01 00:00:00', 'month') -> start='2020-02-01 00:00:00', end='2020-02-29 23:59:59'
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', '2020-02-01 00:00:00'),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-%02d 23:59:59', 2020, 2,
                CAST(strftime('%d', date('2020-02-01', '+1 month', '-1 day')) AS INTEGER))))
    = '{"date_start":"2020-02-01T00:00:00","date_end":"2020-02-29T23:59:59"}'
    THEN 'OK' ELSE 'FAILED' END AS r

UNION ALL

-- TIME_INTERVAL_YMD(2020, 02, 03) -> desc='day', START_OF_YMD(2020,2,3)='2020-02-03 00:00:00'
-- TIME_INTERVAL_REL('2020-02-03 00:00:00', 'day') -> start='2020-02-03 00:00:00', end='2020-02-03 23:59:59'
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', '2020-02-03 00:00:00'),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S', '2020-02-03 23:59:59'))
    = '{"date_start":"2020-02-03T00:00:00","date_end":"2020-02-03T23:59:59"}'
    THEN 'OK' ELSE 'FAILED' END AS r

UNION ALL

-- TIME_INTERVAL_YMD(2020, NULL, 3) -> month=NULL->1 for START_OF_YMD, desc='day' (day not null)
-- START_OF_YMD(2020,NULL,3)='2020-01-03 00:00:00'
-- TIME_INTERVAL_REL('2020-01-03 00:00:00', 'day') -> start='2020-01-03 00:00:00', end='2020-01-03 23:59:59'
SELECT CASE WHEN -- TODO: should support?
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', '2020-01-03 00:00:00'),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S', '2020-01-03 23:59:59'))
    = '{"date_start":"2020-01-03T00:00:00","date_end":"2020-01-03T23:59:59"}'
    THEN 'OK' ELSE 'FAILED' END AS r

UNION ALL

-- TIME_INTERVAL_YMD(YEAR(event), 3, NULL) -> year=2100, month=3, desc='month'
-- START_OF_YMD(2100,3,NULL)='2100-03-01 00:00:00'
-- TIME_INTERVAL_REL('2100-03-01 00:00:00', 'month')
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', '2100-03-01 00:00:00'),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-%02d 23:59:59', 2100, 3,
                CAST(strftime('%d', date('2100-03-01', '+1 month', '-1 day')) AS INTEGER))))
    = '{"date_start":"2100-03-01T00:00:00","date_end":"2100-03-31T23:59:59"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_INTERVAL_YMD(YEAR(event), 3, 05) -> year=2100, month=3, day=5, desc='day'
-- START_OF_YMD(2100,3,5)='2100-03-05 00:00:00'
-- TIME_INTERVAL_REL('2100-03-05 00:00:00', 'day')
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', '2100-03-05 00:00:00'),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S', '2100-03-05 23:59:59'))
    = '{"date_start":"2100-03-05T00:00:00","date_end":"2100-03-05T23:59:59"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_INTERVAL_YMD(YEAR(event), MONTH(event), 5) -> year=2100, month=5, day=5, desc='day'
-- START_OF_YMD(2100,5,5)='2100-05-05 00:00:00'
-- TIME_INTERVAL_REL('2100-05-05 00:00:00', 'day')
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', '2100-05-05 00:00:00'),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S', '2100-05-05 23:59:59'))
    = '{"date_start":"2100-05-05T00:00:00","date_end":"2100-05-05T23:59:59"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_INTERVAL_REL(event, 'year') -> desc_suffix=NULL, desc_prefix='year'
-- START_OF_DT(event, 'year')='2100-01-01 00:00:00', END_OF_DT(event, 'year')='2100-12-31 23:59:59'
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-01-01 00:00:00', CAST(strftime('%Y', dt) AS INTEGER))),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-12-31 23:59:59', CAST(strftime('%Y', dt) AS INTEGER))))
    = '{"date_start":"2100-01-01T00:00:00","date_end":"2100-12-31T23:59:59"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_INTERVAL_REL(event, 'month') -> desc_suffix=NULL, desc_prefix='month'
-- START_OF_DT(event, 'month')='2100-05-01 00:00:00'
-- END_OF_DT(event, 'month')='2100-05-31 23:59:59'
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-01 00:00:00',
                CAST(strftime('%Y', dt) AS INTEGER),
                CAST(strftime('%m', dt) AS INTEGER))),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-%02d 23:59:59',
                CAST(strftime('%Y', dt) AS INTEGER),
                CAST(strftime('%m', dt) AS INTEGER),
                CAST(strftime('%d', date(
                    printf('%04d-%02d-01',
                        CAST(strftime('%Y', dt) AS INTEGER),
                        CAST(strftime('%m', dt) AS INTEGER)),
                    '+1 month', '-1 day')) AS INTEGER))))
    = '{"date_start":"2100-05-01T00:00:00","date_end":"2100-05-31T23:59:59"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_INTERVAL_REL(event, 'day') -> desc_suffix=NULL, desc_prefix='day'
-- START_OF_DT(event, 'day')='2100-05-17 00:00:00'
-- END_OF_DT(event, 'day')='2100-05-17 23:59:59'
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-%02d 00:00:00',
                CAST(strftime('%Y', dt) AS INTEGER),
                CAST(strftime('%m', dt) AS INTEGER),
                CAST(strftime('%d', dt) AS INTEGER))),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-%02d 23:59:59',
                CAST(strftime('%Y', dt) AS INTEGER),
                CAST(strftime('%m', dt) AS INTEGER),
                CAST(strftime('%d', dt) AS INTEGER))))
    = '{"date_start":"2100-05-17T00:00:00","date_end":"2100-05-17T23:59:59"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_INTERVAL_REL(event, 'within +1 year')
-- desc_prefix='within', desc_suffix='+1 year'
-- within_prefix=+1, within_suffix='year'
-- start=event, end=datetime(event, '+1 years')
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', dt),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S', datetime(dt, '+1 years')))
    = '{"date_start":"2100-05-17T12:53:00","date_end":"2101-05-17T12:53:00"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_INTERVAL_REL(event, 'within +2 month')
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', dt),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S', datetime(dt, '+2 months')))
    = '{"date_start":"2100-05-17T12:53:00","date_end":"2100-07-17T12:53:00"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_INTERVAL_REL(event, 'within +3 day')
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', dt),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S', datetime(dt, '+3 days')))
    = '{"date_start":"2100-05-17T12:53:00","date_end":"2100-05-20T12:53:00"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_INTERVAL_REL(event, 'within -1 year')
-- offset=-1 < 0: start=datetime(event, '-1 years'), end=event
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', datetime(dt, '-1 years')),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S', dt))
    = '{"date_start":"2099-05-17T12:53:00","date_end":"2100-05-17T12:53:00"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_INTERVAL_REL(event, 'within -2 month')
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', datetime(dt, '-2 months')),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S', dt))
    = '{"date_start":"2100-03-17T12:53:00","date_end":"2100-05-17T12:53:00"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_INTERVAL_REL(event, 'within -3 day')
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', datetime(dt, '-3 days')),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S', dt))
    = '{"date_start":"2100-05-14T12:53:00","date_end":"2100-05-17T12:53:00"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_POINT_START_OF_YMD(2020, 02, 03) -> TIME_POINT(START_OF_YMD(2020,2,3))
-- START_OF_YMD(2020,2,3) = '2020-02-03 00:00:00'
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', '2020-02-03 00:00:00'),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S', '2020-02-03 00:00:00'))
    = '{"date_start":"2020-02-03T00:00:00","date_end":"2020-02-03T00:00:00"}'
    THEN 'OK' ELSE 'FAILED' END AS r

UNION ALL

-- TIME_POINT_START_OF_YMD(2020, 2, NULL) -> START_OF_YMD(2020,2,NULL) = '2020-02-01 00:00:00'
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', '2020-02-01 00:00:00'),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S', '2020-02-01 00:00:00'))
    = '{"date_start":"2020-02-01T00:00:00","date_end":"2020-02-01T00:00:00"}'
    THEN 'OK' ELSE 'FAILED' END AS r

UNION ALL

-- TIME_POINT_START_OF_YMD(2020, NULL, NULL) -> START_OF_YMD(2020,NULL,NULL) = '2020-01-01 00:00:00'
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', '2020-01-01 00:00:00'),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S', '2020-01-01 00:00:00'))
    = '{"date_start":"2020-01-01T00:00:00","date_end":"2020-01-01T00:00:00"}'
    THEN 'OK' ELSE 'FAILED' END AS r

UNION ALL

-- TIME_POINT_START_OF_YMD(2020, NULL, 3) -> START_OF_YMD(2020,NULL,3) = '2020-01-03 00:00:00'
SELECT CASE WHEN -- TODO: should support?
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S', '2020-01-03 00:00:00'),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S', '2020-01-03 00:00:00'))
    = '{"date_start":"2020-01-03T00:00:00","date_end":"2020-01-03T00:00:00"}'
    THEN 'OK' ELSE 'FAILED' END AS r

UNION ALL

-- TIME_POINT_REL(event, 'start-of year')
-- desc_prefix='start-of', desc_suffix='year'
-- START_OF_DT(event, 'year') = '2100-01-01 00:00:00'
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-01-01 00:00:00', CAST(strftime('%Y', dt) AS INTEGER))),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-01-01 00:00:00', CAST(strftime('%Y', dt) AS INTEGER))))
    = '{"date_start":"2100-01-01T00:00:00","date_end":"2100-01-01T00:00:00"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_POINT_REL(event, 'start-of month')
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-01 00:00:00',
                CAST(strftime('%Y', dt) AS INTEGER),
                CAST(strftime('%m', dt) AS INTEGER))),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-01 00:00:00',
                CAST(strftime('%Y', dt) AS INTEGER),
                CAST(strftime('%m', dt) AS INTEGER))))
    = '{"date_start":"2100-05-01T00:00:00","date_end":"2100-05-01T00:00:00"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_POINT_REL(event, 'start-of day')
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-%02d 00:00:00',
                CAST(strftime('%Y', dt) AS INTEGER),
                CAST(strftime('%m', dt) AS INTEGER),
                CAST(strftime('%d', dt) AS INTEGER))),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-%02d 00:00:00',
                CAST(strftime('%Y', dt) AS INTEGER),
                CAST(strftime('%m', dt) AS INTEGER),
                CAST(strftime('%d', dt) AS INTEGER))))
    = '{"date_start":"2100-05-17T00:00:00","date_end":"2100-05-17T00:00:00"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_POINT_REL(event, 'end-of year')
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-12-31 23:59:59', CAST(strftime('%Y', dt) AS INTEGER))),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-12-31 23:59:59', CAST(strftime('%Y', dt) AS INTEGER))))
    = '{"date_start":"2100-12-31T23:59:59","date_end":"2100-12-31T23:59:59"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_POINT_REL(event, 'end-of month')
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-%02d 23:59:59',
                CAST(strftime('%Y', dt) AS INTEGER),
                CAST(strftime('%m', dt) AS INTEGER),
                CAST(strftime('%d', date(
                    printf('%04d-%02d-01',
                        CAST(strftime('%Y', dt) AS INTEGER),
                        CAST(strftime('%m', dt) AS INTEGER)),
                    '+1 month', '-1 day')) AS INTEGER))),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-%02d 23:59:59',
                CAST(strftime('%Y', dt) AS INTEGER),
                CAST(strftime('%m', dt) AS INTEGER),
                CAST(strftime('%d', date(
                    printf('%04d-%02d-01',
                        CAST(strftime('%Y', dt) AS INTEGER),
                        CAST(strftime('%m', dt) AS INTEGER)),
                    '+1 month', '-1 day')) AS INTEGER))))
    = '{"date_start":"2100-05-31T23:59:59","date_end":"2100-05-31T23:59:59"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_POINT_REL(event, 'end-of day')
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-%02d 23:59:59',
                CAST(strftime('%Y', dt) AS INTEGER),
                CAST(strftime('%m', dt) AS INTEGER),
                CAST(strftime('%d', dt) AS INTEGER))),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-%02d 23:59:59',
                CAST(strftime('%Y', dt) AS INTEGER),
                CAST(strftime('%m', dt) AS INTEGER),
                CAST(strftime('%d', dt) AS INTEGER))))
    = '{"date_start":"2100-05-17T23:59:59","date_end":"2100-05-17T23:59:59"}'
    THEN 'OK' ELSE 'FAILED' END AS r
FROM event

UNION ALL

-- TIME_POINT_YMDHMS(2005, 03, 02, 22, 23, 57)
SELECT CASE WHEN
    json_object(
        'date_start', strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-%02d %02d:%02d:%02d', 2005, 3, 2, 22, 23, 57)),
        'date_end',   strftime('%Y-%m-%dT%H:%M:%S',
            printf('%04d-%02d-%02d %02d:%02d:%02d', 2005, 3, 2, 22, 23, 57)))
    = '{"date_start":"2005-03-02T22:23:57","date_end":"2005-03-02T22:23:57"}'
    THEN 'OK' ELSE 'FAILED' END AS r

UNION ALL

-- JULIAN_DAY_DIFF('2100-07-11 13:26:17', '2100-12-31 23:59:00')
-- T-SQL: STR(dbo.JULIAN_DAY_DIFF(...), 14, 10) = '173.4395833000'
-- SQLite: printf('%14.10f', ROUND((julianday(to) - julianday(from)) * 24 * 60, 0) / (24.0 * 60))
-- Note: SQLite produces '  173.4395833333' due to higher precision than T-SQL float
SELECT CASE WHEN
    printf('%14.10f',
        ROUND((julianday('2100-12-31 23:59:00') - julianday('2100-07-11 13:26:17')) * 24 * 60, 0) / (24.0 * 60))
    = '173.4395833333'
    THEN 'OK' ELSE 'FAILED' END AS r

) AS rs;


----------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                               Relation operators tests:
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- WITH event AS (SELECT '2100-05-17 12:53:00' AS dt)

-- SELECT charttime
-- FROM diagnoses_icd
-- WHERE CASE WHEN charttime >= json_extract(interval_json, '$.date_start')
--             AND charttime <= json_extract(interval_json, '$.date_end')
--            THEN 1 ELSE 0 END = 1

-- SELECT charttime
-- FROM diagnoses_icd
-- WHERE CASE WHEN charttime <= json_extract(interval_json, '$.date_start')
--            THEN 1 ELSE 0 END = 1

-- SELECT charttime
-- FROM diagnoses_icd
-- WHERE CASE WHEN json_extract(interval_json, '$.date_end') <= charttime
--            THEN 1 ELSE 0 END = 1
--------------------------------------------------------------------------------
