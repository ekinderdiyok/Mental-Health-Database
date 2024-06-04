-- ***********************************************************
-- Section 0: Preamble
-- ***********************************************************

/*  
Project:
    Description: This SQL script is part of my personal project. The project repository is available on GitHub.
    Data: Saloni Dattani, Lucas Rodés-Guirao, Hannah Ritchie and Max Roser (2023) - “Mental Health” Published online at OurWorldInData.org. Retrieved from: 'https://ourworldindata.org/mental-health' [Online Resource] accessed on 2024-05-13 via https://www.kaggle.com/datasets/imtkaggleteam/mental-health
    Date: 2024-05-13 (start date)

Versions: 
    Apple M2 macOS Sonoma 14.4.1
    PostgreSQL 16.2 on x86_64-apple-darwin20.6.0, compiled by Apple clang version 12.0.5 (clang-1205.0.22.9), 64-bit
    Visual Studio Code 1.89.1 Commit: dc96b837cf6bb4af9cd736aa3af08cf8279f7685 Date: 2024-05-07T05:14:32.757Z Electron: 28.2.8 ElectronBuildId: 27744544 Chromium: 120.0.6099.291 Node.js: 18.18.2 V8: 12.0.267.19-electron.0 OS: Darwin arm64 23.4.0
    SQLTools (Visual Studio Code extension) v0.28.3
    SQLTools PostgreSQL/Cockroach Driver (Visual Studio Code extension) 0.5.4

Author: 
    Name: Ekin Derdiyok
    GitHub: https://github.com/ekinderdiyok
    LinkedIn: https://www.linkedin.com/in/ekinderdiyok/
    Email: ekin.derdiyok@icloud.com

Table of Contents:
    Section 0: Preamble
    Section 1: Creating the database
    Section 2: Creating the entity_year_index master table via staging tables
    Section 3: Creating the prevalence table
    Section 4: Inspecting the data integrity of the prevalence table
    Section 5: Exploring the prevalence table
    Section 6: Adding a second table
    Section 7: Adding a third table for treatment gap
*/



-- ***********************************************************
-- Section 1: Creating the database
-- ***********************************************************

-- Connect to the server using SQLTools: postgres@localhost:5432/mental_health. Password is password.

-- Create database
CREATE DATABASE mental_health;

-- Check if database is successfully created. Returns True if it exists
SELECT EXISTS (
    SELECT FROM pg_database WHERE datname = 'mental_health'
);

-- Double check with a non-existing database. It should return False
SELECT EXISTS (
    SELECT FROM pg_database WHERE datname = 'non_existing_db'
);

-- Commenting on the mental_health database
COMMENT ON DATABASE mental_health IS 'This database stores data related to prevalence and burden of several mental illnesses as well as on anxiety treatment gap';

-- Query to find the comment on a database
SELECT description 
FROM pg_shdescription 
JOIN pg_database ON pg_database.oid = pg_shdescription.objoid
WHERE datname = 'mental_health';



-- ***********************************************************
-- Section 2: Creating the entity_year_index master table via staging tables
-- ***********************************************************

-- Drop table before creating it. This is to avoid errors if the table already exists
DROP TABLE IF EXISTS entity_year_index;

-- Create entity_year_index table and populate it with unique entities and years from the prevalence and burden tables
CREATE TABLE IF NOT EXISTS entity_year_index (
    entity VARCHAR(255),
    year INT,
    PRIMARY KEY (entity, year)
);

-- Add comments to the entity_year_index table and its columns
COMMENT ON TABLE entity_year_index IS 'Master table for unique entities and years';
COMMENT ON COLUMN entity_year_index.entity IS 'Represents a unique identifier for an entity, e.g., a country or region';
COMMENT ON COLUMN entity_year_index.year IS 'The year associated with the entity data';

-- Retrieve comments on the table
SELECT obj_description('entity_year_index'::regclass, 'pg_class') AS table_comment;

-- Retrieve comments on the columns
SELECT 
    column_name, 
    col_description('entity_year_index'::regclass, ordinal_position) AS column_comment
FROM
    information_schema.columns
WHERE
    table_name = 'entity_year_index'
    AND table_schema = 'public';

