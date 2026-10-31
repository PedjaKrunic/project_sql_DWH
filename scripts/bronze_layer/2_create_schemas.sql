/*
===============================================================================
Initializes the Data Warehouse database schemas.
===============================================================================
Purpose:
    This script creates the three schemas required for the Medallion
    Architecture used in the Data Warehouse project.

    Schemas:
        1. Bronze - Stores raw data loaded directly from source systems.
        2. Silver - Stores cleaned, standardized and transformed data.
        3. Gold   - Stores business-ready data prepared for reporting
                    and analytical purposes.

Parameters:
    None.

Usage:
    Execute this script once to initialize the Data Warehouse structure.
    It can also be executed repeatedly without causing errors if the
    schemas already exist.

Dependencies:
    - PostgreSQL database.

Notes:
    - CREATE SCHEMA IF NOT EXISTS prevents errors when schemas already exist.
    - This script only creates schemas; it does not create tables or load data.

===============================================================================
*/

CREATE SCHEMA IF NOT EXISTS bronze;

CREATE SCHEMA IF NOT EXISTS silver;

CREATE SCHEMA IF NOT EXISTS gold;