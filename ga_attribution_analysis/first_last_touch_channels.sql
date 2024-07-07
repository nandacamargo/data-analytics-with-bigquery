-- First and last touch channels
-- Conversions by touch type (first or last)

WITH split_touches AS (
  SELECT path as original_path,
         SPLIT(path, '>')[OFFSET(0)] as first_touch, 
         SPLIT(path, '>') as splitted_paths, 
         conversions
  FROM `jrjames83-1171.sampledata.conversion_paths` 
  WHERE array_length(SPLIT(path, '>')) > 1
),
first_and_last_touches AS (
  SELECT original_path, 
      first_touch, 
      array_reverse(splitted_paths)[offset(0)] as last_touch,
      conversions
  FROM split_touches
),
summary_table AS (
  SELECT original_path,
      touch,
      conversions,
      CASE 
        WHEN index = 0 THEN "first_touch_gt_1"
        WHEN index =  1 THEN "last_touch_gt_1"
      END as touch_type
  FROM first_and_last_touches, UNNEST([first_touch, last_touch]) as touch WITH OFFSET as index
)

SELECT touch, touch_type, sum(conversions) 
FROM summary_table
GROUP BY 1, 2


-- Another similar way of doing it
-- First touch - index = 0
-- Last touch - index = number_in_path - 1

WITH base_table AS (
  SELECT split(path, ">") as path, 
          path as original_path, 
          conversions, 
          revenue 
  FROM `jrjames83-1171.sampledata.conversion_paths` 
  WHERE ARRAY_LENGTH(split(path, ">")) > 1 -- exclude paths consisting of 1 touch
),
indexes_table AS (
  SELECT 
    original_path,
    LOWER(TRIM(path_row)) as row,
    index,
    array_length(path) as number_in_path,
    conversions,
    revenue
  FROM base_table, UNNEST(path) as path_row WITH OFFSET as index
),
summary_table AS (
  SELECT *, 
  CASE 
    WHEN index = 0 THEN "first_touch_path_gt_1" 
    WHEN index = number_in_path - 1 THEN "last_touch_path_gt_1"
    ELSE "middle_touch_path_gt_1" 
  END as touch_type
  FROM indexes_table
)

SELECT row, touch_type, SUM(conversions) as sum_conversions
FROM summary_table
WHERE touch_type <> "middle_touch_path_gt_1"
GROUP BY 1, 2
