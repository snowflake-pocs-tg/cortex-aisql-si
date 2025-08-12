-- =====================================================================================
-- SEMANTIC VIEWS FOR BANKING INTELLIGENCE - USING REAL DATA
-- =====================================================================================
-- Purpose: Enable natural language querying of banking data with actual values
-- Database: EQUITY_INTEL_POC
-- Schema: PROCESSED
-- Author: Snowflake Intelligence POC Team
-- Last Updated: 2025
-- 
-- OVERVIEW:
-- ---------
-- This file creates semantic views that enable business users to query banking data
-- using natural language through Snowflake's Cortex Analyst. These views have been
-- carefully designed to work with tables that contain ACTUAL numerical values,
-- ensuring every query returns meaningful results.
--
-- KEY INSIGHT:
-- ------------
-- After extensive data analysis, we discovered that the FINANCIAL_INSTITUTION_TIMESERIES
-- table contains NULL values in the VALUE column, making it unsuitable for analytics.
-- Instead, we focus on the FDIC_SUMMARY_OF_DEPOSITS_TIMESERIES table which contains
-- real deposit values, combined with entity and branch data for comprehensive analysis.
--
-- TABLE OF CONTENTS:
-- ------------------
-- Use CTRL+F to search for these section markers:
--
-- [SECTION 1: SETUP]           - Database and warehouse configuration
-- [SECTION 2: FDIC_DEPOSITS]   - FDIC deposit data semantic view
-- [SECTION 3: FDIC_QUERIES]    - Test queries for FDIC deposits view
-- [SECTION 4: BRANCH_NETWORK]  - Branch network semantic view  
-- [SECTION 5: BRANCH_QUERIES]  - Test queries for branch network view
--
-- SEMANTIC VIEWS INCLUDED:
-- ------------------------
-- 1. FDIC_DEPOSITS_ANALYTICS
--    - Analyzes FDIC deposit data with real numerical values
--    - Dimensions: Date, Institution ID, Branch ID, Variable Name
--    - Metrics: Total/Avg/Max/Min deposits, Branch counts
--    - Best for: Deposit trends, institution comparisons, time series analysis
--
-- 2. BANKING_BRANCH_NETWORK_ANALYTICS
--    - Combines bank entities with branch location data
--    - Dimensions: Bank name, State, City, Regulator, Specialization
--    - Metrics: Branch counts, Geographic footprint, Active branches
--    - Best for: Geographic analysis, regulatory comparisons, network size
--
-- HOW TO USE THESE VIEWS:
-- -----------------------
-- 1. Run this entire script to create both semantic views
-- 2. Test with the provided sample queries to verify data availability
-- 3. Use Cortex Analyst to ask natural language questions like:
--    - "Show me total deposits by year"
--    - "Which banks have the most branches in Texas?"
--    - "Compare branch networks by federal regulator"
--
-- DATA SOURCES:
-- -------------
-- - FINANCE_ECONOMICS.CYBERSYN.FDIC_SUMMARY_OF_DEPOSITS_TIMESERIES (deposits)
-- - FINANCE_ECONOMICS.CYBERSYN.FINANCIAL_INSTITUTION_ENTITIES (bank info)
-- - FINANCE_ECONOMICS.CYBERSYN.FINANCIAL_BRANCH_ENTITIES (branch locations)
--
-- TROUBLESHOOTING:
-- ----------------
-- - If queries return 0 rows, check that the Cybersyn data share is properly mounted
-- - Ensure you have SELECT privileges on the FINANCE_ECONOMICS database
-- - Verify the EQUITY_INTEL_WH warehouse is running and sized appropriately
--
-- =====================================================================================

-- =====================================================================================
-- [SECTION 1: SETUP]
-- =====================================================================================

USE ROLE SYSADMIN;
USE DATABASE EQUITY_INTEL_POC;
USE SCHEMA PROCESSED;
USE WAREHOUSE EQUITY_INTEL_WH;

-- =====================================================================================
-- [SECTION 2: FDIC_DEPOSITS]
-- =====================================================================================
-- VIEW 1: FDIC_DEPOSITS_ANALYTICS
-- Analyzes FDIC deposit data which contains actual numerical values
-- This is our most reliable data source for demonstrating semantic view capabilities
-- =====================================================================================

