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
4. What was the first item from the menu by each customer?
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

Conclusion:
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

Conclusion:
- Customer A visited the restaurant 4 times.
- Customer B visited the restaurant 6 times.
- Customer C visited the restaurant 2 times.


### 3. What was the first item from the menu purchased by each customer?
~~~ruby
WITH ordered_sales AS
(
  SELECT customer_id, order_date, product_name,
  DENSE_RANK() OVER(PARTITION BY sales.customer_id 
  ORDER BY sales.order_date) AS rank
  FROM dbo.sales
  LEFT JOIN dbo.menu
  ON sales.product_id = menu.product_id
  )
~~~

Steps:
- Create an intermediate table.
- LEFT JOIN the menu table onto the sales table through product id in order to have the product_name column in the intermediate table.
- Use DENSE_RANK with PARTITION BY in order to rank each transaction by order date (ASC in order to have the earliest date rank the lowest) within each subset of different customer_id.

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/cde92ca941817e7810bde54bf7a2d4cd0ea3e185/Pictures/Q3%20table%201.jpg">
</p>

~~~ruby
SELECT customer_id, product_name
FROM ordered_sales
WHERE rank = 1
GROUP BY customer_id, product_name
~~~
Steps:
- From the intermediate table, select the two needed columns for the question, customer_id and product_name.
- Use the WHERE function to keep rows that have "1" for their rank. We do this because the "1" in the rank column means that this is the first transaction that was made by each customer.
- GROUP BY both customer_id and product_name to make sure all unique combinations are output.

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/cde92ca941817e7810bde54bf7a2d4cd0ea3e185/Pictures/Q3%20table%202.jpg">
</p>

Conclusion:
- Customer A's first items were curry and sushi. He has two first items because they were purchased on the same day and we don't have the information to conclude which one was ordered first.
- Customer B's first item was curry.
- Customer C's first item was ramen.


### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
~~~ruby
SELECT TOP 1
COUNT(customer_id) AS most_purchased, 
product_name
FROM dbo.sales
LEFT JOIN dbo.menu
ON menu.product_id = sales.product_id
GROUP BY product_name
ORDER BY most_purchased DESC;
~~~

Steps:
- LEFT JOIN the menu table onto the sales table through product_id to move the product_name column over.
- Use the aggregate function COUNT in order to count the number of times a customer ordered a product.
- GROUP BY product_name to aggregate by product_name, get a count of the number of times each product was ordered.
- ORDER BY DESC on the "most_purchased" column to find the most_purchased product
- Use TOP 1 to select the first row of the output table. 

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/5dcd3f3481d1bbcfa49fdd012ac0e4eed234f735/Pictures/Q4%20table.jpg">
</p>

Conclusion:
- The most purchased item on the menu was ramen and it was purchased to total of 8 times.


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
LEFT JOIN dbo.sales 
ON menu.product_id = sales.product_id
GROUP BY sales.customer_id, menu.product_name
)
~~~

Steps:
- Create an intermediate table.
- COUNT the number of product_ids and name the column as num_orders
- LEFT JOIN the menu table onto the sales table through the product_id column to bring the product_name column over.
- GROUP BY both customer_id and product_name to get the total counts of each unique product that each customer bought.
- Use DENSE_RANK() along with PARTITION BY to rank the products by most ordered to least ordered within each subset of unique customer_id

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/5dcd3f3481d1bbcfa49fdd012ac0e4eed234f735/Pictures/Q5%20table%201.jpg">
</p>

~~~ruby
SELECT customer_id, product_name, num_orders
FROM most_popular
WHERE rank = 1;
~~~

Steps:
- From the intermediate table, select the three needed columns for the question, customer_id, product_name, and num_orders.
- Use the WHERE function to keep rows that have "1" for their rank. We do this because the "1" in the rank column means that this is the product that each customer bought the most.

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/5dcd3f3481d1bbcfa49fdd012ac0e4eed234f735/Pictures/Q5%20table%202.jpg">
</p>

Conclusion:
- Customer A bought ramen the most with a total of 3 purchases.
- Customer B purchased ramen, curry, and sushi two times each.
- Customer C bought ramen the most with a total of 3 purchases


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

Steps:
- Create an intermediate table.
- LEFT JOIN the members table onto the sales table through the customer_id column to bring the join_date column over.
- Use WHERE to filter out all transactions that happened after customers became members.
- Use DENSE_RANK() along with PARTITION BY to rank the transaction dates by ASCENDING order_date within each subset of unique customer_id.

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

Steps:
- From the intermediate table, select the three needed columns for the question, customer_id, product_name, and order_date.
- LEFT JOIN the menu table onto the intermediate table through product_id to bring the product_name column over
- Use WHERE to select all rows where the rank is 1. In this case, when rank = 1, it represents the earliest transaction at which the person was a member.

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/5dcd3f3481d1bbcfa49fdd012ac0e4eed234f735/Pictures/Q6%20table%202.jpg">
</p>

Conclusion:
- The item purchased first by customer A after they became a member was curry.
- The item purchased first by customer B after they became a member was sushi.
- Customer C never became a member, therefore leaving them with no first meal purchased after becoming a member.


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

Steps:
- Create an intermediate table.
- LEFT JOIN the members table onto the sales table through the customer_id column to bring the join_date column over.
- Use WHERE to filter out all transactions that happened before customers became members.
- Use DENSE_RANK() along with PARTITION BY to rank the transaction dates by DESCENDING order_date within each subset of unique customer_id.

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

Steps:
- From the intermediate table, select the three needed columns for the question, customer_id, product_name, and order_date.
- LEFT JOIN the menu table onto the intermediate table through product_id to bring the product_name column over
- Use WHERE to select all rows where the rank is 1. In this case, when rank = 1, it represents the latest transaction at which the person was not a member.

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/5dcd3f3481d1bbcfa49fdd012ac0e4eed234f735/Pictures/Q7%20table%202.jpg">
</p>

Conclusion:
- Customer A bought both sushi and curry just before becoming a member.
- Customer B bought sushi just before becoming a member.
- Customer C never became a member, therefore leaving them with no meal purchased before becoming a member.


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

Steps:
- Create an intermediate table.
- LEFT JOIN the members table onto the sales table through the customer_id column to bring the join_date column over.
- Use WHERE to filter out all transactions that happened before customers became members.

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

Steps:
- Select the intermediate table.
- LEFT JOIN the menu table onto the intermediate table through product_id to bring the product_name column over.
- Use COUNT to aggregate the amount of products bought and SUM to add up all the money spent by each customer.
- Use GROUP BY on customer_id to apply the aggregate functions on each of the customer_ids.

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/d1f1184738ddfa2e3ea176b1438989b165beede5/Pictures/Q8%20table%202.jpg">
</p>

Conlusion:
- Customer A bought 2 items and spent a total of 25 dollars.
- Customer B bought 3 items and spent a total of 40 dollars.
- Customer C never became a member.


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

Steps:
- Create an intermediate table.
- Use the CASE statement to create the points column. Because sushi gives us a 2x points multiplier, using the CASE statement allows us to multiply the price value by 2 when the row's product_id is "1", which is sushi. In all other scenarios of product_id, the price is multiplied by 10.
- LEFT JOIN the menu table onto the sales table through the product_id column to bring the price column over.

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/d1f1184738ddfa2e3ea176b1438989b165beede5/Pictures/Q9%20table%201.jpg">
</p>

~~~ruby
SELECT customer_id, SUM(points) FROM points
GROUP BY customer_id
ORDER BY customer_id ASC;
~~~

Steps:
- Select the intermediate table.
- Use SUM to sum together the number of points collected by each customer.
- Use GROUP BY on customer_id to apply the aggregate functions on each of the customer_ids.

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/d1f1184738ddfa2e3ea176b1438989b165beede5/Pictures/Q9%20table%202.jpg">
</p>

Conclusion:
- Customer A had a sum of 860 points.
- Customer B had a sum of 940 points.
- Customer C had a sum of 360 points.


### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?
~~~ruby
WITH double_points_week AS
(
SELECT
*,
DATEADD(DAY, 6, join_date) AS double_points_date,
('2021-01-31') AS last_date
FROM 
dbo.members
)
~~~

Steps:
- Create an intermediate table with the members table.
- Create a column that tells us the last date at which each customer earns 2x points on all items, use the DATEADD function to add 6 days onto the date where each customer joined the membership program
- Create a column that states the date at the end of January.

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

Steps:
- Select the intermediate table.
- Use SUM along with CASE to sum together different scenarios of gaining points:
  - If the product_name is "sushi, then multiply the price by 20.
  - If the order date is between the membership join date and the last date at which the customer earns 2x points on all items, then multiply the price by 20.
  - In all other scenarios, multiply the price by 10.
- LEFT JOIN the sales table onto the intermediate table through customer_id to move the order_date column over.
- LEFT JOIN the menu table onto the sales table through the product_id to move the product_name column over.
- Use GROUP BY on customer_id to apply the aggregate functions on each of the customer_ids.

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/d1f1184738ddfa2e3ea176b1438989b165beede5/Pictures/Q10%20table%202.jpg">
</p>

Conclusion:
- Customer A had a total of 1370 points at the end of January
- Customer B had a total of 820 points at the end of January


### 11. The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL. Recreate the following table output using the available data:

<p align="center">
  <img width="1000" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/16583b5c8ea750108b2de9ce6b8566470ac2c14f/Pictures/recreate%20this%20table.jpg">
</p>

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

Steps:
- Select the columns that are shown in the original table, customer_id, order_date, product_name, and price. The member column will have to be created.
- To create the member column, use a CASE statement:
  - If the transaction happened after the corresponding customer's membership join date, then output "Y".
  - In all other scenarios, output "N".
- LEFT JOIN the menu table onto the sales table through product_id to bring the price and product_name column over.
- LEFT JOIN the members table onto the sales table through customer_id to bring the join_date column over.
- Use ORDER BY on customer_id, order_date, and product_name in that order to place all the data in the same order as the original table.

Final Table:
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
