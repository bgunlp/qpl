use mimic_iv;

----------------------------------------------------------------------------------------------
--                                      Public  
----------------------------------------------------------------------------------------------

---------------------------------- Relation operators: ---------------------------------------

IF OBJECT_ID (N'dbo.MEETS', N'FN') IS NOT NULL
    DROP FUNCTION MEETS;
GO -- not tested
CREATE FUNCTION dbo.MEETS(@event datetime, @interval NVARCHAR(MAX))
RETURNS int 
AS
BEGIN
	DECLARE @start datetime = JSON_VALUE(@interval, '$.date_start');  -- TODO: use wrapper function to fetch json values
	IF  @event <= @start
		RETURN 1;
    RETURN 0;
END
GO


IF OBJECT_ID (N'dbo.MET_BY', N'FN') IS NOT NULL
    DROP FUNCTION MET_BY;
GO -- not tested
CREATE FUNCTION dbo.MET_BY(@event datetime, @interval NVARCHAR(MAX))
RETURNS int 
AS
BEGIN
	DECLARE @end datetime = JSON_VALUE(@interval, '$.date_end');  -- TODO: use wrapper function to fetch json values
	IF  @end <= @event
		RETURN 1;
    RETURN 0;
END
GO


IF OBJECT_ID (N'dbo.DURING', N'FN') IS NOT NULL
    DROP FUNCTION DURING;
GO -- not tested
CREATE FUNCTION dbo.DURING(@event datetime, @interval NVARCHAR(MAX))
RETURNS int 
AS
BEGIN
	DECLARE @start datetime = JSON_VALUE(@interval, '$.date_start');  -- TODO: use wrapper function to fetch json values
	DECLARE @end   datetime = JSON_VALUE(@interval, '$.date_end');  -- TODO: use wrapper function to fetch json values
	IF (@event >= @start AND @event <= @end) 
		RETURN 1;
    RETURN 0;
END
GO

------------------------------------ Time intervals: -----------------------------------------

IF OBJECT_ID (N'dbo.TIME_POINT_START_OF_YMD', N'FN') IS NOT NULL
    DROP FUNCTION dbo.TIME_POINT_START_OF_YMD;
GO 
CREATE FUNCTION dbo.TIME_POINT_START_OF_YMD(@year int, @month int, @day int)
RETURNS NVARCHAR(MAX) 
AS
BEGIN
    RETURN dbo.TIME_POINT(dbo.START_OF_YMD(@year, @month, @day))
END
GO


IF OBJECT_ID (N'dbo.TIME_POINT_YMDHMS', N'FN') IS NOT NULL
    DROP FUNCTION dbo.TIME_POINT_YMDHMS;
GO 
CREATE FUNCTION dbo.TIME_POINT_YMDHMS(@year int, @month int, @day int, @hour int, @min int, @sec int)    
RETURNS NVARCHAR(MAX) 
AS
BEGIN
    RETURN dbo.TIME_POINT(dbo.START_OF_YMDHMS(@year, @month, @day, @hour, @min, @sec))
END
GO


IF OBJECT_ID (N'dbo.TIME_POINT_REL', N'FN') IS NOT NULL
    DROP FUNCTION dbo.TIME_POINT_REL;
GO 
CREATE FUNCTION dbo.TIME_POINT_REL(@datetime datetime, @description varchar(20))
RETURNS NVARCHAR(MAX) 
AS
BEGIN
	-- TODO: check: @desc_prefix is 'start-of/end-of', @desc_suffix is 'year/month/day'
	DECLARE @desc_prefix varchar(10) = dbo.GET_PREFIX(@description);
	DECLARE @desc_suffix varchar(10) = dbo.GET_SUFFIX(@description);  

	SET @datetime = dbo.END_OF_DT(@datetime, @desc_suffix)
	IF @desc_prefix = 'start-of'
		SET @datetime = dbo.START_OF_DT(@datetime, @desc_suffix)

    RETURN dbo.TIME_POINT(@datetime)
END
GO


IF OBJECT_ID (N'dbo.TIME_INTERVAL_YMD', N'FN') IS NOT NULL
    DROP FUNCTION dbo.TIME_INTERVAL_YMD;
GO 
CREATE FUNCTION dbo.TIME_INTERVAL_YMD(@year int, @month int, @day int)
RETURNS NVARCHAR(MAX) -- TODO: check @year not NULL
AS
BEGIN
	DECLARE @desc varchar(20) = 'year'; 
	IF @month is not NULL
		SET @desc = 'month'; 
	IF @day is not NULL
		SET @desc = 'day'; 
    RETURN dbo.TIME_INTERVAL_REL(dbo.START_OF_YMD(@year, @month, @day), @desc)
END
GO


IF OBJECT_ID (N'dbo.TIME_INTERVAL_REL', N'FN') IS NOT NULL
    DROP FUNCTION dbo.TIME_INTERVAL_REL;
