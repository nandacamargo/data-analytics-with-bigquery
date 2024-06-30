-- Here, we use a JS UDF instead of using the CASE WHEN,
-- just to practice a little bit

CREATE TEMP FUNCTION chooseIfValid(
                          low_char STRING, 
                          high_char STRING, 
                          target_char STRING)
RETURNS BOOL
LANGUAGE js AS """
  if (low_char == target_char && high_char == target_char) {
    return false;
  }    
  else if (low_char != target_char && high_char != target_char) {
    return false;
  }    
  else {
    return true;
  } 
""";

WITH base_table AS (
  SELECT *,
      regexp_extract(occurrence_range, r'\d+') as low,
      regexp_extract(occurrence_range, r'-(\d+)') as high
  FROM `jrjames83-1171.sampledata.aoc2017day2` 
),

getting_high_and_low AS (
  SELECT *, 
      SUBSTR(datafield,CAST(low AS INT64),1) as low_char, 
      SUBSTR(datafield,CAST(high AS INT64),1) as high_char
  FROM base_table
)

SELECT * 
FROM (SELECT *, chooseIfValid(low_char, high_char, character) as valid 
      FROM getting_high_and_low)
WHERE valid

