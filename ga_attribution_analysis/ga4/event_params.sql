-- Event date and name by number of unique users
SELECT FORMAT_DATE("%Y-%m-%d", PARSE_DATE("%Y%m%d", _TABLE_SUFFIX)) as formatted_date,
      event_name,
      COUNT (DISTINCT user_pseudo_id) as unique_users
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` 
WHERE _TABLE_SUFFIX between "20201203" and "20201209"
GROUP BY 1, 2
ORDER BY 1

-- For some given date, get the user id, session id and number of sessions
-- for that user_id (it envolves dealing with the event_params field)

-- Here, we list the session ids in the result
SELECT event_date,
      user_pseudo_id,
      p.key,
      p.value.int_value,
      COUNT(distinct p.value.int_value) OVER(PARTITION BY (user_pseudo_id)) as number_sessions
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20201219`,
      UNNEST(event_params) p
WHERE p.key = "ga_session_id"
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC

-- Here, we don't show the session ids in the result
SELECT event_date,
      user_pseudo_id,
      COUNT(distinct p.value.int_value) as number_sessions
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20201219`,
      UNNEST(event_params) p
WHERE p.key = "ga_session_id"
GROUP BY 1, 2
ORDER BY 3 DESC