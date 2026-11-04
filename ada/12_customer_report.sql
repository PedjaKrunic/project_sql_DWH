/*
===================================================================
Customer Report
===================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details
    2. Segments customers into categories (VIP, Regular, New) and age groups
    3. Aggregates customer-level metrics:
        - total orders
        - total sales
        - total quantity purchased
        - total products
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value
        - average monthly spend

When we finish with all this, we are gonna put our query in VIEW.
Once we have a report in the database, we can share it with others.

===================================================================
*/;

CREATE OR REPLACE VIEW gold.report_customers AS
WITH base_query AS(
    -- 1. Gathers essential fields such as names, ages, and transaction details
    SELECT 
        fs.order_number,
        fs.product_key,
        fs.order_date,
        fs.sales_amount,
        fs.quantity,
        dc.customer_key,
        dc.customer_number,
        CONCAT(dc.first_name, ' ', dc.last_name) AS customer_name,
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, dc.birthdate))::INTEGER AS age
    FROM gold.fact_sales as fs
    LEFT JOIN gold.dim_customers as dc
        ON fs.customer_key = dc.customer_key
    WHERE fs.order_date IS NOT NULL
),

customer_aggregation AS(
    /*
    3. Aggregates customer-level metrics:
        - total orders
        - total sales
        - total quantity purchased
        - total products
        - lifespan (in months)
    */
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order,
        (EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
        + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date)))) AS lifespan
    FROM base_query
    GROUP BY customer_key, customer_number, customer_name, age
)


SELECT 
    -- 2. Segments customers into categories (VIP, Regular, New) and age groups
    customer_key,
    customer_number,
    customer_name, 
    age,
    CASE WHEN age < 20 THEN 'Under 20'
         WHEN age BETWEEN 20 AND 29 THEN '20-29'
         WHEN age BETWEEN 30 AND 39 THEN '30-39'
         WHEN age BETWEEN 40 AND 49 THEN '40-49'
         WHEN age BETWEEN 50 AND 59 THEN '50-59'
         ELSE '60+'
    END AS age_group,
    CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_status,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    last_order,
    (
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, last_order)) * 12
        + EXTRACT(MONTH FROM AGE(CURRENT_DATE, last_order))
    )::INTEGER AS months_since_last_order,
    lifespan,
    CASE WHEN total_orders = 0 THEN 0
         ELSE total_sales / total_orders 
    END AS avg_order_value,

    CASE WHEN lifespan = 0 THEN total_sales
         ELSE total_sales / lifespan 
    END AS avg_monthly_spend
FROM customer_aggregation;


SELECT * FROM gold.report_customers