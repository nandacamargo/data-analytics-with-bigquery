
-- Java, Python, SQL or Javascript
-- Which language appears to be more popular?

WITH base_table as (
  SELECT distinct title,
    CASE
      WHEN title LIKE '%python%' THEN 'python'
      WHEN title LIKE '%javascript%' THEN 'javascript'
      WHEN title LIKE '%java%' THEN 'java'
      WHEN title LIKE '%sql%' THEN 'sql'    
      ELSE 'other_case'
    END as language
  FROM `jrjames83-1171.sampledata.top_questions`
)

select language, count(*)
from base_table
group by 1
order by 2 desc



-- For each of these categories, how often is the
-- string within the tag as well?

WITH 
base_table as (
    SELECT distinct id, title, ARRAY_TO_STRING(ARRAY_AGG(tag), " ") as tag_content
    FROM `jrjames83-1171.sampledata.top_questions`
    GROUP BY 1, 2
),

language_table AS (
  
    SELECT distinct id,
    CASE
        WHEN title LIKE '%python%' AND tag_content LIKE '%python%' THEN 'python_for_both'
        WHEN title LIKE '%python%' AND NOT tag_content LIKE '%python%' THEN 'python_title_only'
        WHEN title NOT LIKE '%python%' AND tag_content LIKE '%python%' THEN 'python_tag_only'

        WHEN title LIKE '%sql%' AND tag_content LIKE '%sql%' THEN 'sql_for_both'
        WHEN title LIKE '%sql%' AND NOT tag_content LIKE '%sql%' THEN 'sql_title_only'
        WHEN title NOT LIKE '%sql%' AND tag_content LIKE '%sql%' THEN 'sql_tag_only'

        WHEN title LIKE '%javascript%' AND tag_content LIKE '%javascript%' THEN 'javascript_for_both'
        WHEN title LIKE '%javascript%' AND NOT tag_content LIKE '%javascript%' THEN 'javascript_title_only'
        WHEN title NOT LIKE '%javascript%' AND tag_content LIKE '%javascript%' THEN 'javascript_tag_only'
        
        ELSE NULL
    END as language
    FROM base_table
)

SELECT COALESCE(language, "no_match"), count(*) as number_questions
FROM language_table
GROUP BY 1
ORDER BY 2 DESC

