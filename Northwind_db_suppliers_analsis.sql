
--SUPPLIERS ANALYSIS--

1.--Country distribution of suppliers
SELECT country,
COUNT(supplier_id) as supplier_count
FROM suppliers
GROUP BY 1
ORDER BY 2 DESC;

2.--Top 10 Suppliers by revenue
SELECT s.company_name,
	   s.country,
       ROUND(SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS net_sales
FROM suppliers s
LEFT JOIN products p ON s.supplier_id = p.supplier_id
LEFT JOIN order_details od ON p.product_id = od.product_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10;

3.--Suppliers' order counts, order amounts, categories
SELECT company_name AS suppliers_company,
	   c.category_name AS category,
	   COUNT(od.order_id) AS order_count,
	   SUM(od.quantity) AS amount
FROM suppliers s
LEFT JOIN products p ON s.supplier_id = p.supplier_id
LEFT JOIN categories c ON p.category_id = c.category_id
LEFT JOIN order_details od ON p.product_id = od.product_id
GROUP BY 1,2
ORDER BY 1;

4.--Distinct product counts by suppliers
SELECT s.company_name AS suppliers_company,
		COUNT (DISTINCT (p.product_id)) AS product_count
FROM suppliers s
JOIN products p ON p.supplier_id = s.supplier_id
GROUP BY 1
ORDER BY 2 DESC;

5.--Average shipping time of suppliers
SELECT s.company_name AS suppliers_company,
	   s.country,
       ROUND(AVG(o.shipped_date - o.order_date),2) AS avg_shipping_time
FROM suppliers s
LEFT JOIN products p ON s.supplier_id = p.supplier_id
LEFT JOIN order_details od ON p.product_id = od.product_id
LEFT JOIN orders o ON od.order_id = o.order_id
WHERE o.shipped_date IS NOT NULL 
GROUP BY 1,2
ORDER BY 3 DESC;

6.--Let's review the sales quantities and stock status of the products that I received from suppliers.
SELECT s.company_name AS suppliers_company,
	   p.product_name,
	   p.unit_in_stock,
	   SUM (od.quantity) AS total_amount
FROM suppliers s
LEFT JOIN products p ON s.supplier_id = p.supplier_id
LEFT JOIN order_details od ON p.product_id = od.product_id
GROUP BY 1,2,3
ORDER BY 4 DESC;

7.--Freight according to the number of orders from suppliers
SELECT s.company_name AS suppliers_company,
       COUNT(DISTINCT od.order_id) AS order_count,
       ROUND(SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS net_sales,
	   ROUND(SUM(o.freight)) AS freight
FROM suppliers s
LEFT JOIN products p ON s.supplier_id = p.supplier_id
LEFT JOIN order_details od ON p.product_id = od.product_id
LEFT JOIN orders o ON od.order_id = o.order_id
GROUP BY 1
ORDER BY 3 DESC;






