-- Get the first and the last characters and check if it coincides
-- with the given character. It has to coincide with only one of them
-- If matches both or neither, it is not valid; else, it is valid

with base_table AS (
  SELECT t.*, 
  "record-" || ROW_NUMBER() OVER () as row_index,
    split(t.datafield, "")[0] as first_element,
    split(reverse(t.datafield), "")[0] as last_element
  FROM `jrjames83-1171.sampledata.aoc2017day2` t
),
check_first_last_chars AS(
  SELECT *,
    CASE WHEN first_element = character and last_element = character 
    THEN false
    WHEN first_element <> character and last_element <> character 
    THEN false
    ELSE true
    END as valid
  FROM base_table
)

SELECT count(*)
FROM check_first_last_chars
WHERE valid is true



-- Get the character at low and at high positions; then check if it coincides
-- with the given character. It has to coincide with only one of them.
-- If matches both or neither, it is not valid; else, it is valid

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
),
checking_characters AS (
  SELECT *,
    CASE 
        WHEN low_char = character and high_char = character 
        THEN false
        WHEN low_char <> character and high_char <> character 
        THEN false
        ELSE true
    END as valid
  FROM getting_high_and_low
)

SELECT COUNT(*) FROM checking_characters WHERE valid

