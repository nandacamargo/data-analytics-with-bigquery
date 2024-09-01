-- Last click attribution model using source / medium
-- Do we have revenue implemented? If not, transactions

SELECT source_medium, count(*) as purchases, sum(purchase_revenue) as sales
FROM(
  SELECT 
    user_pseudo_id,
    (SELECT value.int_value  FROM UNNEST(event_params) WHERE key = 'ga_session_id') as session_id,
    (SELECT COALESCE(value.int_value, value.float_value, value.double_value) 
        FROM UNNEST(event_params) WHERE key = 'value') as purchase_revenue,
    traffic_source.source || " / " || traffic_source.medium AS source_medium,    
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` 
  WHERE event_name = 'purchase' AND _TABLE_SUFFIX BETWEEN '20210125' AND '20210131'
)
GROUP BY 1
ORDER BY 2 DESC
