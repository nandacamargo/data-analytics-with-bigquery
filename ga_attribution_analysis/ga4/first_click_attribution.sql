-- First click attribution

# Ignoring cases where some user has multiple transactions in the specified date range
# So all the transaction revenue and purchase will be credit to that session

WITH revenue_summary AS (
    SELECT 
    user_pseudo_id,
    SUM((SELECT COALESCE(value.int_value, value.float_value, value.double_value) 
        FROM UNNEST(event_params) WHERE key = 'value')) as purchase_revenue,
    COUNT(*) purchases
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` 
  WHERE event_name = 'purchase' AND _TABLE_SUFFIX BETWEEN '20210125' AND '20210131'
  GROUP BY 1
),

user_first_session AS (
    SELECT 
        distinct user_pseudo_id,
        event_timestamp,
        ROW_NUMBER() OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) as user_session_rank,
        (SELECT value.int_value  FROM UNNEST(event_params) WHERE key = 'ga_session_id') as session_id,
        traffic_source.source || " / " || traffic_source.medium AS source_medium
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` 
    WHERE event_name = 'session_start' AND _TABLE_SUFFIX BETWEEN '20210125' AND '20210131'
    ORDER BY 1, 3
)

SELECT f.source_medium, 
        sum(r.purchase_revenue) as first_touch_revenues,
        sum(r.purchases) AS first_touch_total_purchases
FROM user_first_session f
LEFT JOIN revenue_summary r
ON f.user_pseudo_id = r.user_pseudo_id
WHERE f.user_session_rank = 1
GROUP BY 1
ORDER BY 3 DESC

