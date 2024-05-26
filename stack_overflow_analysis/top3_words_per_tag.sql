
WITH base_table AS (
    SELECT tag, title, id, split(title, " ") as words
    FROM `jrjames83-1171.sampledata.top_questions` 
),
words_table AS (
    SELECT DISTINCT tag, title, lower(trim(word)) as word
    FROM base_table, UNNEST(words) word
),
stopwords AS (
    SELECT "a" as word UNION ALL
    SELECT "in" UNION ALL
    SELECT "on" UNION ALL
    SELECT "at" UNION ALL
    SELECT "do" UNION ALL
    SELECT "does" UNION ALL
    SELECT "of" UNION ALL
    SELECT "i" UNION ALL
    SELECT "you" UNION ALL
    SELECT "and" UNION ALL
    SELECT "or" UNION ALL
    SELECT "the" UNION ALL
    SELECT "it" UNION ALL
    SELECT "if" UNION ALL
    SELECT "how" UNION ALL
    SELECT "to" UNION ALL
    SELECT "for" UNION ALL
    SELECT "what" UNION ALL
    SELECT "this" UNION ALL
    SELECT "that" UNION ALL
    SELECT "with" 
),

rank_table AS (
    SELECT tag, word, COUNT(*) as frequency,
        ROW_NUMBER() OVER (PARTITION BY tag ORDER BY COUNT(*) DESC) as tag_word_rank
    FROM words_table
    WHERE word NOT IN (SELECT word FROM stopwords) --remove stopwords
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC
)

SELECT * 
FROM rank_table
WHERE tag_word_rank < 4 -- Get top 3 words
