
-- SALES ANALYSIS--

1.--Let's examine net sales by month per year.
SELECT date_trunc('MONTH',o.order_date)::date AS order_month,
ROUND (SUM (od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS net_sales
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
GROUP BY 1
ORDER BY 1;

2.--Let's examine gross sales, freight and percentage of freight.
SELECT date_trunc('month', o.order_date)::date AS order_month,
    COUNT(o.order_id) AS total_order,
    ROUND (SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS net_sales,
    o.freight AS total_freight,
    ROUND(SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric - o.freight::numeric, 2) AS gross_sales_profit_or_loss,
    ROUND((o.freight)::numeric / NULLIF(SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric, 0) * 100, 2) AS percentage_of_freight
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY 1,4
ORDER BY 1;

3.--Let's find the employees' sales performance.
SELECT  date_trunc('year', o.order_date)::date AS order_year,
	e.employee_name,
	COUNT(o.order_id) AS total_order,
	ROUND (SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS net_sales
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN employees e ON o.employee_id = e.employee_id
GROUP BY 1,2
ORDER BY 1,3 DESC;

4.--Sales percentage by category.
WITH cs AS (SELECT c.category_name,
           ROUND (SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS net_sales
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_details od ON p.product_id = od.product_id
GROUP BY 1
ORDER BY 2 DESC), 
ts AS  (SELECT
       ROUND (SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS net_sales
       FROM order_details od)
SELECT cs.category_name,
       ROUND (cs.net_sales /ts.net_sales*100, 2)  AS category_sales_percentage
FROM cs ,ts
GROUP BY 1,2
ORDER BY 2 DESC;

5.--Net sales and total orders per country by year
SELECT date_trunc('year',o.order_date)::date AS order_year,
c.country,
COUNT (o.order_id) AS total_order,
ROUND (SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS net_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY 1,2
ORDER BY 1,4 DESC;

6.--Shipping companies costs
SELECT s.company_name AS shipping_company,
    ROUND(SUM(o.freight)) AS total_shipping_cost
FROM shippers s
JOIN orders o ON s.shipper_id = o.ship_via
GROUP BY 1;

7.--Order counts and net sales by region
SELECT date_trunc('year',o.order_date)::date AS order_year,
COUNT(o.order_id) AS order_count,
ROUND (SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS net_sales,
r.region_description AS region
FROM orders o
JOIN order_details od ON o.order_id =od.order_id
JOIN employees e ON o.employee_id = e.employee_id
JOIN employeeterritories et ON e.employee_id = et.employee_id
JOIN territories t ON  et.territory_id = t.territory_id
JOIN region r ON t.region_id = r.region_id
GROUP BY 1,4
ORDER BY 1;



