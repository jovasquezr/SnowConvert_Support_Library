
# Definition and Usage
 It returns a substring from the given string, starting at the startpos index. SUBSTR_TD_UDF() function is equivalent to Teradata SUBSTR() when the startpos is lower or equal than zero. For all other cases, the internal function of Snowflake SUBSTR() is used.


## Syntax
`SUBSTR_TD_UDF(julian_date)`

## Parameter Values
| Parameter	    | Description |
|---------------|-------------|
| base_exp	| Required. The string to take a substring from.
| startpos	| Required. The start position in base_exp to start the substring.
| length	  | The length of the substring, if not given it will take the substring until the end of base_exp.

## Snowflake Implementation

> Credit goes to Mike Gohl

```sql
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
```
  ## Examples

```sql
SELECT SUBSTR_TD_UDF('ABC',-1,1); 	-- Returns empty string
SELECT SUBSTR_TD_UDF('ABC',-1,2); 	-- Returns empty string
SELECT SUBSTR_TD_UDF('ABC',-1,3); 	-- Returns 'A'
SELECT SUBSTR_TD_UDF('ABC',0,1); 		-- Returns empty string
SELECT SUBSTR_TD_UDF('ABC',0,2); 		-- Returns 'A'
```
# Equivalent
[TERADATA'S SUBSTR FUNCTIONALITY](https://docs.teradata.com/r/kmuOwjp1zEYg98JsB8fu_A/lxOd~YrdVkJGt0_anAEXFQ)

## Examples 
```sql
SELECT SUBSTR('ABC',-1,1);  -- Returns empty string
SELECT SUBSTR('ABC',-1,2);  -- Returns empty string
SELECT SUBSTR('ABC',-1,3);  -- Returns 'A'
SELECT SUBSTR('ABC',0,1);   -- Returns empty string
SELECT SUBSTR('ABC',0,2);   -- Returns 'A'
```
