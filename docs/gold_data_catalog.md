# Gold Layer – Data Catalog

## Overview

The Gold layer represents the business-ready layer of the Data Warehouse. It contains data that has been cleaned, standardized, integrated, and organized into a dimensional model to support analytical reporting and business intelligence.

The Gold layer follows a **Star Schema** approach, consisting of two dimension views and one fact view.

### Objects overview

| Object | Type | Description |
|---|---|---|
| `gold.dim_customers` | VIEW | Contains customer-related information, enriched with data from CRM and ERP systems. |
| `gold.dim_products` | VIEW | Contains product-related information, including product categories and subcategories. Only current product records are included. |
| `gold.fact_sales` | VIEW | Contains sales transaction data, connected to customer and product dimensions. |


---

## 1. Dimension: gold.dim_customers

### Purpose

This view provides a consolidated overview of customers by integrating customer information from CRM and ERP systems.

It combines customer details, geographical information, and demographic attributes into a single customer dimension.

CRM is considered the primary source for gender information. When CRM gender is unavailable (`n/a`), the ERP gender value is used as a fallback.

### Columns

| Column | Data Type | Description |
|---|---|---|
| `customer_key` | INT | Surrogate key generated using `ROW_NUMBER()`, ordered by customer ID. |
| `customer_id` | INT | Original customer ID from the CRM system. |
| `customer_number` | VARCHAR(50) | Unique customer reference number from the CRM system. |
| `first_name` | VARCHAR(50) | Customer's first name, obtained from CRM. |
| `last_name` | VARCHAR(50) | Customer's last name, obtained from CRM. |
| `country` | VARCHAR(50) | Customer's country, obtained from the ERP location data. |
| `marital_status` | VARCHAR(50) | Customer's marital status, standardized in the Silver layer. (e.g. 'Married', 'Single') |
| `gender` | VARCHAR(50) | Customer's gender. (e.g. 'Male', 'Female', 'n/a')|
| `birthdate` | DATE | Customer's date of birth, obtained from ERP. Formatted as YYYY-MM-DD. |
| `create_date` | DATE | Date when the customer record was created in CRM. |

### Source tables

- `silver.crm_cust_info`
- `silver.erp_cust_az12`
- `silver.erp_loc_a101`

---

## 2. Dimension: gold.dim_products

### Purpose

This view provides descriptive information about products, including their category, subcategory, cost, and product line.

It integrates CRM product information with ERP product category information.

Only current product records are included in this dimension. Historical product records are excluded by filtering for records where `prd_end_dt IS NULL`.

### Columns

| Column | Data Type | Description |
|---|---|---|
| `product_key` | INT | Surrogate key generated using `ROW_NUMBER()`, ordered by product start date and product number. |
| `product_id` | INT | Original product ID from the CRM system. |
| `product_number` | VARCHAR(50) | Product reference number from the CRM system. |
| `product_name` | VARCHAR(50) | Descriptive name of the product. |
| `category_id` | VARCHAR(50) | Product category identifier extracted from the original product key. |
| `category` | VARCHAR(50) | Product category obtained from ERP. |
| `subcategory` | VARCHAR(50) | Product subcategory obtained from ERP. |
| `maintenance` | VARCHAR(50) | Indicates the product's maintenance classification or requirement, based on ERP data. (e.g. 'Yes', 'No') |
| `cost` | INT | Product cost. |
| `product_line` | VARCHAR(50) | Standardized product line description. (e.g. Road, Mountian)|
| `start_date` | DATE | Date when the current product record became effective. |

### Source tables

- `silver.crm_prd_info`
- `silver.erp_px_cat_g1v2`

---

## 3. Fact: gold.fact_sales

### Purpose

This view contains sales transaction data and connects sales records with customer and product dimensions.

It provides the measurable business information required for sales analysis and reporting.

The fact view uses customer and product surrogate keys to establish relationships with the corresponding dimension views.

### Grain

One row represents one sales transaction line from the CRM sales details source, associated with a product and customer.

An individual order may contain multiple sales transaction lines.

### Columns

| Column | Data Type | Description |
|---|---|---|
| `order_number` | VARCHAR(50) | Sales order reference number. |
| `product_key` | INT | Surrogate key referencing `gold.dim_products`. |
| `customer_key` | INT | Surrogate key referencing `gold.dim_customers`. |
| `order_date` | DATE | Date when the sales order was placed. |
| `shipping_date` | DATE | Date when the order was shipped. |
| `due_date` | DATE | Date when the order payment was due. |
| `sales_amount` | INT | Total sales amount for the transaction line. |
| `quantity` | INT | Number of product units sold. |
| `price` | INT | Price per product unit. |

### Source tables

- `silver.crm_sales_details`
- `gold.dim_products`
- `gold.dim_customers`

---

**Architecture:** Medallion Data Warehouse  
**Layer:** Gold  
**Modeling approach:** Star Schema  
**Database:** PostgreSQL  
**Source layer:** Silver