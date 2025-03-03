
-- PRODUCT ANALYSIS--

1.--Let's find the products that I made sales above the average sales.
SELECT p.product_name,
       SUM(od.quantity) AS sales_amount,
	   ROUND (AVG (od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS avg_sales,
       ROUND(SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS net_sales
FROM products p
JOIN order_details od ON od.product_id = p.product_id
GROUP BY 1
HAVING ROUND (AVG (od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) > 
       (SELECT ROUND (AVG (od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) 
        FROM order_details od)
ORDER BY 3 DESC;

-- Avg_sales=587,37 -- SELECT ROUND (AVG (od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) FROM order_details od

2.--Is the stock sufficient for each product? Should a reorder be placed? What are the stock quantities? Which products are still on sale?
WITH tb1 AS (SELECT p.product_name,
		p.unit_in_stock,
		CASE 
			WHEN p.unit_in_stock <= p.reorder_level THEN 'Reorder Required'
			WHEN p.unit_in_stock > p.reorder_level THEN 'Enough Stock'
        END AS stock_status,
        CASE
            WHEN p.discontinued = 1 THEN 'Discontinued'
            WHEN p.discontinued = 0 THEN 'Active'
        END AS product_status,
        p.product_id
    FROM products p 
),
order_summary AS (
    SELECT 
        od.product_id,
        COUNT (od.order_id) AS order_count
    FROM order_details od
    GROUP BY od.product_id
)
SELECT 
    tb1.product_name,
    tb1.stock_status,
    tb1.product_status,
    SUM(tb1.unit_in_stock) AS stock_count,
    COALESCE(os.order_count, 0) AS total_orders
FROM 
    tb1
LEFT JOIN order_summary os ON tb1.product_id = os.product_id
GROUP BY tb1.product_name, tb1.stock_status, tb1.product_status, os.order_count
ORDER BY stock_count DESC;

3.--Top 10 products by sales
SELECT p.product_name, 
	ROUND(SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS net_sales
FROM products p
JOIN order_details od
ON od.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

4.--The most trend products
SELECT p.product_name, 
	COUNT(od.order_id) AS order_count
FROM products p
JOIN order_details od ON od.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC;

5.--Average unit price per product
SELECT p.product_name,
	   ROUND (AVG (od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS avg_sales
FROM products p
JOIN order_details od
ON od.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC;

6.--Total order counts of categories by year
SELECT EXTRACT (YEAR FROM o.order_date) AS year,
	c.category_name,
	COUNT(o.order_id) AS total_order
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY 1, 2
ORDER BY 1,3 DESC;





