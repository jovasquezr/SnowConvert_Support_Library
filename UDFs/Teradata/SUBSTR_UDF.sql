-- <copyright file="SUBSTR_UDF.sql" company="Mobilize.Net">
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

-- =============================================
-- DESCRIPTION: EXTRACTS A SUBSTRING FROM A NAMED STRING BASED ON POSITION.
-- PARAMETERS:
-- BASE_EXPRESSION: STRING - THE EXPRESSION FROM WHICH THE SUBSTRING IS TO BE EXTRACTED
-- START_POSITION: FLOAT - THE STARTING POSITION OF THE SUBSTRING TO EXTRACT FROM
-- LENGTH (Optional): FLOAT - THE STARTING POSITION OF THE SUBSTRING TO EXTRACT FROM
-- RETURNS: THE SUBSTRING REQUIRED
-- EXAMPLE:
--    SELECT PUBLIC.SUBSTR_UDF('ABC', -1, 1),
--    PUBLIC.SUBSTR_UDF('ABC', -1, 2),
--    PUBLIC.SUBSTR_UDF('ABC', -1, 3),
--    PUBLIC.SUBSTR_UDF('ABC', 0, 1),
--    PUBLIC.SUBSTR_UDF('ABC', 0, 2);
-- RETURNS '','','A','','A'
--
-- EQUIVALENT: TERADATA'S SUBSTR FUNCTIONALITY
-- EXAMPLE:
--    SELECT SUBSTR('ABC',-1,1), 
--    SUBSTR('ABC',-1,2),
--    SUBSTR('ABC',-1,3),
--    SUBSTR('ABC',0,1),
--    SUBSTR('ABC',0,2);
-- RETURNS '','','A','','A'
-- =============================================

CREATE OR REPLACE FUNCTION PUBLIC.SUBSTR_UDF(BASE_EXPRESSION STRING, START_POSITION FLOAT, LENGTH FLOAT)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS
$$
  if (START_POSITION > 0) {
      return BASE_EXPRESSION.substr(START_POSITION -1, LENGTH);
  } else if (START_POSITION == 0 ) {
      return BASE_EXPRESSION.substr(START_POSITION, LENGTH - 1);
  } else {
      return BASE_EXPRESSION.substr(0, LENGTH + START_POSITION - 1);
  }
$$
;

CREATE OR REPLACE FUNCTION PUBLIC.SUBSTR_UDF(BASE_EXPRESSION STRING, START_POSITION FLOAT)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS
$$
  return START_POSITION > 0 ? BASE_EXPRESSION.substr(START_POSITION - 1) : BASE_EXPRESSION.substr(0);
$$
;
