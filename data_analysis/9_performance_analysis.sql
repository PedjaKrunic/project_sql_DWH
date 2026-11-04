/*
===============================================================================
Performance Analysis
===============================================================================
Purpose:
    Evaluate business performance by comparing current metrics against
    historical performance and average values.

Highlights:
    1. Compares yearly product sales against historical averages.
    2. Compares current-year sales with previous-year sales.
    3. Identifies increases, decreases, and changes in performance.
===============================================================================
*/


-- Analyze the yearly performance of products by comparing
-- each product's sales to both its average sales performance
-- and the previous year's sales

WITH yearly_product_sales AS(
    SELECT 
        DATE_TRUNC('year', fs.order_date)::DATE AS order_year,
        dp.product_name,
        SUM(fs.sales_amount) AS current_sales
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_products AS dp
        ON fs.product_key = dp.product_key
    WHERE order_date IS NOT NULL
    GROUP BY order_year, dp.product_name
)

SELECT 
    order_year,
    product_name,
    current_sales,
    LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) AS previous_year_sales,
    AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
    CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above avg'
         WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below avg'
         ELSE 'Average'
    END AS avg_change,
    current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) AS diff_py,
    CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) > 0 THEN 'Increase'
         WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) < 0 THEN 'Decrease'
         ELSE 'No Change'
    END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year