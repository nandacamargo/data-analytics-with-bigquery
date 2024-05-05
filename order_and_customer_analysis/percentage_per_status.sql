
-- Percentage per order_status

SELECT distinct order_status, 
      count(*)/sum(count(*)) OVER () as percentage
FROM `jrjames83-1171.sampledata.orders` 
GROUP BY 1
