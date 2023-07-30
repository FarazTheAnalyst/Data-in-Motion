CREATE TABLE customers (
    customer_id integer PRIMARY KEY,
    first_name varchar(100),
    last_name varchar(100),
    email varchar(100)
);

CREATE TABLE products (
    product_id integer PRIMARY KEY,
    product_name varchar(100),
    price decimal
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    customer_id integer,
    order_date date
);

CREATE TABLE order_items (
    order_id integer,
    product_id integer,
    quantity integer
);

INSERT INTO customers (customer_id, first_name, last_name, email) VALUES
(1, 'John', 'Doe', 'johndoe@email.com'),
(2, 'Jane', 'Smith', 'janesmith@email.com'),
(3, 'Bob', 'Johnson', 'bobjohnson@email.com'),
(4, 'Alice', 'Brown', 'alicebrown@email.com'),
(5, 'Charlie', 'Davis', 'charliedavis@email.com'),
(6, 'Eva', 'Fisher', 'evafisher@email.com'),
(7, 'George', 'Harris', 'georgeharris@email.com'),
(8, 'Ivy', 'Jones', 'ivyjones@email.com'),
(9, 'Kevin', 'Miller', 'kevinmiller@email.com'),
(10, 'Lily', 'Nelson', 'lilynelson@email.com'),
(11, 'Oliver', 'Patterson', 'oliverpatterson@email.com'),
(12, 'Quinn', 'Roberts', 'quinnroberts@email.com'),
(13, 'Sophia', 'Thomas', 'sophiathomas@email.com');

INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Product A', 10.00),
(2, 'Product B', 15.00),
(3, 'Product C', 20.00),
(4, 'Product D', 25.00),
(5, 'Product E', 30.00),
(6, 'Product F', 35.00),
(7, 'Product G', 40.00),
(8, 'Product H', 45.00),
(9, 'Product I', 50.00),
(10, 'Product J', 55.00),
(11, 'Product K', 60.00),
(12, 'Product L', 65.00),
(13, 'Product M', 70.00);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1, 1, '2023-05-01'),
(2, 2, '2023-05-02'),
(3, 3, '2023-05-03'),
(4, 1, '2023-05-04'),
(5, 2, '2023-05-05'),
(6, 3, '2023-05-06'),
(7, 4, '2023-05-07'),
(8, 5, '2023-05-08'),
(9, 6, '2023-05-09'),
(10, 7, '2023-05-10'),
(11, 8, '2023-05-11'),
(12, 9, '2023-05-12'),
(13, 10, '2023-05-13'),
(14, 11, '2023-05-14'),
(15, 12, '2023-05-15'),
(16, 13, '2023-05-16');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 2, 1),
(2, 3, 3),
(3, 1, 1),
(3, 3, 2),
(4, 2, 4),
(4, 3, 1),
(5, 1, 1),
(5, 3, 2),
(6, 2, 3),
(6, 1, 1),
(7, 4, 1),
(7, 5, 2),
(8, 6, 3),
(8, 7, 1),
(9, 8, 2),
(9, 9, 1),
(10, 10, 3),
(10, 11, 2),
(11, 12, 1),
(11, 13, 3),
(12, 4, 2),
(12, 5, 1),
(13, 6, 3),
(13, 7, 2),
(14, 8, 1),
(14, 9, 2),
(15, 10, 3),
(15, 11, 1),
(16, 12, 2),
(16, 13, 3);

SELECT * FROM order_items;

-- Case Study Questions
USE TinyShopDb;

--1) Which product has the highest price? Only return a single row.

 SELECT TOP 1 product_name, price FROM products
 ORDER BY price DESC;

 --2) Which customer has made the most orders?

WITH cte_MaxOrders(customer_id, orderCount)
AS
(
	SELECT customer_id, count(order_id) AS orderCount FROM orders
	GROUP BY customer_id 
	HAVING count(order_id) > 1
	
)

SELECT c.first_name, c.last_name, ct.orderCount AS Most_orders FROM
customers c JOIN cte_MaxOrders ct
ON c.customer_id = ct.customer_id
ORDER BY c.customer_id DESC;

--3) Whats the Total Revenue per product?

SELECT p.product_id, p.product_name, SUM(price * oi.quantity) AS Revenue
FROM products p INNER JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY SUM(price * oi.quantity) DESC;

--4) Find the day with highest revenue.

WITH cte_highRevenue(order_id, Revenue)
AS
(
	SELECT oi.order_id, p.price * oi.quantity AS Revenue
	FROM products p JOIN order_items oi
	ON p.product_id = oi.product_id
)

SELECT TOP 1 o.order_date, SUM(ct.Revenue) AS HighesRevenue FROM orders o 
join cte_highRevenue ct
ON o.order_id = ct.order_id
GROUP BY order_date
ORDER BY SUM(ct.Revenue) DESC;

--5) Find the first order (by date) for each customer.

WITH cte_firstOrder(customer_id, first_purchase) 
AS
(
	SELECT customer_id, min(order_date) AS first_purchase FROM
	orders 
	GROUP BY customer_id
)
SELECT o.order_id AS frist_order, o.customer_id, ct.first_purchase FROM
orders o JOIN cte_firstOrder ct
ON ct.customer_id = o.customer_id AND ct.first_purchase = 
o.order_date;

--6) Find the top 3 customers who have ordered the most distinct products

SELECT TOP 3 c.customer_id, c.first_name, c.last_name, COUNT(DISTINCT oi.product_id) 
AS Distinct_Product
FROM customers c 
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi 
ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY COUNT(DISTINCT oi.product_id) DESC;

--7) Which product has been bought the least terms of quantity?

SELECT TOP 1 p.product_id, p.product_name, SUM(oi.quantity) AS QTY
FROM products p 
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY SUM(quantity);

--8) What is median order total?

WITH cte_orderTotal AS
(
	SELECT SUM(p.price * oi.quantity) AS total
	FROM order_items oi
	JOIN products p
	ON oi.product_id = p.product_id
	GROUP BY oi.order_id
)
SELECT DISTINCT median = PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total)
OVER() FROM cte_orderTotal;

--9) For each order, determine if it was 'Expensive' (total over 300),'Affordable' (total over 100), or 'Cheap'.

SELECT oi.order_id, SUM(p.price * oi.quantity) as Total,
CASE
WHEN SUM(p.price * oi.quantity) > 300 THEN  'Expensive'
WHEN SUM(p.price * oi.quantity) < 300 AND SUM(p.price * oi.quantity) > 100 THEN 'Affordable'
Else 'Cheap'
END AS Category
FROM products p JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY oi.order_id
ORDER BY Total DESC;

--10) Find customers who have ordered the product with the highest price.

SELECT c.first_name, c.last_name, o.order_id FROM 
customers c JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IN (
	SELECT order_id FROM order_items
	WHERE product_id IN (SELECT TOP 1 product_id FROM products
		ORDER BY price DESC)
)

