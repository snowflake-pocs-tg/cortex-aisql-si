/*
===============================================================================
EQUITY INTELLIGENCE POC - ENVIRONMENT SETUP
===============================================================================
Purpose: Set up Snowflake environment for unstructured document processing
         POC demonstration
         
This script creates:
- Database for equity management POC
- Schemas for raw and processed documents
- Warehouse for compute
- Stages for document storage
- Document upload commands

Prerequisites:
- ACCOUNTADMIN or SYSADMIN role
- Access to Snowflake account with Cortex Suite enabled
===============================================================================
*/

-- ============================================================================
-- SECTION 1: DATABASE SETUP
-- ============================================================================

USE ROLE SYSADMIN;

-- Create dedicated POC database
CREATE DATABASE IF NOT EXISTS EQUITY_INTEL_POC
    COMMENT = 'Equity Intelligence POC - Document Processing & Financial Analysis';

USE DATABASE EQUITY_INTEL_POC;

-- ============================================================================
-- SECTION 2: SCHEMA SETUP
-- ============================================================================

-- Raw document storage layer
CREATE SCHEMA IF NOT EXISTS DOCUMENTS
    COMMENT = 'Raw document storage for valuation reports and legal documents';

-- Processed data layer
CREATE SCHEMA IF NOT EXISTS PROCESSED
    COMMENT = 'Extracted and processed data from documents';

-- Processed data layer
CREATE SCHEMA IF NOT EXISTS TOOLS
    COMMENT = 'Custom Tools';

-- ============================================================================
-- SECTION 3: WAREHOUSE SETUP
-- ============================================================================

-- Create optimized warehouse for POC workloads
CREATE WAREHOUSE IF NOT EXISTS EQUITY_INTEL_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1
    SCALING_POLICY = 'STANDARD'
    COMMENT = 'Warehouse for document processing and analytics queries';

USE WAREHOUSE EQUITY_INTEL_WH;

-- ============================================================================
-- SECTION 4: STAGE SETUP FOR DOCUMENT STORAGE
-- ============================================================================

USE SCHEMA DOCUMENTS;

-- Create dedicated stage for each valuation document source
-- This allows for better organization and tracking of different formats

-- Stage 1: Eton Venture Services documents
CREATE OR REPLACE STAGE ETON_DOCS_STAGE
    COMMENT = 'Eton Venture Services valuation reports - complex calculations'
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    DIRECTORY = (ENABLE = TRUE);

-- Stage 2: Eqvista documents  
CREATE OR REPLACE STAGE EQVISTA_DOCS_STAGE
    COMMENT = 'Eqvista valuation reports - standard structure'
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    DIRECTORY = (ENABLE = TRUE);

-- Stage 3: Meld Valuation documents
CREATE OR REPLACE STAGE MELD_DOCS_STAGE
    COMMENT = 'Meld Valuation reports - historical format testing'
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    DIRECTORY = (ENABLE = TRUE);

-- Stage 4: Industry Standard documents
CREATE OR REPLACE STAGE CARTA_DOCS_STAGE
    COMMENT = 'Industry standard valuation reports - baseline format'
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    DIRECTORY = (ENABLE = TRUE);

-- ============================================================================
-- SECTION 5: PUT SAMPLE DATA INTO STAGES
-- ============================================================================

-- Upload valuation report samples from local PDFs (relative to repo root)
-- IMPORTANT: AUTO_COMPRESS must be FALSE for PARSE_DOCUMENT to work with PDFs
PUT file://./_pdfs/abc_llc.pdf 
    @ETON_DOCS_STAGE 
    AUTO_COMPRESS=FALSE 
    OVERWRITE=TRUE;

PUT file://./_pdfs/eqvista.pdf 
    @EQVISTA_DOCS_STAGE 
    AUTO_COMPRESS=FALSE 
    OVERWRITE=TRUE;

PUT file://./_pdfs/meldvaluation.pdf 
    @MELD_DOCS_STAGE 
    AUTO_COMPRESS=FALSE 
    OVERWRITE=TRUE;

PUT file://./_pdfs/carta.pdf 
    @CARTA_DOCS_STAGE 
    AUTO_COMPRESS=FALSE 
    OVERWRITE=TRUE;

