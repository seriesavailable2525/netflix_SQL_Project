CREATE TABLE netflix (
show_id varchar(5)primary key,
type varchar(10),
title varchar(250),
director varchar(550),
casts varchar(1050),
country varchar(550),
date_added varchar(550),
release_year int,
rating varchar(15),
duration varchar(15),
listing_in varchar(250),
description varchar(550)
);

SELECT * FROM netflix

---1. Count the Number of Movies vs TV Shows.
SELECT type,count(*) AS total_contents from netflix
GROUP By 1

 ---2. Find the Most Common Rating for Movies and TV Shows.
 WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

---03.List All Movies Released in a Specific Year (e.g., 2020)
SELECT * FROM netflix
WHERE release_year = 2020;

---4. Find the Top 5 Countries with the Most Content on Netflix
SELECT 
   UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
   COUNT(*) AS total_content
FROM netflix
GROUP BY 1
ORDER BY total_content DESC
LIMIT 5;

---5.Identify the Longest Movie
SELECT * FROM netflix
WHERE type = 'Movie'
ORDER by SPLIT_PART(duration, ' ', 1)::INT DESC;

---6.Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

---7.Find all the movies/TV shows by director 'Rajiv Chilaka'.
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'

---8. List all TV shows with more than 5 seasons.
SELECT * FROM netflix
WHERE type ='TV Show' AND SPLIT_PART(duration, ' ', 1)::INT > 5;

---9. Count the Number of Content Items in Each Genre
SELECT 
    UNNEST(STRING_TO_ARRAY(listing_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;

---10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!
total content 333/972

SELECT 
   EXTRACT(YEAR FROM TO_Date(date_added,'Month DD,YYYY'))as year,
   COUNT(*)as yearly_content,
   ROUND(
   COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100
   ,2)as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1

---11. List all movies that are documentaries
SELECT *
FROM netflix
WHERE 
    listing_in ILIKE '%documentaries%'

---12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL;

---13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE
   casts ILIKE '%Salman Khan%'
   AND
   release_year > EXTRACT(YEAR FROM CURRENT_DATE ) - 10

---14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*) as total_content
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

---15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
