
-- Customers, Lifetime Value
-- What we need: customer_id, first order date, total revenue, first order revenue

with base_table AS (
    SELECT customer_id, 
        min(payment_date) as first_payment, 
        sum(amount) as total_revenue
    FROM `jrjames83-1171.sampledata.payments`
    GROUP BY 1
), 

summary AS (
    SELECT  bt.customer_id, 
            bt.first_payment, 
            bt.total_revenue,
        (select amount 
            from `jrjames83-1171.sampledata.payments` p
            where p.customer_id = bt.customer_id and p.payment_date = bt.first_payment) as first_order_revenue
    FROM base_table bt 
)

-- Customers orders within the first 30, 60, 90 days of their first purchase
SELECT customer_id, 
       first_payment, 
       total_revenue,
       first_order_revenue,
       first_order_revenue/total_revenue as percentage_first_over_total,
       (
        SELECT sum(amount)
        FROM `jrjames83-1171.sampledata.payments` p
        WHERE p.customer_id = s.customer_id
            AND DATE(p.payment_date) BETWEEN DATE(s.first_payment) AND DATE_ADD(DATE(s.first_payment), INTERVAL 30 DAY)
       ) as customer_first_30_total_value,
       (
        SELECT sum(amount)
        FROM `jrjames83-1171.sampledata.payments` p
        WHERE p.customer_id = s.customer_id
            AND DATE(p.payment_date) BETWEEN DATE(s.first_payment) AND DATE_ADD(DATE(s.first_payment), INTERVAL 60 DAY)
       ) as customer_first_60_total_value,
       (
        SELECT sum(amount)
        FROM `jrjames83-1171.sampledata.payments` p
        WHERE p.customer_id = s.customer_id
            AND DATE(p.payment_date) BETWEEN DATE(s.first_payment) AND DATE_ADD(DATE(s.first_payment), INTERVAL 90 DAY)
       ) as customer_first_90_total_value,
FROM summary s

