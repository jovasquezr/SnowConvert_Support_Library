-- <copyright file="DATETIME_FUNCTIONS_UDF.cs" company="Mobilize.Net">
--        Copyright (C) Mobilize.Net info@mobilize.net - All Rights Reserved
-- 
--        This file is part of the Mobilize Frameworks, which is
--        proprietary and confidential.
-- 
--        NOTICE:  All information contained herein is, and remains
--        the property of Mobilize.Net Corporation.
--        The intellectual and technical concepts contained herein are
--        proprietary to Mobilize.Net Corporation and may be covered
--        by U.S. Patents, and are protected by trade secret or copyright law.
--        Dissemination of this information or reproduction of this material
--        is strictly forbidden unless prior written permission is obtained
--        from Mobilize.Net Corporation.
-- </copyright>

-- ======================================================================
-- IT CONVERTS BOTH INPUTS TO THE SYSTEM OR SESSION TIMEZONE AND 
-- SUBTRACTS THE DATES (FIRST_DATE - SECOND_DATE) TAKING 1900-01-01 00:00:00.000 AS THE ZERO VALUE. 
-- PARAMETERS:
--     INPUT: TWO TIMESTAMP_TZ VALUES THE FIRST_DATE IS THE MINUEND, AND SECOND_DATE IS THE SUBTRAHEND. IF SOME VALUE DOES NOT INCLUDE TIMEZONE, THE CURRENT SESSION TIMEZONE IS USED
-- RETURNS THE DIFFERENCE BETWEEN THE TWO INPUT DATES
-- EQUIVALENT:
--     TRANSACT DIFFERENCE BETWEEN DATETIMES
-- EXAMPLE:
--     ALTER SESSION SET TIMEZONE = 'Europe/London'
--     SELECT SUBTRACT_TIMESTAMP_TZ_UDF('1900-01-01 00:00:00.000 +0100', '1900-01-01 00:00:00.003 -0100')
--     RETURNS 1899-12-31 21:59:59.997 +0000
-- ======================================================================

CREATE OR REPLACE FUNCTION PUBLIC.SUBTRACT_TIMESTAMP_TZ_UDF(FIRST_DATE TIMESTAMP_TZ, SECOND_DATE TIMESTAMP_TZ)
RETURNS TIMESTAMP_TZ
LANGUAGE SQL
AS
$$ 
PUBLIC.ROUND_MILISECONDS_UDF(CONVERT_TIMEZONE(PUBLIC.GET_CURRENT_TIMEZONE_UDF(),
            TIMEADD( ms, -TIMEDIFF( ms, time_from_parts(0, 0, 0), CONVERT_TIMEZONE('UTC', SECOND_DATE) :: time), 
            TIMEADD(day, -DATEDIFF(day, DATE_FROM_PARTS(1900, 1, 1), CONVERT_TIMEZONE('UTC', SECOND_DATE)), CONVERT_TIMEZONE('UTC', FIRST_DATE)))
            ))
$$;

-- ======================================================================
-- IT CONVERTS BOTH INPUTS TO THE SYSTEM OR SESSION TIMEZONE AND 
-- SUM THE DATES TAKING 1900-01-01 00:00:00.000 AS THE ZERO VALUE. 
-- PARAMETERS:
--     INPUT: TWO TIMESTAMP_TZ, IF SOME VALUE DOES NOT INCLUDE TIMEZONE, THE CURRENT SESSION TIMEZONE IS USED
-- RETURNS THE SUM BETWEEN THE TWO INPUT DATES
-- EQUIVALENT:
--     TRANSACT SUM BETWEEN DATETIMES
-- EXAMPLE:
--     ALTER SESSION SET TIMEZONE = 'Europe/London'
--     SELECT SUM_TIMESTAMP_TZ_UDF('1900-01-01 00:00:00.000 +0100', '1900-01-01 00:00:00.003 -0100')
--     RETURNS 1900-01-01 00:00:00.003 +0000
-- ======================================================================

CREATE OR REPLACE FUNCTION PUBLIC.SUM_TIMESTAMP_TZ_UDF(FIRST_DATE TIMESTAMP_TZ, SECOND_DATE TIMESTAMP_TZ)
RETURNS TIMESTAMP_TZ
LANGUAGE SQL
AS
$$ 
PUBLIC.ROUND_MILISECONDS_UDF(CONVERT_TIMEZONE(PUBLIC.GET_CURRENT_TIMEZONE_UDF(),
            TIMEADD( ms, TIMEDIFF( ms, time_from_parts(0, 0, 0), CONVERT_TIMEZONE('UTC', SECOND_DATE) :: time), 
            TIMEADD(day, DATEDIFF(day, DATE_FROM_PARTS(1900, 1, 1), CONVERT_TIMEZONE('UTC', SECOND_DATE)), CONVERT_TIMEZONE('UTC', FIRST_DATE)))
            ))
$$;

-- ======================================================================
-- GETS THE CURRENT SESSION OR SYSTEM TIMEZONE AS A LITERAL
-- RETURNS A LITERAL VALUE
-- EXAMPLE:
--     ALTER SESSION SET TIMEZONE = 'Europe/London'
--     SELECT PUBLIC.GET_CURRENT_TIMEZONE_UDF()
--     RETURNS 'Europe/London'
-- ======================================================================
CREATE OR REPLACE FUNCTION PUBLIC.GET_CURRENT_TIMEZONE_UDF()
RETURNS STRING
LANGUAGE JAVASCRIPT
as
$$
    return Intl.DateTimeFormat().resolvedOptions().timeZone;
$$;

