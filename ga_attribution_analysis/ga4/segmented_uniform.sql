####################
# Segmented Uniform
####################

WITH user_events AS (
  SELECT 'UserA' AS user_pseudo_id, TIMESTAMP '2021-01-26 10:00:00' AS session_timestamp, 'session_start' AS event_name, 'google / cpc' AS source_medium, NULL AS purchase_value UNION ALL
  SELECT 'UserA', TIMESTAMP '2021-01-27 15:00:00', 'session_start', 'direct / none', NULL UNION ALL
  SELECT 'UserA', TIMESTAMP '2021-01-27 15:30:00', 'purchase', 'direct / none', 100 UNION ALL
  SELECT 'UserA', TIMESTAMP '2021-01-29 14:00:00', 'session_start', 'facebook / social', NULL UNION ALL
  SELECT 'UserA', TIMESTAMP '2021-01-30 16:00:00', 'session_start', 'email / newsletter', NULL UNION ALL
  SELECT 'UserA', TIMESTAMP '2021-01-30 16:20:00', 'purchase', 'email / newsletter', 150 UNION ALL
  SELECT 'UserB', TIMESTAMP '2021-01-28 16:00:00', 'session_start', 'direct / none', NULL UNION ALL
  SELECT 'UserB', TIMESTAMP '2021-01-28 16:20:00', 'purchase', 'email / newsletter', 75 UNION ALL 
  SELECT 'UserC', TIMESTAMP '2021-01-31 17:20:00', 'session_start', 'instagram / social', NULL UNION ALL
  SELECT 'UserD', TIMESTAMP '2021-01-29 18:20:00', 'session_start', 'instagram / social', NULL
),

flagged_purchases AS (
  select *,
  CASE WHEN(event_name = "purchase") THEN 1 ELSE 0 END as is_purchase
  from user_events
),

-- Assign a unique group identifier to each series of sessions leading up to a purchase
grouped_sessions AS (
  SELECT *,
    SUM(is_purchase) OVER(PARTITION BY user_pseudo_id ORDER BY session_timestamp DESC) as purchase_group
  FROM flagged_purchases

),

revenue_rows AS (
  SELECT *,
    SUM(purchase_value) OVER(PARTITION BY user_pseudo_id, purchase_group) as purchase_group_revenue,
    SUM(purchase_value) OVER (PARTITION BY user_pseudo_id, purchase_group) / count(1) OVER (PARTITION BY  user_pseudo_id, purchase_group) as fractional_revenue  
  FROM grouped_sessions
)

SELECT source_medium,
       sum(fractional_revenue) as linear_revenue
FROM revenue_rows
GROUP BY 1
