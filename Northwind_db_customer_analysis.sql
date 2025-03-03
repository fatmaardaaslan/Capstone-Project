
-- CUSTOMER ANALYSIS--

1.--Let's find the top 10 customers who made the most purchases.
SELECT c.customer_id,
	c.company_name,
    ROUND (SUM (od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS net_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10;

2.--Let's find the customers I made sales above the average sales.
SELECT c.customer_id, 
       c.company_name,
       COUNT(o.order_id) AS total_orders,
       ROUND (AVG (od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS avg_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.company_name
HAVING ROUND (AVG (od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) > 
       (SELECT ROUND (AVG (od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) 
        FROM order_details od)
ORDER BY 4 DESC;

3.--Let's do customer segmentation with RFM analysis.
WITH recency1 AS (
    SELECT 
        o.customer_id,
        MAX(o.order_date) AS max_ord_date
    FROM orders o
    GROUP BY 1 
),
monetary1 AS (
    SELECT 
        r.customer_id,
        '1998-05-06'::date - r.max_ord_date AS recency,
        round(SUM(od.quantity * od.unit_price)) AS payment
    FROM recency1 r 
    JOIN orders o ON o.customer_id = r.customer_id 
    JOIN order_details od ON od.order_id = o.order_id
    WHERE od.quantity * od.unit_price > 0
    GROUP BY 1,2 
 ),
frequency1 AS (
    SELECT 
        m.customer_id,
        m.recency,
        m.payment,
        COUNT(DISTINCT o.order_id) AS frequency 
    FROM monetary1 m
    JOIN orders o ON o.customer_id = m.customer_id
    GROUP BY 1,2,3 
),
rfm_analyze AS (
    SELECT 
        f.customer_id,
        f.recency,
        NTILE(5) OVER(ORDER BY f.recency DESC) AS recency_score,
        f.frequency,
        NTILE(5) OVER(ORDER BY f.frequency) AS frequency_score,
        f.payment AS monetary,
        NTILE(5) OVER(ORDER BY f.payment) AS monetary_score
    FROM frequency1 f
)
SELECT
    customer_id,
    recency_score::varchar || '-' || frequency_score::varchar || '-' || monetary_score::varchar AS RFM_scores,
	CASE 
		WHEN frequency_score = 5 and monetary_score >=4 THEN 'Champions'
		WHEN frequency_score >=4 and monetary_score between 2 and 3 THEN 'Potential Loyalist'
	    WHEN frequency_score =5 and monetary_score =1  THEN 'New Customers'
        WHEN frequency_score =4 and monetary_score =1  THEN 'Promising'
		WHEN frequency_score between 3 and 4 and monetary_score >=4 THEN 'Loyal Customers'
		WHEN frequency_score = 3 and monetary_score = 3 THEN 'Need Attention'
		WHEN frequency_score = 3 and monetary_score between 1 and 2 THEN 'About To Sleep'
        WHEN frequency_score <= 2 and monetary_score =5 THEN 'Can Not Loose'
        WHEN frequency_score <= 2 and monetary_score between 3 and 4 THEN 'At Risk'
        WHEN frequency_score <= 2 and monetary_score <= 2 THEN 'Hibernating'
    END AS segment_name
FROM 
    rfm_analyze
ORDER BY 
    recency_score DESC, frequency_score DESC, monetary_score DESC;

4.--Let's examine the countries of customers.
SELECT c.country,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    ROUND (SUM (od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS net_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY 1
ORDER BY 3 DESC;






