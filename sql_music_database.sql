
USE spotify;

-- 1. Who is the senior most employee based on job title?
SELECT first_name, MIN(hire_date), title
FROM employees
GROUP BY title, first_name
ORDER BY MIN(hire_date) DESC
LIMIT 1;

-- 2. Which countries have the most invoices?
SELECT COUNT(i.invoice_id) AS no_of_invoices, c.country
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY no_of_invoices DESC;

-- 3. What are the top 3 values of total invoice?
SELECT customer_id, invoice_id, total
FROM invoice
ORDER BY total DESC
LIMIT 3;

-- 4. Which city has the best customers? (City with the most customers)
SELECT COUNT(customer_id) AS best_customer, city
FROM customer
GROUP BY city
ORDER BY best_customer DESC
LIMIT 1;

-- 5. Who is the best customer? (The customer who has spent the most money)
SELECT c.customer_id, SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;

-- 6. Return the email, first name, last name, and Genre of all Rock music listeners ordered by email
SELECT c.first_name, c.last_name, c.email, g.name AS genre
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY email;

-- 7. Top 10 artists who have written the most Rock music (Top 10 Rock bands by track count)
SELECT a.name AS artist_name, COUNT(t.track_id) AS total_tracks
FROM artist a
JOIN album2 al ON a.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY artist_name
ORDER BY total_tracks DESC
LIMIT 10;

-- 8. Return all track names longer than the average song length
SELECT name AS track_name, milliseconds AS track_length
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

-- 9. How much amount has each customer spent on each artist?
SELECT c.customer_id, 
       CONCAT(c.first_name, ' ', c.last_name) AS name, 
       SUM(il.unit_price * il.quantity) AS amount_spent, 
       a.name AS artist_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album2 al ON t.album_id = al.album_id
JOIN artist a ON al.artist_id = a.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, a.artist_id, a.name
ORDER BY amount_spent DESC;

-- 10. Most popular music genre in each country (genre with the highest purchases per country)
WITH top_genre AS (
    SELECT i.billing_country AS country, g.name AS genre, 
           COUNT(il.quantity) AS purchases,
           DENSE_RANK() OVER (PARTITION BY i.billing_country ORDER BY COUNT(il.quantity) DESC) AS rnk
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY i.billing_country, g.name
)
SELECT country, genre
FROM top_genre
WHERE rnk = 1
ORDER BY country;

-- 11. Top-spending customer in each country
WITH customer_total_spending AS (
    SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer,
           i.billing_country,
           ROUND(SUM(i.total), 2) AS total_spent,
           ROW_NUMBER() OVER (PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS rn
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id  
    GROUP BY c.first_name, c.last_name, i.billing_country
)
SELECT billing_country, customer, total_spent
FROM customer_total_spending
WHERE rn = 1
ORDER BY total_spent DESC;
