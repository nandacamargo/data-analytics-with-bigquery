#################
# Simple Uniform
#################

WITH user_events AS (
  SELECT 'UserA' AS user_pseudo_id, TIMESTAMP '2021-01-26 10:00:00' AS session_timestamp, 'session_start' AS event_name, 'google / cpc' AS source_medium, NULL AS purchase_value UNION ALL
  SELECT 'UserA', TIMESTAMP '2021-01-27 15:00:00', 'session_start', 'direct / none', NULL UNION ALL
  SELECT 'UserA', TIMESTAMP '2021-01-27 15:30:00', 'purchase', 'direct / none', 100 UNION ALL
  SELECT 'UserA', TIMESTAMP '2021-01-29 14:00:00', 'session_start', 'facebook / social', NULL UNION ALL
  SELECT 'UserA', TIMESTAMP '2021-01-30 16:00:00', 'session_start', 'email / newsletter', NULL UNION ALL
  SELECT 'UserA', TIMESTAMP '2021-01-30 16:20:00', 'purchase', 'email / newsletter', 150 UNION ALL
  SELECT 'UserB', TIMESTAMP '2021-01-28 16:00:00', 'session_start', 'direct / none', NULL UNION ALL
  SELECT 'UserB', TIMESTAMP '2021-01-28 16:20:00', 'purchase', 'email / newsletter', 150
),

-- SELECT *,
--   sum(purchase_value) over () as total_revenue,
--   count(1) over(partition by user_pseudo_id) as total_touches
-- FROM user_events

revenue_rows AS (
  SELECT *,
    sum(purchase_value) over(partition by user_pseudo_id) as total_revenue,
    sum(purchase_value) over (partition by user_pseudo_id) / count(1) over(partition by user_pseudo_id) as fractional_revenue  
  FROM user_events
)

SELECT source_medium,
      sum(fractional_revenue) as linear_revenue
FROM revenue_rows
GROUP BY 1