-- Create a temporary staging table to accommodate all data in the CSV, without deleting the original data in csv file:
CREATE TABLE staging_table (
    entity VARCHAR(255),
    code VARCHAR(10),
    year INT,
    metric1 DOUBLE PRECISION,
    metric2 DOUBLE PRECISION,
    metric3 DOUBLE PRECISION,
    metric4 DOUBLE PRECISION,
    metric5 DOUBLE PRECISION
);

-- Import CSV file to staging_table. Run this command in the psql terminal. Replace the path with your own path. Prompt should look like this: mental_health=#
\copy staging_table FROM '/Users/ekinderdiyok/Documents/Mental Health/Data/1- mental-illnesses-prevalence.csv' DELIMITER ',' CSV HEADER;

-- Once the data is in the staging table, insert only the necessary columns into the entity_year_index table:
INSERT INTO entity_year_index (entity, year)
SELECT DISTINCT entity, year
FROM staging_table
ON CONFLICT (entity, year) DO NOTHING;

-- Create a temporary or staging table that has columns to accommodate all data in the CSV:
CREATE TABLE staging_table_2 (
    entity VARCHAR(255),
    code VARCHAR(10),
    year INT,
    metric1 DOUBLE PRECISION,
    metric2 DOUBLE PRECISION,
    metric3 DOUBLE PRECISION,
    metric4 DOUBLE PRECISION,
    metric5 DOUBLE PRECISION
);

-- Import CSV file to staging_table. Run this command in the psql terminal. Replace the path with your own path. Prompt should look like this: mental_health=#
\copy staging_table_2 FROM '/Users/ekinderdiyok/Documents/Mental Health/Data/2- burden-disease-from-each-mental-illness(1).csv' DELIMITER ',' CSV HEADER;

-- Once the data is in the staging table, insert only the necessary columns into the entity_year_index table:
INSERT INTO entity_year_index (entity, year)
SELECT DISTINCT entity, year
FROM staging_table_2
ON CONFLICT (entity, year) DO NOTHING;

-- Create a temporary or staging table that has columns to accommodate all data in the CSV:
CREATE TABLE staging_table_3 (
    entity VARCHAR(255),
    code VARCHAR(10),
    year INT,
    metric1 DOUBLE PRECISION,
    metric2 DOUBLE PRECISION,
    metric3 DOUBLE PRECISION
);

-- Import CSV file to staging_table. Run this command in the psql terminal. Replace the path with your own path. Prompt should look like this: mental_health=#
\copy staging_table_3 FROM '/Users/ekinderdiyok/Documents/Mental Health/Data/5- anxiety-disorders-treatment-gap.csv' DELIMITER ',' CSV HEADER;

-- Once the data is in the staging table, insert only the necessary columns into the entity_year_index table:
INSERT INTO entity_year_index (entity, year)
SELECT DISTINCT entity, year
FROM staging_table_3
ON CONFLICT (entity, year) DO NOTHING;

-- Check if entity_year_index table is successfully created.
SELECT * FROM entity_year_index;

-- Drop staging tables
DROP TABLE IF EXISTS staging_table;
DROP TABLE IF EXISTS staging_table_2;
DROP TABLE IF EXISTS staging_table_3;




-- ***********************************************************
-- Section 3: Creating the prevalence table
-- ***********************************************************


-- Drop table before creating it. This is to avoid errors if the table already exists
DROP TABLE IF EXISTS prevalence;

-- Create a table for mental illness prevalence
CREATE TABLE IF NOT EXISTS prevalence (
    "entity" VARCHAR(255),
    "code" VARCHAR(10),
    "year" INT,
    "schi" DOUBLE PRECISION,
    "depr" DOUBLE PRECISION,
    "anxi" DOUBLE PRECISION,
    "bipo" DOUBLE PRECISION,
    "eati" DOUBLE PRECISION,
    PRIMARY KEY ("entity", "year") -- Composite primary key
    FOREIGN KEY ("entity", "year") REFERENCES entity_year_index("entity", "year") -- Ensures referential integrity
);

