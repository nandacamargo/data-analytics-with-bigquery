
-- Find questions with more than two unique tags
SELECT id, title, ARRAY_AGG(distinct tag) as tags
FROM `jrjames83-1171.sampledata.top_questions`
WHERE tag <> 'undefined'
GROUP BY 1, 2
HAVING ARRAY_LENGTH(ARRAY_AGG(distinct tag)) > 2
ORDER BY ARRAY_LENGTH(ARRAY_AGG(distinct tag)) DESC

-- Filtering by Python tag or title
select * from (
  select title, id, array_agg(distinct tag) as question_tags 
  from `jrjames83-1171.sampledata.top_questions`
  where tag like '%python%' and TRIM(lower(title)) like '%python%'
  group by 1, 2
) as temp
where array_length(temp.question_tags) >= 2
order by array_length(temp.question_tags) desc


-- For each tag, get me all the questions they have associated with them
select tag, array_agg(distinct title) as questions
from `jrjames83-1171.sampledata.top_questions`
group by 1


-- Which tag has the most number of questions?
select tag, array_length(array_agg(distinct title)) as number_questions
from `jrjames83-1171.sampledata.top_questions`
group by 1
order by 2 desc


-- What's the average number of questions per tag?
with base_table as (
  select tag, array_length(array_agg(distinct title)) as number_questions
  from `jrjames83-1171.sampledata.top_questions`
  group by 1
  order by 2 desc
)

select avg(number_questions) from base_table
--29,729 ~ 30


-- Which tags have a number of questions greater than or equal to the average number
select * from base_table
where number_questions >= (
  select avg(number_questions) from base_table
)


-- Get me all views (sum of views) for questions containing python in the title
select title, sum(quarter_views) as views
from
(
  select distinct quarter, quarter_views, title, id
  from `jrjames83-1171.sampledata.top_questions`
  where TRIM(LOWER(title)) like  '%python%'
  order by id
)
group by 1