CREATE OR REPLACE SEMANTIC VIEW FDIC_DEPOSITS_ANALYTICS
  TABLES (
    -- Deposit data - THE ONLY TABLE WITH ACTUAL VALUES!
    deposits AS FINANCE_ECONOMICS.CYBERSYN.FDIC_SUMMARY_OF_DEPOSITS_TIMESERIES
      PRIMARY KEY (FDIC_INSTITUTION_ID, FDIC_BRANCH_ID, VARIABLE, DATE)
      WITH SYNONYMS ('deposits', 'branch deposits', 'deposit data')
      COMMENT = 'FDIC branch-level deposit information'
  )
  
  DIMENSIONS (
    -- Time dimensions
    deposits.DATE AS deposits.DATE
      WITH SYNONYMS = ('date', 'period', 'reporting date', 'year')
      COMMENT = 'Deposit reporting date',
    
    -- Institution dimensions
    deposits.FDIC_INSTITUTION_ID AS deposits.FDIC_INSTITUTION_ID
      WITH SYNONYMS = ('institution', 'bank id', 'fdic id')
      COMMENT = 'FDIC institution identifier',
    
    -- Branch dimensions
    deposits.FDIC_BRANCH_ID AS deposits.FDIC_BRANCH_ID
      WITH SYNONYMS = ('branch', 'branch id', 'location')
      COMMENT = 'FDIC branch identifier',
    
    -- Variable dimensions
    deposits.VARIABLE AS deposits.VARIABLE
      WITH SYNONYMS = ('metric code', 'variable code')
      COMMENT = 'FDIC variable identifier',
    
    deposits.VARIABLE_NAME AS deposits.VARIABLE_NAME
      WITH SYNONYMS = ('metric', 'measure', 'variable description')
      COMMENT = 'Human-readable description of the financial metric',
    
    deposits.UNIT AS deposits.UNIT
      WITH SYNONYMS = ('units', 'currency', 'denomination')
      COMMENT = 'Unit of measurement (typically USD)'
  )
  
  METRICS (
    -- Deposit metrics - REAL VALUES!
    deposits.total_deposits AS SUM(deposits.VALUE)
      WITH SYNONYMS = ('total deposits', 'deposit amount', 'sum of deposits')
      COMMENT = 'Total deposits across all branches',
    
    deposits.avg_deposits AS AVG(deposits.VALUE)
      WITH SYNONYMS = ('average deposits', 'mean deposits', 'avg branch deposits')
      COMMENT = 'Average deposits per branch',
    
    deposits.max_deposits AS MAX(deposits.VALUE)
      WITH SYNONYMS = ('maximum deposits', 'largest branch', 'highest deposits')
      COMMENT = 'Maximum deposits at any single branch',
    
    deposits.min_deposits AS MIN(deposits.VALUE)
      WITH SYNONYMS = ('minimum deposits', 'smallest branch', 'lowest deposits')
      COMMENT = 'Minimum deposits at any branch',
    
    -- Count metrics
    deposits.branch_count AS COUNT(DISTINCT deposits.FDIC_BRANCH_ID)
      WITH SYNONYMS = ('number of branches', 'branch count', 'locations')
      COMMENT = 'Total number of unique branches',
    
    deposits.institution_count AS COUNT(DISTINCT deposits.FDIC_INSTITUTION_ID)
      WITH SYNONYMS = ('number of banks', 'institution count', 'bank count')
      COMMENT = 'Total number of unique institutions',
    
    deposits.record_count AS COUNT(*)
      WITH SYNONYMS = ('records', 'data points', 'observations')
      COMMENT = 'Total number of deposit records'
  )
  
  COMMENT = 'FDIC deposit analytics with real numerical data';

-- =====================================================================================
-- [SECTION 3: FDIC_QUERIES]
-- =====================================================================================
-- TEST QUERIES FOR FDIC_DEPOSITS_ANALYTICS
-- These queries demonstrate various ways to analyze FDIC deposit data
-- =====================================================================================

-- Query 1: Total deposits by year
SELECT * FROM SEMANTIC_VIEW(
    FDIC_DEPOSITS_ANALYTICS
    DIMENSIONS YEAR(deposits.DATE) AS year
    METRICS deposits.total_deposits, deposits.branch_count
)
WHERE year >= 2020
ORDER BY year DESC;

-- Query 2: Top institutions by total deposits
SELECT * FROM SEMANTIC_VIEW(
    FDIC_DEPOSITS_ANALYTICS
    DIMENSIONS deposits.FDIC_INSTITUTION_ID
    METRICS deposits.total_deposits, deposits.branch_count, deposits.avg_deposits
)
ORDER BY total_deposits DESC
LIMIT 10;

-- Query 3: Deposit trends over time
SELECT * FROM SEMANTIC_VIEW(
    FDIC_DEPOSITS_ANALYTICS
    DIMENSIONS deposits.DATE
    METRICS deposits.total_deposits, deposits.institution_count
)
WHERE DATE >= '2020-01-01'
ORDER BY DATE;

