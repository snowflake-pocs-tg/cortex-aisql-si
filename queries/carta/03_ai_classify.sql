-- =====================================================================================
-- SNOWFLAKE CORTEX AI CLASSIFICATION PIPELINE
-- =====================================================================================
-- Purpose: Classify document chunks using AI to identify content patterns
-- Database: EQUITY_INTEL_POC
-- Schema: PROCESSED
-- Last Updated: 2025
-- 
-- OVERVIEW:
-- ---------
-- This script demonstrates Snowflake's AI classification capabilities using
-- Cortex functions to automatically identify and categorize document content.
-- It focuses on detecting structured data within unstructured text, particularly
-- tables and financial data formats commonly found in valuation documents.
--
-- TABLE OF CONTENTS:
-- ------------------
-- Use CTRL+F to search for these section markers:
--
-- [SECTION 1: SETUP]         - Database and warehouse configuration
-- [SECTION 2: TABLE_DETECT]  - Identify chunks containing data tables
--
-- TABLES CREATED:
-- ---------------
-- CHUNKS_WITH_TABLE_CLASSIFICATION - Document chunks with table detection flags
--
-- KEY FEATURES:
-- -------------
-- - AI_CLASSIFY: Multi-label classification using natural language descriptions
-- - AI_FILTER: Pre-filtering to optimize processing
-- - Pattern detection for markdown tables, financial statements
-- - Boolean classification for downstream processing
--
-- CLASSIFICATION LOGIC:
-- --------------------
-- The AI looks for:
-- - Pipe characters (|) indicating markdown tables
-- - Horizontal dividers (---) for table headers
-- - Columnar alignment of data
-- - Financial indicators ($ symbols, percentages)
-- - Structured numeric data in rows and columns
--
-- PREREQUISITES:
-- --------------
-- - Run 02_parse_document.sql first
-- - CARTA_DOCS_CHUNKS_FLAT table must exist
-- - Cortex AI functions enabled
-- - Sufficient warehouse compute for AI operations
--
-- USE CASES:
-- -----------
-- - Extract financial tables from valuation reports
-- - Identify cap tables and ownership structures
-- - Locate comparative analysis sections
-- - Find pricing and valuation matrices
-- - Detect structured financial statements
--
-- PERFORMANCE NOTES:
-- ------------------
-- - AI_FILTER reduces processing by pre-screening chunks
-- - Classification is compute-intensive; use appropriate warehouse size
-- - Results are cached in the output table for efficiency
--
-- =====================================================================================

-- =====================================================================================
-- [SECTION 1: SETUP]
-- =====================================================================================
-- Configure database context for AI classification operations

USE DATABASE EQUITY_INTEL_POC;
USE SCHEMA PROCESSED;
USE WAREHOUSE EQUITY_INTEL_WH;

-- =====================================================================================
-- [SECTION 2: TABLE_DETECT]
-- =====================================================================================
-- Use AI to identify document chunks containing data tables
-- This is critical for extracting structured financial data from PDFs
CREATE OR REPLACE TABLE CHUNKS_WITH_TABLE_CLASSIFICATION AS
SELECT 
    relative_path,
    chunk_id,
    chunk_number,
    chunk_text,
    main_section,
    subsection,
    detail_section,
    chunk_length,
    -- AI Classification: Detect if chunk contains a data table
    -- AI_CLASSIFY returns JSON like {"labels": ["TABLE"]} or {"labels": ["TEXT"]}
    TO_VARIANT(AI_CLASSIFY(
        chunk_text,
        [
            {'label': 'TABLE', 
             'description': 'Has pipe characters | separating columns and rows of aligned data representing a data table'},
            {'label': 'TEXT', 
             'description': 'Plain paragraphs without | delimiters or columnar structure'}
        ],
        {
            'task_description': 'Find markdown tables with | separators, --- dividers, or financial data in columns with values like $ or %'
        }
    )):labels[0]::STRING = 'TABLE' AS has_data_table
FROM 
    CARTA_DOCS_CHUNKS_FLAT
WHERE 
    chunk_text IS NOT NULL
AND 
    AI_FILTER( PROMPT('Is there pipe characters | separating columns and rows of aligned data representing a data table?: {0}', chunk_text ) );
SELECT *
FROM CHUNKS_WITH_TABLE_CLASSIFICATION
WHERE HAS_DATA_TABLE = true;
