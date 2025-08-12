-- =====================================================================================
-- SNOWFLAKE CORTEX AI_COMPLETE FOR INTELLIGENT TABLE EXTRACTION
-- =====================================================================================
-- Purpose: Extract structured data tables from text using generative AI
-- Database: EQUITY_INTEL_POC
-- Schema: PROCESSED
-- Last Updated: 2025
-- 
-- OVERVIEW:
-- ---------
-- This script uses Snowflake's AI_COMPLETE function with structured output to
-- intelligently extract tables from document text and convert them into queryable
-- JSON objects. Each table row becomes a key-value object using column headers.
--
-- TABLE OF CONTENTS:
-- ------------------
-- Use CTRL+F to search for these section markers:
--
-- [SECTION 1: SETUP]          - Database and warehouse configuration
-- [SECTION 2: EXTRACT_TABLES] - AI extraction of tables to JSON objects
-- [SECTION 3: VIEW_RESULTS]   - Query flattened table data
--
-- TABLES CREATED:
-- ---------------
-- EXTRACTED_TABLE_OBJECTS - Tables extracted as structured JSON with row objects
--
-- KEY FEATURES:
-- -------------
-- - AI_COMPLETE with Mistral Large 2 model for accuracy
-- - Structured JSON output with defined schema
-- - Automatic header detection and key-value mapping
-- - Handles markdown tables with pipe delimiters
-- - Skips separator rows (---) automatically
--
-- EXTRACTION PROCESS:
-- -------------------
-- 1. Input: Chunks flagged as containing tables
-- 2. AI Analysis: Mistral Large 2 identifies table structure
-- 3. Transformation: Headers become JSON keys, rows become objects
-- 4. Output: Nested JSON with table name and data array
--
-- JSON OUTPUT STRUCTURE:
-- ----------------------
-- {
--   "tables": [
--     {
--       "table_name": "Financial Metrics",
--       "data": [
--         {"Company": "ABC Corp", "Revenue": "$1M", "Growth": "25%"},
--         {"Company": "XYZ Inc", "Revenue": "$2M", "Growth": "15%"}
--       ]
--     }
--   ]
-- }
--
-- PREREQUISITES:
-- --------------
-- - Run 03_ai_classify.sql first
-- - CHUNKS_WITH_TABLE_CLASSIFICATION table must exist
-- - Cortex AI_COMPLETE function enabled
-- - Mistral Large 2 model available
--
-- USE CASES:
-- -----------
-- - Extract cap tables from valuation documents
-- - Parse financial statements and metrics
-- - Convert comparison tables to structured data
-- - Extract ownership and equity tables
-- - Process regulatory filing tables
--
-- PERFORMANCE NOTES:
-- ------------------
-- - AI_COMPLETE is compute-intensive; use SMALL+ warehouse
-- - Processing time depends on chunk size and complexity
-- - Results are cached for repeated queries
--
-- =====================================================================================

-- =====================================================================================
-- [SECTION 1: SETUP]
-- =====================================================================================
-- Configure database context for AI table extraction

USE DATABASE EQUITY_INTEL_POC;
USE SCHEMA PROCESSED;
USE WAREHOUSE EQUITY_INTEL_WH;

-- =====================================================================================
-- [SECTION 2: EXTRACT_TABLES]
-- =====================================================================================
-- Use AI_COMPLETE to extract tables and convert to structured JSON
-- Each row becomes an object with column headers as keys
CREATE OR REPLACE TABLE EXTRACTED_TABLE_OBJECTS AS
SELECT 
    chunk_id,
    chunk_number,
    chunk_text,
    main_section,
    subsection,
    -- Use AI_COMPLETE to extract tables as list of objects
    TRY_PARSE_JSON(
        AI_COMPLETE(
            model => 'mistral-large2',
            prompt => CONCAT(
                'Extract tables from markdown text. Return JSON with tables array. ',
                'Each table has table_name and data array. ',
                'Each data item is an object with key-value pairs from the table row. ',
                'Use column headers as keys. Skip separator rows with ---. ',
                'Example: {"tables":[{"table_name":"Metrics","data":[{"Company":"ABC","Revenue":"$1M"}]}]}',
                '\n\nText:\n', chunk_text
            ),
            response_format => {
                'type': 'json',
                'schema': {
                    'type': 'object',
                    'properties': {
                        'tables': {
                            'type': 'array',
                            'items': {
                                'type': 'object',
                                'properties': {
                                    'table_name': {'type': 'string'},
                                    'data': {'type': 'array'}
                                },
                                'required': ['table_name', 'data']
                            }
                        }
                    },
                    'required': ['tables']
                }
            }
        )
    ) AS extracted_tables_json
FROM 
    CHUNKS_WITH_TABLE_CLASSIFICATION
WHERE 
    has_data_table = true;

-- =====================================================================================
-- [SECTION 3: VIEW_RESULTS]
-- =====================================================================================
-- Query the extracted table data in flattened format
-- Shows table names, row counts, and actual data
SELECT 
    chunk_id,
    main_section,
    table_data.index AS table_index,
    table_data.value:table_name::STRING AS table_name,
    ARRAY_SIZE(table_data.value:data) AS row_count,
    chunk_text,
    table_data.value:data AS all_rows_as_objects
FROM 
    EXTRACTED_TABLE_OBJECTS,
    LATERAL FLATTEN(input => extracted_tables_json:tables) AS table_data
WHERE 
    extracted_tables_json IS NOT NULL;