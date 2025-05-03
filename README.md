# Netflix Content Analysis Using SQL Project

![netflix_logo](https://github.com/user-attachments/assets/d36a8854-97ed-4dd5-b2fc-7c4f1527b958)

## 🔗 Data set from Kaggle: [data_set](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## 🎯 Objectives
- Analyze the distribution of content types (Movies vs TV Shows).
- Identify the most common ratings for different types of content.
- Explore content trends based on release year, duration, and countries.
- Retrieve specific types of content (e.g., documentaries, by director, by actor).
- Categorize and filter content based on keywords.

### 📦 Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix (
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## ⁉️ Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows
```sql
SELECT 
    type, 
    COUNT(*) AS total_content
FROM netflix
GROUP BY type;
```
Objective: Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows
```sql
WITH RANK_RATING AS (
    SELECT 
        rating,
        type,
        COUNT(*) AS count_rating,
        RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY rating, type
)
SELECT 
    type,
    rating,
    count_rating
FROM RANK_RATING
WHERE ranking = 1;
```
Objective: Identify the most frequent rating per content type.

### 3. List All Movies Released in 2020
```sql
SELECT show_id, title 
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;
```
Objective: Retrieve all movies released in 2020.

### 4. Top 5 Countries with the Most Content
```sql
SELECT 
    TRIM(nc.country) AS country,
    COUNT(*) AS total_content
FROM (
    SELECT 
        show_id,
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country
    FROM netflix
    WHERE country IS NOT NULL
) AS nc
GROUP BY TRIM(nc.country)
ORDER BY total_content DESC
LIMIT 5;
```
Objective: Find countries producing the most Netflix content.

### 5. Identify the Longest Movie
```sql
SELECT title, duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INT) DESC
LIMIT 1;
```
Objective: Determine the longest movie on Netflix.

### 6. Content Added in the Last 5 Years
```sql
SELECT show_id, title, date_added 
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```
Objective: Get content added in the last 5 years.

### 7. Movies/TV Shows by Director 'Toshiya Shinohara'
```sql
SELECT TITLE, TYPE, DIRECTOR 
FROM NETFLIX
WHERE 
	DIRECTOR LIKE '%Toshiya Shinohara%';
```
Objective:  List content directed by 'Toshiya Shinohara'.

### 8. TV Shows with More Than 5 Seasons
```sql
SELECT title, type, duration 
FROM netflix
WHERE type = 'TV Show' AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) > 5;
```
Objective: Identify TV shows with more than 5 seasons.

### 9. Count Content Items by Genre
```sql
SELECT  
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY genre;
```
Objective: Count the number of titles per genre.
 
### 10. Top 10 Years with Highest Content Releases in US
```sql
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric / 
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'United States')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'United States'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 10;
```
Objective: Analyze release trends in the US.

### 11. List Documentaries
```sql
SELECT show_id, title, listed_in  
FROM netflix
WHERE type = 'Movie' AND listed_in LIKE '%Documentaries%';
```
Objective:  Filter out all documentaries.

### 12. Content Without a Directors
```sql
SELECT show_id, title 
FROM netflix
WHERE director IS NULL;
```
Objective: Identify entries with missing director data.

### 13. Movies Featuring 'Salman Khan' in Last 10 Years
```sql
SELECT show_id, title, casts AS actors 
FROM netflix
WHERE type = 'Movie'
  AND casts LIKE '%Salman Khan%' 
  AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```
Objective: Find recent movies with 'Salman Khan'.

### 14. Top 10 Actors in US Movies
```sql
WITH highest_count AS (
    SELECT 
        casts AS actors, 
        COUNT(*) AS total_count
    FROM netflix
    WHERE country LIKE '%United States%' 
      AND casts IS NOT NULL
      AND type = 'Movie'
    GROUP BY actors
    ORDER BY total_count DESC
    LIMIT 10
)
SELECT * 
FROM highest_count
ORDER BY total_count DESC;
```
Objective: Identify actors with most appearances in US movies.

### 15. Categorize Content by Keywords 'Kill' or 'Violence'
```sql
SELECT
    CASE
        WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS content_category,
    COUNT(*) AS content_count
FROM netflix
GROUP BY content_category;
```
Objective: Categorize and count titles based on sensitive keywords.

## 📈 Tableau Dashboard
Tableau Public Project Dashboard: [click here](https://public.tableau.com/views/Netflix_Dashboard_by_lip/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

![{47471CD4-4E63-4D69-9540-B873D443339B}](https://github.com/user-attachments/assets/9e1bb45f-c8be-4522-a478-30bfed59ef85)
![{D9556AD7-9582-475E-9F53-B91C9C491F2C}](https://github.com/user-attachments/assets/025c7794-59a2-4e20-9f36-acbac710625a)

## ⭐ Findings and Conclusion

### Findings:

1. Between 2012 and 2021, movies dominate Netflix’s catalog, representing 69.62% of all content, while TV shows account for 30.38%.
2. Within the TV-MA rating category, movies have a higher count (2062) compared to TV shows (1145).
3. The United States overwhelmingly leads with 3690 titles, followed by India (1046), United Kingdom (805), Canada (445), and France (393).
4. International Movies stand out as the most prominent genre with 2624 titles, followed by Dramas (1600), Comedies (1210), Action & Adventure (859), and Documentaries (829).
5. There was a steady growth in average content releases from 2012 (7.20) up to a peak around 2018 (36.63), after which the trend plateaued slightly and then declined in 2021 (14.20).
6. An overwhelming majority (96.12%) of content descriptions are considered "good" (minimal or no mentions of violence, killing, etc.), while only 3.88% are categorized as "bad".

### Conclusion (Insight):
- Between 2012 and 2021, Netflix's content strategy strongly favored movies over TV shows, with the U.S. being the primary contributor to its library. International content, particularly movies, played a critical role in genre diversity, highlighting Netflix’s global expansion.
Content production in the U.S. experienced a consistent rise up to 2018, suggesting a period of aggressive content growth, before seeing a slight decline in 2021, possibly influenced by external factors like the Covid-19 pandemic.
Overall, Netflix maintained a positive content quality, focusing largely on non-violent entertainment, aligning with a broader audience appeal.
