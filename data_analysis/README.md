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
- Using aggregate functions, joins, subqueries, and window functions.
- Ranking products and customers based on business performance.
- Translating raw query results into meaningful business insights.

## Conclusions

This project provided practical experience in using SQL for exploratory data analysis and understanding business performance.

By exploring customer, product, and sales data, I developed a better understanding of how to examine datasets, calculate key metrics, and identify patterns that can support business decision-making.