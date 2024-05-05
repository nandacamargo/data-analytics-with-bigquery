
-- Find the order when was the n-th time a product was purchased

SELECT 
  items.product_id, 
  o.order_purchase_timestamp,
  ROW_NUMBER() 
        OVER(PARTITION BY items.product_id 
              ORDER BY order_purchase_timestamp) as order_nth_occurence
FROM `jrjames83-1171.sampledata.orders` o
JOIN `jrjames83-1171.sampledata.order_items` items
ON o.order_id = items.order_id
ORDER BY 1, 3