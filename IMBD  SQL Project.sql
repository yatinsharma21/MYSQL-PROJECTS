-- Q1. Find the total number of rows in each table of the schema?

-- Number of rows for the table 'director_mapping'
SELECT count(*) from director_mapping;

-- Number of rows for the table 'genre'
SELECT count(*) from  genre;

-- Number of rows for the table 'movie'
SELECT count(*) from movie;

-- Number of rows for the table 'names'
SELECT count(*) from names;

-- Number of rows for the table 'ratings'
SELECT count(*) from ratings;

-- Q2. Which columns in the movie table have null values?
select *
from movie
where id is null
or title is null
or year is null
or date_published is null
or country is null
or duration is null
or worlwide_gross_income is null
or languages is null
or production_company is null

-- ROUGH NOTE: The 4 columns: country , worldwide_gross_income,languages,production_company have null values .


-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 

-- Q3. Find the total number of movies released each year? How does the trend look month wise?
-- Part 1
select year, count(id) as number_of_movies
from movie
group by year
select * from movie

-- Part 2
SELECT 
    MONTH(date_published) AS month,
    COUNT(*) AS movie_count
FROM 
    movie
WHERE 
    YEAR(date_published) = 2019
GROUP BY 
    MONTH(date_published)
ORDER BY 
    MONTH(date_published);
    
    -- Checking which month has maximum movies released
-- ORDER BY number_of_movies DESC;

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/

-- Q4. How many movies were produced in the USA or India in the year 2019??
select count(id) as movie_count
from movie
where (country = 'USA' or country= 'India') and year = '2019'

-- ROUGH NOTE: Together India and USA has produced 1007 movies

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/


-- Q5. Find the unique list of the genres present in the data set?
select distinct(genre) from genre

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?

-- Getting the genre in which highest number of movies were produced in the year 2019:
SELECT 
    g.genre, 
    COUNT(mg.id) AS movie_count
FROM 
    genre g
JOIN 
    movie mg ON g.movie_id = mg.id
GROUP BY 
    g.genre
ORDER BY 
    movie_count DESC
LIMIT 1;

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?

SELECT 
    COUNT(*) AS movies_with_one_genre
FROM (
    SELECT  movie_id
        
    FROM 
        genre
    GROUP BY movie_id
    HAVING 
        COUNT(movie_id) = 1
) AS single_genre_movies;

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

SELECT 	genre, avg(duration) as avg_duration
from genre g
inner join movie m
on g.movie_id=m.id
group by genre
order by avg_duration desc

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/


-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced?
-- (Hint: Use the Rank function)

WITH GenreRanking AS(
   SELECT 
      genre,count(movie_id) AS movie_count,
      RANK() OVER(ORDER BY count(movie_id) DESC) AS movie_rank
   FROM genre
   GROUP BY genre
)
SELECT genre,movie_count,movie_rank
FROM GenreRanking
WHERE genre = 'Thriller';