-- ======================================================================
-- FUNCTION TO ROUND THE MILISECONDS TO INCREMENTS OF 0, 3 OR 7 MILISECONDS
-- PARAMETERS:
--     INPUT: TIMESTAMP_TZ
-- RETURNS THE SAME TIMESTAMP_TZ VALUE BUT WITH THE MILISECONDS ROUNDED
-- EQUIVALENT:
--     TRANSACT AUTOMATICALLY ROUNDS THE MILISECONDS OF DATETIME VALUES
-- EXAMPLE:
--     SELECT PUBLIC.ROUND_MILISECONDS_UDF('1900-01-01 00:00:00.995 +0100')
--     RETURNS '1900-01-01 00:00:00.997 +0100'
-- ======================================================================

CREATE OR REPLACE FUNCTION PUBLIC.ROUND_MILISECONDS_UDF(INPUT TIMESTAMP_TZ)
RETURNS TIMESTAMP_TZ
LANGUAGE SQL
IMMUTABLE
AS
$$
TIMEADD(ns, (CASE WHEN EXTRACT(ns FROM INPUT)%10000000 >= 8500000 THEN 10000000
      WHEN EXTRACT(ns FROM INPUT)%10000000 >= 5000000 THEN 7000000
      WHEN EXTRACT(ns FROM INPUT)%10000000 >= 1500000 THEN 3000000
      ELSE 0 END) - EXTRACT(ns FROM INPUT)%10000000, INPUT)
$$;

-- ======================================================================
-- FUNCTION TO CAST TIME TO TIMESTAMP_TZ
-- PARAMETERS:
--     INPUT: TIME
-- RETURNS A TIMESTAMP_TZ WITH DATE AS 1900-01-01 AND THE SAME TIME AS THE INPUT
-- EQUIVALENT:
--     TRANSACT CAST TIME TO DATETIME ADDING 1900-01-01 AS THE DATE PART
-- EXAMPLE:
--     SELECT PUBLIC.CAST_TIME_TO_TIMESTAMP_TZ_UDF('00:00:00.995')
--     RETURNS '1900-01-01 00:00:00.997'
-- ======================================================================
CREATE OR REPLACE FUNCTION PUBLIC.CAST_TIME_TO_TIMESTAMP_TZ_UDF(INPUT TIME)
RETURNS TIMESTAMP_TZ
LANGUAGE SQL
AS
$$
PUBLIC.ROUND_MILISECONDS_UDF(CONVERT_TIMEZONE(PUBLIC.GET_CURRENT_TIMEZONE_UDF(), TIMESTAMP_TZ_FROM_PARTS(1900, 1, 1, HOUR(INPUT), MINUTE(INPUT), SECOND(INPUT), DATE_PART(ns ,INPUT), 'UTC')))
$$; 

-- ======================================================================
-- FUNCTION TO CAST NUMERIC TO TIMESTAMP_TZ
-- PARAMETERS:
--     INPUT: NUMBER
-- RETURNS A TIMESTAMP_TZ WITH CURRENT TIMEZONE
-- EQUIVALENT:
--     TRANSACT CAST NUMERIC FLOAT TO DATETIME
-- EXAMPLE:
--     SELECT PUBLIC.CAST_NUMERIC_TO_TIMESTAMP_TZ_UDF(0)
--     RETURNS '1900-01-01 01:00:00.000 +0100'
-- ======================================================================
CREATE OR REPLACE FUNCTION PUBLIC.CAST_NUMERIC_TO_TIMESTAMP_TZ_UDF(INPUT NUMBER)
RETURNS TIMESTAMP_TZ
LANGUAGE SQL
IMMUTABLE
AS
$$
PUBLIC.ROUND_MILISECONDS_UDF(CONVERT_TIMEZONE(PUBLIC.GET_CURRENT_TIMEZONE_UDF(), TIMESTAMP_TZ_FROM_PARTS( 1900, 1, TRUNC(INPUT)+1,  0, 0, 0, (INPUT%1)*86400000000000, 'UTC')))
$$;  

-- ======================================================================
-- FUNCTION TO CAST TIMESTAMP_TZ TO NUMERIC, IT CONVERT THE CURRENT TIMEZONE TO UTC BECAUSE THE NUMERIC VALUE CANNOT SAVE THE TIMESTAMP INFORMATION
-- PARAMETERS:
--     INPUT: TIMESTAMP_TZ
-- RETURNS A NUMERIC WITH DECIMAL POINTS, THE INTEGER PART REPRESET THE NUMBER OF DAYS FROM 1900-01-01 AND THE DECIMAL PART IS THE PERCENTAGE OF MILISECONDS IN 24 HOURS
-- EQUIVALENT:
--     TRANSACT CAST DATETIME TO FLOAT
-- EXAMPLE:
--     SELECT PUBLIC.CAST_TIMESTAMP_TZ_TO_NUMERIC_UDF('1900-01-01 01:00:00.000 +0100')
--     RETURNS 0
-- ======================================================================
CREATE OR REPLACE FUNCTION PUBLIC.CAST_TIMESTAMP_TZ_TO_NUMERIC_UDF(INPUT TIMESTAMP_TZ)
RETURNS NUMBER
LANGUAGE SQL
IMMUTABLE
AS
$$
DATEDIFF(day, DATE_FROM_PARTS(1900, 1, 1), DATE(CONVERT_TIMEZONE('UTC', INPUT))) + TRUNC(TIMEDIFF(ms, TIME_FROM_PARTS(0,0,0), TIME(CONVERT_TIMEZONE('UTC', INPUT)))::NUMBER(20,8)/86400000, 8)
$$;