GO 
CREATE FUNCTION dbo.TIME_INTERVAL_REL(@datetime datetime, @description varchar(20))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @start datetime = NULL;   
	DECLARE @end datetime = NULL;
	DECLARE @desc_prefix varchar(10) = dbo.GET_PREFIX(@description); 
	DECLARE @desc_suffix varchar(10) = dbo.GET_SUFFIX(@description);

	IF @desc_suffix is NULL -- @description='[year/month/day]'
		BEGIN              --               ^@desc_prefix
			SET @start = dbo.START_OF_DT(@datetime, @desc_prefix); 
		    SET @end = dbo.END_OF_DT(@datetime, @desc_prefix);
		END     
	ELSE 
	IF @desc_prefix = 'within'  -- @description = 'within [+/-]<num> [year/month/day]' 
		BEGIN                   --                         ^@desc_suffix
			DECLARE @within_prefix varchar(10) = CAST(dbo.GET_PREFIX(@desc_suffix) AS int);  -- @within_prefix=[+/-]<num> 
			DECLARE @within_suffix varchar(10) = dbo.GET_SUFFIX(@desc_suffix);               -- @within_suffix=[year/month/day]

			SET @start = @datetime;  -- @within_prefix=+<num>
		    SET @end = dbo.DATE_ADD(@datetime, @within_prefix, @within_suffix);

			IF @within_prefix < 0  
				BEGIN -- @within_prefix=-<num>
					SET @start = @end
					SET @end = @datetime
				END
		END -- TODO: error if @desc_prefix is not '[year/month/day]' or 'within'
		
    RETURN dbo.TIME_INTERVAL(@start, @end)
END
GO


IF OBJECT_ID (N'dbo.TIME_POINT', N'FN') IS NOT NULL
    DROP FUNCTION dbo.TIME_POINT;
GO 
CREATE FUNCTION dbo.TIME_POINT(@datetime datetime)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN dbo.TIME_INTERVAL(@datetime, @datetime)
END
GO


IF OBJECT_ID (N'dbo.TIME_INTERVAL', N'FN') IS NOT NULL
    DROP FUNCTION dbo.TIME_INTERVAL;
GO
CREATE FUNCTION dbo.TIME_INTERVAL(@datetime_start datetime, @datetime_end datetime)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @json NVARCHAR(MAX)
    SET @json = (
        SELECT 
            @datetime_start as date_start,
            @datetime_end as date_end
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    )
    RETURN @json 
END
GO

------------------------------------ Aux: -----------------------------------------
-- ...

----------------------------------------------------------------------------------------------
--                                      Private utility methods:  
----------------------------------------------------------------------------------------------

IF OBJECT_ID (N'dbo.DATE_ADD', N'FN') IS NOT NULL
    DROP FUNCTION dbo.DATE_ADD;
GO  
CREATE FUNCTION dbo.DATE_ADD(@date datetime, @offset int, @datepart varchar(20))
RETURNS datetime
AS
BEGIN
    IF @datepart = 'year'
		RETURN DATEADD(YEAR, @offset, @date);

	IF @datepart = 'month'
		RETURN DATEADD(MONTH, @offset, @date);

	IF @datepart != 'day'
		RETURN cast(CONCAT('ERROR during DATE_ADD: unknown datepart: [', @datepart, ']') as int);

	RETURN DATEADD(DAY, @offset, @date);
END
GO



IF OBJECT_ID (N'dbo.GET_PREFIX', N'FN') IS NOT NULL
    DROP FUNCTION dbo.GET_PREFIX;
GO  
CREATE FUNCTION dbo.GET_PREFIX(@str varchar(MAX))
RETURNS varchar(MAX)
AS 
BEGIN  
	IF CHARINDEX(' ', @str) != 0
		RETURN SUBSTRING(@str, 1, CHARINDEX(' ', @str) - 1);
	RETURN @str
END
GO


IF OBJECT_ID (N'dbo.GET_SUFFIX', N'FN') IS NOT NULL
    DROP FUNCTION dbo.GET_SUFFIX;
GO  
CREATE FUNCTION dbo.GET_SUFFIX(@str varchar(MAX))
RETURNS varchar(MAX)
AS 
BEGIN
	IF CHARINDEX(' ', @str) != 0
		RETURN LTRIM(SUBSTRING(@str, CHARINDEX(' ', @str), LEN(@str)))
	RETURN NULL
END
GO



IF OBJECT_ID (N'dbo.START_OF_DT', N'FN') IS NOT NULL
    DROP FUNCTION dbo.START_OF_DT;
GO  
CREATE FUNCTION dbo.START_OF_DT(@date datetime, @datepart varchar(20))
RETURNS datetime
AS 
BEGIN
    IF @datepart = 'year'
		RETURN dbo.START_OF_YMD(YEAR(@date), NULL, NULL)

	IF @datepart = 'month'
		RETURN dbo.START_OF_YMD(YEAR(@date), MONTH(@date), NULL)

	IF @datepart = 'day'
		RETURN dbo.START_OF_YMD(YEAR(@date), MONTH(@date), DAY(@date))

	RETURN cast(CONCAT('ERROR during START_OF_DT: unknown datepart: [', @datepart, ']') as int);
END
GO


