# Danny's Diner Case Study
Thank you Danny for the case study! You can find the case study [here](https://8weeksqlchallenge.com/case-study-1/).
## Introduction
<p align="center">
  <img width="700" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/158b40911c3db14133a2d955bd662cedfaee5d49/Pictures/danny's%20diner.png">
</p>

Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and which menu items are their favorites.

Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.
There are 3 key datasets for this case study, of which the relationship diagram between the three are shown below.

<p align="center">
  <img width="700" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/7fa4859dad1b81c75d80ef6b9b067ffd047e6842/Pictures/relationship%20diagram.jpg">
</p>

## Case Study Questions
1. What is the total amount each customer spent at the restaurant?
3. How many days has each customer visited the restaurant?
4. What was the first item from the menu purchased by each customer?
5. What is the most purchased item on the menu and how many times was it purchased by all customers?
6. Which item was the most popular for each customer?
7. Which item was purchased first by the customer after they became a member?
8. Which item was purchased just before the customer became a member?
9. What is the total items and amount spent for each member before they became a member?
10. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
11. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?
12. The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL. Recreate the following table output using the available data:
13. Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program. Recreate the following table output using the available data:

## Solutions
For this case study, I used PostgreSQL to query data for the solutions. Aggregate, numerical, joins, temporary tables, and windows functions were some of the main functions used to complete the case study.
### 1. What is the total amount each customer spent at the restaurant?
~~~ruby
SELECT
customer_id,
SUM(price) AS Total_Price
FROM dbo.sales
LEFT JOIN dbo.menu 
ON menu.product_id = sales.product_id
GROUP BY customer_id
ORDER BY total_price DESC
~~~

Steps: 
- LEFT JOIN menu table onto sales table through product_id.
- GROUP BY customer_id with aggregate function on "price" column to find out how much was spent by each customer.

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/cde92ca941817e7810bde54bf7a2d4cd0ea3e185/Pictures/Q1%20table.jpg">
</p>

- Customer A spent a total of $76.
- Customer B spent a total of $74.
- Customer C spent a total of $36.

### 2. How many days has each customer visited the restaurant?
~~~ruby
SELECT
    customer_id,
    COUNT(DISTINCT(order_date))
FROM dbo.sales
GROUP BY customer_id;
~~~

Steps:
- If they ordered two items in a single day, two of the same date will be recorded. Due to this, we can't just use COUNT to find the number of times they went to the resturant. To get around this, use DISTINCT on the order_date column in order to get unique days of which the customer went to the resturant.
- Use COUNT aggregate function in order to count all of the UNIQUE dates on which the customer went to the resturant
- Use GROUP BY customer_id to aggregate by each customer.

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/cde92ca941817e7810bde54bf7a2d4cd0ea3e185/Pictures/Q2%20table.jpg">
</p>

### 3. What was the first item from the menu purchased by each customer?
~~~ruby
WITH ordered_sales AS
(
  SELECT customer_id, order_date, product_name,
  DENSE_RANK() OVER(PARTITION BY sales.customer_id 
  ORDER BY sales.order_date) AS rank
  FROM dbo.sales
  JOIN dbo.menu
  ON sales.product_id = menu.product_id
  )
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/cde92ca941817e7810bde54bf7a2d4cd0ea3e185/Pictures/Q3%20table%201.jpg">
</p>

~~~ruby
SELECT customer_id, product_name
FROM ordered_sales
WHERE rank = 1
GROUP BY customer_id, product_name
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/cde92ca941817e7810bde54bf7a2d4cd0ea3e185/Pictures/Q3%20table%202.jpg">
</p>

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
~~~ruby
SELECT TOP 1
COUNT(customer_id) AS most_purchased, product_name
FROM dbo.sales
LEFT JOIN dbo.menu
ON menu.product_id = sales.product_id
GROUP BY product_name
ORDER BY most_purchased DESC;
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/5dcd3f3481d1bbcfa49fdd012ac0e4eed234f735/Pictures/Q4%20table.jpg">
</p>

### 5. Which item was the most popular for each customer?
~~~ruby
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
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/5dcd3f3481d1bbcfa49fdd012ac0e4eed234f735/Pictures/Q5%20table%201.jpg">
</p>

~~~ruby
SELECT customer_id, product_name, num_orders
FROM most_popular
WHERE rank = 1;
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/5dcd3f3481d1bbcfa49fdd012ac0e4eed234f735/Pictures/Q5%20table%202.jpg">
</p>

### 6. Which item was purchased first by the customer after they became a member?
~~~ruby
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
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/5dcd3f3481d1bbcfa49fdd012ac0e4eed234f735/Pictures/Q6%20table%201.jpg">
</p>

~~~ruby
SELECT 
customer_id,
menu.product_name,
order_date
FROM diner_member_transactions
LEFT JOIN dbo.menu 
ON menu.product_id = diner_member_transactions.product_id
WHERE rank = 1
ORDER BY customer_id ASC;
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/5dcd3f3481d1bbcfa49fdd012ac0e4eed234f735/Pictures/Q6%20table%202.jpg">
</p>

### 7. Which item was purchased just before the customer became a member?
~~~ruby
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
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/5dcd3f3481d1bbcfa49fdd012ac0e4eed234f735/Pictures/Q7%20table%201.jpg">
</p>

~~~ruby
SELECT 
customer_id,
menu.product_name,
order_date
FROM before_member_transactions
LEFT JOIN dbo.menu 
ON menu.product_id = before_member_transactions.product_id
WHERE rank = 1
ORDER BY customer_id ASC;
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/5dcd3f3481d1bbcfa49fdd012ac0e4eed234f735/Pictures/Q7%20table%202.jpg">
</p>

### 8. What is the total items and amount spent for each member before they became a member?
~~~ruby
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
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/d1f1184738ddfa2e3ea176b1438989b165beede5/Pictures/Q8%20table%201.jpg">
</p>

~~~ruby
SELECT 
customer_id, 
COUNT(menu.product_id) AS num_items, 
SUM(menu.price) AS total_spent 
FROM before_member_transactions
LEFT JOIN dbo.menu 
ON menu.product_id = before_member_transactions.product_id
GROUP BY customer_id;
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/d1f1184738ddfa2e3ea176b1438989b165beede5/Pictures/Q8%20table%202.jpg">
</p>

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
~~~ruby
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
ON menu.product_id = sales.product_id
)
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/d1f1184738ddfa2e3ea176b1438989b165beede5/Pictures/Q9%20table%201.jpg">
</p>

