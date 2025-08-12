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


-- =====================================================================================
-- 2. BANKING_MARKET_INTELLIGENCE
-- =====================================================================================
-- Market structure, M&A activity, branch networks, and competitive analysis
-- =====================================================================================

CREATE OR REPLACE SEMANTIC VIEW BANKING_MARKET_INTELLIGENCE
  TABLES (
    -- Bank entities
    banks AS FINANCE_ECONOMICS.CYBERSYN.FINANCIAL_INSTITUTION_ENTITIES
      PRIMARY KEY (ID_RSSD)
      WITH SYNONYMS ('institutions', 'financial companies', 'banks')
      COMMENT = 'Financial institutions master data',
    
    -- Branch network
    branches AS FINANCE_ECONOMICS.CYBERSYN.FINANCIAL_BRANCH_ENTITIES
      PRIMARY KEY (ID_RSSD)
      WITH SYNONYMS ('locations', 'offices', 'banking centers', 'outlets')
      COMMENT = 'Physical branch and office locations',
    
    -- M&A events
    mergers AS FINANCE_ECONOMICS.CYBERSYN.FINANCIAL_INSTITUTION_EVENTS
      PRIMARY KEY (ID_RSSD_PREDECESSOR, ID_RSSD_SUCCESSOR, TRANSACTION_DATE)
      WITH SYNONYMS ('acquisitions', 'M&A', 'transactions', 'deals', 'consolidations')
      COMMENT = 'Merger, acquisition, and transformation events',
    
    -- Deposit market share
    deposits AS FINANCE_ECONOMICS.CYBERSYN.FDIC_SUMMARY_OF_DEPOSITS_TIMESERIES
      PRIMARY KEY (FDIC_INSTITUTION_ID, FDIC_BRANCH_ID, DATE)
      WITH SYNONYMS ('deposit data', 'market share', 'deposit base')
      COMMENT = 'FDIC deposit data for market share analysis'
  )
  
  RELATIONSHIPS (
    -- Define relationships
    branches_to_bank AS
      branches (ID_RSSD_PARENT) REFERENCES banks (ID_RSSD),
    mergers_predecessor_to_bank AS
      mergers (ID_RSSD_PREDECESSOR) REFERENCES banks (ID_RSSD),
    mergers_successor_to_bank AS
      mergers (ID_RSSD_SUCCESSOR) REFERENCES banks (ID_RSSD)
  )
  
  FACTS (
    -- Branch facts
    branches.START_DATE AS branches.START_DATE,
    branches.END_DATE AS branches.END_DATE,
    
    -- Deposit facts
    deposits.VALUE AS deposits.VALUE
  )
  
  DIMENSIONS (
    -- Time dimensions
    mergers.TRANSACTION_DATE AS mergers.TRANSACTION_DATE
      WITH SYNONYMS = ('deal date', 'merger date', 'acquisition date')
      COMMENT = 'Date of M&A transaction',
    deposits.DATE AS deposits.DATE
      WITH SYNONYMS = ('deposit date', 'reporting period')
      COMMENT = 'Deposit reporting date',
    
    -- Geographic dimensions
    branches.STATE_ABBREVIATION AS branches.STATE_ABBREVIATION
      WITH SYNONYMS = ('branch state', 'location', 'geography')
      COMMENT = 'State where branch is located',
    branches.CITY AS branches.CITY
      WITH SYNONYMS = ('branch city', 'municipality', 'metro')
      COMMENT = 'City where branch is located',
    branches.ZIP_CODE AS branches.ZIP_CODE
      WITH SYNONYMS = ('postal code', 'zip')
      COMMENT = 'ZIP code of branch location',
    
    -- Bank dimensions
    banks.NAME AS banks.NAME
      WITH SYNONYMS = ('bank name', 'institution name')
      COMMENT = 'Legal name of institution',
    banks.CATEGORY AS banks.CATEGORY
      WITH SYNONYMS = ('bank type', 'charter type')
      COMMENT = 'Type of financial institution',
    banks.IS_ACTIVE AS banks.IS_ACTIVE
      WITH SYNONYMS = ('active status', 'operating')
      COMMENT = 'Current operating status',
    
    -- Branch dimensions
    branches.BRANCH_NAME AS branches.BRANCH_NAME
      WITH SYNONYMS = ('office name', 'location name')
      COMMENT = 'Name of the branch location',
    branches.IS_ACTIVE AS branches.IS_ACTIVE
      WITH SYNONYMS = ('branch status', 'branch active')
      COMMENT = 'Whether branch is currently operating',
    branches.NAME_PARENT AS branches.NAME_PARENT
      WITH SYNONYMS = ('parent bank', 'owning institution')
      COMMENT = 'Name of parent institution',
    
    -- M&A dimensions
    mergers.TRANSFORMATION_TYPE AS mergers.TRANSFORMATION_TYPE
      WITH SYNONYMS = ('deal type', 'merger type', 'transaction type')
      COMMENT = 'Type of transaction: Merger, Acquisition, Purchase, etc.',
    mergers.NAME_PREDECESSOR AS mergers.NAME_PREDECESSOR
      WITH SYNONYMS = ('target bank', 'acquired bank', 'seller')
      COMMENT = 'Name of acquired/merged institution',
    mergers.NAME_SUCCESSOR AS mergers.NAME_SUCCESSOR
      WITH SYNONYMS = ('acquiring bank', 'buyer', 'acquirer')
      COMMENT = 'Name of acquiring institution',
    
    -- Deposit dimensions
    deposits.VARIABLE_NAME AS deposits.VARIABLE_NAME
      WITH SYNONYMS = ('deposit metric', 'deposit type')
      COMMENT = 'Type of deposit metric'
  )
  
  METRICS (
    -- Branch Network Metrics
    branches.total_branches AS COUNT(DISTINCT branches.ID_RSSD)
      WITH SYNONYMS = ('branch count', 'locations', 'outlets')
      COMMENT = 'Total number of bank branches',
    branches.active_branches AS COUNT(DISTINCT CASE WHEN branches.IS_ACTIVE = TRUE THEN branches.ID_RSSD END)
      COMMENT = 'Number of currently active branches',
    
    -- Geographic Distribution
    branches.states_with_presence AS COUNT(DISTINCT branches.STATE_ABBREVIATION)
      COMMENT = 'Number of states with branch presence',
    branches.cities_served AS COUNT(DISTINCT branches.CITY)
      COMMENT = 'Number of cities with branches',
    
    -- M&A Activity Metrics
    mergers.total_transactions AS COUNT(DISTINCT mergers.TRANSACTION_DATE || mergers.ID_RSSD_PREDECESSOR || mergers.ID_RSSD_SUCCESSOR)
      WITH SYNONYMS = ('deals', 'M&A count', 'merger count')
      COMMENT = 'Total number of M&A transactions',
    mergers.merger_count AS COUNT(DISTINCT CASE 
      WHEN mergers.TRANSFORMATION_TYPE = 'Merger' 
      THEN mergers.TRANSACTION_DATE || mergers.ID_RSSD_PREDECESSOR || mergers.ID_RSSD_SUCCESSOR END)
      COMMENT = 'Number of merger transactions',
    mergers.acquisition_count AS COUNT(DISTINCT CASE 
      WHEN mergers.TRANSFORMATION_TYPE IN ('Acquisition', 'Purchase') 
      THEN mergers.TRANSACTION_DATE || mergers.ID_RSSD_PREDECESSOR || mergers.ID_RSSD_SUCCESSOR END)
      COMMENT = 'Number of acquisition transactions',
    
    -- Market Concentration Metrics  
    deposits.total_market_deposits AS SUM(deposits.VALUE)
      WITH SYNONYMS = ('deposit base', 'total deposits', 'market size')
      COMMENT = 'Total deposits in market',
    deposits.avg_deposits AS AVG(deposits.VALUE)
      COMMENT = 'Average deposits per branch'
  )
  
  COMMENT = 'Banking market intelligence view for analyzing branch networks, M&A activity, and market concentration';

