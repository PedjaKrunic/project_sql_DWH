/*
===============================================================================
Gold Layer - Data Quality Checks
===============================================================================
Purpose:
    This script contains SQL queries used to validate the quality and
    integrity of the Gold layer views.

===============================================================================
*/

-- ===============================================
-- Dimension Customers 
-- ===============================================
-- Checking if there is duplicates after joining tables
SELECT 
    cst_id,
    COUNT(*)
FROM (
    SELECT 
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_marital_status,
        ci.cst_gndr,
        ci.cst_create_date,
        ca.bdate,
        ca.gen,
        la.cntry
    FROM silver.crm_cust_info AS ci
    LEFT JOIN silver.erp_cust_az12 AS ca
        ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 AS la
        ON ci.cst_key = la.cid
)t GROUP BY cst_id
HAVING COUNT(*) > 1


-- Checking the quality of genders
-- Lets say that the master source of customer data is CRM
SELECT DISTINCT
    ci.cst_gndr,
    ca.gen
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid
ORDER BY 1, 2


SELECT * FROM gold.dim_customers;

-- ===============================================
-- Dimension Products
-- ===============================================
-- Checking if there is duplicates after joining tables
SELECT 
    prd_key,
    COUNT(*)
FROM (
    SELECT 
        pn.prd_id,
        pn.cat_id,
        pn.prd_key,
        pn.prd_nm,
        pn.prd_cost,
        pn.prd_line,
        pn.prd_start_dt,
        pc.cat,
        pc.subcat,
        pc.maintenance
    FROM silver.crm_prd_info AS pn
    LEFT JOIN silver.erp_px_cat_g1v2 AS pc
        ON pn.cat_id = pc.id
    WHERE prd_end_dt IS NULL -- Filter out all historical data
)t GROUP BY prd_key
HAVING COUNT(*) > 1

SELECT * FROM gold.dim_products;


-- ===============================================
-- Fact sales
-- ===============================================
SELECT * FROM gold.fact_sales as f
LEFT JOIN gold.dim_customers as c
    ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products as p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL