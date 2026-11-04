/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    Explore the database structure, including tables and columns across
    the Bronze, Silver, and Gold schemas.

This is basicaly saying hello to your database - exploration

Understand what data you have and how the database is structured.

Before analyzing anything, you need to understand the database itself.

You explore:
    - Which tables exist?
    - Which schemas contain them?
    - What columns do the tables have?
    - How is the data organized?

The question you're answering: What data is available to me, and where can I find it?

===============================================================================
*/;


-- Explore all objects in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema IN ('gold', 'silver', 'bronze')
ORDER BY table_schema, table_name;

-- Explore all columns in the database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'
ORDER BY ordinal_position;