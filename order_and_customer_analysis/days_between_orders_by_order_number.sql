
-- For customers with more than 1 order, what is the avg time
-- in days between orders, taking into account the number of unique 
-- users that made that number of orders
-- LAG() the order purchase timestamp along the customer

WITH base_table AS (
    SELECT c.customer_unique_id, 
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER(PARTITION BY customer_unique_id
            ORDER BY o.order_purchase_timestamp) as customer_order_number
    FROM  `jrjames83-1171.sampledata.orders` o
    JOIN `jrjames83-1171.sampledata.customers` c ON o.customer_id = c.customer_id
    ORDER BY 1, 2
),

exclude_table AS (
    SELECT customer_unique_id, max(customer_order_number)
    FROM base_table
    GROUP BY 1
    HAVING max(customer_order_number) = 1 
),
more_than_2_orders AS (
    SELECT *, LAG(order_purchase_timestamp)
                OVER(PARTITION BY customer_unique_id)
                ORDER BY (order_purchase_timestamp) as prev_order_timestamp
    FROM base_table 
    WHERE customer_unique_id NOT IN (SELECT customer_unique_id FROM exclude_table)
    ORDER BY 1, 3
)

SELECT max(customer_order_number) as max_orders,
        AVG(DATE_DIFF(order_purchase_timestamp, 
                        prev_order_timestamp, DAY)) avg_date_diff,
        count(customer_unique_id) as unique_customers                        
FROM more_than_2_orders as mo
ORDER BY max_orders