/*Thriller movies is in top 3 among all genres in terms of number of movies
 
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/
-- Segment 2:


-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
SELECT 
       min(avg_rating),
       max(avg_rating),
       min(total_votes),
       max(total_votes),
       max(median_rating),
        min(median_rating) 
from ratings

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/


-- Q11. Which are the top 10 movies based on average rating?

SELECT m.title, r.avg_rating,
       DENSE_RANK() OVER(ORDER BY r.avg_rating DESC) AS movie_rank
FROM ratings as r
INNER JOIN movie as m
ON r.movie_id = m.id
LIMIT 10;

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/
 
-- Q12. Summarise the ratings table based on the movie counts by median ratings. 
SELECT median_rating,count(movie_id) as movie_count
from ratings
group by median_rating 
order by median_rating;

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)?

WITH prod_company_details AS
(
SELECT production_company,
       COUNT(id) as movie_count,
       avg(avg_rating)
FROM ratings as r
INNER JOIN movie as m
ON r.movie_id = m.id
WHERE avg_rating > 8 AND production_company IS NOT NULL
GROUP BY production_company
)
SELECT production_company,
       movie_count,
       DENSE_RANK() OVER(ORDER BY movie_count DESC) AS prod_company_rank
FROM prod_company_details;

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

WITH Movie_in_march AS (
    SELECT 
        g.genre,
        COUNT(m.id) AS movie_count
    FROM movie m
    INNER JOIN 
        genre g
    ON 
        m.id = g.movie_id
    INNER JOIN 
        ratings r
    ON 
        r.movie_id = m.id
	WHERE 
		m.date_published BETWEEN '2017-03-01' AND '2017-03-31'
        AND m.country = 'USA' 
        AND r.total_votes > 1000
        GROUP BY 
        g.genre, 
        m.country
    ORDER BY 
        movie_count DESC
)
SELECT 
    genre,
    movie_count 
FROM 
    Movie_in_march;
    
-- Lets try to analyse with a unique problem statement.    

-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?

SELECT m.title,g.genre,r.avg_rating
from movie m
inner join genre g
on m.id=g.movie_id
inner join ratings r
on r.movie_id=m.id
where title like 'The%' and avg_rating > 8
order by avg_rating desc

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
SELECT title,median_rating,genre
FROM movie as m
INNER JOIN ratings as r
ON m.id = r.movie_id
INNER JOIN genre as g
ON g.movie_id = m.id
WHERE title LIKE "The%" AND median_rating > 8
ORDER BY median_rating DESC;

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
Select count(m.id) as movie_count
from movie m
inner join ratings r
on m.id=r.movie_id
where m.date_published BETWEEN '2018-04-01' AND '2019-04-01' AND median_rating = 8

-- Q17. Do German movies get more votes than Italian movies?

SELECT 
    m.languages AS language, 
    SUM(r.total_votes) AS total_votes, 
    COUNT(m.id) AS movie_count
FROM 
    movie AS m
INNER JOIN 
    ratings AS r
ON 
    m.id = r.movie_id
WHERE 
    m.languages IN ('German', 'Italian') 
GROUP BY 
    m.languages
ORDER BY 
    total_votes DESC;
    
/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/
-- Segment 3:

-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
SELECT 
    SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_null_count,
    SUM(CASE WHEN height  IS NULL THEN 1 ELSE 0 END) AS height_null_count,
    SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS DOB_null_count,
	SUM(CASE WHEN known_for_movies  IS NULL THEN 1 ELSE 0 END) AS Known_null_count
FROM names;

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/


-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
WITH top3_genre AS (
    SELECT 
        g.genre, 
        COUNT(g.movie_id) AS movie_count
    FROM 
        genre AS g
    INNER JOIN 
        ratings AS r
    ON 
        g.movie_id = r.movie_id
    WHERE 
        r.avg_rating > 8
    GROUP BY 
        g.genre
    ORDER BY 
        movie_count DESC
    LIMIT 3
),

top3_director AS (
    SELECT 
        n.name AS director_name,
        COUNT(g.movie_id) AS movie_count,
        ROW_NUMBER() OVER(ORDER BY COUNT(g.movie_id) DESC) AS director_row_rank
    FROM 
        names AS n
    INNER JOIN 
        director_mapping AS dm 
    ON 
        n.id = dm.name_id 
    INNER JOIN 
        genre AS g 
    ON 
        dm.movie_id = g.movie_id 
    INNER JOIN 
        ratings AS r 
    ON 
        r.movie_id = g.movie_id
    INNER JOIN 
        top3_genre AS t
    ON 
        g.genre = t.genre
    WHERE 
        r.avg_rating > 8
    GROUP BY 
        n.name
)

SELECT 
    director_name, 
    movie_count
FROM 
    top3_director
WHERE 
    director_row_rank <= 3;
    
/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:
+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT name as actor_name,COUNT(r.movie_id) as movie_count
FROM names as n
INNER JOIN role_mapping as rm
ON n.id = rm.name_id
INNER JOIN ratings as r
ON rm.movie_id = r.movie_id
WHERE median_rating >=8 AND rm.category = 'actor'
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 2;

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

Select m.production_company,sum(r.total_votes) as total_votes,
Rank() over(order by sum(r.total_votes) desc)as prod_com_rank from movie m
Inner join ratings r
on m.id=r.movie_id
group by m.production_company
limit 3

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.
Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
with actor_rating_details as
(
Select name as actor_name,sum(total_votes)as total_votes,count(r.movie_id)as movie_count,
        round(sum(avg_rating*total_votes)/sum(total_votes),2)as avg_rating
from names as n
Inner join role_mapping as rm
on n.id=rm.name_id
Inner join  ratings as r
on rm.movie_id=r.movie_id
Inner join movie as m
on m.id=r.movie_id
where country="INDIA" and category="actor"
group by actor_name
having movie_count>=5
)
Select * ,
         Rank() over (order by avg_rating DESC) as actor_rank
from  actor_rating_details
limit 1

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

with actress_rating_details as
(
Select name as actress_name,sum(total_votes)as total_votes,count(r.movie_id)as movie_count,
        round(sum(avg_rating*total_votes)/sum(total_votes),2)as avg_rating
from names as n
Inner join role_mapping as rm
on n.id=rm.name_id
Inner join  ratings as r
on rm.movie_id=r.movie_id
Inner join movie as m
on m.id=r.movie_id
where country="INDIA" and category="actress"and languages="Hindi"
group by actress_name
having movie_count>=3
)
Select * ,
         Rank() over (order by avg_rating DESC) as actor_rank
from  actress_rating_details
limit 1

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/

/* Q24. Consider thriller movies having at least 25,000 votes. Classify them according to their average ratings in
   the following categories:  

			Rating > 8: Superhit
			Rating between 7 and 8: Hit
			Rating between 5 and 7: One-time-watch
			Rating < 5: Flop
	 Note: Sort the output by average ratings (desc).*/
     
