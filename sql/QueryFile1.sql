/*
NovaSlice Pizza
SQL Analysis Script

Author: Adnan Haider
Purpose: End to end SQL analysis of NovaSlice Pizza’s transactional dataset.

This script contains all twenty analytical query sections aligned with the business 
objectives and business questions defined in the project README.

Schema definitions for all tables are stored separately in:
schemas/schema.sql

Do not run the full script at once.
Run each section individually.

---------------------------------------
Section index
---------------------------------------
1. Orders Volume Analysis
2. Total Revenue from Pizza Sales
3. Highest Priced Pizza
4. Most Common Pizza Size
5. Top 5 Pizza Types by Units Sold
6. Total Quantity by Category
7. Orders by Hour
8. Category Share of Units Sold
9. Average Pizzas Per Day
10. Top 3 Pizzas by Revenue
11. Revenue Contribution per Pizza
12. Cumulative Revenue Over Time
13. Top 3 Pizzas per Category
14. Top 10 Customers by Total Spend
15. Orders by Weekday
16. Average Order Size
17. Seasonal Trends
18. Revenue by Pizza Size
19. Customer Segmentation
20. Repeat Customer Rate
*/



/*
----------------------
Analysis and Reporting
----------------------
*/


/* ---------------------------------------
   Section 1: Orders Volume Analysis
---------------------------------------- */

/*
Stakeholder: Operations Manager

"We are trying to understand our order volume in detail so we can measure store performance and benchmark growth.
Instead of just knowing the total number of unique orders, I'd like a deeper breakdown"

1.1: What is the total number of unique orders placed so far?
1.2: How has this order volume changed month-over-month?
1.3: Can we identify peak and off-peak ordering days?
1.4: How do order volumes vary by day of the week (e.g., weekends vs. weekdays)?
1.5: What is the average number of orders per customer?
1.6: Who are our top repeat customers driving the order volume?
1.7: Can you also project the expected order growth trend based on historical data?

Analyst Tasks:
1.1: Count the total number of unique orders (COUNT(DISTINCT order_id)).
1.2: Break down orders by year and month using YEAR(order_date) and MONTH(order_date), 
     and calculate month over month growth percentage using LAG(order_count) OVER(ORDER BY month_start)
1.3: Find day wise order distribution using DATENAME(weekday, order_date)
1.4: Classify each day as weekday or weekend using a CASE expression on DATENAME(weekday, order_date)
     and compare total orders by that classification
1.5: Compute average orders per customer as COUNT(DISTINCT order_id) divided by COUNT(DISTINCT custid)
1.6: Identify repeat customers and their order frequency using GROUP BY custid and HAVING COUNT(DISTINCT order_id) greater than one
1.7: Build a trend projection using cumulative counts of orders with SUM(order_count) OVER(ORDER BY month_start)

*/

-- 1.1 
SELECT COUNT(DISTINCT order_id) FROM orders;

-- 1.2
WITH monthly_orders AS (
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start,
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
),
monthly_with_lags AS (
    SELECT
        month_start,
        order_count,
        LAG(order_count) OVER (ORDER BY month_start) AS prev_month
    FROM monthly_orders
)
SELECT
    month_start,
    order_count,
    prev_month,
    CAST(
        ROUND(
            100.0 * (order_count - prev_month)
            / NULLIF(prev_month, 0),
            2
        ) AS DECIMAL(10, 2)
    ) AS mom_growth_pct
FROM monthly_with_lags
ORDER BY month_start;

-- 1.3
SELECT
    DATENAME(weekday, order_date) AS weekday_name,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY DATENAME(weekday, order_date)
ORDER BY total_orders;

-- 1.4
WITH orders_with_dow AS (
    SELECT
        order_id,
        order_date,
        DATENAME(weekday, order_date) AS weekday_name,
        CASE 
            WHEN DATENAME(weekday, order_date) IN ('Saturday', 'Sunday') 
                THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_type
    FROM orders
)
SELECT
    weekday_name,
    day_type,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders_with_dow
GROUP BY
    weekday_name,
    day_type
ORDER BY
    CASE weekday_name
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

-- 1.5
SELECT
    CAST(
        COUNT(DISTINCT order_id) * 1.0 / COUNT(DISTINCT custid)
        AS DECIMAL(10,2)
    ) AS avg_orders_per_customer
FROM orders;

-- 1.6
SELECT
    c.custid,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT o.order_id) AS order_count
FROM orders AS o
JOIN customers AS c
    ON c.custid = o.custid
GROUP BY
    c.custid,
    c.first_name,
    c.last_name
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY order_count DESC;

-- 1.7