-- =====================================================================================
-- SAMPLE QUERIES: BANKING_MARKET_INTELLIGENCE
-- =====================================================================================

-- Query 1: Branch Network Analysis by State
SELECT * FROM SEMANTIC_VIEW(
    BANKING_MARKET_INTELLIGENCE
    DIMENSIONS branches.STATE_ABBREVIATION
    METRICS branches.total_branches, branches.active_branches, branches.cities_served
  )
  ORDER BY total_branches DESC
  LIMIT 10;

-- Query 2: Recent M&A Activity
SELECT * FROM SEMANTIC_VIEW(
    BANKING_MARKET_INTELLIGENCE
    DIMENSIONS mergers.TRANSACTION_DATE, mergers.NAME_PREDECESSOR, mergers.NAME_SUCCESSOR, mergers.TRANSFORMATION_TYPE
    METRICS mergers.total_transactions
  )
  WHERE TRANSACTION_DATE >= '2025-01-01'
  ORDER BY TRANSACTION_DATE DESC
  LIMIT 20;

-- =====================================================================================
-- 3. BANKING_RISK_ANALYTICS
-- =====================================================================================
-- Risk assessment for credit, operational, and regulatory compliance
-- =====================================================================================

CREATE OR REPLACE SEMANTIC VIEW BANKING_RISK_ANALYTICS
  TABLES (
    -- Bank entities
    banks AS FINANCE_ECONOMICS.CYBERSYN.FINANCIAL_INSTITUTION_ENTITIES
      PRIMARY KEY (ID_RSSD)
      WITH SYNONYMS ('institutions', 'banks', 'financial companies')
      COMMENT = 'Financial institutions with risk profiles',
    
    -- Risk metrics time series
    risk_metrics AS FINANCE_ECONOMICS.CYBERSYN.FINANCIAL_INSTITUTION_TIMESERIES
      PRIMARY KEY (ID_RSSD, VARIABLE, DATE)
      WITH SYNONYMS ('risk data', 'risk indicators', 'safety metrics')
      COMMENT = 'Time series risk and safety metrics',
    
    -- Deposit flows for stability analysis
    deposit_flows AS FINANCE_ECONOMICS.CYBERSYN.FDIC_SUMMARY_OF_DEPOSITS_TIMESERIES
      PRIMARY KEY (FDIC_INSTITUTION_ID, FDIC_BRANCH_ID, DATE)
      WITH SYNONYMS ('deposit data', 'funding stability', 'liquidity')
      COMMENT = 'Deposit flows for liquidity risk analysis',
    
    -- Transformation events (failures, interventions)
    events AS FINANCE_ECONOMICS.CYBERSYN.FINANCIAL_INSTITUTION_EVENTS
      PRIMARY KEY (ID_RSSD_PREDECESSOR, ID_RSSD_SUCCESSOR, TRANSACTION_DATE)
      WITH SYNONYMS ('failures', 'resolutions', 'interventions')
      COMMENT = 'Bank failures and regulatory interventions'
  )
  
  RELATIONSHIPS (
    -- Define relationships
    risk_to_bank AS
      risk_metrics (ID_RSSD) REFERENCES banks,
    events_predecessor_to_bank AS
      events (ID_RSSD_PREDECESSOR) REFERENCES banks (ID_RSSD),
    events_successor_to_bank AS
      events (ID_RSSD_SUCCESSOR) REFERENCES banks (ID_RSSD)
  )
  
  FACTS (
    -- Risk metric values
    risk_metrics.VALUE AS risk_metrics.VALUE,
    
    -- Deposit values
    deposit_flows.VALUE AS deposit_flows.VALUE
  )
  
  DIMENSIONS (
    -- Time dimensions
    risk_metrics.DATE AS risk_metrics.DATE
      WITH SYNONYMS = ('reporting date', 'risk date', 'period')
      COMMENT = 'Risk metric reporting date',
    deposit_flows.DATE AS deposit_flows.DATE
      WITH SYNONYMS = ('deposit date', 'liquidity date')
      COMMENT = 'Deposit reporting date',
    events.TRANSACTION_DATE AS events.TRANSACTION_DATE
      WITH SYNONYMS = ('event date', 'failure date')
      COMMENT = 'Date of risk event',
    
    -- Bank dimensions
    banks.NAME AS banks.NAME
      WITH SYNONYMS = ('bank name', 'institution')
      COMMENT = 'Name of financial institution',
    banks.STATE_ABBREVIATION AS banks.STATE_ABBREVIATION
      WITH SYNONYMS = ('state', 'location', 'headquarters')
      COMMENT = 'State of headquarters',
    banks.FEDERAL_REGULATOR AS banks.FEDERAL_REGULATOR
      WITH SYNONYMS = ('regulator', 'supervisor', 'regulatory body')
      COMMENT = 'Primary federal regulator',
    banks.IS_ACTIVE AS banks.IS_ACTIVE
      WITH SYNONYMS = ('active status', 'operating')
      COMMENT = 'Current operating status',
    banks.CATEGORY AS banks.CATEGORY
      WITH SYNONYMS = ('bank type', 'institution type')
      COMMENT = 'Type of financial institution',
    
    -- Risk metric dimensions
    risk_metrics.VARIABLE_NAME AS risk_metrics.VARIABLE_NAME
      WITH SYNONYMS = ('risk metric', 'risk measure', 'risk kpi')
      COMMENT = 'Name of risk indicator',
    risk_metrics.UNIT AS risk_metrics.UNIT
      WITH SYNONYMS = ('measurement unit', 'units')
      COMMENT = 'Unit of measurement',
    
    -- Event dimensions
    events.TRANSFORMATION_TYPE AS events.TRANSFORMATION_TYPE
      WITH SYNONYMS = ('event type', 'failure type', 'resolution type')
      COMMENT = 'Type of risk event or transformation',
    events.NAME_PREDECESSOR AS events.NAME_PREDECESSOR
      WITH SYNONYMS = ('failed bank', 'troubled institution')
      COMMENT = 'Name of failed or troubled institution',
    
    -- Deposit dimensions
    deposit_flows.VARIABLE_NAME AS deposit_flows.VARIABLE_NAME
      WITH SYNONYMS = ('deposit metric', 'deposit type')
      COMMENT = 'Type of deposit metric'
  )
  
  METRICS (
    -- Credit Risk Metrics
    risk_metrics.avg_npl_ratio AS AVG(CASE 
      WHEN risk_metrics.VARIABLE_NAME = 'Nonperforming Loans to Total Loans' 
      THEN risk_metrics.VALUE END)
      WITH SYNONYMS = ('npl', 'bad loan ratio', 'problem loans')
      COMMENT = 'Nonperforming loans as percentage of total loans',
    
    risk_metrics.avg_charge_off_rate AS AVG(CASE 
      WHEN risk_metrics.VARIABLE_NAME = 'Net Charge-offs to Average Loans' 
      THEN risk_metrics.VALUE END)
      WITH SYNONYMS = ('charge-offs', 'loss rate', 'write-offs')
      COMMENT = 'Net charge-offs as percentage of average loans',
    
    -- Capital Adequacy Metrics
    risk_metrics.avg_tier1_ratio AS AVG(CASE 
      WHEN risk_metrics.VARIABLE_NAME = 'Tier 1 Capital Ratio' 
      THEN risk_metrics.VALUE END)
      WITH SYNONYMS = ('tier 1', 'capital strength', 'capital ratio')
      COMMENT = 'Tier 1 capital to risk-weighted assets',
    
    risk_metrics.avg_total_capital_ratio AS AVG(CASE 
      WHEN risk_metrics.VARIABLE_NAME = 'Total Risk-Based Capital Ratio' 
      THEN risk_metrics.VALUE END)
      WITH SYNONYMS = ('total capital', 'capital adequacy')
      COMMENT = 'Total capital to risk-weighted assets',
    
    risk_metrics.avg_leverage_ratio AS AVG(CASE 
      WHEN risk_metrics.VARIABLE_NAME = 'Leverage Ratio' 
      THEN risk_metrics.VALUE END)
      WITH SYNONYMS = ('leverage', 'capital leverage')
      COMMENT = 'Tier 1 capital to average assets',
    
    -- Liquidity Risk Metrics
    risk_metrics.avg_loan_to_deposit AS AVG(CASE 
      WHEN risk_metrics.VARIABLE_NAME = 'Total Loans and Leases' 
      THEN risk_metrics.VALUE END) / 
      NULLIF(AVG(CASE 
        WHEN risk_metrics.VARIABLE_NAME = 'Total Deposits' 
        THEN risk_metrics.VALUE END), 0) * 100
      WITH SYNONYMS = ('LTD ratio', 'liquidity ratio')
      COMMENT = 'Loans to deposits ratio - liquidity indicator',
    
    -- Deposit Stability Metrics
    deposit_flows.total_deposits AS SUM(deposit_flows.VALUE)
      WITH SYNONYMS = ('deposit base', 'funding base')
      COMMENT = 'Total deposit funding',
    
    deposit_flows.avg_deposits AS AVG(deposit_flows.VALUE)
      COMMENT = 'Average deposit balance',
    
    -- Operational Risk Metrics
    risk_metrics.avg_efficiency_ratio AS AVG(CASE 
      WHEN risk_metrics.VARIABLE_NAME = 'Efficiency Ratio' 
      THEN risk_metrics.VALUE END)
      WITH SYNONYMS = ('efficiency', 'operational efficiency')
      COMMENT = 'Operating efficiency - higher indicates operational risk',
    
    -- Failure Risk Indicators
    events.failure_count AS COUNT(DISTINCT CASE 
      WHEN events.TRANSFORMATION_TYPE IN ('Failed', 'Failure') 
      THEN events.TRANSACTION_DATE || events.ID_RSSD_PREDECESSOR END)
      WITH SYNONYMS = ('bank failures', 'failed banks')
      COMMENT = 'Number of bank failures',
    
    -- Composite Risk Scoring
    risk_metrics.high_risk_flag AS CASE 
      WHEN AVG(CASE WHEN risk_metrics.VARIABLE_NAME = 'Nonperforming Loans to Total Loans' THEN risk_metrics.VALUE END) > 3.0
        OR AVG(CASE WHEN risk_metrics.VARIABLE_NAME = 'Tier 1 Capital Ratio' THEN risk_metrics.VALUE END) < 8.0
      THEN 1 ELSE 0 END
      WITH SYNONYMS = ('risk flag', 'troubled bank')
      COMMENT = 'High risk indicator based on NPL and capital thresholds'
  )
  
  COMMENT = 'Banking risk analytics view for assessing credit risk, capital adequacy, liquidity risk, and regulatory compliance';

