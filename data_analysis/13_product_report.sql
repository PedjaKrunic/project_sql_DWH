/*
===================================================================
Product Report
===================================================================
Purpose:
    - This report consolidates key product metrics and behaviors

Highlights:
    1. Gathers essential fields such as product name, category, subcategory and cost
    2. Segments products by revenue to identify High-performers, Mid-range or low-performers
    3. Aggregates product-level metrics:
        - total orders
        - total sales
        - total quantity sold
        - total customers (unique)
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last sale)
        - average order revenue
        - average monthly revenue

When we finish with all this, we are gonna put our query in VIEW.
Once we have a report in the database, we can share it with others.

===================================================================
*/;



CREATE OR REPLACE VIEW gold.report_products AS
WITH base_query AS(
    -- 1. Gathers essential fields such as product name, category, subcategory and cost
    SELECT 
        fs.order_number,
        fs.customer_key,
        fs.order_date,
        fs.sales_amount,
        fs.quantity,
        dp.product_key,
        dp.product_name,
        dp.category,
        dp.subcategory,
        dp.cost
    FROM gold.fact_sales as fs
    LEFT JOIN gold.dim_products as dp
        ON fs.product_key = dp.product_key
    WHERE fs.order_date IS NOT NULL
),

product_aggregation AS(
    /*
    3. Aggregates product-level metrics:
        - total orders
        - total sales
        - total quantity sold
        - total customers (unique)
        - lifespan (in months)
    */
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        (EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
        + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date)))) AS lifespan,
        MAX(order_date) AS last_sale,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        ROUND((AVG(sales_amount / NULLIF(quantity, 0))), 1) AS avg_selling_price
    FROM base_query
    GROUP BY 
        product_key,
        product_name,
        category,
        subcategory,
        cost
)


SELECT 
    -- 2. Segments products by revenue to identify High-performers, Mid-range or low-performers
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale,
    (
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, last_sale)) * 12
        + EXTRACT(MONTH FROM AGE(CURRENT_DATE, last_sale))
    )::INTEGER AS recency_in_months,

    CASE WHEN total_sales > 50000 THEN 'High-Performer'
         WHEN  total_sales >= 10000 THEN 'Mid-Range'
         ELSE 'Low-Performer'
    END AS product_status,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    
    CASE WHEN total_orders = 0 THEN 0
         ELSE total_sales / total_orders 
    END AS avg_order_revenue,

    CASE WHEN lifespan = 0 THEN total_sales
         ELSE total_sales / lifespan 
    END AS avg_monthly_revenue
FROM product_aggregation;

SELECT * FROM gold.report_products