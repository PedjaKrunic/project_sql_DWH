/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    Analyze the contribution of individual categories to overall business
    metrics to understand their relative importance.

Highlights:
    1. Calculates total sales for each product category.
    2. Determines each category's percentage contribution to overall sales.
    3. Identifies the categories generating the largest share of revenue.
===============================================================================
*/


-- Which categories contribute the most to overall sales?
WITH category_sales AS(
    SELECT
        dp.category,
        SUM(fs.sales_amount) AS total_sales
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_products AS dp
        ON fs.product_key = dp.product_key
    GROUP BY category
)

SELECT
    category,
    total_sales,
    SUM(total_sales) OVER() AS overall_sales,
    CONCAT(ROUND((total_sales / SUM(total_sales) OVER()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC