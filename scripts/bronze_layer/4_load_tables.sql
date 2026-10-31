/*
===============================================================================
Stored procedure for loading raw source data into the Bronze
               layer of the Data Warehouse.
===============================================================================

Purpose:
    This procedure performs a full load of six source tables from CRM and ERP
    CSV files into the Bronze layer.

    For each table, the procedure:
        1. Records the loading start time.
        2. Truncates the existing table data.
        3. Loads fresh data from the corresponding CSV file using COPY.
        4. Records and displays the loading duration.

    Additional functionality:
        - Displays ETL execution progress using RAISE NOTICE.
        - Measures individual table loading durations.
        - Measures total Bronze layer loading duration.
        - Handles errors using an EXCEPTION block.
        - Displays error messages and re-throws the original exception.

Parameters:
    None.

Usage:
    CALL bronze.load_bronze();

Dependencies:
    - PostgreSQL database.
    - Existing bronze schema and target tables.
    - Source CSV files located in the specified Windows directories.
    - PostgreSQL server must have access to the CSV files and the necessary
      permissions to read them.

Loading Strategy:
    Full Load (TRUNCATE + COPY).

Target Tables:
    CRM:
        - bronze.crm_cust_info
        - bronze.crm_prd_info
        - bronze.crm_sales_details

    ERP:
        - bronze.erp_cust_az12
        - bronze.erp_loc_a101
        - bronze.erp_px_cat_g1v2

Notes:
    - Existing table data is removed before loading new data.
    - If an error occurs, the exception is logged and re-thrown.
    - Changes made within the procedure's block are rolled back if an error
      occurs and is caught by the exception handler.
    - CSV file paths may need to be adjusted depending on the environment.

===============================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
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
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '================================';

    start_time := clock_timestamp();
    RAISE NOTICE '--------------------------------';
    RAISE NOTICE 'Loading data into: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;
    COPY bronze.crm_cust_info
    FROM 'D:\SQL\project_sql_DWH\datasets\source_crm\cust_info.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
    end_time := clock_timestamp();
    RAISE NOTICE 'Loading duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '--------------------------------';

    start_time := clock_timestamp();
    RAISE NOTICE 'Loading data into: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;
    COPY bronze.crm_prd_info
    FROM 'D:\SQL\project_sql_DWH\datasets\source_crm\prd_info.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
    end_time := clock_timestamp();
    RAISE NOTICE 'Loading duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '--------------------------------';

    start_time := clock_timestamp();
    RAISE NOTICE 'Loading data into: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;
    COPY bronze.crm_sales_details
    FROM 'D:\SQL\project_sql_DWH\datasets\source_crm\sales_details.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
    end_time := clock_timestamp();
    RAISE NOTICE 'Loading duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '--------------------------------';

    start_time := clock_timestamp();
    RAISE NOTICE 'Loading data into: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;
    COPY bronze.erp_cust_az12
    FROM 'D:\SQL\project_sql_DWH\datasets\source_erp\CUST_AZ12.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
    end_time := clock_timestamp();
    RAISE NOTICE 'Loading duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '--------------------------------';

    start_time := clock_timestamp();
    RAISE NOTICE 'Loading data into: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;
    COPY bronze.erp_loc_a101
    FROM 'D:\SQL\project_sql_DWH\datasets\source_erp\LOC_A101.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
    end_time := clock_timestamp();
    RAISE NOTICE 'Loading duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '--------------------------------';

    start_time := clock_timestamp();
    RAISE NOTICE 'Loading data into: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    COPY bronze.erp_px_cat_g1v2
    FROM 'D:\SQL\project_sql_DWH\datasets\source_erp\PX_CAT_G1V2.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
    end_time := clock_timestamp();
    RAISE NOTICE 'Loading duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '--------------------------------';

    RAISE NOTICE '================================';
    RAISE NOTICE 'Bronze Layer Loaded Successfully';
    RAISE NOTICE '================================';
    total_end_time := clock_timestamp();
    RAISE NOTICE 'Total Loading duration: % seconds',
        EXTRACT(EPOCH FROM (total_end_time - total_start_time));
    RAISE NOTICE '--------------------------------';


EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '================================';
        RAISE WARNING 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        RAISE WARNING 'ERROR MESSAGE: %', SQLERRM;
        RAISE WARNING '================================';

        RAISE;

END;
$$;

CALL bronze.load_bronze();