-- Query 4: Branch deposit distribution
SELECT * FROM SEMANTIC_VIEW(
    FDIC_DEPOSITS_ANALYTICS
    DIMENSIONS deposits.FDIC_BRANCH_ID
    METRICS deposits.total_deposits, deposits.avg_deposits
)
WHERE total_deposits > 0
ORDER BY total_deposits DESC
LIMIT 20;

-- Query 5: Metrics by variable type
SELECT * FROM SEMANTIC_VIEW(
    FDIC_DEPOSITS_ANALYTICS
    DIMENSIONS deposits.VARIABLE_NAME
    METRICS deposits.total_deposits, deposits.record_count
)
ORDER BY record_count DESC;


-- =====================================================================================
-- [SECTION 4: BRANCH_NETWORK]
-- =====================================================================================
-- VIEW 2: BANKING_BRANCH_NETWORK_ANALYTICS
-- Analyzes branch locations and geographic footprint of financial institutions
-- Combines bank entity data with branch network information
-- Note: Deposit data uses different IDs (FDIC) than branch data (RSSD)
-- =====================================================================================

CREATE OR REPLACE SEMANTIC VIEW BANKING_BRANCH_NETWORK_ANALYTICS
  TABLES (
    -- Bank entity dimension
    banks AS FINANCE_ECONOMICS.CYBERSYN.FINANCIAL_INSTITUTION_ENTITIES
      PRIMARY KEY (ID_RSSD)
      WITH SYNONYMS ('financial institutions', 'banks', 'credit unions')
      COMMENT = 'Financial institutions including banks, credit unions, and thrifts',
    
    -- Branch locations
    branches AS FINANCE_ECONOMICS.CYBERSYN.FINANCIAL_BRANCH_ENTITIES
      PRIMARY KEY (ID_RSSD)
      WITH SYNONYMS ('branch', 'location', 'office')
      COMMENT = 'Individual branch locations for financial institutions',
    
    -- Deposit data - THE ONLY TABLE WITH ACTUAL VALUES!
    deposits AS FINANCE_ECONOMICS.CYBERSYN.FDIC_SUMMARY_OF_DEPOSITS_TIMESERIES
      PRIMARY KEY (FDIC_INSTITUTION_ID, FDIC_BRANCH_ID, VARIABLE, DATE)
      WITH SYNONYMS ('deposits', 'branch deposits', 'deposit data')
      COMMENT = 'Branch-level deposit information'
  )
  
  RELATIONSHIPS (
    -- Define relationships between tables
    branches_to_banks AS
      branches (ID_RSSD_PARENT) REFERENCES banks
  )
  
  FACTS (
    -- Core numeric values - ACTUAL DATA!
    deposits.VALUE AS deposits.VALUE,
    banks.START_DATE AS banks.START_DATE,
    branches.START_DATE AS branches.START_DATE
  )
  
  DIMENSIONS (
    -- Time dimensions
    deposits.DATE AS deposits.DATE
      WITH SYNONYMS = ('date', 'period', 'reporting date')
      COMMENT = 'Deposit reporting date',
    
    -- Bank dimensions
    banks.NAME AS banks.NAME
      WITH SYNONYMS = ('bank name', 'institution name', 'company')
      COMMENT = 'Legal name of the financial institution',
    banks.STATE_ABBREVIATION AS banks.STATE_ABBREVIATION
      WITH SYNONYMS = ('bank state', 'headquarters state')
      COMMENT = 'State where institution is headquartered',
    banks.CATEGORY AS banks.CATEGORY
      WITH SYNONYMS = ('bank type', 'institution type')
      COMMENT = 'Type of institution: Bank, Credit Union, Thrift',
    banks.IS_ACTIVE AS banks.IS_ACTIVE
      WITH SYNONYMS = ('status', 'active')
      COMMENT = 'Whether institution is currently active',
    banks.FEDERAL_REGULATOR AS banks.FEDERAL_REGULATOR
      WITH SYNONYMS = ('regulator', 'supervisor')
      COMMENT = 'Primary federal regulator',
    banks.SPECIALIZATION_GROUP AS banks.SPECIALIZATION_GROUP
      WITH SYNONYMS = ('specialization', 'focus area')
      COMMENT = 'Bank specialization area',
    
    -- Branch dimensions
    branches.BRANCH_NAME AS branches.BRANCH_NAME
      WITH SYNONYMS = ('branch', 'location name')
      COMMENT = 'Name of the branch location',
    branches.CITY AS branches.CITY
      WITH SYNONYMS = ('branch city', 'location city')
      COMMENT = 'City where branch is located',
    branches.STATE_ABBREVIATION AS branches.STATE_ABBREVIATION
      WITH SYNONYMS = ('branch state', 'location state')
      COMMENT = 'State where branch is located',
    branches.ZIP_CODE AS branches.ZIP_CODE
      WITH SYNONYMS = ('zip', 'postal code')
      COMMENT = 'Branch ZIP code',
    branches.IS_ACTIVE AS branches.IS_ACTIVE
      WITH SYNONYMS = ('branch status', 'branch active')
      COMMENT = 'Whether branch is currently active'
  )
  
  METRICS (
    -- Deposit metrics - REAL VALUES!
    deposits.total_deposits AS SUM(deposits.VALUE)
      WITH SYNONYMS = ('total deposits', 'deposit amount')
      COMMENT = 'Total deposits across branches',
    
    deposits.avg_deposits AS AVG(deposits.VALUE)
      WITH SYNONYMS = ('average deposits', 'mean deposits')
      COMMENT = 'Average deposits per branch',
    
    deposits.max_deposits AS MAX(deposits.VALUE)
      WITH SYNONYMS = ('maximum deposits', 'largest branch')
      COMMENT = 'Maximum deposits at any branch',
    
    deposits.min_deposits AS MIN(deposits.VALUE)
      WITH SYNONYMS = ('minimum deposits', 'smallest branch')
      COMMENT = 'Minimum deposits at any branch',
    
    -- Branch network metrics
    branches.branch_count AS COUNT(DISTINCT branches.ID_RSSD)
      WITH SYNONYMS = ('number of branches', 'branch network size')
      COMMENT = 'Total number of branches',
    
    branches.active_branches AS COUNT(DISTINCT CASE 
      WHEN branches.IS_ACTIVE = TRUE THEN branches.ID_RSSD END)
      WITH SYNONYMS = ('active branches', 'operating branches')
      COMMENT = 'Number of active branches',
    
    -- Geographic metrics
    branches.state_count AS COUNT(DISTINCT branches.STATE_ABBREVIATION)
      WITH SYNONYMS = ('states covered', 'geographic footprint')
      COMMENT = 'Number of states with branches',
    
    branches.city_count AS COUNT(DISTINCT branches.CITY)
      WITH SYNONYMS = ('cities covered', 'urban footprint')
      COMMENT = 'Number of cities with branches',
    
    -- Institution metrics
    banks.bank_count AS COUNT(DISTINCT banks.ID_RSSD)
      WITH SYNONYMS = ('number of banks', 'institution count')
      COMMENT = 'Total number of institutions'
  )
  
  COMMENT = 'Branch network and deposit analytics with real data';