WITH monthly_orders AS (
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start,
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
),
monthly_with_windows AS (
    SELECT
        month_start,
        order_count,
        LAG(order_count) OVER (ORDER BY month_start) AS prev_month,
        SUM(order_count) OVER (
            ORDER BY month_start
            ROWS UNBOUNDED PRECEDING
        ) AS cumulative_orders
    FROM monthly_orders
)
SELECT
    month_start,
    order_count,
    prev_month,
    CAST(
        ROUND(
            100.0 * (order_count - prev_month)
            / NULLIF(prev_month, 0),
            2
        ) AS DECIMAL(10, 2)
    ) AS mom_growth_pct,
    cumulative_orders
FROM monthly_with_windows
ORDER BY month_start;



/* ---------------------------------------
   Section 2: Total Revenue from Pizza Sales
---------------------------------------- */

/*

Stakeholder: Finance Team

"We need the total revenue generated from all pizza sales so far. 
Please calculate overall revenue by multiplying price and quantity for every pizza sold 
across all orders."

Analyst Tasks:
2.0: Join order_details with pizzas and sum (price * quantity).

*/

-- 2.0
SELECT SUM(od.quantity * p.price) AS total_revenue
FROM order_details AS od
JOIN pizzas AS p
    ON od.pizza_id = p.pizza_id;


/* ---------------------------------------
   Section 3: Highest-Priced Pizza
---------------------------------------- */

/*
Stakeholder: Menu Manager

"Our premium pizzas must be correctly priced. Can you find out which pizza has the 
highest price on our menu and confirm its category and size?"

Analyst Task:
3.0: Query the pizzas table for the maximum price, joining with pizza_types for details.

*/

-- 3.0
SELECT
    pt.name,
    pt.category,
    p.size,
    p.price
FROM pizzas AS p
JOIN pizza_types AS pt
    ON p.pizza_type_id = pt.pizza_type_id
WHERE p.price = (SELECT MAX(price) FROM pizzas);


/* ---------------------------------------
   Section 4: Most Common Pizza Size Ordered
---------------------------------------- */

/*
Stakeholder: Logistics Manager

"To optimize packaging and raw materials supply. I need to know which pizza size (S, M, L, XL, XXL) is ordered the most."

Analyst Task:
4.0: Count and group orders by pizza size from pizzas + order_details.
*/

-- 4.0
SELECT TOP 1
    p.size,
    COUNT(*) AS total_orders
FROM order_details AS od
JOIN pizzas AS p
    ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_orders DESC;

/* ---------------------------------------
   Section 5: Top 5 Pizza Types by Units Sold
---------------------------------------- */

/*
Stakeholder: Product Head

"We want to promote our top-selling pizzas. Can you provide the top 5 pizza types ordered by quantity, along with the exact number
of units sold?"

Analyst Task:
Join order_details with pizza_types, group by pizza name, and rank top 5.
*/

-- 5.0
SELECT TOP 5
    pt.name AS pizza_type,
    SUM(od.quantity) AS total_quantity_ordered
FROM order_details AS od
JOIN pizzas AS p
    ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY
    pt.name
ORDER BY
    total_quantity_ordered DESC;


/* ---------------------------------------
   Section 6: Total Quantity by Pizza Category
---------------------------------------- */

/*
Stakeholder: Marketing Manager

"We run promotions based on categories (Classic, Veggie, Supreme, Chicken, etc.).
Can you calculate the total number of pizzas sold in each category so we can plan targetted campaigns?"

Analyst Task:
Join pizzas with pizza_types and sum quantities by category.
*/

-- 6.0
SELECT
    pt.category,
    SUM(od.quantity) AS total_qty
FROM order_details AS od
JOIN pizzas AS p 
    ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt 
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_qty DESC;


/* ---------------------------------------
   Section 7: Orders by Hour of Day
---------------------------------------- */

/*
Stakeholder: Operations Head

"When are customers ordering the most? Do they prefer lunch (12-2 PM),
evenings (6-9 PM), or late-night? Please give me a distribution of orders
by hour of the day so we can adjust staffing."

Analyst Task:
Extract the hour from the order_time in orders table and count frequency.
*/

-- 7.0
SELECT
    RIGHT('0' + CAST(DATEPART(HOUR, CAST(order_time AS time)) AS varchar(2)), 2) 
        + ':00' AS order_hour,
    COUNT(*) AS order_count
FROM orders
GROUP BY DATEPART(HOUR, CAST(order_time AS time))
ORDER BY DATEPART(HOUR, CAST(order_time AS time));


/* ---------------------------------------
   Section 8: Category-wise Pizza Distribution
---------------------------------------- */

/*
Stakeholder: Product strategy team

"Which categories (like Veggie, Chicken, Supreme) dominate our menu sales? Can you prepare a breakdown of orders
 per category with percentage share?"

Analyst Task:
Join tables and calculate share of each category.
*/

