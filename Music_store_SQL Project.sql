-- Easy Level -- 
-- 01 : Who is the senior most employee based on job role?
SELECT last_name, first_name FROM employee
ORDER BY levels DESC LIMIT 1

-- 02 : Which countries has the most invoices?
SELECT billing_country,
COUNT(*) AS max_invoice FROM invoice
GROUP BY billing_country
ORDER BY max_invoice DESC

-- 03 : What are top 3 values of total invoice?
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3

-- 04 : Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals. 
--Return both the city name & sum of all invoice totals? 
SELECT billing_city, sum(total) as invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC LIMIT 3

-- 05 : Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money?
SELECT first_name,last_name,sum(total) as total_spending
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY first_name,last_name
ORDER BY total_spending DESC LIMIT 1


--Moderate level --
-- 01 : Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A.
SELECT DISTINCT c.first_name,c.last_name,c.email FROM customer c
	JOIN invoice i ON c.customer_id = i.customer_id
	JOIN invoice_line il ON il.invoice_id = i.invoice_id
	JOIN track t ON il.track_id = t.track_id
	JOIN genre g ON t.genre_id = g.genre_id
	WHERE g.name LIKE 'Rock'
	ORDER BY c.email
	
	      -- OR--
SELECT DISTINCT first_name,last_name,email FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
WHERE track_id IN (
	SELECT track_id FROM track t
	JOIN genre  ON t.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY c.email

-- 02 : Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands.

SELECT artist.artist_id,artist.name, count(track.name) as no_of_songs FROM artist
JOIN album ON artist.artist_id = album.artist_id
JOIN track ON album.album_id = track.album_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id,artist.name
ORDER BY no_of_songs DESC LIMIT 10


-- 03 : Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

SELECT track.name, track.milliseconds FROM track
WHERE milliseconds > (
	SELECT avg(track.milliseconds) FROM track
)
ORDER BY track.milliseconds DESC


-- Advance level --
-- 01 : Find how much amount spent by each customer on artists? 
--Write a query to return customer name, artist name and total spent

WITH best_selling_artist AS (
SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
FROM invoice_line
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


-- 02 : We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
--with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
--the maximum number of purchases is shared return all Genres.

WITH popular_genre AS (
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
    ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY 2,3,4
    ORDER BY 2 ASC, 1 DESC
)
 SELECT * FROM popular_genre WHERE RowNo <= 1


-- ---- Thank You ---- --