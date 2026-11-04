/*
===============================================================================
Date Exploration
===============================================================================
Purpose:
    Explore date ranges in the sales data and analyze the age distribution
    of customers by identifying the oldest and youngest customers.
    
    Understand the time boundaries and temporal coverage of your dataset.

The question you're answering: What time period does my data cover, and what 
are the temporal characteristics of my customers?

===============================================================================
*/;

-- Identify the earliest and latest dates (boundaries)
-- How many months of sales are available
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 
    + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date)))
FROM gold.fact_sales;


-- Find the youngest and oldest customer
SELECT 
    MIN(birthdate) AS oldest_birthdate,
    MAX(birthdate) AS youngest_birthdate,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, MAX(birthdate))) AS youngest_years,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, MIN(birthdate))) AS oldest_years
FROM gold.dim_customers;
