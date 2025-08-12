-- =====================================================================================
-- EQUITY INTELLIGENCE POC - ENVIRONMENT SETUP
-- =====================================================================================
-- Purpose: Set up Snowflake environment for unstructured document processing POC
-- Database: EQUITY_INTEL_POC
-- Last Updated: 2025
-- 
-- OVERVIEW:
-- ---------
-- This script establishes the complete Snowflake environment needed for the Equity
-- Intelligence POC. It creates all necessary database objects for storing, processing,
-- and analyzing 409A valuation documents using Snowflake's Cortex AI capabilities.
--
-- TABLE OF CONTENTS:
-- ------------------
-- Use CTRL+F to search for these section markers:
--
-- [SECTION 1: DATABASE]    - Create POC database
-- [SECTION 2: SCHEMAS]     - Create storage and processing schemas
-- [SECTION 3: WAREHOUSE]   - Set up compute resources
-- [SECTION 4: STAGES]      - Configure document storage stages
-- [SECTION 5: UPLOAD]      - Upload sample PDF documents
--
-- WHAT THIS CREATES:
-- ------------------
-- Database: EQUITY_INTEL_POC
-- Schemas:  DOCUMENTS (raw storage), PROCESSED (enriched data), TOOLS (utilities)
-- Warehouse: EQUITY_INTEL_WH (XSMALL, auto-suspend)
-- Stages: ETON_DOCS_STAGE, EQVISTA_DOCS_STAGE, MELD_DOCS_STAGE, CARTA_DOCS_STAGE
--
-- PREREQUISITES:
-- --------------
-- - ACCOUNTADMIN or SYSADMIN role
-- - Snowflake account with Cortex Suite enabled
-- - Sample PDF files in _pdfs/ directory
--
-- SAMPLE DOCUMENTS:
-- -----------------
-- - abc_llc.pdf       - Eton Venture Services format
-- - eqvista.pdf       - Eqvista standard format
-- - meldvaluation.pdf - Meld Valuation historical format
-- - carta.pdf         - Industry standard baseline
--
-- IMPORTANT NOTES:
-- ----------------
-- - AUTO_COMPRESS must be FALSE for PARSE_DOCUMENT to work with PDFs
-- - Stages use Snowflake Server-Side Encryption (SSE)
-- - Warehouse auto-suspends after 60 seconds of inactivity
-- - All stages have DIRECTORY enabled for metadata tracking
--
-- =====================================================================================

-- =====================================================================================
-- [SECTION 1: DATABASE]
-- =====================================================================================
-- Create the main POC database for all equity intelligence operations

USE ROLE SYSADMIN;

-- Create dedicated POC database
CREATE DATABASE IF NOT EXISTS EQUITY_INTEL_POC
    COMMENT = 'Equity Intelligence POC - Document Processing & Financial Analysis';

USE DATABASE EQUITY_INTEL_POC;

-- =====================================================================================
-- [SECTION 2: SCHEMAS]
-- =====================================================================================
-- Create schemas for organizing different data layers

-- Raw document storage layer
CREATE SCHEMA IF NOT EXISTS DOCUMENTS
    COMMENT = 'Raw document storage for valuation reports and legal documents';

-- Processed data layer
CREATE SCHEMA IF NOT EXISTS PROCESSED
    COMMENT = 'Extracted and processed data from documents';

-- Processed data layer
CREATE SCHEMA IF NOT EXISTS TOOLS
    COMMENT = 'Custom Tools';

-- =====================================================================================
-- [SECTION 3: WAREHOUSE]
-- =====================================================================================
-- Configure compute resources optimized for document processing

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

-- =====================================================================================
-- [SECTION 4: STAGES]
-- =====================================================================================
-- Create secure stages for storing different valuation document formats

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

-- =====================================================================================
-- [SECTION 5: UPLOAD]
-- =====================================================================================
-- Upload sample valuation PDFs to their respective stages

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

