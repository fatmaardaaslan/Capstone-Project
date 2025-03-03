
--LOGISTIC ANALYSIS--

1.--Total shipping counts
SELECT s.company_name,
	COUNT(o.order_id) as shipping_count
FROM orders o
JOIN shippers s ON o.ship_via = s.shipper_id
WHERE o.shipped_date IS NOT NULL
GROUP BY 1
ORDER BY 2;

2.--Total shipping costs
SELECT s.company_name,
       ROUND(SUM(o.freight)) AS total_shipping_cost
FROM orders o
JOIN shippers s ON s.shipper_id = o.ship_via
GROUP BY 1
ORDER BY 2 DESC;

3.--The fastest shipping company
SELECT s.company_name, 
	   ROUND(AVG(o.shipped_date - o.order_date),2) AS avg_delivery_time
FROM orders o
JOIN shippers s ON o.ship_via = s.shipper_id
WHERE o.shipped_date IS NOT NULL
GROUP BY 1
ORDER BY 2;

4.--Shipping companies success rate
SELECT s.company_name,
       SUM(CASE WHEN o.shipped_date > o.required_date THEN 1 ELSE 0 END) AS not_on_time,
       SUM(CASE WHEN o.shipped_date <= o.required_date THEN 1 ELSE 0 END) AS on_time,
       COUNT(o.order_id) AS total_shipping,
       CASE 
	   	WHEN 
	      COUNT(o.order_id) > 0 
		  THEN 
	      	ROUND(SUM(CASE WHEN o.shipped_date <= o.required_date THEN 1 ELSE 0 END) * 100.0 / COUNT(o.order_id),2)
           ELSE 
               0 
       END AS success_rate
FROM orders o
JOIN shippers s ON o.ship_via = s.shipper_id
WHERE o.shipped_date IS NOT NULL
GROUP BY 1;

5.--Shipping preferences of suppliers
SELECT p.supplier_id,
	s.company_name,
	COUNT(o.order_id) as shipping_count
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
JOIN shippers s ON o.ship_via = s.shipper_id
GROUP BY 1,2
ORDER BY 1;

6.--Shipping time by country
SELECT c.country,
	ROUND(AVG(o.shipped_date - o.order_date),2) AS avg_shipping_time
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.shipped_date IS NOT NULL 
GROUP BY 1
ORDER BY 2 DESC;


