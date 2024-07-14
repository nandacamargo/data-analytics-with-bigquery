-- For some date, what's the most common landing page, how many sessions
-- and unique users land on it? What event name do we need?
-- Get the source medium for each landing page

SELECT 
    traffic_source.source || " / " || traffic_source.medium AS source_medium,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS landing_page,
    COUNT(distinct user_pseudo_id) as unique_users,    
    COUNT(*) as number_sessions
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` 
WHERE event_name = 'session_start' 
GROUP BY 1, 2
ORDER BY unique_users DESC
LIMIT 10


-- How many transactions from sessions that started from that landing page and source medium?
WITH traffic_data AS (
  SELECT 
    traffic_source.source || " / " || traffic_source.medium AS source_medium,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS landing_page,
    COUNT(distinct user_pseudo_id) as unique_users,    
    COUNT(*) as number_sessions
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` 
  WHERE event_name = 'session_start' 
  GROUP BY 1, 2
  ORDER BY number_sessions DESC
),

transactions_data AS (
  SELECT 
    traffic_source.source || " / " || traffic_source.medium AS source_medium,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS landing_page,
     COUNT(ecommerce.transaction_id) as total_transactions
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` 
  WHERE event_name = 'purchase' 
  GROUP BY 1, 2
  ORDER BY 3 DESC
)

SELECT start.*, purchase.total_transactions
FROM traffic_data start
LEFT JOIN transactions_data purchase 
ON start.landing_page = purchase.landing_page and
start.source_medium = purchase.source_medium
