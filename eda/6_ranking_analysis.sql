/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    Rank products and customers based on sales performance and order activity
    to identify top and bottom performers.

    Identify the best- and worst-performing business entities.

This helps identify high-performing products, valuable customers, and 
potentially underperforming areas.

The question you're answering: Which products and customers perform best or 
worst according to specific metrics?

===============================================================================
*/;

-- Which 5 products generate the highest revenue
-- With no window function
SELECT 
    dp.product_name,
    SUM(fs.sales_amount) as total_revenue
FROM gold.fact_sales as fs
LEFT JOIN gold.dim_products as dp
    ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY total_revenue DESC
LIMIT 5;

-- with window function
SELECT 
    *
FROM(
    SELECT 
        dp.product_name,
        SUM(fs.sales_amount) as total_revenue,
        ROW_NUMBER() OVER(ORDER BY SUM(fs.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales as fs
    LEFT JOIN gold.dim_products as dp
        ON fs.product_key = dp.product_key
    GROUP BY dp.product_name
)t WHERE rank_products <= 5;


-- What are the 5 worst-performing products n terms of sales?
SELECT 
    dp.product_name,
    SUM(fs.sales_amount) as total_revenue
FROM gold.fact_sales as fs
LEFT JOIN gold.dim_products as dp
    ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY total_revenue
LIMIT 5;


-- Find the top 10 customers who have generated the highest revenue
SELECT *
FROM(
    SELECT 
        dc.customer_key,
        dc.first_name,
        dc.last_name,
        SUM(fs.sales_amount) AS total_revenue,
        DENSE_RANK() OVER(ORDER BY SUM(fs.sales_amount) DESC) AS rank_customers
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_customers AS dc
        ON fs.customer_key = dc.customer_key
    GROUP BY dc.customer_key, dc.first_name, dc.last_name
    ORDER BY total_revenue DESC
)t WHERE rank_customers <= 10;


-- The 3 customers with fewest orders placed
SELECT 
    dc.customer_key,
    dc.first_name,
    dc.last_name,
    COUNT(DISTINCT fs.order_number) AS total_orders
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
    ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_key, dc.first_name, dc.last_name
ORDER BY total_orders 
LIMIT 3;