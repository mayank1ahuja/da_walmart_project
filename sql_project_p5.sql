SELECT * FROM walmart;

--Business Problems
--Q.1 Find different payment method, number of transactions as well as the number of quantity sold.
SELECT 
	 payment_method,
	 COUNT(*) AS no_payments,
	 SUM(quantity) AS number_of_quantity_sold
FROM walmart
GROUP BY payment_method;

--Q.2 Identify the highest-rated category in each branch, displaying the branch, category and the average rating.

SELECT * FROM 
(	
SELECT 
		branch,
		category,
		AVG(rating) AS avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank = 1;


--Q.3 Identify the busiest day for each branch based on the number of transactions.

SELECT * FROM
(
	SELECT 
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
		COUNT(*) AS no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank = 1;

--Q.4 Calculate the total quantity of items sold per payment method. List the payment methods and the total quantity sold.

SELECT 
	 payment_method,
	 COUNT(*) AS number_of_payments,
	 SUM(quantity) AS total_quantity_sold
FROM walmart
GROUP BY payment_method;

--Q.5 Determine the average, minimum, and maximum rating of category for each city. List the city, average rating, minimum rating, and maximum rating.

SELECT 
	city,
	category,
	MIN(rating) AS min_rating,
	MAX(rating) AS max_rating,
	AVG(rating) AS avg_rating
FROM walmart
GROUP BY 1, 2;


/*Q.6 Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin).
List category and total_profit, ordered from highest to lowest profit.
*/

SELECT 
	category,
	SUM(total) AS total_revenue,
	SUM(total * profit_margin) AS total_profit
FROM walmart
GROUP BY 1
ORDER BY 3 DESC;

--Q.7 Determine the most common payment method for each Branch. Display Branch and the preferred payment method.

WITH cte AS
(
SELECT 
	branch,
	payment_method,
	COUNT(*) AS total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart
GROUP BY 1, 2
)
SELECT *
FROM cte
WHERE rank = 1;

--Q.8 Categorize sales into 3 group MORNING, AFTERNOON, EVENING. Find out each of the shift and number of invoices.

SELECT
	branch,
CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END shift,
	COUNT(*) AS number_of_invoices
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