-- =====================================================================================
-- SAMPLE QUERIES: BANKING_RISK_ANALYTICS
-- =====================================================================================

-- Query 1: High Risk Banks 
SELECT * FROM SEMANTIC_VIEW(
    BANKING_RISK_ANALYTICS
    DIMENSIONS banks.NAME, banks.STATE_ABBREVIATION, risk_metrics.DATE, banks.IS_ACTIVE
    METRICS risk_metrics.avg_npl_ratio, risk_metrics.avg_tier1_ratio, risk_metrics.avg_charge_off_rate
  )
  WHERE IS_ACTIVE = TRUE
  ORDER BY avg_npl_ratio DESC
  LIMIT 20;

-- Query 2: Risk Metrics by Federal Regulator
SELECT * FROM SEMANTIC_VIEW(
    BANKING_RISK_ANALYTICS
    DIMENSIONS banks.FEDERAL_REGULATOR, banks.IS_ACTIVE
    METRICS risk_metrics.avg_tier1_ratio, risk_metrics.avg_total_capital_ratio, risk_metrics.avg_npl_ratio
  )
  WHERE IS_ACTIVE = TRUE
  ORDER BY avg_tier1_ratio DESC;

-- =====================================================================================
-- END OF SEMANTIC VIEWS
-- =====================================================================================