-- Add comment to prevalence table and its columns
COMMENT ON TABLE prevalence IS 'Prevalence of mental illnesses in percentage';
COMMENT ON COLUMN prevalence.entity IS 'Name of a country or region';
COMMENT ON COLUMN prevalence.year IS '4 digit year';
COMMENT ON COLUMN prevalence.code IS 'ISO country code';
COMMENT ON COLUMN prevalence.schi IS 'Schizophrenia prevalence in percentage';
COMMENT ON COLUMN prevalence.depr IS 'Depression prevalence in percentage';
COMMENT ON COLUMN prevalence.anxi IS 'Anxiety prevalence in percentage';
COMMENT ON COLUMN prevalence.bipo IS 'Bipolar disorder prevalence in percentage';
COMMENT ON COLUMN prevalence.eati IS 'Eating disorders prevalence in percentage';

-- Check if table is successfully created. Returns True if it exists
SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_name = 'prevalence'
);

-- Double check with a non-existing table. It should return False
SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_name = 'non_existing_table'
);

-- Display table (it should be empty)
SELECT * FROM prevalence;

-- Connect to database from the terminal. Execute the next line in the terminal without "--"
psql -U postgres -d mental_health 

-- Import CSV file to mental_health table. Run this command in the psql terminal. Replace the path with your own path. Prompt should look like this: mental_health=#
\copy prevalence FROM '/Users/ekinderdiyok/Documents/Mental Health/Data/1- mental-illnesses-prevalence.csv' DELIMITER ',' CSV HEADER;




-- ***********************************************************
-- Section 4: Inspecting the data integrity of the prevalence table
-- ***********************************************************

-- Display head of the prevalence table it should contain 8 columns.
SELECT * FROM prevalence LIMIT 5;

-- Check column names, data types, and approximate max size again. It should match the table definition.
SELECT 
    column_name, 
    data_type, 
    CASE 
        WHEN data_type = 'integer' THEN 4
        WHEN data_type = 'double precision' THEN 8
        WHEN data_type LIKE 'character varying%' THEN character_maximum_length
        ELSE null 
    END AS approximate_max_size,
    is_nullable
FROM 
    information_schema.columns
WHERE 
    table_name = 'prevalence';


-- Identify which columns have missing values using DO. Then inspect SQL console for the results.
DO $$
DECLARE
    column_info RECORD;
    query TEXT;
BEGIN
    -- Initialize an empty result set
    CREATE TEMP TABLE IF NOT EXISTS missing_values (column_name TEXT, null_count INT);

    FOR column_info IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = 'prevalence' -- Make sure to specify your schema if not public
    LOOP
        -- Construct a query for each column to count NULLs
        query := FORMAT('INSERT INTO missing_values (column_name, null_count) SELECT %L, COUNT(*) FROM prevalence WHERE %I IS NULL', column_info.column_name, column_info.column_name);

        -- Execute the query
        EXECUTE query;
    END LOOP;

    -- Output the results
    RAISE NOTICE 'Missing values per column:';
    FOR column_info IN
        SELECT * FROM missing_values
    LOOP
        RAISE NOTICE '%: %', column_info.column_name, column_info.null_count;
    END LOOP;

    -- Drop the temporary table
    -- DROP TABLE missing_values;
END $$;

-- Check missing values in the prevalence table
SELECT * FROM missing_values;

-- Inspect missing values. There are 270 missing values in the code column that are either continents or regions without an ISO country code.
SELECT * FROM prevalence WHERE code IS NULL;

-- Check the number of unique entities in the prevalence table
SELECT COUNT(DISTINCT entity) AS unique_entities FROM prevalence;

-- Check the number of unique years in the prevalence table
SELECT COUNT(DISTINCT year) AS unique_years FROM prevalence;

-- Summary statistics for the schizophrenia column
SELECT 
    'Schizophrenia' AS disorder,
    COUNT(schi) AS non_null_count,
    AVG(schi) AS mean,
    STDDEV(schi) AS stddev,
    MIN(schi) AS min,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY schi) AS first_quartile,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY schi) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY schi) AS third_quartile,
    MAX(schi) AS max
FROM 
    prevalence;

-- Summary statistics for all illness prevalence columns using a lateral join
SELECT 
    v.disorder,
    COUNT(v.value) AS non_null_count,
    AVG(v.value) AS mean,
    STDDEV(v.value) AS stddev,
    MIN(v.value) AS min,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY v.value) AS first_quartile,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY v.value) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY v.value) AS third_quartile,
    MAX(v.value) AS max
