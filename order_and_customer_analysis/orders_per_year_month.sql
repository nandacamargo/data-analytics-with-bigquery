
-- Get the number of orders per year-month

SELECT 
  DATE_TRUNC(DATE(order_purchase_timestamp), YEAR) as year,
  EXTRACT(MONTH from order_purchase_timestamp) as month,
  count(*) as number_orders
FROM `jrjames83-1171.sampledata.orders` 
GROUP BY 1, 2
ORDER BY 1, 2
