/*
===============================================================================
Dimension Exploration
===============================================================================
Purpose:
    Explore dimension tables to identify the unique countries, product
    categories, subcategories, and products available in the dataset.

This helps you understand the different ways you can segment your data.

The question you're answering: What entities and categories exist in my dataset?

===============================================================================
*/;

-- Explore all countries our customers come from
SELECT DISTINCT country FROM gold.dim_customers;

-- Explore all categories 'The major Divisions'
SELECT DISTINCT category, subcategory, product_name FROM gold.dim_products
ORDER BY 1, 2, 3;