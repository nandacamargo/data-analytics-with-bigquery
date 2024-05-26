-- Revenue Trends
-- We need to know the revenue by time of day: morning (from 6 until 11AM), 
-- afternoon (12 to 16PM), evening (17 to 22PM) and late evening (from 23 until 5AM)

WITH base_table AS (
    SELECT EXTRACT(hour from o.order_purchase_timestamp) as hour, 
           ROUND(SUM(op.payment_value), 2) as sales
    FROM `jrjames83-1171.sampledata.orders` o
    JOIN `jrjames83-1171.sampledata.order_payments` op
        ON o.order_id = op.order_id
    GROUP BY 1
    ORDER BY 1
)

SELECT 
    CASE 
        WHEN hour in (6, 7, 8, 9, 10, 11) THEN "morning"
        WHEN hour in (12, 13, 14, 15, 16) THEN "afternoon"
        WHEN hour in (17, 18, 19, 20, 21, 22) THEN "evening"
        WHEN hour between 0 and 5 or hour = 23  THEN "overnight"
    END as period,
    sum(sales) as sales
FROM base_table
GROUP BY 1
ORDER BY 1