IF OBJECT_ID (N'dbo.END_OF_DT', N'FN') IS NOT NULL
    DROP FUNCTION dbo.END_OF_DT;
GO 
CREATE FUNCTION dbo.END_OF_DT(@date datetime, @datepart varchar(20))
RETURNS datetime
AS 
BEGIN
    IF @datepart = 'year'
		RETURN dbo.END_OF_YMD(YEAR(@date), NULL, NULL)


	IF @datepart = 'month'
		RETURN dbo.END_OF_YMD(YEAR(@date), MONTH(@date), NULL)

	IF @datepart = 'day'
		RETURN dbo.END_OF_YMD(YEAR(@date), MONTH(@date), DAY(@date))

	RETURN cast(CONCAT('ERROR during END_OF_DT: unknown datepart: [', @datepart, ']') as int);
END
GO



-- [!!!]
IF OBJECT_ID (N'dbo.START_OF_YMD', N'FN') IS NOT NULL
    DROP FUNCTION dbo.START_OF_YMD;
GO 
CREATE FUNCTION dbo.START_OF_YMD(@year int, @month int, @day int)
RETURNS datetime 
AS 
BEGIN
	RETURN dbo.START_OF_YMDHMS(@year, @month, @day, NULL, NULL, NULL);   
END
GO


IF OBJECT_ID (N'dbo.START_OF_YMDHMS', N'FN') IS NOT NULL
    DROP FUNCTION dbo.START_OF_YMDHMS;
GO 
CREATE FUNCTION dbo.START_OF_YMDHMS(@year int, @month int, @day int, @hour int, @min int, @sec int)
RETURNS datetime 
AS 
BEGIN
	IF @year IS NULL
		RETURN cast('ERROR during START_OF_YMDHMS: @year is null' as int); 

	IF @month IS NULL
		SET @month = 1;

	IF @day IS NULL
		SET @day = 1;

	IF @hour IS NULL
		SET @hour = 0;

	IF @min IS NULL
		SET @min = 0;

	IF @sec IS NULL
		SET @sec = 0;

	RETURN DATETIMEFROMPARTS (@year, @month, @day, @hour, @min, @sec, 0); 
END
GO
-------------------------------------------------------------------------


IF OBJECT_ID (N'dbo.END_OF_YMD', N'FN') IS NOT NULL
    DROP FUNCTION dbo.END_OF_YMD;
GO 
CREATE FUNCTION dbo.END_OF_YMD(@year int, @month int, @day int)
RETURNS datetime 
AS 
BEGIN
	IF @year IS NULL
		RETURN cast('ERROR during END_OF_YMD: @year is null' as int);

	IF @month IS NULL
		SET @month = 12;

	IF @day IS NULL
		BEGIN
			SET @day = DAY(EOMONTH(dbo.START_OF_YMD(@year, @month, NULL)));
		END

	RETURN DATETIMEFROMPARTS (@year, @month, @day, 23, 59, 59, 0);  -- MS: 0 <--> 999
END
GO


----------------------------------------------------------------------------------------------
--   For value comparison between SQLite and T-SQL,
--
--   specifically to replicate the behavior of SQLite's:
--			strftime('%J', datetime_to) - strftime('%J', datetime_from)
--
--   (see also ehrsql_to_tsql_execution_plans.py --> 
--            func_name_translate, date_diff_tests+date_diff_replacer, finalize_translation, tsql_modify_for_translation_validation)
----------------------------------------------------------------------------------------------
IF OBJECT_ID (N'dbo.JULIAN_DAY_DIFF', N'FN') IS NOT NULL
    DROP FUNCTION dbo.JULIAN_DAY_DIFF;
GO 
CREATE FUNCTION dbo.JULIAN_DAY_DIFF(@dt_from datetime, @dt_to datetime)
RETURNS float 
AS 
BEGIN
	-- RETURN DATEDIFF(SECOND , @dt_from, @dt_to) / (24.0 * 60 * 60)  
	RETURN DATEDIFF(MINUTE , @dt_from, @dt_to) / (24.0 * 60)  
END
GO


----------------------------------------------------------------------------------------------
--                              Unused/obsolete:  
----------------------------------------------------------------------------------------------
-- [!!!] name
IF OBJECT_ID (N'dbo.OVERRIDE_DT', N'FN') IS NOT NULL
    DROP FUNCTION dbo.OVERRIDE_DT;
GO 
CREATE FUNCTION dbo.OVERRIDE_DT(@date datetime, @year int, @month int, @day int)
RETURNS datetime 
AS 
BEGIN
	IF @year IS NULL
		SET @year = YEAR(@date);
	
	IF @month IS NULL
		SET @month = MONTH(@date);

	IF @day IS NULL
		SET @day = DAY(@date);

	DECLARE @hours int = DATEPART(hour, @date);
	DECLARE @minutes int = DATEPART(minute, @date);
	DECLARE @seconds int = DATEPART(second, @date);

	RETURN DATETIMEFROMPARTS (@year, @month, @day, @hours, @minutes, @seconds, 0);  -- milliseconds always = 0
END
GO

