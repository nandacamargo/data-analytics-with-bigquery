-- If occurrence range was not related to the number of occurrences, 
-- but instead the index in which that character appears, this could be
-- a possible solution to check if we can find the character in datafield

with base_table AS (
  SELECT *,
      regexp_extract(occurrence_range, r'\d+') as first_digit,
      regexp_extract(occurrence_range, r'-(\d+)') as last_digit,
  FROM `jrjames83-1171.sampledata.aoc2017day2` 
),

find_occur_table AS (
  SELECT *,
     regexp_instr(datafield, character, cast(first_digit as int64)) as find_occur
  FROM base_table
)

SELECT * , 
  CASE WHEN find_occur <= CAST(last_digit as int64)
  THEN "found"
  ELSE "not found"
  END as occur_found
FROM find_occur_table


-- Find the registers whose character number of occurrences inside datafield
-- is in occurrence range
with base_table AS (
  SELECT *,
      regexp_extract(occurrence_range, r'\d+') as low,
      regexp_extract(occurrence_range, r'-(\d+)') as high,
      array_length(regexp_extract_all(datafield, character)) as nbr_matching_chars,
  FROM `jrjames83-1171.sampledata.aoc2017day2` 
),

matching_chars AS (
    SELECT *, 
    nbr_matching_chars BETWEEN cast(low as INT64) AND cast(high as INT64) as result
    FROM base_table
)

SELECT * 
FROM matching_chars
WHERE result is true

-- OR

WITH base_table AS (
  SELECT t.*, 
  "record-" || ROW_NUMBER() OVER () as row_index,
    split(t.datafield, "") as elements
  FROM `jrjames83-1171.sampledata.aoc2017day2` t
),

filter_equal_chars AS (
  SELECT * EXCEPT(elements)
  FROM base_table, UNNEST(elements) element
  WHERE character = element
),

extract_indexes AS (
  SELECT row_index, 
        split(occurrence_range,"-")[0] as low_index, 
        split(occurrence_range, "-")[1] as high_index,
        character,
        count(*) as nbr_found_chars,
  FROM filter_equal_chars
  GROUP BY 1, 2, 3, 4

)

SELECT *,
FROM extract_indexes
WHERE nbr_found_chars BETWEEN CAST(low_index AS INT64) and CAST(high_index AS INT64)

