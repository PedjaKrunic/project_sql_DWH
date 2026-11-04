/*
===============================================================================
Measures Exploration
===============================================================================
Purpose:
    Calculate key business metrics, including total sales, quantity sold,
    average selling price, orders, products, and customers.

These metrics give you an overview of the business before you start comparing 
individual segments.

For example, knowing total revenue is useful, but knowing that one category 
contributes 60% of that revenue is even more useful.

The question you're answering: What are the overall business performance 
metrics?

===============================================================================
*/;

-- Find the Total Sales
SELECT 
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales;


-- Find how many items are sold
SELECT 
    SUM(quantity) AS total_quantity
FROM gold.fact_sales;


-- Find the average selling price
SELECT 
    AVG(price) AS average_price
FROM gold.fact_sales;


-- Find the total number of Orders
SELECT 
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;


-- Find the total number of products
SELECT
    COUNT(DISTINCT product_id) AS total_products
FROM gold.dim_products;


-- Find the total number of customers
SELECT 
    COUNT(DISTINCT customer_id) AS total_customers
FROM gold.dim_customers;


-- Find the total number of customers that have placed an order
SELECT 
    COUNT(DISTINCT customer_key) AS customers_with_orders
FROM gold.fact_sales;



-- Generate a report that shows all key metrics of the business
SELECT 'Total Earned from Sales' as measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales

UNION ALL

SELECT 'Total Quantity' as measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales

UNION ALL

SELECT 'Average Price' as measure_name, AVG(price) AS measure_value FROM gold.fact_sales

UNION ALL

SELECT 'Total Orders' as measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales

UNION ALL

SELECT 'Total Products' as measure_name, COUNT(DISTINCT product_id) AS measure_value FROM gold.dim_products

UNION ALL

SELECT 'Total Customers' as measure_name, COUNT(DISTINCT customer_id) AS measure_value FROM gold.dim_customers

UNION ALL

SELECT 'Number of Customers with orders' as measure_name, COUNT(DISTINCT customer_key) AS measure_value FROM gold.fact_sales;


