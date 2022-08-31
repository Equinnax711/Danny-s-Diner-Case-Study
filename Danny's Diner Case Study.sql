--CREATE TABLE sales (
--  "customer_id" VARCHAR(1),
--  "order_date" DATE,
--  "product_id" INTEGER
--);

--INSERT INTO sales
--  ("customer_id", "order_date", "product_id")
--VALUES
--  ('A', '2021-01-01', '1'),
--  ('A', '2021-01-01', '2'),
--  ('A', '2021-01-07', '2'),
--  ('A', '2021-01-10', '3'),
--  ('A', '2021-01-11', '3'),
--  ('A', '2021-01-11', '3'),
--  ('B', '2021-01-01', '2'),
--  ('B', '2021-01-02', '2'),
--  ('B', '2021-01-04', '1'),
--  ('B', '2021-01-11', '1'),
--  ('B', '2021-01-16', '3'),
--  ('B', '2021-02-01', '3'),
--  ('C', '2021-01-01', '3'),
--  ('C', '2021-01-01', '3'),
--  ('C', '2021-01-07', '3');
 

--CREATE TABLE menu (
--  "product_id" INTEGER,
--  "product_name" VARCHAR(5),
--  "price" INTEGER
--);

--INSERT INTO menu
--  ("product_id", "product_name", "price")
--VALUES
--  ('1', 'sushi', '10'),
--  ('2', 'curry', '15'),
--  ('3', 'ramen', '12');
  

--CREATE TABLE members (
--  "customer_id" VARCHAR(1),
--  "join_date" DATE
--);

--INSERT INTO members
--  ("customer_id", "join_date")
--VALUES
--  ('A', '2021-01-07'),
--  ('B', '2021-01-09');

-- Q1
SELECT
  	sales.customer_id,
    SUM(price) AS Total_Price
FROM dbo.sales
LEFT JOIN dbo.menu ON menu.product_id = sales.product_id
GROUP BY customer_id
ORDER BY total_price DESC


-- Q2
SELECT
	customer_id,
    COUNT(DISTINCT(order_date))
FROM dbo.sales
GROUP BY customer_id;

-- Q3
WITH ordered_sales AS
(
  SELECT customer_id, order_date, product_name,
  DENSE_RANK() OVER(PARTITION BY sales.customer_id 
  ORDER BY sales.order_date) AS rank
  FROM dbo.sales
  JOIN dbo.menu
  ON sales.product_id = menu.product_id
  )
  
SELECT customer_id, product_name
FROM ordered_sales
WHERE rank = 1
GROUP BY customer_id, product_name

-- Q4
SELECT TOP 1
COUNT(customer_id) AS most_purchased, product_name
FROM dbo.sales
LEFT JOIN dbo.menu
ON menu.product_id = sales.product_id
GROUP BY product_name
ORDER BY most_purchased DESC;

-- Q5
WITH most_popular AS 
(
SELECT 
customer_id,
product_name,
COUNT(menu.product_id) AS num_orders,
DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY COUNT(menu.product_id) DESC) AS rank
FROM dbo.menu
JOIN dbo.sales 
ON menu.product_id = sales.product_id
GROUP BY sales.customer_id, menu.product_name)

SELECT customer_id, product_name, num_orders
FROM most_popular
WHERE rank = 1;

-- Q6
WITH diner_member_transactions AS
(
SELECT 
sales.customer_id,
sales.order_date, 
members.join_date,
sales.product_id, 
DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date) AS rank
FROM dbo.sales
LEFT JOIN dbo.members
ON sales.customer_id = members.customer_id
WHERE sales.order_date >= members.join_date
)

SELECT 
customer_id,
menu.product_name,
order_date
FROM diner_member_transactions
LEFT JOIN dbo.menu 
ON menu.product_id = diner_member_transactions.product_id
WHERE rank = 1
ORDER BY customer_id ASC;

-- Q7
WITH before_member_transactions AS
(
SELECT 
sales.customer_id,
sales.order_date, 
members.join_date,
sales.product_id, 
DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date DESC) AS rank
FROM dbo.sales
LEFT JOIN dbo.members
ON sales.customer_id = members.customer_id
WHERE sales.order_date < members.join_date
)

SELECT 
customer_id,
menu.product_name,
order_date
FROM before_member_transactions
LEFT JOIN dbo.menu 
ON menu.product_id = before_member_transactions.product_id
WHERE rank = 1
ORDER BY customer_id ASC;

-- Q8
WITH before_member_transactions AS
(
SELECT 
sales.customer_id,
sales.order_date, 
members.join_date,
sales.product_id 
FROM dbo.sales
LEFT JOIN dbo.members
ON sales.customer_id = members.customer_id
WHERE sales.order_date < members.join_date
)

SELECT 
customer_id, 
COUNT(menu.product_id) AS num_items, 
SUM(menu.price) AS total_spent 
FROM before_member_transactions
LEFT JOIN dbo.menu 
ON menu.product_id = before_member_transactions.product_id
GROUP BY customer_id;

-- Q9
WITH points AS
(
SELECT 
customer_id, 
sales.product_id,
menu.price,
CASE 
	WHEN sales.product_id = 1
    THEN (menu.price * 20)
    ELSE (menu.price * 10)
    END AS points
FROM
dbo.sales
LEFT JOIN dbo.menu
ON menu.product_id = sales.product_id)

SELECT customer_id, SUM(points) FROM points
GROUP BY customer_id
ORDER BY customer_id ASC;

-- Q10
WITH double_points_week AS
(
SELECT
*,
DATEADD(DAY, 6, join_date) AS double_points_date,
('2021-01-31') AS last_date
FROM 
dbo.members
)
 
SELECT
double_points_week.customer_id,
SUM(CASE
    WHEN menu.product_name = 'sushi' THEN 20 * menu.price
    WHEN sales.order_date BETWEEN double_points_week.join_date AND double_points_week.double_points_date THEN 20 * menu.price
    ELSE menu.price * 10
	END)
    AS points
FROM double_points_week
LEFT JOIN dbo.sales
ON double_points_week.customer_id = sales.customer_id
LEFT JOIN dbo.menu
ON sales.product_id = menu.product_id
WHERE sales.order_date < double_points_week.last_date
GROUP BY double_points_week.customer_id;

-- Q11
SELECT 
sales.customer_id,
sales.order_date,
menu.product_name,
menu.price,
CASE 
	WHEN sales.order_date >= members.join_date
    THEN 'Y'
    ELSE 'N'
    END AS member
FROM dbo.sales
LEFT JOIN dbo.menu
ON menu.product_id = sales.product_id
LEFT JOIN dbo.members
ON sales.customer_id = members.customer_id
ORDER BY customer_id, sales.order_date, menu.product_name;

-- Q12
WITH q11_table AS
(
SELECT 
sales.customer_id,
sales.order_date,
menu.product_name,
menu.price,
CASE 
	WHEN sales.order_date >= members.join_date
    THEN 'Y'
    ELSE 'N'
    END AS member
FROM dbo.sales
LEFT JOIN dbo.menu
ON menu.product_id = sales.product_id
LEFT JOIN dbo.members
ON sales.customer_id = members.customer_id
)

SELECT 
*,
CASE 
	WHEN q11_table.member = 'N' THEN NULL
    ELSE RANK() OVER(PARTITION BY customer_id, member ORDER BY customer_id, order_date, product_name) 
    END AS ranking
FROM q11_table;

