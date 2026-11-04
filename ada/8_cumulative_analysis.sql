/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    Calculate cumulative business metrics over time to track business growth
    and understand overall performance progression.

Highlights:
    1. Calculates running total sales over time.
    2. Computes moving average prices.
    3. Analyzes cumulative sales within yearly periods.
===============================================================================
*/

-- Calculate the total sales per month
-- and running total of sales over time & moving average
SELECT
    order_month,
    total_sales,
    SUM(total_sales) OVER(ORDER BY order_month ASC) AS running_total_sales,
    AVG(average_price) OVER(ORDER BY order_month ASC) AS moving_average_price
FROM(
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS order_month,
        SUM(sales_amount) total_sales,
        AVG(price) AS average_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY order_month
    ORDER BY order_month
)t;



SELECT
    order_month,
    total_sales,
    SUM(total_sales) OVER(PARTITION BY DATE_TRUNC('year', order_month) ORDER BY order_month ASC) AS running_total_sales
FROM(
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS order_month,
        SUM(sales_amount) total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY order_month
)t;

-- Normalne agregacije obicno koristimo da proverimo performanse svakog reda ponaosob.
-- Ako zelis da vidis kakav je napredak i kako tvoj biznis raste, koristi kumulativne agregacije