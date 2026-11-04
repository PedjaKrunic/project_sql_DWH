/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    Analyze how business metrics change over time to identify trends and
    patterns in sales performance.

Highlights:
    1. Tracks total sales, customers, and quantity sold over time.
    2. Groups sales data by year and month.
    3. Identifies changes in business performance across different periods.
===============================================================================
*/

-- Analyze sales performance over time
SELECT 
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,    
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY order_year, order_month
ORDER BY order_year, order_month ASC;

SELECT 
    DATE_TRUNC('month', order_date)::DATE AS order_month,    
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY order_month
ORDER BY order_month ASC;