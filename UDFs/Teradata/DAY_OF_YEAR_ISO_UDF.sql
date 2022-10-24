-- <copyright file="DAY_OF_YEAR_ISO_UDF.sql" company="Mobilize.Net">
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
-- RETURNS THE DAY OF THE YEAR A TIMESTAMP BELONGS TO, 
-- HAS THE SAME BEHAVIOR AS THE DAYNUMBER_OF_YEAR(DATE, 'ISO') FUNCTION
-- WITH ISO CALENDAR FROM TERADATA
-- PARAMETERS:
--      INPUT: TIMESTAMP_TZ. DATE TO GET THE DAY OF WEEK FROM
-- RETURNS:
--      AN INTEGER BETWEEN 1 AND 371 
--
-- EXAMPLE:
--  SELECT PUBLIC.DAY_OF_YEAR_ISO_UDF(DATE '2023-01-01'),
--  PUBLIC.DAY_OF_YEAR_ISO_UDF(DATE '2027-01-03');
-- RETURNS 364, 371
--
-- EQUIVALENT: TERADATA'S DAYNUMBER_OF_YEAR FUNCTIONALITY
-- EXAMPLE:
--  SELECT DAYNUMBER_OF_YEAR (DATE '2023-01-01', 'ISO'),
--  DAYNUMBER_OF_YEAR (DATE '2027-01-03', 'ISO');
-- RETURNS 364, 371
-- ======================================================================
CREATE OR REPLACE FUNCTION PUBLIC.DAY_OF_YEAR_ISO_UDF(INPUT TIMESTAMP_TZ)
RETURNS INT
LANGUAGE SQL
IMMUTABLE
AS
$$
(WEEKISO(INPUT) - 1) * 7 + DAYOFWEEKISO(INPUT)
$$;
