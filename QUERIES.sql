-- 15 Business Problems & Solutions:
SELECT * FROM NETFLIX;

-- 1. Count the number of Movies vs TV Shows
SELECT 
	TYPE, 
	COUNT(*) AS TOTAL_CONTENT
FROM NETFLIX

GROUP BY TYPE;

-- 2. Find the most common rating for movies and TV shows
WITH RANK_RATING AS
(
	SELECT 
		RATING,
		TYPE,
		COUNT(*) AS COUNT_RATING,
		RANK() OVER(PARTITION BY TYPE ORDER BY COUNT(*) DESC) AS RANKING
	FROM NETFLIX
	GROUP BY 
		RATING,
		TYPE
)

SELECT 
	TYPE,
	RATING,
	RANKING,
	COUNT_RATING
FROM RANK_RATING
WHERE RANKING = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT SHOW_ID, TITLE 
FROM NETFLIX
WHERE TYPE = 'Movie' AND RELEASE_YEAR = 2020;

-- 4. Find the top 5 countries with the most content on NetfliX 
-- (5 Top countries have most movies)

SELECT 
    TRIM(NC.COUNTRY) AS COUNTRY,
    COUNT(*) AS TOTAL_CONTENT
FROM (
    SELECT 
        SHOW_ID,
        UNNEST(STRING_TO_ARRAY(COUNTRY, ',')) AS COUNTRY
    FROM NETFLIX
    WHERE COUNTRY IS NOT NULL
) AS NC
GROUP BY TRIM(NC.COUNTRY)
ORDER BY TOTAL_CONTENT DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT TITLE, DURATION
FROM NETFLIX
WHERE 
	TYPE = 'Movie' 
	AND 
	DURATION IS NOT NULL
ORDER BY CAST(SPLIT_PART(DURATION, ' ', 1) AS INT) DESC --SLICE OUT AND CONVERT FROM STRING TO INTEGER
LIMIT 1;

-- 6. Find content added in the last 5 years
SELECT SHOW_ID, TITLE, DATE_ADDED 
FROM NETFLIX
WHERE TO_DATE(DATE_ADDED, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Toshiya Shinohara'!
SELECT TITLE, TYPE, DIRECTOR 
FROM NETFLIX
WHERE 
	DIRECTOR LIKE '%Toshiya Shinohara%';

-- 8. List all TV shows with more than 5 seasons
SELECT TITLE, TYPE, DURATION 
FROM NETFLIX
WHERE 
    TYPE = 'TV Show' 
    AND CAST(SPLIT_PART(DURATION, ' ', 1) AS INT) > 5;

-- 9. Count the number of content items in each genre
SELECT  
	UNNEST(STRING_TO_ARRAY(LISTED_IN, ',')) AS GENRE,
	COUNT(*) AS TOTAL_CONTENT
FROM NETFLIX
GROUP BY
	GENRE;	


-- 10.Find each year and the average numbers of content release in US on netflix.
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'United States'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 10;

-- 11. List all movies that are documentaries
SELECT SHOW_ID, TITLE, LISTED_IN  
FROM NETFLIX
WHERE TYPE = 'Movie' AND LISTED_IN LIKE '%Documentaries%';

-- 12. Find all content without a director
SELECT SHOW_ID, TITLE 
FROM NETFLIX
WHERE DIRECTOR IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT SHOW_ID, TITLE, CASTS AS ACTORS 
FROM NETFLIX
WHERE 
	TYPE = 'Movie'
	AND 
	CASTS LIKE '%Salman Khan%' 
	AND
	CAST(SPLIT_PART(DURATION, ' ', 1) AS INT) > 10;
	

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in US.
WITH HIGHEST_COUNT AS 
(
	SELECT 
		CASTS AS ACTORS, 
		COUNT(*) AS TOTAL_COUNT
	FROM NETFLIX
	WHERE 
		COUNTRY LIKE '%United States' 
		AND 
		CASTS IS NOT NULL
		AND TYPE = 'Movie'
	GROUP BY
		ACTORS
	ORDER BY TOTAL_COUNT DESC
	LIMIT 10
)

SELECT * 
FROM HIGHEST_COUNT
ORDER BY TOTAL_COUNT DESC
LIMIT 10;

-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

SELECT
	CASE
		WHEN DESCRIPTION ILIKE '%kill%' OR DESCRIPTION ILIKE '%violence%' THEN 'Bad'
		ElSE 'Good'
	END AS CONTENT_CATEGORY,
	COUNT(*) AS CONTENT_COUNT
FROM NETFLIX
GROUP BY CONTENT_CATEGORY;


	