Select title,avg_rating,
Case when avg_rating>8 Then "SUPERHIT"
	 when avg_rating Between 7 and 8 Then "Hit Movies"
     when avg_rating between 5 and 7 then "One-time-watch"
     Else "flop"
     End as rating_category
from movie as m
Inner join genre g
on m.id=g.movie_id
Inner join ratings r 
on g.movie_id=r.movie_id
where genre="Thriller"
order by avg_rating desc 

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:


-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT genre,
	   ROUND(AVG(duration),2) AS avg_duration,
       SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
       AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM genre as g
INNER JOIN movie as m
ON m.id = g.movie_id
GROUP BY genre
ORDER BY genre;

-- Round is good to have and not a must have; Same thing applies to sorting

-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

WITH top_3_genre AS
( 	
	SELECT genre, COUNT(movie_id) AS number_of_movies
    FROM genre AS g
    INNER JOIN movie AS m
    ON g.movie_id = m.id
    GROUP BY genre
    ORDER BY COUNT(movie_id) DESC
    LIMIT 3
),
top_5 AS
(
	SELECT genre,
			year,
			title AS movie_name,
			worlwide_gross_income,
			RANK() OVER(PARTITION BY year ORDER BY worlwide_gross_income DESC) AS movie_rank

	FROM movie AS m 
    INNER JOIN genre AS g 
    ON m.id= g.movie_id
	WHERE genre IN (SELECT genre FROM top_3_genre)
)
SELECT *
FROM top_5
WHERE movie_rank<=5;

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.

-- Q27. Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?

Select m.production_company, count(m.id) as movie_count,
       Rank() over (order by count(m.id) desc) AS prod_comp_rank
       from movie as m
       inner join ratings as r
       on m.id=r.movie_id
       WHERE median_rating>=8 AND production_company IS NOT NULL AND POSITION(',' IN languages)>0
	   GROUP BY production_company
	   LIMIT 2;
-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language

-- Q28. Who are the top 3 actresses based on the number of Super Hit movies (Superhit movie: average rating of movie > 8) in 'drama' genre?

-- Note: Consider only superhit movies to calculate the actress average ratings.
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes
-- should act as the tie breaker. If number of votes are same, sort alphabetically by actress name.)

SELECT name as actress_name,
       SUM(total_votes) AS total_votes,
       count(r.movie_id) as movie_count,
       avg(avg_rating) as actress_avg_rating,
	   RANK() OVER(ORDER BY avg(avg_rating) DESC) AS actress_rank
FROM names as n
INNER JOIN role_mapping as rm
ON n.id = rm.name_id
INNER JOIN ratings as r
ON rm.movie_id = r.movie_id
INNER JOIN genre as g
ON g.movie_id = r.movie_id
WHERE category = 'actress' AND avg_rating > 8 AND genre = "drama"
GROUP BY actress_name
LIMIT 3;       

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/

WITH movie_date_info AS
(
SELECT d.name_id, name, d.movie_id,
	   m.date_published, 
       LEAD(date_published, 1) OVER(PARTITION BY d.name_id ORDER BY date_published) AS next_movie_date
FROM director_mapping d
	 JOIN names AS n 
     ON d.name_id=n.id 
	 JOIN movie AS m 
     ON d.movie_id=m.id
),

date_difference AS
(
	 SELECT *, DATEDIFF(next_movie_date, date_published) AS diff
	 FROM movie_date_info
 ),

 avg_inter_days AS
 (
	 SELECT name_id, AVG(diff) AS avg_inter_movie_days
	 FROM date_difference
	 GROUP BY name_id
 ),

 director_details AS
 (
	 SELECT d.name_id AS director_id,
		 name AS director_name,
		 COUNT(d.movie_id) AS number_of_movies,
		 ROUND(avg_inter_movie_days) AS inter_movie_days,
		 ROUND(AVG(avg_rating),2) AS avg_rating,
		 SUM(total_votes) AS total_votes,
		 MIN(avg_rating) AS min_rating,
		 MAX(avg_rating) AS max_rating,
		 SUM(duration) AS total_duration
		 -- DENSE_RANK() OVER(ORDER BY COUNT(d.movie_id) DESC) AS director_rank
	 FROM
		 names AS n 
         JOIN director_mapping AS d 
         ON n.id=d.name_id
		 JOIN ratings AS r 
         ON d.movie_id=r.movie_id
		 JOIN movie AS m 
         ON m.id=r.movie_id
		 JOIN avg_inter_days AS a 
         ON a.name_id=d.name_id

	 GROUP BY director_id
     ORDER BY COUNT(d.movie_id) DESC
 )
 SELECT director_id,
        director_name,
        number_of_movies,
        inter_movie_days,
        avg_rating,
        total_votes,
        min_rating,
        max_rating,
        total_duration	
 FROM director_details
 LIMIT 9;

