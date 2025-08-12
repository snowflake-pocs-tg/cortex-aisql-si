-- =====================================================================================
-- FINANCIAL INSTITUTION SEMANTIC VIEWS FOR CORTEX ANALYST
-- =====================================================================================
-- Purpose: Enable natural language querying of Cybersyn Financial Institution data
-- Database: EQUITY_INTEL_POC
-- Schema: PROCESSED
-- 
-- This file creates three semantic views that transform complex financial data into
-- business-friendly structures for analysis via Cortex Analyst. Each view focuses on
-- a specific analytical domain while maintaining interconnected relationships.
--
-- TABLE OF CONTENTS:
-- ------------------
-- 1. BANKING_PERFORMANCE_ANALYTICS
--    - Financial performance, profitability, efficiency metrics
--    - Target Questions: ROA rankings, efficiency analysis, capital strength
--
-- 2. BANKING_MARKET_INTELLIGENCE
--    - Branch networks, M&A activity, market concentration
--    - Target Questions: Branch density, merger trends, market share
--
-- 3. BANKING_RISK_ANALYTICS
--    - Credit risk, capital adequacy, deposit stability
--    - Target Questions: NPL analysis, capital buffers, risk assessment
--
-- USAGE:
-- ------
-- These views are designed for querying with the SEMANTIC_VIEW() function:
-- SELECT * FROM SEMANTIC_VIEW(view_name, DIMENSIONS..., METRICS...)
--
-- =====================================================================================

USE ROLE SYSADMIN;
USE DATABASE EQUITY_INTEL_POC;
USE SCHEMA PROCESSED;
USE WAREHOUSE EQUITY_INTEL_WH;

-- =====================================================================================
-- 1. BANKING_PERFORMANCE_ANALYTICS
-- =====================================================================================
-- Financial performance analytics including profitability, efficiency, and capital metrics
-- =====================================================================================