~~~ruby
SELECT customer_id, SUM(points) FROM points
GROUP BY customer_id
ORDER BY customer_id ASC;
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/d1f1184738ddfa2e3ea176b1438989b165beede5/Pictures/Q9%20table%202.jpg">
</p>

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?
~~~ruby
WITH double_points_week AS
(
SELECT
*,
DATEADD(DAY, 6, join_date) AS double_points_date,
EOMONTH('2021-01-31') AS last_date
FROM 
dbo.members
)
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/d1f1184738ddfa2e3ea176b1438989b165beede5/Pictures/Q10%20table%201.jpg">
</p>

~~~ruby
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
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/d1f1184738ddfa2e3ea176b1438989b165beede5/Pictures/Q10%20table%202.jpg">
</p>

### 11. The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL. Recreate the following table output using the available data:
~~~ruby
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
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/d1f1184738ddfa2e3ea176b1438989b165beede5/Pictures/Q11%20table.jpg">
</p>

### 12. Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program. Recreate the following table output using the available data:
~~~ruby
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
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/d1f1184738ddfa2e3ea176b1438989b165beede5/Pictures/Q12%20table%201.jpg">
</p>

~~~ruby
SELECT 
*,
CASE 
	WHEN q11_table.member = 'N' THEN NULL
    ELSE RANK() OVER(PARTITION BY customer_id, member ORDER BY customer_id, order_date, product_name) 
    END AS ranking
FROM q11_table;
~~~

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/d1f1184738ddfa2e3ea176b1438989b165beede5/Pictures/Q12%20table%202.jpg">
</p>