-- =====================================================================================
-- [SECTION 5: BRANCH_QUERIES]
-- =====================================================================================
-- TEST QUERIES FOR BANKING_BRANCH_NETWORK_ANALYTICS
-- These queries demonstrate geographic and network analysis capabilities
-- =====================================================================================

-- Query 1: Bank branch networks by state
SELECT * FROM SEMANTIC_VIEW(
    BANKING_BRANCH_NETWORK_ANALYTICS
    DIMENSIONS banks.STATE_ABBREVIATION, banks.NAME
    METRICS branches.branch_count, branches.active_branches
)
WHERE STATE_ABBREVIATION IN ('TX', 'CA', 'NY', 'FL')
ORDER BY branch_count DESC
LIMIT 20;

-- Query 2: Geographic footprint analysis
SELECT * FROM SEMANTIC_VIEW(
    BANKING_BRANCH_NETWORK_ANALYTICS
    DIMENSIONS banks.NAME
    METRICS branches.state_count, branches.city_count, branches.branch_count
)
WHERE branch_count > 5
ORDER BY state_count DESC, city_count DESC
LIMIT 15;

-- Query 3: Branch activity by regulator
SELECT * FROM SEMANTIC_VIEW(
    BANKING_BRANCH_NETWORK_ANALYTICS
    DIMENSIONS banks.FEDERAL_REGULATOR
    METRICS branches.branch_count, branches.active_branches, banks.bank_count
)
ORDER BY branch_count DESC;

-- Query 4: Bank specialization and branch distribution
SELECT * FROM SEMANTIC_VIEW(
    BANKING_BRANCH_NETWORK_ANALYTICS
    DIMENSIONS banks.SPECIALIZATION_GROUP, banks.CATEGORY
    METRICS branches.branch_count, branches.city_count, banks.bank_count
)
WHERE SPECIALIZATION_GROUP IS NOT NULL
ORDER BY branch_count DESC;

-- Query 5: Active vs inactive branches by institution type
SELECT * FROM SEMANTIC_VIEW(
    BANKING_BRANCH_NETWORK_ANALYTICS
    DIMENSIONS banks.CATEGORY, banks.IS_ACTIVE
    METRICS branches.branch_count, branches.active_branches
)
ORDER BY branch_count DESC;