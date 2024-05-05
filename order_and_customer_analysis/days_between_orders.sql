
-- For customers with more than 1 order, what is the avg time
-- in days between orders
-- LAG() the order purchase timestamp along the customer


WITH 
base_table AS (
  SELECT c.customer_unique_id, count(o.order_id) as number_of_orders
  FROM  `jrjames83-1171.sampledata.orders` o
  JOIN `jrjames83-1171.sampledata.customers` c
  ON o.customer_id = c.customer_id
  GROUP BY c.customer_unique_id
  ORDER BY number_of_orders desc
),

customer_with_more_than_two_orders AS (
  SELECT b.customer_unique_id
  FROM base_table b
  where b.number_of_orders >= 2
),

customer_purchases AS (
  SELECT c.customer_unique_id, 
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER(PARTITION BY customer_unique_id
        ORDER BY o.order_purchase_timestamp) as customer_order_number
  FROM  `jrjames83-1171.sampledata.orders` o
  JOIN `jrjames83-1171.sampledata.customers` c
  ON o.customer_id = c.customer_id
  ORDER BY 1, 2
),

lag_purchase_time AS (
  SELECT *, LAG(order_purchase_timestamp) 
              OVER (PARTITION BY customer_unique_id 
              ORDER BY order_purchase_timestamp) AS previous_order_purchase
  FROM customer_purchases
  WHERE customer_unique_id IN (SELECT customer_unique_id FROM customer_with_more_than_two_orders)
),

day_diffs_per_client AS (
  SELECT customer_unique_id,
      date_diff(order_purchase_timestamp, previous_order_purchase, DAY) orders_day_diff
  FROM lag_purchase_time
  ORDER BY 1
)

SELECT customer_unique_id, AVG(orders_day_diff) as avg_days
FROM day_diffs_per_client
WHERE orders_day_diff IS NOT NULL
GROUP BY 1

