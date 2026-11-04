# Exploratory Data Analysis (EDA)

## Project Overview

This project focuses on performing Exploratory Data Analysis (EDA) using **PostgreSQL** to understand the business data stored in the Gold layer of the Data Warehouse.

The goal is to explore the dataset, identify key business metrics, understand data distributions, and uncover insights about customers, products, and sales performance.

## Analysis Steps

The EDA process is organized into 13 steps:

1. **[Database Exploration](1_db_structure_exploration.sql):** Explore the database structure, schemas, tables, and columns to understand the available data.
2. **[Dimension Exploration](2_dimension_exploration.sql):** Identify unique values and explore the different categories, countries, and products in the dimension tables.
3. **[Date Exploration](3_date_exploration.sql):** Examine date ranges, sales history, and customer age boundaries to understand the temporal coverage of the dataset.
4. **[Measures Exploration](4_measures_exploration.sql):** Calculate key business metrics, including total sales, quantity sold, average selling price, orders, products, and customers.
5. **[Magnitude Analysis](5_magnitude_analysis.sql):** Analyze business metrics across different dimensions, such as countries, customer genders, product categories, and individual customers.
6. **[Ranking Analysis](6_ranking_analysis.sql):** Identify top and bottom-performing products and customers based on revenue and order activity.
7. **[Change Over Time Analysis](7_change_over_time_trends.sql):** Analyze changes in sales, customer activity, and quantity sold over time to identify trends.
8. **[Cumulative Analysis](8_cumulative_analysis.sql):** Calculate running totals and moving averages to track business performance and growth over time.
9. **[Performance Analysis](9_performance_analysis.sql):** Evaluate product sales performance by comparing yearly results against historical averages and previous-year sales.
10. **[Part-to-Whole Analysis](10_part_to_whole_analysis.sql):** Calculate the percentage contribution of individual product categories to overall sales.
11. **[Data Segmentation](11_data_segmentation.sql):** Group products and customers into segments based on product costs, customer spending, and customer lifespan.
12. **[Customer Report](12_customer_report.sql):** Create a customer-level SQL view consolidating customer information, purchasing behavior, segments, and key performance metrics.
13. **[Product Report](13_product_report.sql):** Create a product-level SQL view consolidating product information, sales performance, revenue segments, and key performance metrics.

## Technologies & Tools

- **PostgreSQL** – Database querying and data analysis.
- **SQL** – Aggregations, joins, subqueries, window functions, and analytical queries.
- **pgAdmin** – Database management and query execution.
- **Visual Studio Code** – SQL development.
- **Git & GitHub** – Version control and project documentation.

## What I Learned

Through this project, I gained practical experience with:

- Exploring database structures and dimensional models.
- Writing SQL queries for exploratory data analysis.
- Calculating business KPIs and aggregate metrics.
- Analyzing data across different dimensions.
- Using aggregate functions, joins, CTEs, subqueries and window functions.
- Ranking products and customers based on business performance.
- Performing cumulative, performance, and part-to-whole analysis.
- Segmenting customers and products based on business criteria.
- Creating reusable customer and product reports using SQL views.
- Translating raw query results into meaningful business insights.

## Conclusions

This project provided practical experience in using SQL for exploratory data analysis and understanding business performance.

By analyzing customer, product, and sales data, I developed a better understanding of how to examine datasets, calculate key metrics, identify trends, and evaluate business performance.