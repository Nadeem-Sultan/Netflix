CREATE TABLE netflix
(
show_id VARCHAR(10),	
type_ VARCHAR(10),	
title VARCHAR(120),
director VARCHAR(210),
cast_ VARCHAR(800),	
country	VARCHAR(130),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(20),
listed_in VARCHAR(100),
description VARCHAR(300)
);

SELECT * FROM netflix

--Question1: Count the number of Movies vs TV Shows

SELECT 
		type_, 
		COUNT(*)
FROM netflix
GROUP BY 1


--Question2: Find the most common rating for movies and TV shows


SELECT 
		type_, 
		rating
FROM 
		(
			SELECT 
					type_,
					rating,
					COUNT(*),
					RANK() OVER(PARTITION BY type_ ORDER BY COUNT(*) DESC) AS Ranking 
			FROM netflix
			GROUP BY type_, rating
		) AS t1

WHERE Ranking = 1

-- Question3: List all movies released in a specific year (e.g., 2020)

SELECT 
		release_year,   
		title
FROM netflix
GROUP BY release_year, title
ORDER BY release_year ASC


--Question4:  Find the top 5 countries with the most content on Netflix

SELECT 
		TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
		COUNT(*) 
FROM netflix 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--Question5: Identify the longest movie

SELECT 
		title, type_,
		SPLIT_PART(duration, 'm', 1)::INT as leng
FROM netflix
WHERE type_ = 'Movie' 
ORDER BY leng DESC
LIMIT 5


--Question6:  Find content added in the last 5 years

SELECT 
		type_, title, date_added
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE -  INTERVAL'5 YEARS'


--Question7: Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT 
		type_, director
FROM netflix 
WHERE director ILIKE '%Rajiv Chilaka%' 


--Question8: List all TV shows with more than 5 seasons

SELECT 
		type_,
		title,
		SPLIT_PART(DURATION, 'S', 1)::INT AS seasons 
FROM netflix
WHERE  type_ = 'TV Show' 
		AND 
		SPLIT_PART(DURATION, 'S', 1)::INT > 5
ORDER BY seasons DESC


--Question9: Count the number of content items in each genre

SELECT 
		TRIM(UNNEST(STRING_TO_ARRAY(LISTED_IN, ','))) AS genre,
		COUNT(*)
FROM netflix
GROUP BY 1


--Question10: Find each year and the average numbers of content release by India on netflix. 
           -- return top 5 year with highest avg content release !

SELECT 
		EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
		COUNT(*),
		ROUND(COUNT(*)::NUMERIC/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::NUMERIC * 100, 2) AS avg_content_release
		
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC

--Question11: List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries'


--Question12: Find all content without a director


SELECT 
		COUNT(*)
FROM NETFLIX
WHERE director IS NULL



--Question13: Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT 
		*
FROM netflix
WHERE cast_ ILIKE '%Salman Khan%'
AND
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

--Question14: Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
		UNNEST(STRING_TO_ARRAY(cast_,',')) AS actors,
		COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10



--Question15:Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
           --the description field. Label content containing these keywords as 'Bad' and all other 
           --content as 'Good'. Count how many items fall into each category.
WITH new_table
AS
(
SELECT 
		type_, description,
		CASE
		WHEN description ILIKE '%kill%' OR
			 description ILIKE '%violence%' THEN 'Bad_Content'
			 ELSE 'Good_Content'
		END AS category
FROM netflix
)
SELECT 
		category,
		count(*) AS total_count
FROM new_table
GROUP BY 1
ORDER BY 2


 