-- 8.0
SELECT
    pt.category,
    SUM(od.quantity) AS total_units_sold,
    CAST(
        100.0 * SUM(od.quantity)
        / SUM(SUM(od.quantity)) OVER ()
        AS DECIMAL(10, 2)
    ) AS pct_share_of_units
FROM order_details AS od
JOIN pizzas AS p
    ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_units_sold DESC;


/* ---------------------------------------
   Section 9: Average Pizzas Ordered per Day
---------------------------------------- */

/*
Stakeholder: CEO

"I want to see if our daily demand is consistent.
Can you group orders by date and tell me the average number of pizzas ordered per day?"

Analyst Task:
Aggregate by order_date, calculate total pizzas per day, then average.
*/

-- 9.0
SELECT AVG(daily_total) AS avg_pizzas_per_day
FROM (
    SELECT 
        o.order_date, 
        SUM(od.quantity) AS daily_total
    FROM orders o
    JOIN order_details od 
        ON o.order_id = od.order_id
    GROUP BY o.order_date
) t;


/* ---------------------------------------
   Section 10: Top 3 Pizzas by Revenue
---------------------------------------- */

/*
Stakeholder: Finance Team

"We need to know which pizzas are our biggest revenue drivers. Please provide the top 3 pizzas by revenue generated."

Analyst Task:
Calculate revenue per pizza (price * quantity) and rank top 3.
*/

-- 10.0
WITH pizza_revenue AS (
    SELECT 
        pt.name,
        SUM(od.quantity * p.price) AS revenue,
        RANK() OVER (ORDER BY SUM(od.quantity * p.price) DESC) AS rank
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.name
)
SELECT 
    name,
    revenue
FROM pizza_revenue
WHERE rank <= 3;

/* ---------------------------------------
   Section 11: Revenue Contribution per Pizza
---------------------------------------- */

/*
Stakeholder: CFO

"For our revenue mix analysis, I need to know what percentage of total revenue each pizza contributes.
This will show which items carry the business."

Analyst Task:
Divide revenue of each pizza by total revenue, express it in %.
*/

-- 11.0
SELECT
    pt.name,
    SUM(od.quantity * p.price) AS revenue,
    CONCAT(
        CAST(
            ROUND(
                100.0 * SUM(od.quantity * p.price)
                / SUM(SUM(od.quantity * p.price)) OVER (),
                2
            ) AS DECIMAL(10, 2)
        ),
        '%'
    ) AS pct_contribution
FROM order_details AS od
JOIN pizzas AS p 
    ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt 
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY
    ROUND(
        100.0 * SUM(od.quantity * p.price)
        / SUM(SUM(od.quantity * p.price)) OVER (),
        2
    ) DESC;


/* ---------------------------------------
   Section 12: Cumulative Revenue Over Time
---------------------------------------- */

/*
Stakeholder: Board of Directors

"We want to see how our cumulative revenue has grown month by month since launch.
 Can you prepare a cumulative revenue trend line?"

Analyst Task:
Aggregate revenue by date/month and calculate running total.
*/

-- 12.0

SELECT
    order_date,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT
        o.order_date,
        SUM(od.quantity * p.price) AS daily_revenue
    FROM
        orders AS o
        JOIN order_details AS od ON o.order_id = od.order_id
        JOIN pizzas AS p ON od.pizza_id = p.pizza_id
    GROUP BY
        o.order_date
) AS t;

/* ---------------------------------------
   Section 13: Top 3 Pizzas by Category (Revenue-based)
---------------------------------------- */

/*
Stakeholder: Product Head

"Within each pizza category, which 3 pizzas bring the most revenue?
This will help us decide which pizzas to promote or expand."

Analyst Task:
Partition by category, calculate revenue per pizza, rank top 3.
*/

-- 13.0

WITH cat_rank AS (
    SELECT
        pt.category,
        pt.name,
        SUM(od.quantity * p.price) AS revenue,
        RANK() OVER (
            PARTITION BY pt.category
            ORDER BY SUM(od.quantity * p.price) DESC
        ) AS rnk
    FROM order_details AS od
    JOIN pizzas AS p
        ON od.pizza_id = p.pizza_id
    JOIN pizza_types AS pt
        ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY
        pt.category,
        pt.name
)
SELECT
    category,
    name,
    revenue
FROM cat_rank
WHERE rnk <= 3;


/* ---------------------------------------
   Section 14: Top 10 Customers by Spending
---------------------------------------- */

/*
Stakeholder: Customer Retention Manager

"Who are our top 10 customers based on total spend? 
We want to reward them with loyalty offers."

*/

-- 14.0