CREATE OR REPLACE SEMANTIC VIEW BANKING_PERFORMANCE_ANALYTICS
  TABLES (
    -- Bank entity dimension
    banks AS FINANCE_ECONOMICS.CYBERSYN.FINANCIAL_INSTITUTION_ENTITIES
      PRIMARY KEY (ID_RSSD)
      WITH SYNONYMS ('financial institutions', 'banks', 'credit unions')
      COMMENT = 'Financial institutions including banks, credit unions, and thrifts',
    
    -- Performance metrics fact table
    performance AS FINANCE_ECONOMICS.CYBERSYN.FINANCIAL_INSTITUTION_TIMESERIES
      PRIMARY KEY (ID_RSSD, VARIABLE, DATE)
      WITH SYNONYMS ('metrics', 'financials', 'performance data')
      COMMENT = 'Time series financial performance metrics for institutions'
  )
  
  RELATIONSHIPS (
    -- Define relationship between tables
    performance_to_bank AS
      performance (ID_RSSD) REFERENCES banks
  )
  
  FACTS (
    -- Core numeric values
    performance.VALUE AS performance.VALUE,
    banks.START_DATE AS banks.START_DATE
  )
  
  DIMENSIONS (
    -- Time dimensions
    performance.DATE AS performance.DATE
      WITH SYNONYMS = ('date', 'quarter', 'period', 'reporting date')
      COMMENT = 'Financial reporting date',
    
    -- Performance dimensions
    performance.VARIABLE_NAME AS performance.VARIABLE_NAME
      WITH SYNONYMS = ('metric', 'measure', 'kpi', 'indicator')
      COMMENT = 'Name of the financial metric',
    performance.UNIT AS performance.UNIT
      WITH SYNONYMS = ('units', 'denomination')
      COMMENT = 'Unit of measurement',
    
    -- Bank dimensions
    banks.NAME AS banks.NAME
      WITH SYNONYMS = ('bank name', 'institution name', 'company')
      COMMENT = 'Legal name of the financial institution',
    banks.STATE_ABBREVIATION AS banks.STATE_ABBREVIATION
      WITH SYNONYMS = ('state', 'location', 'headquarters')
      COMMENT = 'State where institution is headquartered',
    banks.CATEGORY AS banks.CATEGORY
      WITH SYNONYMS = ('bank type', 'institution type', 'charter type')
      COMMENT = 'Type of institution: Bank, Credit Union, Thrift',
    banks.IS_ACTIVE AS banks.IS_ACTIVE
      WITH SYNONYMS = ('status', 'active', 'operating')
      COMMENT = 'Whether institution is currently active',
    banks.FEDERAL_REGULATOR AS banks.FEDERAL_REGULATOR
      WITH SYNONYMS = ('regulator', 'supervisor', 'regulatory body')
      COMMENT = 'Primary federal regulator: OCC, Fed, FDIC, NCUA',
    banks.SPECIALIZATION_GROUP AS banks.SPECIALIZATION_GROUP
      WITH SYNONYMS = ('specialization', 'focus area', 'business model')
      COMMENT = 'Bank specialization area'
  )
  
  METRICS (
    -- Basic aggregations
    performance.avg_value AS AVG(performance.VALUE)
      COMMENT = 'Average value of metrics',
    performance.sum_value AS SUM(performance.VALUE)
      COMMENT = 'Sum of metric values',
    
    -- Asset Metrics
    performance.total_assets AS SUM(CASE 
      WHEN performance.VARIABLE_NAME = 'Total Assets' 
      THEN performance.VALUE END)
      WITH SYNONYMS = ('assets', 'bank size', 'total bank assets')
      COMMENT = 'Total assets in USD',
    
    -- Profitability Metrics
    performance.avg_roa AS AVG(CASE 
      WHEN performance.VARIABLE_NAME = 'Return on Average Assets (ROA)' 
      THEN performance.VALUE END)
      WITH SYNONYMS = ('roa', 'return on assets')
      COMMENT = 'Return on Average Assets',
    
    performance.avg_roe AS AVG(CASE 
      WHEN performance.VARIABLE_NAME = 'Return on Average Equity (ROE)' 
      THEN performance.VALUE END)
      WITH SYNONYMS = ('roe', 'return on equity')
      COMMENT = 'Return on Average Equity',
    
    performance.avg_nim AS AVG(CASE 
      WHEN performance.VARIABLE_NAME = 'Net Interest Margin' 
      THEN performance.VALUE END)
      WITH SYNONYMS = ('nim', 'net interest margin', 'margin')
      COMMENT = 'Net Interest Margin',
    
    -- Efficiency Metrics
    performance.avg_efficiency_ratio AS AVG(CASE 
      WHEN performance.VARIABLE_NAME = 'Efficiency Ratio' 
      THEN performance.VALUE END)
      WITH SYNONYMS = ('efficiency', 'cost to income')
      COMMENT = 'Efficiency Ratio - lower is better',
    
    -- Capital Metrics
    performance.avg_tier1_ratio AS AVG(CASE 
      WHEN performance.VARIABLE_NAME = 'Tier 1 Capital Ratio' 
      THEN performance.VALUE END)
      WITH SYNONYMS = ('tier 1', 'capital ratio', 'capital adequacy')
      COMMENT = 'Tier 1 Capital Ratio',
    
    -- Asset Quality Metrics
    performance.avg_npl_ratio AS AVG(CASE 
      WHEN performance.VARIABLE_NAME = 'Nonperforming Loans to Total Loans' 
      THEN performance.VALUE END)
      WITH SYNONYMS = ('npl', 'nonperforming loans', 'bad loans')
      COMMENT = 'Nonperforming Loans Ratio',
    
    -- Deposit and Loan Metrics
    performance.total_deposits AS SUM(CASE 
      WHEN performance.VARIABLE_NAME = 'Total Deposits' 
      THEN performance.VALUE END)
      WITH SYNONYMS = ('deposits', 'customer deposits')
      COMMENT = 'Total customer deposits in USD',
    
    performance.total_loans AS SUM(CASE 
      WHEN performance.VARIABLE_NAME = 'Total Loans and Leases' 
      THEN performance.VALUE END)
      WITH SYNONYMS = ('loans', 'lending')
      COMMENT = 'Total loans and leases'
  )
  
  COMMENT = 'Banking performance analytics view for analyzing profitability, efficiency, capital strength, and asset quality';

-- =====================================================================================
-- SAMPLE QUERIES: BANKING_PERFORMANCE_ANALYTICS
-- =====================================================================================

-- Query 1: Top Banks by ROA in Texas

SELECT * FROM SEMANTIC_VIEW(
    BANKING_PERFORMANCE_ANALYTICS
    DIMENSIONS banks.NAME, banks.STATE_ABBREVIATION
    METRICS performance.avg_roa, performance.total_assets
  )
  WHERE STATE_ABBREVIATION = 'TX'
  ORDER BY avg_roa DESC
  LIMIT 10;


-- Query 2: Capital Strength by Federal Regulator

SELECT * FROM SEMANTIC_VIEW(
    BANKING_PERFORMANCE_ANALYTICS
    DIMENSIONS banks.FEDERAL_REGULATOR, banks.IS_ACTIVE
    METRICS performance.avg_tier1_ratio, performance.avg_npl_ratio
  )
  WHERE IS_ACTIVE = TRUE
  ORDER BY avg_tier1_ratio DESC;