FROM 
    prevalence,
    LATERAL (
        VALUES 
            ('Schizophrenia', schi),
            ('Depression', depr),
            ('Anxiety', anxi),
            ('Bipolar', bipo),
            ('Eating Disorders', eati)
    ) AS v(disorder, value)
GROUP BY 
    v.disorder
ORDER BY 
    v.disorder;

-- Make sure all country codes are only 3 chars long
SELECT DISTINCT code, LENGTH(code) AS code_length
FROM prevalence
WHERE code IS NOT NULL

-- Check the storage size of the 'prevalence' table
SELECT 
    pg_size_pretty(pg_total_relation_size('prevalence')) AS total_table_size,  -- Total size of the table, including indexes, TOAST tables (The Oversized-Attribute Storage Technique), and free space 
    pg_size_pretty(pg_indexes_size('prevalence')) AS index_size,  -- Total size of all indexes on the table
    pg_size_pretty(pg_total_relation_size('prevalence') - pg_indexes_size('prevalence')) AS data_size,  -- Size of the table's data, excluding indexes
    pg_size_pretty(pg_relation_size('prevalence')) AS table_size;  -- Size of the table's main data file, excluding indexes and TOAST tables





-- ***********************************************************
-- Section 5: Exploring the prevalence table
-- ***********************************************************

-- List disorder country pair with the highest prevalence for each disorder
WITH DisorderMax AS (
    SELECT 
        disorder,
        entity AS country,
        code AS country_code,
        CASE disorder
            WHEN 'Schizophrenia' THEN MAX(schi)
            WHEN 'Depression' THEN MAX(depr)
            WHEN 'Anxiety' THEN MAX(anxi)
            WHEN 'Bipolar' THEN MAX(bipo)
            WHEN 'Eating Disorders' THEN MAX(eati)
        END AS max_value
    FROM prevalence
    CROSS JOIN (VALUES
        ('Schizophrenia'), 
        ('Depression'), 
        ('Anxiety'), 
        ('Bipolar'), 
        ('Eating Disorders')
    ) AS Disorders(disorder)
    GROUP BY disorder, entity, code
)
, MaxPerDisorder AS (
    SELECT disorder, country, country_code, max_value
    FROM (
        SELECT 
            disorder,
            country,
            country_code,
            max_value,
            ROW_NUMBER() OVER (PARTITION BY disorder ORDER BY max_value DESC) AS rn
        FROM DisorderMax
    ) AS ranked
    WHERE rn = 1
)
SELECT * FROM MaxPerDisorder;

-- Show the top 5 countries with the HIGHEST total prevalence of all disorders in year 2019
SELECT entity AS country, code AS country_code, SUM(schi + depr + anxi + bipo + eati) AS total_prevalence
FROM prevalence
WHERE year = 2019
GROUP BY entity, code
ORDER BY total_prevalence DESC
LIMIT 5;

-- Show the top 5 countries with the LOWEST total prevalence of all disorders in year 2019
SELECT entity AS country, code AS country_code, SUM(schi + depr + anxi + bipo + eati) AS total_prevalence
FROM prevalence
WHERE year = 2019
GROUP BY entity, code
ORDER BY total_prevalence ASC
LIMIT 5;

-- Compare non-country entities (continents, regions) with the highest total prevalence of all disorders in year 2019
-- IHME GBD stands for "Institute for Health Metrics and Evaluation Global Burden of Disease"
SELECT entity AS region, SUM(schi + depr + anxi + bipo + eati) AS total_prevalence
FROM prevalence
WHERE year = 2019 AND code IS NULL
GROUP BY entity
ORDER BY total_prevalence DESC;




-- ***********************************************************
-- Section 6: Adding a second table
-- ***********************************************************

-- Drop table before creating it. This is to avoid errors if the table already exists
DROP TABLE IF EXISTS burden;

-- Create a table for burden (DALYs: Disability-Adjusted Life Years)
CREATE TABLE IF NOT EXISTS burden (
    entity VARCHAR(255),
    code VARCHAR(10),
    year INTEGER,
    depr DOUBLE PRECISION,
    schi DOUBLE PRECISION,
    bipo DOUBLE PRECISION,
    eati DOUBLE PRECISION,
    anxi DOUBLE PRECISION,
    PRIMARY KEY (entity, year), -- Composite primary key for entity and year 
    FOREIGN KEY ("entity", "year") REFERENCES entity_year_index("entity", "year") -- Ensures referential integrity
);

