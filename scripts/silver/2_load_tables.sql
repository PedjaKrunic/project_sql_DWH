/*
===============================================================================
Stored Procedure: silver.load_silver()
===============================================================================
Purpose:
    This stored procedure loads cleaned, standardized, and transformed data
    from the Bronze layer into the Silver layer of the Data Warehouse.

    The procedure performs a full refresh of all six Silver layer tables.
    For each target table, it:
        1. Truncates the existing Silver layer table.
        2. Extracts data from the corresponding Bronze layer table.
        3. Applies data cleansing, standardization, and transformation rules.
        4. Inserts the transformed data into the Silver layer table.
        5. Measures and reports the individual table loading duration.

Transformations:
    - silver.crm_cust_info:
        * Removes leading and trailing whitespace from customer names.
        * Standardizes marital status and gender values.
        * Removes records with NULL customer IDs.
        * Removes duplicate customer records using ROW_NUMBER(), keeping
          the most recent record based on the customer creation date.

    - silver.crm_prd_info:
        * Extracts category IDs and product IDs from the original product key.
        * Replaces category ID separators to standardize their format.
        * Replaces NULL product costs with 0.
        * Maps product line codes to descriptive values.
        * Converts product start timestamps into DATE values.
        * Calculates product end dates using LEAD(), setting each end date
          to one day before the next product start date.

    - silver.crm_sales_details:
        * Validates date values and converts valid YYYYMMDD integers into
          DATE values; invalid or non-positive values are replaced with NULL.
        * Recalculates sales amounts when values are NULL, non-positive,
          or inconsistent with quantity multiplied by price.
        * Corrects invalid or non-positive product prices using sales amount
          divided by quantity, while preventing division by zero.

    - silver.erp_cust_az12:
        * Removes the 'NAS' prefix from customer IDs where present.
        * Replaces future birth dates with NULL.
        * Standardizes gender values into descriptive categories.

    - silver.erp_loc_a101:
        * Removes hyphens from customer IDs.
        * Standardizes country names and country codes.
        * Replaces NULL or empty country values with 'n/a'.

    - silver.erp_px_cat_g1v2:
        * Transfers product category information from Bronze to Silver
          without additional transformations.

Execution:
    The procedure:
        1. Records the total loading start time.
        2. Loads each Silver layer table sequentially.
        3. Reports individual table loading durations using RAISE NOTICE.
        4. Reports the total execution duration.
        5. Handles unexpected errors using an EXCEPTION block, logs the
           error message, and rethrows the original exception.

Parameters:
    None.

Usage:
    Execute the stored procedure using:

        CALL silver.load_silver();

Dependencies:
    - PostgreSQL database.
    - Existing bronze and silver schemas.
    - Bronze source tables
    - Silver target tables

Notes:
    - This procedure uses a Full Load (Full Refresh) strategy rather than
      incremental loading.
    - Existing Silver layer data is removed using TRUNCATE before new data
      is inserted.
    - Loading durations are measured using clock_timestamp() and reported
      in seconds.
    - The procedure does not accept parameters.
    - If an error occurs, the exception handler logs the error message
      and rethrows the exception.
    - The procedure should be executed after the Bronze layer has been
      successfully loaded.

===============================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    total_start_time TIMESTAMP;
    total_end_time TIMESTAMP;
BEGIN

    total_start_time := clock_timestamp();
    RAISE NOTICE '================================';
    RAISE NOTICE 'Loading SILVER Layer';
    RAISE NOTICE '================================';

    start_time := clock_timestamp();
    RAISE NOTICE '--------------------------------';
    RAISE NOTICE '-> Loading data into: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;
    INSERT INTO silver.crm_cust_info (
        cst_id, 
        cst_key, 
        cst_firstname, 
        cst_lastname, 
        cst_marital_status, 
        cst_gndr, 
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,
        CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date
    FROM(
        SELECT 
            *,
            ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    )t 
    WHERE flag_last = 1;
    end_time := clock_timestamp();
    RAISE NOTICE 'Loading duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '--------------------------------';

    start_time := clock_timestamp();
    RAISE NOTICE '-> Loading data into: silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;
    INSERT INTO silver.crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT 
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- extract category id
        SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key, -- extract product id
        prd_nm,
        COALESCE(prd_cost, 0) AS prd_cost,
        CASE UPPER(TRIM(prd_line)) 
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line, -- map product line codes to descriptive values
        CAST(prd_start_dt AS DATE) prd_start_dt,
        CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day' AS DATE) AS prd_end_dt -- calculate end date as one day before the next start date
    FROM bronze.crm_prd_info;

    end_time := clock_timestamp();
    RAISE NOTICE 'Loading duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '--------------------------------';


    start_time := clock_timestamp();
    RAISE NOTICE '-> Loading data into: silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;
    INSERT INTO silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt <= 0 OR LENGTH(sls_order_dt::TEXT) != 8 THEN NULL
            ELSE TO_DATE(sls_order_dt::TEXT, 'YYYYMMDD') 
        END AS sls_order_dt, -- handling invalid data and casting

        CASE WHEN sls_ship_dt <= 0 OR LENGTH(sls_ship_dt::TEXT) != 8 THEN NULL
            ELSE TO_DATE(sls_ship_dt::TEXT, 'YYYYMMDD') 
        END AS sls_ship_dt,

        CASE WHEN sls_due_dt <= 0 OR LENGTH(sls_due_dt::TEXT) != 8 THEN NULL
            ELSE TO_DATE(sls_due_dt::TEXT, 'YYYYMMDD') 
        END AS sls_due_dt,

        CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,

        sls_quantity,

        CASE WHEN sls_price IS NULL OR sls_price <= 0 
                THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END AS sls_price
    FROM bronze.crm_sales_details;
    end_time := clock_timestamp();
    RAISE NOTICE 'Loading duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '--------------------------------';


    start_time := clock_timestamp();
    RAISE NOTICE '-> Loading data into: silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12;
    INSERT INTO silver.erp_cust_az12 (
        cid,
        bdate,
        gen
    )
    SELECT 
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
            ELSE cid
        END AS cid,

        CASE WHEN bdate > CURRENT_DATE THEN NULL
            ELSE bdate
        END AS bdate,

        CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END AS gen
    FROM bronze.erp_cust_az12;
    end_time := clock_timestamp();
    RAISE NOTICE 'Loading duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '--------------------------------';


    start_time := clock_timestamp();
    RAISE NOTICE '-> Loading data into: silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;
    INSERT INTO silver.erp_loc_a101 (
        cid,
        cntry
    )
    SELECT 
        REPLACE(cid, '-', '') AS cid,

        CASE WHEN UPPER(TRIM(cntry)) IN ('UK', 'UNITED KINGDOM') THEN 'United Kingdom'
            WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY') THEN 'Germany'
            WHEN UPPER(TRIM(cntry)) IN ('US', 'UNITED STATES', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
            ELSE cntry
        END AS cntry
    FROM bronze.erp_loc_a101;
    end_time := clock_timestamp();
    RAISE NOTICE 'Loading duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '--------------------------------';


    start_time := clock_timestamp();
    RAISE NOTICE '-> Loading data into: silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    INSERT INTO silver.erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT 
        id,
        cat,
        subcat,
        maintenance
    FROM bronze.erp_px_cat_g1v2;
    end_time := clock_timestamp();
    RAISE NOTICE 'Loading duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '--------------------------------';

    RAISE NOTICE '================================';
    RAISE NOTICE 'Silver Layer Loaded Successfully';
    RAISE NOTICE '================================';
    total_end_time := clock_timestamp();
    RAISE NOTICE 'Total Loading duration: % seconds',
        EXTRACT(EPOCH FROM (total_end_time - total_start_time));
    RAISE NOTICE '--------------------------------';


EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '================================';
        RAISE WARNING 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        RAISE WARNING 'ERROR MESSAGE: %', SQLERRM;
        RAISE WARNING '================================';

        RAISE;

END;
$$;

CALL silver.load_silver();