SELECT TOP 10
    c.custid,
    c.first_name + ' ' + c.last_name AS full_name,
    SUM(od.quantity * p.price) AS total_spent
FROM customers AS c
JOIN orders AS o
    ON c.custid = o.custid
JOIN order_details AS od
    ON o.order_id = od.order_id
JOIN pizzas AS p
    ON od.pizza_id = p.pizza_id
GROUP BY
    c.custid,
    c.first_name,
    c.last_name
ORDER BY
    total_spent DESC;

/* ---------------------------------------
   Section 15: Orders by Weekday
---------------------------------------- */

/*
Stakeholder: Marketing Team

"Which days of the week are busiest for orders?
Do customers order more on weekends?"
*/

-- 15.1: Which days of the week are busiest for orders?
SELECT
    DATENAME(weekday, order_date) AS weekday_name,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY
    DATENAME(weekday, order_date)
ORDER BY
    total_orders DESC;

-- 15.2: Do customers order more on weekends?
SELECT
    CASE
        WHEN DATENAME(weekday, order_date) IN ('Saturday', 'Sunday')
            THEN 'weekend'
        ELSE 'weekday'
    END AS day_type,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY
    CASE
        WHEN DATENAME(weekday, order_date) IN ('Saturday', 'Sunday')
            THEN 'weekend'
        ELSE 'weekday'
    END
ORDER BY
    total_orders DESC;


/* ---------------------------------------
   Section 16: Average Order Size
---------------------------------------- */

/*
Stakeholder: Supply Chain Manager

"What's the average number of pizzas per order?
This helps us in planning inventory and staffing"
*/

-- 16.0

SELECT
    AVG(order_size) AS avg_order_size
FROM (
    SELECT
        od.order_id,
        SUM(od.quantity) AS order_size
    FROM order_details AS od
    GROUP BY
        od.order_id
) AS t;

/* ---------------------------------------
   Section 17: Seasonal Trends
---------------------------------------- */

/*
Stakeholder: Operations Manager

"Do we see peak sales in certain months or holidays? 
This will help us manage seasonal demand"
*/

-- 17.0

SELECT
    DATENAME(month, order_date) AS month_name,
    COUNT(*) AS total_orders
FROM orders
GROUP BY
    DATENAME(month, order_date)
ORDER BY
    MIN(order_date);

/* ---------------------------------------
   Section 18: Revenue by Pizza Size
---------------------------------------- */

/*
Stakeholder: Finance head

"What is the revenue contribution of each pizza size (S, M, L, XL, XXL)?"
*/

-- 18.0
SELECT
    p.size,
    SUM(od.quantity * p.price) AS revenue
FROM order_details AS od
JOIN pizzas AS p
    ON od.pizza_id = p.pizza_id
GROUP BY
    p.size
ORDER BY
    revenue DESC;


/* ---------------------------------------
   Section 19: Customer Segmentation
---------------------------------------- */

/*
Stakeholder: Customer Insights Team

"Do our high-value customers prefer premium pizzas or regular pizzas? We want to personalize marketing."
*/

-- 19.0

WITH cust_spend AS (
    SELECT 
        c.custid, 
        SUM(od.quantity * p.price) AS total_spent
    FROM customers AS c
    JOIN orders AS o 
        ON c.custid = o.custid
    JOIN order_details AS od 
        ON o.order_id = od.order_id
    JOIN pizzas AS p 
        ON od.pizza_id = p.pizza_id
    GROUP BY 
        c.custid
)
SELECT 
    CASE 
        WHEN total_spent > 500 THEN 'High Value' 
        ELSE 'Regular' 
    END AS segment,
    COUNT(*) AS customer_count
FROM cust_spend
GROUP BY 
    CASE 
        WHEN total_spent > 500 THEN 'High Value' 
        ELSE 'Regular' 
    END;

/* ---------------------------------------
   Section 20: Repeat Customer Rate
---------------------------------------- */

/*
Stakeholder: CRM Head - Customer Relationship Manager

"We want to measure customer loyalty. Can you calculate the percentage
of repeat customers (customers who placed more than one order) versus 
one-time buyers?" This will help us design retention campaign.

Analyst Tasks:
 From the orders table, count distinct customers.
 Count how many customers have more than one order.
 Calculate repeat rate = (repeat customers / total customers) * 100
*/

-- 20.0
WITH cust_orders AS (
    SELECT 
        custid, 
        COUNT(DISTINCT order_id) AS order_count
    FROM orders
    GROUP BY custid
)
SELECT 
    CAST(
        ROUND(
            100.0 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
            / COUNT(*),
            2
        ) 
        AS DECIMAL(10, 2)
    ) AS repeat_rate
FROM cust_orders;