-- Add comment to burden table and its columns
COMMENT ON TABLE burden IS 'Disability-Adjusted Life Years (DALYS) from each mental illness';
COMMENT ON COLUMN burden.entity IS 'Name of a country or region';
COMMENT ON COLUMN burden.year IS '4 digit year';
COMMENT ON COLUMN burden.code IS 'ISO country code';
COMMENT ON COLUMN burden.depr IS 'Total DALYs from depression';
COMMENT ON COLUMN burden.schi IS 'Total DALYs from schizophrenia';
COMMENT ON COLUMN burden.bipo IS 'Total DALYs from bipolar disorder';
COMMENT ON COLUMN burden.eati IS 'Total DALYs from eating disorders';
COMMENT ON COLUMN burden.anxi IS 'Total DALYs from anxiety';

-- Retrieve comments on the table to check if it was successfully added
SELECT obj_description('burden'::regclass, 'pg_class') AS table_comment;

-- Eetrieve comments on the columns to check if they were successfully added
SELECT 
    column_name, 
    col_description('burden'::regclass, ordinal_position) AS column_comment
FROM
    information_schema.columns
WHERE
    table_name = 'burden'
    AND table_schema = 'public';

-- Check if table is successfully created. Returns True if it exists
SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'burden');

-- Import CSV file to burden table. Run this command in the psql terminal. Replace the path with your own path. Prompt should look like this: mental_health=#
\copy burden FROM '/Users/ekinderdiyok/Documents/Mental Health/Data/2- burden-disease-from-each-mental-illness(1).csv' DELIMITER ',' CSV HEADER;

-- Check if import was successful
SELECT * FROM burden;

-- Create missing values burden table
DO $$
DECLARE
    column_info RECORD;
    query TEXT;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS missing_values_burden (column_name TEXT, null_count INT);

    FOR column_info IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = 'burden'
    LOOP
        query := FORMAT('INSERT INTO missing_values_burden (column_name, null_count) SELECT %L, COUNT(*) FROM burden WHERE %I IS NULL', column_info.column_name, column_info.column_name);
        EXECUTE query;
    END LOOP;

    RAISE NOTICE 'Missing values per column:';
    FOR column_info IN
        SELECT * FROM missing_values_burden
    LOOP
        RAISE NOTICE '%: %', column_info.column_name, column_info.null_count;
    END LOOP;
END $$;

-- Check missing value count
SELECT * FROM missing_values_burden;


-- Summary statistics for all burden columns in burden table using a lateral join
SELECT 
    v.disorder,
    COUNT(v.value) AS non_null_count,
    AVG(v.value) AS mean,
    STDDEV(v.value) AS stddev,
    MIN(v.value) AS min,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY v.value) AS first_quartile,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY v.value) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY v.value) AS third_quartile,
    MAX(v.value) AS max
FROM 
    burden,
    LATERAL (
        VALUES 
            ('Schizophrenia', schi),
            ('Depression', depr),
            ('Anxiety', anxi),
            ('Bipolar', bipo),
            ('Eating Disorders', eati)
    ) AS v(disorder, value)
GROUP BY 
    v.disorder
ORDER BY 
    v.disorder;

-- Find the entity names with missing codes
SELECT DISTINCT entity, code
FROM burden
WHERE code IS NULL;

-- Full outer join prevalence and burden tables
SELECT 
    COALESCE(p.entity, b.entity) AS entity,  -- Selects p.entity if not null; otherwise, selects b.entity
    COALESCE(p.year, b.year) AS year,        -- Selects p.year if not null; otherwise, selects b.year
    p.schi AS schizophrenia_prevalence,
    b.schi AS schizophrenia_burden,
    p.depr AS depression_prevalence,
    b.depr AS depression_burden,
    p.anxi AS anxiety_prevalence,
    b.anxi AS anxiety_burden,
    p.bipo AS bipolar_prevalence,
    b.bipo AS bipolar_burden,
    p.eati AS eating_disorders_prevalence,
    b.eati AS eating_disorders_burden
FROM 
    prevalence p
FULL OUTER JOIN 
    burden b ON p.entity = b.entity AND p.year = b.year;  -- Includes all records from both tables, with NULLs where there are no matches





