
-- Have any customers placed more than 1 order, if we use the 
-- customer_unique_id?
-- 2997

WITH number_of_orders_tables AS (
    SELECT c.customer_unique_id, 
           count(o.order_id) as number_of_orders
    FROM  `jrjames83-1171.sampledata.orders` o
    JOIN `jrjames83-1171.sampledata.customers` c
    ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
    ORDER BY number_of_orders DESC
)

SELECT count(b.customer_unique_id)
FROM number_of_orders_tables b
WHERE b.number_of_orders >= 2


-- OR

WITH base_table AS (
    SELECT  c.customer_unique_id, 
            o.order_purchase_timestamp,
            ROW_NUMBER() OVER(PARTITION BY customer_unique_id
                        ORDER BY o.order_purchase_timestamp) as customer_order_number
    FROM  `jrjames83-1171.sampledata.orders` o
    JOIN `jrjames83-1171.sampledata.customers` c 
    ON o.customer_id = c.customer_id
    ORDER BY 1, 2
),

exclude_table AS (
    SELECT customer_unique_id, max(customer_order_number)
    FROM base_table
    GROUP BY 1
    HAVING max(customer_order_number) = 1 
)

SELECT * 
FROM base_table 
WHERE customer_unique_id NOT IN (SELECT customer_unique_id FROM exclude_table)
ORDER BY 1, 3

