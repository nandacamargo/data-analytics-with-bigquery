

WITH took_offer AS
(
    SELECT 1 as customer_id, 34.99 as spend UNION ALL 
    SELECT 2, 21.99 UNION ALL
    SELECT 3, 179.0 UNION ALL
    SELECT 4, .99 UNION ALL
    SELECT 5, 1299.00
),

loyalty_club AS 
(
    SELECT 3 as customer_id, 1 as status UNION ALL
    SELECT 4, 1 UNION ALL
    SELECT 8, 2 UNION ALL
    SELECT 12, 1 UNION ALL
    SELECT 10, 2 
),

complete_table AS (
    SELECT t.customer_id, t.spend, l.customer_id as loyalty_customer_id, l.status 
    FROM loyalty_club l
    FULL OUTER JOIN took_offer t
    ON l.customer_id = t.customer_id
)


-- We want to get a complete view of whether a customer_id took an offer
-- and whether they are in a loyalty_club
-- Try to classify each row as 1 of 3 outcomes

SELECT customer_id, spend, loyalty_customer_id, status,
    CASE
        WHEN (customer_id IS NOT NULL AND loyalty_customer_id IS NULL) THEN "only_took_offer"
        WHEN (customer_id IS NULL AND loyalty_customer_id IS NOT NULL) THEN "only_loyalty_club"
        ELSE "both"
    END AS customer_type
FROM complete_table