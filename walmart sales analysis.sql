-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;

-- Create table
CREATE TABLE IF NOT EXISTS sales(
     invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
     branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- -------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------Feature Engineering-----------------------------------------------
-- Add the time_of_day column
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;

alter table sales add column time_of_day varchar(20);

update sales 
set time_of_day = (
     CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
     END
);

-- Add day_name column
select date, dayname(date) as day_name from sales;

alter table sales add column day_name varchar(20);

update sales
set day_name = dayname(date);

-- Add month_name column
SELECT
	date,
	MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- -------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------Generic--------------------------------------------------------
-- How many unique cities does the data have?
select distinct(city) from sales;

-- In which city is each branch?
SELECT 
	DISTINCT city,
    branch
FROM sales;

-- -------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------Product----------------------------------------------------------
-- How many unique product lines does the data have?
select count(distinct product_line) as prd from sales;

-- What is the most selling product line
select product_line, count(product_line) as cnt
from sales
group by product_line
order by cnt desc ;

-- What is the most common payment method?
select payment, count(payment) as pay
from sales
group by payment
order by pay desc;

-- What is the total revenue by month
select month_name, sum(total) as revenue
from sales
group by month_name
order by revenue desc;

-- What month had the largest COGS?
select month_name, sum(cogs) as cost_of_goods_sold
from sales
group by month_name
order by cost_of_goods_sold desc;

-- What product line had the largest revenue?
SELECT product_line, SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?
SELECT city, SUM(total) as total_revenue
FROM sales
GROUP BY city
ORDER BY total_revenue DESC;

-- What product line had the largest VAT?
SELECT product_line, avg(tax_pct) as VAT
FROM sales
GROUP BY product_line
ORDER BY VAT DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
select round(avg(quantity)) as avg_qnt
from sales;


select product_line, 
      (case 
           when avg(quantity) > 5 then "Good"
           else "Bad"
	   end
       ) as new
from sales
group by product_line;

-- Which branch sold more products than average product sold?
select branch, sum(quantity) as qnt
from sales
group by branch
having qnt > (select avg(quantity) from sales);

-- What is the most common product line by gender
select count(product_line) as product, gender, product_line
from sales
group by gender, product_line
order by product desc;

-- What is the average rating of each product line
select product_line, round(avg(rating), 2) as avg_rating
from sales
group by product_line
order by avg_rating desc;

-- -------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------Sales---------------------------------------------------------
-- Number of sales made in each time of the day per weekday 
select time_of_day, count(quantity) as sales
from sales
where day_name = 'Wednesday'
group by time_of_day
order by sales desc;

-- Which of the customer types brings the most revenue?
select customer_type, sum(total) as revenue
from sales
group by customer_type
order by revenue desc;

-- Which city has the largest tax/VAT(Value Added Tax) percent?
select city, avg(tax_pct) as VAT
from sales
group by city
order by VAT desc;

-- Which customer type pays the most in VAT?
select customer_type, avg(tax_pct) as VAT
from sales
group by customer_type
order by VAT desc;

-- -------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------Customer--------------------------------------------------------
-- How many unique customer types does the data have?
SELECT DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT DISTINCT payment
FROM sales;

-- What is the most common customer type?
SELECT customer_type, count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- What is the gender of most of the customers?
SELECT gender, count(*) as count
FROM sales
GROUP BY gender
ORDER BY count DESC;

-- What is the gender distribution per branch?
SELECT gender, COUNT(*) as gender_cnt
FROM sales
WHERE branch = "B"
GROUP BY gender
ORDER BY gender_cnt DESC;

-- Which time of the day do customers give most ratings?
SELECT time_of_day, avg(rating) as  rating_count 
from sales
group by time_of_day
order by rating_count desc;

-- Which time of the day do customers give most ratings per branch?
SELECT time_of_day, AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which day of the week has the best avg ratings?
select day_name, avg(rating) as rating_count
from sales
group by day_name
order by rating_count desc;































