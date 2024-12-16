-- Calculate a three-day moving average
WITH base_table AS (
    SELECT dollars, index
    FROM UNNEST(generate_array(1, 10, 2)) dollars WITH OFFSET as index
)

SELECT *, 
    AVG(dollars) OVER(ORDER BY index ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) three_day_ma,
FROM base_table;


-- Does dollars always increase?
WITH base_table2 AS (
    SELECT dollars, index
    FROM UNNEST(generate_array(1, 10, 2)) dollars WITH OFFSET as index
)

SELECT dollars, index, 
    CASE WHEN dollars > previous_dollar_qtty THEN "YES"
        WHEN dollars <= previous_dollar_qtty THEN "NO"
        ELSE "FIRST RECORD"
    END dollars_always_increase
FROM (
    SELECT dollars, index,
        LAG(dollars) OVER(ORDER BY index) as previous_dollar_qtty
    FROM base_table2
)