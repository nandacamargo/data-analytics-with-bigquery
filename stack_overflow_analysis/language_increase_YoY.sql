-- Which language has seen the greatest increase in views Year over Year

WITH base_table as (
  SELECT distinct title, quarter_views, quarter,
    CASE
      WHEN title LIKE '%python%' THEN 'python'
      WHEN title LIKE '%javascript%' THEN 'javascript'
      WHEN title LIKE '%java%' THEN 'java'
      WHEN title LIKE '%sql%' THEN 'sql'    
      ELSE 'other_case'
    END as language
  FROM `jrjames83-1171.sampledata.top_questions`
), 
summary_table AS (
    SELECT language, 
          EXTRACT(YEAR FROM quarter) AS year,
          SUM(quarter_views) as year_views        
    FROM base_table 
    WHERE language <> 'other_case'
    GROUP BY 1, 2
    ORDER BY 1, 2
)

SELECT 
  st.*, 
  round((year_views / LAG(year_views) OVER (PARTITION BY language ORDER BY year)) * 100, 2) || '%'  as pct_change_yoy
FROM summary_table st


