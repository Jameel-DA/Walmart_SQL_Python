-- Walmart Project Queries - MySQL

SELECT * FROM walmart.walmart_data;

select database();

use walmart;

rename table wal to walmart_data;

show tables;

-- Exploratory Data Analysis

-- Count total records
select count(*) as total_rows from walmart_data;

-- Count payment methods and number of transactions by payment method
select payment_method, count(*)  as Total_Transaction from walmart_data
group by payment_method;

-- Count distinct branches
select count(distinct(branch)) from walmart_data;

-- Find the minimum quantity sold
select min(quantity) from walmart_data;

-- Business Problem Q1: Find different payment methods, number of transactions, and quantity sold by payment method
select payment_method,count(*) as no_of_transaction,sum(quantity) as total_quantity_sold from walmart_data
group by payment_method;

-- Project Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
SELECT branch, category, avg_rating
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS r
    FROM walmart_data
    GROUP BY branch, category
) AS ranked
WHERE r = 1;

-- Q3: Identify the busiest day for each branch based on the number of transactions
SELECT branch, day_name, no_transactions,rank1
FROM (
    SELECT 
        branch,
        COUNT(*) AS no_transactions,
        dayname(date) as day_name,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank1
    FROM walmart_data
    GROUP BY branch, day_name
) AS ranked
WHERE rank1 = 1;

-- Q4: Calculate the total quantity of items sold per payment method
select payment_method,sum(quantity) from walmart_data
group by payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city
select city,category,avg(rating),min(rating),max(rating) from walmart_data
group by city,category;

-- Q6: Calculate the total profit for each category
select category,sum(unit_price * quantity * profit_margin) as total_profit from walmart_data
group by category
ORDER BY total_profit DESC;

-- Q7: Determine the most common payment method for each branch
with t as
(select 
branch,payment_method, count(*), 
rank() over(partition by branch order by count(*) desc) as r 
from walmart_data
group by 1,2)
select * from t where r = 1;


-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT branch, 
    CASE 
        WHEN HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    count(*)
FROM walmart_data
group by 1,2
order by 1,3; 

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total_price) AS revenue
    FROM walmart_data
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total_price) AS revenue
    FROM walmart_data
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;
