 -- Look at database top 10 
 SELECT * 
 FROM survey
 LIMIT 10;

-- Find number of responses to each question 
SELECT question, COUNT(response) AS num_responses
FROM survey
GROUP BY question;


-- Find number of responses to each question 
SELECT SUBSTR(question, 1, 1) as q_num, question, COUNT(response) AS num_responses
FROM survey
GROUP BY question;


--- Check if there are any NULLs in the question columns
SELECT DISTINCT(question)
FROM SURVEY
ORDER BY question; 

SELECT COUNT(question)
FROM survey
WHERE response IS NULL;

-- Create a lagged column with the number of responses and join on number of responses to calculate completion rates 

WITH num_rep AS ( 
	SELECT question, SUBSTR(question, 1, 1)+1 as q_num, COUNT(response)*1.0 AS num_responses
	FROM survey
	GROUP BY question
  ORDER BY question
), 
lags AS(
	SELECT 	1 AS 'q_num', 
				NULL AS 'lag'
	UNION 
	SELECT q_num, num_responses
	FROM num_rep
	GROUP BY question
	LIMIT 5), 
qs AS (
	SELECT 	SUBSTR(question, 1, 1)*1 as q_num, 
  				question, 
  				COUNT(response) AS num_responses
	FROM survey
	GROUP BY question
)
SELECT 	question, 
        num_responses,  
        num_responses/lag*100 as pct
FROM qs
JOIN lags ON qs.q_num = lags.q_num;

-- Look at top 5 rows of tables
SELECT *
FROM quiz
LIMIT 5;

SELECT * 
FROM home_try_on
LIMIT 5;

SELECT * 
FROM purchase
LIMIT 5;

-- 5.Create table with status at each step in the funnel. I do not get the same results for the top three rows as the example. Why?
SELECT 	SUBSTR(q.user_id, 1, 8) as user_id, 
				CASE
        	WHEN h.number_of_pairs IS NULL THEN 'False'
          ELSE 'True'
        END AS is_home_try_on,
        SUBSTR(h.number_of_pairs, 1, 1) AS number_of_pairs, 
        CASE
        	WHEN p.product_id IS NULL then 'False'
          ELSE 'True'
        END AS is_purchase
FROM quiz AS q
LEFT JOIN home_try_on AS h
	ON q.user_id = h.user_id
LEFT JOIN purchase AS p
	ON q.user_id = p.user_id
LIMIT 10;

-- 6.Calculating conversion rates
WITH funnel as (
SELECT 	SUBSTR(q.user_id, 1, 8) as user_id, 
				CASE
        	WHEN h.number_of_pairs IS NULL THEN 0
          ELSE 1
        END AS is_home_try_on,
        SUBSTR(h.number_of_pairs, 1, 1)*1.0 AS number_of_pairs, 
        CASE
        	WHEN p.product_id IS NULL then 0
          ELSE 1
        END AS is_purchase
FROM quiz AS q
LEFT JOIN home_try_on AS h
	ON q.user_id = h.user_id
LEFT JOIN purchase AS p
	ON q.user_id = p.user_id
)
SELECT 	COUNT(user_id) as num_browse, 
				SUM(is_home_try_on) as num_try, 
        SUM(is_purchase) as num_buy, 
        SUM(is_home_try_on)*1.0/COUNT(user_id) home_conv,
        SUM(is_purchase)*1.0/SUM(is_home_try_on) as htobuy_conv, 
        SUM(is_purchase)*1.0/COUNT(user_id) as buy_conv 
FROM funnel;

-- Calculating purchase rates for 3 and 5 pairs
WITH funnel as (
SELECT 	SUBSTR(q.user_id, 1, 8) as user_id, 
				CASE
        	WHEN h.number_of_pairs IS NULL THEN 0
          ELSE 1
        END AS is_home_try_on,
        SUBSTR(h.number_of_pairs, 1, 1)*1.0 AS number_of_pairs, 
        CASE
        	WHEN p.product_id IS NULL then 0
          ELSE 1
        END AS is_purchase
FROM quiz AS q
LEFT JOIN home_try_on AS h
	ON q.user_id = h.user_id
LEFT JOIN purchase AS p
	ON q.user_id = p.user_id
)
SELECT	number_of_pairs,
				COUNT(user_id) as num_try_on, 
				SUM(is_purchase) as num_purchased, 
        SUM(is_purchase)*1.0/COUNT(user_id) as purchase_rate
FROM funnel
WHERE number_of_pairs IS NOT NULL
GROUP BY number_of_pairs;

-- Calculating most common results in style quiz 
SELECT style, fit, shape, color, count(*) as num_answers
FROM quiz
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC
LIMIT 5;

-- Calculating the most common type of purchase
SELECT product_id, style, model_name, color, count (*) as num_purchases
FROM purchase
GROUP BY product_id, style, model_name, color
ORDER BY num_purchases DESC
LIMIT 5;

-- Do customers buy more than one pair? 
SELECT user_id, COUNT(user_id) as num_purchases
FROM purchase
GROUP BY user_id
ORDER BY num_purchases DESC
LIMIT 10; -- NOPE

-- What price point generates the highest gross income? 
SELECT price, COUNT(price) AS num_purchases, sum(price) AS total_income, COUNT(DISTINCT(product_id)) AS num_models
FROM purchase
GROUP BY price
ORDER BY num_purchases DESC
LIMIT 10;













