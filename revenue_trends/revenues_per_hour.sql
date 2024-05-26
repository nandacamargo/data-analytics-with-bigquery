WITH base_table AS (
    SELECT EXTRACT(hour from o.order_purchase_timestamp) as hour, 
        ROUND(SUM(op.payment_value), 2) as sales,
        --SUM(SUM(op.payment_value)) OVER() as total_sales  -- similar to the sales total below
    FROM `jrjames83-1171.sampledata.orders` o
    JOIN `jrjames83-1171.sampledata.order_payments` op
        ON o.order_id = op.order_id
    GROUP BY 1
    ORDER BY 1
), 
sales_total AS (
    SELECT SUM(sales) as total
    FROM base_table
)

SELECT *, (SELECT total from sales_total) as total_table_sales
FROM base_table 
