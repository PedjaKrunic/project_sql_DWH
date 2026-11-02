/*
===============================================================================
Data Quality Checks 
===============================================================================
Purpose:
    This script contains SQL queries used to assess data quality in the
    Bronze layer and inspect the results of transformations applied in
    the Silver layer.

    The main objective is to identify data quality issues in the raw
    source data before defining and implementing the necessary cleansing
    and standardization rules.

    The script performs several types of data quality checks:

    1. Uniqueness Checks:
        - Identifies duplicate values in columns expected to contain
          unique identifiers.
        - Checks for NULL values in primary key candidates.

    2. Data Completeness Checks:
        - Identifies missing or NULL values in relevant columns.
        - Detects incomplete or invalid source records.

    3. Data Consistency Checks:
        - Identifies inconsistencies between related columns.
        - Validates relationships between sales, quantity, and price.
        - Checks chronological order of dates.

    4. Data Standardization Checks:
        - Identifies inconsistent categorical values.
        - Checks for unwanted leading and trailing whitespace.
        - Inspects distinct values in columns such as gender,
          marital status, product lines, and country names.

    5. Data Validity Checks:
        - Identifies invalid or out-of-range numeric values.
        - Checks date formats and invalid date components.
        - Detects negative or zero values where they are not expected.
        - Identifies dates outside the expected range.

    6. Transformation Validation:
        - Inspects Silver layer tables after data cleansing and
          transformation.
        - Allows comparison between raw Bronze data and processed
          Silver data.
        - Helps verify whether the implemented transformation rules
          address the identified data quality issues.

===============================================================================
*/

-- =======================================================;
-- bronze.crm_cust_info;
-- =======================================================;

-- Check for NULLs or duplicates in Primary Key
-- Expectation: No Result
SELECT 
    cst_id,
    COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;


-- Check for unwanted spaces
-- Expectation: no results 
-- Check every column -> only firstname and lastname needs to be trimmed
SELECT
    cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);


-- Data Standardization & Consistency
SELECT
    DISTINCT cst_gndr
FROM bronze.crm_cust_info;

SELECT * FROM silver.crm_cust_info;



-- =======================================================;
-- bronze.crm_prd_info;
-- =======================================================;

-- Check for unwanted spaces 
-- Expectation: No results
SELECT
    prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Check for NULLs or Negative numbers 
-- Expectation: no Nulls
SELECT
    prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency 
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

-- Check for Invalid Date Orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


SELECT * FROM silver.crm_prd_info;


-- =======================================================;
-- bronze.crm_sales_details
-- =======================================================;

-- Check for unwanted spaces 
-- Expectation: No results
SELECT
    sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

-- Check for invalid dates
SELECT
    NULLIF(sls_order_dt, 0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 -- can't be in minus
    OR LENGTH(sls_order_dt::TEXT) != 8 -- all dates need to have 8 digits
    OR sls_order_dt > 20500101 
    OR sls_order_dt < 19000101
    OR (sls_order_dt / 100) % 100 > 12 -- there is max 12 months
    OR sls_order_dt % 100 > 31; -- there is max 31 days in month

-- Check for invalid date orders
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Check data consistency
-- >> Sales = Quantity * Price
-- Values must NOT be NULL, zero or negative

-- If sales is negative, zero or null, derive it using quantity and price
-- If price is zero or null, calculate it using sales and quantity
-- If price is negative, convert it to positive value
SELECT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0;


SELECT * FROM silver.crm_sales_details;


-- =======================================================;
-- bronze.erp_cust_az12
-- =======================================================;

-- Identify out of range bdates
SELECT 
    bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1926-01-01' OR bdate > CURRENT_DATE

--Data standardization & consistency
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;

SELECT *
FROM silver.erp_cust_az12;


-- =======================================================;
-- bronze.erp_loc_a101
-- =======================================================;

SELECT DISTINCT cntry
FROM bronze.erp_loc_a101;

SELECT *
FROM silver.erp_loc_a101;


-- =======================================================;
-- bronze.erp_px_cat_g1v2
-- =======================================================;

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;

-- check for unwanted spaces
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

SELECT 
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;

SELECT *
FROM silver.erp_px_cat_g1v2;

