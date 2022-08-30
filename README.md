# Danny's Diner Case Study
Thank you Danny for the case study! You can find the case study [here](https://8weeksqlchallenge.com/case-study-1/).
## Introduction
![ramen bowl](https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/a6d4f26a7be5f110a1f632b934184aa2d3c5d5fb/Pictures/danny's%20diner.png)

Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their:
- visiting patterns
- how much money they’ve spent and
- which menu items are their favourite.

Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.
There are 3 key datasets for this case study, of which the relationship diagram between the three are shown below.

<p align="center">
  <img width="460" height="300" src="https://github.com/Equinnax711/Dannys-Diner-Case-Study/blob/7fa4859dad1b81c75d80ef6b9b067ffd047e6842/Pictures/relationship%20diagram.jpg">
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
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu 
ON menu.product_id = sales.product_id
GROUP BY customer_id
ORDER BY total_price DESC
~~~

### 2. How many days has each customer visited the restaurant?
~~~ruby
SELECT
	customer_id,
    COUNT(DISTINCT(order_date))
FROM dannys_diner.sales
GROUP BY customer_id
~~~
### 3. What was the first item from the menu purchased by each customer?
~~~
WITH ordered_sales AS
(
  SELECT customer_id, order_date, product_name,
  DENSE_RANK() OVER(PARTITION BY sales.customer_id 
  ORDER BY sales.order_date) AS rank
  FROM dannys_diner.sales
  JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
  )
~~~
~~~
SELECT customer_id, product_name
FROM ordered_sales
WHERE rank = 1
GROUP BY customer_id, product_name
~~~
### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
### 5. Which item was the most popular for each customer?
### 6. Which item was purchased first by the customer after they became a member?
### 7. Which item was purchased just before the customer became a member?
### 8. What is the total items and amount spent for each member before they became a member?
### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?
### 11. The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL. Recreate the following table output using the available data:
### 12. Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program. Recreate the following table output using the available data:
