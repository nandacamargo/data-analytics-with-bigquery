
-- How many customers were acquired in each month and year

SELECT EXTRACT(YEAR FROM order_purchase_timestamp) as year,
       EXTRACT(MONTH FROM order_purchase_timestamp) as month,
       COUNT(customer_unique_id) number_of_customers
FROM
      (SELECT c.customer_unique_id, 
            o.order_purchase_timestamp,
            ROW_NUMBER() OVER(PARTITION BY customer_unique_id
                  ORDER BY o.order_purchase_timestamp) as customer_order_number
      FROM  `jrjames83-1171.sampledata.orders` o
      JOIN `jrjames83-1171.sampledata.customers` c
      ON o.customer_id = c.customer_id
      ORDER BY 1, 2)
WHERE customer_order_number = 1
GROUP BY 1, 2
ORDER BY 1 DESC, 2 DESC
