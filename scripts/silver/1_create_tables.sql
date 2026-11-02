/*
===============================================================================
Creates the Silver layer tables for the Data Warehouse.
===============================================================================
Purpose:
    This script defines the database structure for the Silver layer by
    creating six tables that store cleaned, standardized, and transformed
    data from the Bronze layer.

    Compared to the Bronze layer, the Silver layer introduces several
    modifications to improve data consistency and prepare the data for
    further processing:

        1. Changes column data types where necessary to ensure consistency
           and proper data representation.
        2. Converts date columns stored as integers or timestamps in the
           Bronze layer into the DATE data type.
        3. Adds a product category identifier (cat_id) to the
           silver.crm_prd_info table.
        4. Adds a dwh_create_date column to all tables to record when each
           row is inserted into the Silver layer.

    For each table, the script:
        1. Checks whether the table already exists.
        2. Drops the existing table if it exists.
        3. Creates a new table with the required columns and data types.

Parameters:
    None.

Usage:
    Execute this script to create or recreate all Silver layer tables.

Dependencies:
    - PostgreSQL database.
    - Existing silver schema.

Notes:
    - The Silver layer stores cleaned and standardized data originating
      from the Bronze layer.
    - Column data types are adjusted to support consistent data
      representation and downstream transformations.
    - The dwh_create_date column uses TIMESTAMPTZ with DEFAULT CURRENT_TIMESTAMP
      to automatically record the transaction timestamp when a row is inserted,
      unless an explicit value is provided.
    - All tables are created without primary keys or foreign key constraints.
    - Existing tables are dropped and recreated, meaning all previously
      stored data in these tables will be permanently removed.

===============================================================================
*/

DROP TABLE IF EXISTS silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
    cst_id              INT,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date     DATE,
    dwh_create_date     TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP --time when new row is inserted
);

DROP TABLE IF EXISTS silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
    prd_id       INT,
    cat_id       VARCHAR(50),
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INT,
    prd_line     VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE,
    dwh_create_date     TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP --time when new row is inserted
);

DROP TABLE IF EXISTS silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt DATE,
    sls_ship_dt  DATE,
    sls_due_dt   DATE,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
    dwh_create_date     TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP --time when new row is inserted
);

DROP TABLE IF EXISTS silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101 (
    cid    VARCHAR(50),
    cntry  VARCHAR(50),
    dwh_create_date     TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP --time when new row is inserted
);

DROP TABLE IF EXISTS silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12 (
    cid    VARCHAR(50),
    bdate  DATE,
    gen    VARCHAR(50),
    dwh_create_date     TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP --time when new row is inserted
);

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2 (
    id           VARCHAR(50),
    cat          VARCHAR(50),
    subcat       VARCHAR(50),
    maintenance  VARCHAR(50),
    dwh_create_date     TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP --time when new row is inserted
);