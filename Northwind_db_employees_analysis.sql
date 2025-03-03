
-- EMPLOYEES ANALYSIS--

1.--Sales Performance Of Employees
SELECT e.employee_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS net_sales
FROM employees e
JOIN orders o ON o.employee_id = e.employee_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY 1
ORDER BY 2 DESC;

2.--Average sales of employees
SELECT employee_name,
     ROUND (AVG (od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0)))::numeric,2) AS avg_sales
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY 1
ORDER BY 2 DESC;

3.--Order counts of employees
SELECT e.employee_name,
	COUNT(o.order_id) AS total_orders
FROM orders o
JOIN employees e ON o.employee_id = e.employee_id
GROUP BY 1
ORDER BY 2 DESC;

4.--Age distribution of employees
SELECT employee_name,
	EXTRACT(YEAR FROM AGE('1998-01-01'::Date,birth_date)) AS age
FROM employees
GROUP BY 1,2;

5.--Order counts of employees by region, territory and country
SELECT COUNT(o.order_id) AS total_order,
	e.employee_name,
	e.country,
	t.territory_description AS territory,
	r.region_description AS region
FROM orders o
LEFT JOIN employees e ON o.employee_id = e.employee_id
LEFT JOIN employeeterritories et ON e.employee_id = et.employee_id
LEFT JOIN territories t ON  et.territory_id = t.territory_id
LEFT JOIN region r ON t.region_id = r.region_id
GROUP BY 2,3,4,5
ORDER BY 5;

6.--Employees by hire date, title, and number of reports
SELECT employee_name,
	hire_date,
	title,
	reports_to
FROM employees
GROUP BY 1,2,3,4
ORDER BY 2;

