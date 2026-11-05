# SQL Data Warehouse Project

## Project Overview

This project focuses on building a SQL-based Data Warehouse using **PostgreSQL** and the **Medallion Architecture**.

The main objective was to bring together data from CRM and ERP source systems, clean and transform it, and organize it into an analytical model that can be used for reporting and further analysis.

The project covers the main stages of a Data Warehouse workflow, from loading raw CSV files to creating business-oriented views in the Gold layer.

## Data Architecture

The project follows the Medallion Architecture, consisting of three layers: **Bronze**, **Silver** and **Gold**
![Data Architecture](docs/data_architecture.png)

- **Bronze:** Stores raw data imported from CRM and ERP CSV files without applying transformations.
- **Silver:** Cleans, standardizes and transforms data to improve its quality and consistency.
- **Gold:** Integrates data into business-friendly dimension and fact views, following a **Star Schema**.

## Data Sources

The project uses two source systems provided as CSV files:

- **CRM:** Customer information, product information and sales details.
- **ERP:** Additional customer details, location information and product categories.

## Data Processing

Data is processed through SQL-based ETL workflows:

1. **Data Ingestion:** Load source CSV files into Bronze tables.
2. **Data Cleaning:** Identified and handled duplicate records, missing values, inconsistent formats, invalid values and other data quality issues.
3. **Data Transformation:** Clean and standardize data in the Silver layer.
4. **Data Modeling:** Organize the transformed data into dimension and fact views in the Gold layer.
5. **Data Validation:** Run data quality checks across the layers to identify inconsistencies and missing relationships.

The Bronze and Silver layers use a full-refresh approach (`TRUNCATE` and `INSERT`), while the Gold layer is implemented using SQL views.

## Gold Data Model

The Gold layer follows a **Star Schema** and contains three analytical views:

- `gold.dim_customers` – Customer attributes and demographic information.
- `gold.dim_products` – Product details and category information.
- `gold.fact_sales` – Sales transactions, dates, quantities and sales amounts.

![Data Model](docs/data_model.png)

Surrogate keys for the customer and product dimensions are generated using `ROW_NUMBER()` and used to connect the fact view to the dimensions.

For detailed column descriptions and relationships, see the [Gold Data Catalog](docs/gold_data_catalog.md).

## Exploratory Data Analysis - EDA

After building the Data Warehouse, I used PostgreSQL to explore the data in the Gold layer through a series of SQL-based EDA queries.

The analysis covers database and dimension exploration, key business metrics, magnitude and ranking analysis, time-based trends, cumulative analysis, performance analysis, data segmentation, and customer and product reporting.

The analysis scripts and their descriptions are available in the [Data Analysis directory](data_analysis/).

## Technologies & Tools

- **PostgreSQL** – Database management and SQL transformations.
- **SQL** – Data definition, ingestion, transformation, validation and analysis.
- **pgAdmin** – Database management and query execution.
- **Visual Studio Code** – SQL development.
- **Draw.io** – Data architecture and data model diagrams.
- **Git & GitHub** – Version control and project documentation.

## What I Learned

Through this project, I gained practical experience with:

- Structuring a Data Warehouse using the Medallion Architecture.
- Writing SQL-based ETL workflows and stored procedures.
- Cleaning, standardizing, and validating data from multiple source systems.
- Applying dimensional modeling concepts and designing a Star Schema.
- Working with fact and dimension views and surrogate keys.
- Using SQL for exploratory analysis, aggregations, and business metrics.
- Applying CTEs, joins, subqueries, and window functions to analytical problems.
- Organizing SQL code and documenting a Data Warehouse project.

## Project Structure
```text
├── data_analysis/  # Exploratory Data Analysis SQL scripts
├── datasets/       # Source CSV files
├── docs/           # Architecture diagrams and documentation
├── scripts/        # Data Warehouse SQL scripts
├── tests/          # Data quality checks
├── LICENSE
└── README.md
```

## Conclusions

This project allowed me to work through the main stages of building a Data Warehouse, from raw data ingestion and transformation to dimensional modeling and exploratory analysis.

It helped me develop a better understanding of how data engineering concepts come together to prepare data for analytical use.


### Credits

Special thanks to Baraa Khatib Salkini for his excellent 30-hour SQL course on YouTube. His explanations and hands-on projects were a valuable resource throughout my learning process and helped me build this project.

If you're learning SQL or working in the data field, I highly recommend checking out his [YouTube channel](https://www.youtube.com/@DataWithBaraa).