-- ***********************************************************
-- Section 7: Adding a third table for treatment gap
-- ***********************************************************

-- Drop table before creating it. This is to avoid errors if the table already exists
DROP TABLE IF EXISTS anxiety_treatment_gap;

-- Create a table for anxiety treatment gap TEST
CREATE TABLE IF NOT EXISTS anxiety_treatment_gap (
    entity VARCHAR(255),
    code VARCHAR(10),
    year INT,
    adequate_treat DOUBLE PRECISION,
    other_treat DOUBLE PRECISION,
    untreated DOUBLE PRECISION,
    PRIMARY KEY (entity, year),  -- Ensures uniqueness and improves query performance
    FOREIGN KEY (entity, year) REFERENCES entity_year_index(entity, year)  -- Ensures referential integrity
);
COMMENT ON TABLE anxiety_treatment_gap IS 'Breakdown of anxiety patients treatment gap';
COMMENT ON COLUMN anxiety_treatment_gap.entity IS 'Name of a country or region';
COMMENT ON COLUMN anxiety_treatment_gap.year IS '4 digit year';
COMMENT ON COLUMN anxiety_treatment_gap.code IS 'ISO country code';
COMMENT ON COLUMN anxiety_treatment_gap.adequate_treat IS 'Percentage of anxiety patients';
COMMENT ON COLUMN anxiety_treatment_gap.other_treat IS 'Percentage of anxiety patients';
COMMENT ON COLUMN anxiety_treatment_gap.untreated IS 'Percentage of anxiety patients';

-- Retrieve comments on the table comment
SELECT obj_description('anxiety_treatment_gap'::regclass, 'pg_class') AS table_comment;

-- Retrieve comments on the columns
SELECT 
    column_name, 
    col_description('anxiety_treatment_gap'::regclass, ordinal_position) AS column_comment
FROM 
    information_schema.columns 
WHERE 
    table_name = 'anxiety_treatment_gap' 
    AND table_schema = 'public';  -- Replace 'public' with your schema name if different

-- Check if table is successfully created. Returns True if it exists
SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'anxiety_treatment_gap');

-- Import CSV file to anxiety_treatment_gap table. Run this command in the psql terminal. Replace the path with your own path. Prompt should look like this: mental_health=#
\copy anxiety_treatment_gap FROM '/Users/ekinderdiyok/Documents/Mental Health/Data/5- anxiety-disorders-treatment-gap.csv' DELIMITER ',' CSV HEADER;

-- Check if import was successful
SELECT * FROM anxiety_treatment_gap ;

-- Summary statistics for all columns in anxiety_treatment_gap table using a lateral join
SELECT 
    v.treatment,
    COUNT(v.value) AS non_null_count,
    AVG(v.value) AS mean,
    STDDEV(v.value) AS stddev,
    MIN(v.value) AS min,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY v.value) AS first_quartile,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY v.value) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY v.value) AS third_quartile,
    MAX(v.value) AS max
FROM
    anxiety_treatment_gap,
    LATERAL (
        VALUES 
            ('Adequate Treatment', adequate_treat),
            ('Other Treatment', other_treat),
            ('Untreated', untreated)
    ) AS v(treatment, value)
GROUP BY
    v.treatment
ORDER BY
    v.treatment;

-- Join the prevalence, burden, and anxiety treatment gap tables
SELECT 
    COALESCE(p.entity, b.entity, c.entity) AS entity,
    COALESCE(p.year, b.year, c.year) AS year,
    p.schi AS schizophrenia_prevalence,
    b.schi AS schizophrenia_burden,
    p.depr AS depression_prevalence,
    b.depr AS depression_burden,
    p.anxi AS anxiety_prevalence,
    b.anxi AS anxiety_burden,
    p.bipo AS bipolar_prevalence,
    b.bipo AS bipolar_burden,
    p.eati AS eating_disorders_prevalence,
    b.eati AS eating_disorders_burden,
    c.adequate_treat AS anxiety_adequate_treatment,
    c.other_treat AS anxiety_other_treatment,
    c.untreated AS anxiety_untreated
FROM
    prevalence p
FULL OUTER JOIN
    burden b ON p.entity = b.entity AND p.year = b.year
LEFT JOIN
    anxiety_treatment_gap c ON p.entity = c.entity AND p.year = c.year;

-- End of the SQL script