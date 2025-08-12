-- =====================================================================================
-- SNOWFLAKE CORTEX DOCUMENT PROCESSING PIPELINE
-- =====================================================================================
-- Purpose: Parse and process PDF documents using Cortex AI capabilities
-- Database: EQUITY_INTEL_POC
-- Schema: PROCESSED
-- Last Updated: 2025
-- 
-- OVERVIEW:
-- ---------
-- This script demonstrates Snowflake's advanced document processing capabilities
-- using the PARSE_DOCUMENT function from Cortex Suite. It transforms unstructured
-- PDF documents into queryable, structured data suitable for AI analysis.
--
-- TABLE OF CONTENTS:
-- ------------------
-- Use CTRL+F to search for these section markers:
--
-- [SECTION 1: SETUP]         - Database and warehouse configuration
-- [SECTION 2: PARSE_TEST]    - Single document parsing validation
-- [SECTION 3: BATCH_PROCESS] - Process all PDFs in stage
-- [SECTION 4: CHUNK_DOCS]    - Semantic chunking for RAG
-- [SECTION 5: FLATTEN_PAGES] - Page-level data extraction
--
-- TABLES CREATED:
-- ---------------
-- 1. CARTA_DOCS_ENRICHED     - Master table with parsed document data
-- 2. CARTA_DOCS_CHUNKED      - Documents split by semantic headers
-- 3. CARTA_DOCS_CHUNKS_FLAT  - Flattened chunks for vector search
-- 4. CARTA_DOCS_PAGES_FLAT   - Individual pages as queryable records
--
-- KEY FEATURES:
-- -------------
-- - LAYOUT mode parsing preserves tables and formatting
-- - Page splitting handles large documents efficiently
-- - Semantic chunking based on markdown headers
-- - 2000 character chunks with 200 character overlap
-- - Automatic metadata extraction and URL generation
--
-- PREREQUISITES:
-- --------------
-- - Run 01_environment_setup.sql first
-- - Documents uploaded to CARTA_DOCS_STAGE
-- - Cortex Suite enabled in account
-- - EQUITY_INTEL_WH warehouse running
--
-- USE CASES:
-- -----------
-- - 409A valuation report analysis
-- - Document search and retrieval
-- - RAG (Retrieval Augmented Generation)
-- - Compliance document processing
-- - Financial data extraction
--
-- =====================================================================================

-- =====================================================================================
-- [SECTION 1: SETUP]
-- =====================================================================================
-- Configure database context for document processing operations

USE DATABASE EQUITY_INTEL_POC;
USE SCHEMA PROCESSED;
USE WAREHOUSE EQUITY_INTEL_WH;

-- =====================================================================================
-- [SECTION 2: PARSE_TEST]
-- =====================================================================================
-- Test PARSE_DOCUMENT on a single PDF to validate Cortex functionality
-- This query helps verify parsing parameters before batch processing
-- Expected output: JSON with pages array containing extracted content
SELECT 
    TO_VARIANT(
        SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
            '@DOCUMENTS.CARTA_DOCS_STAGE',
            'carta.pdf',
            {'mode': 'LAYOUT', 'page_split': TRUE}
        )
    ) AS parsed_document;

-- =====================================================================================
-- [SECTION 3: BATCH_PROCESS]
-- =====================================================================================
-- Process all PDFs in the stage and create master enriched table
-- Stores multiple parsing formats for maximum flexibility:
-- - raw_text_dict: Page-split JSON for granular analysis
-- - raw_text_layout: Complete document with preserved formatting
-- - raw_text: Plain text extraction for full-text search
CREATE OR REPLACE TABLE CARTA_DOCS_ENRICHED AS 
SELECT
    relative_path,
    GET_PRESIGNED_URL(@DOCUMENTS.CARTA_DOCS_STAGE, relative_path) as scoped_file_url,
    TO_VARIANT(SNOWFLAKE.CORTEX.PARSE_DOCUMENT(@DOCUMENTS.CARTA_DOCS_STAGE, relative_path, {'mode': 'LAYOUT', 'page_split': True})) as raw_text_dict,
    TO_VARIANT(SNOWFLAKE.CORTEX.PARSE_DOCUMENT(@DOCUMENTS.CARTA_DOCS_STAGE, relative_path, {'mode': 'LAYOUT'})) as raw_text_layout,
    raw_text_layout:content as raw_text
FROM DIRECTORY(@DOCUMENTS.CARTA_DOCS_STAGE);

-- View the results
SELECT * FROM CARTA_DOCS_ENRICHED;

-- =====================================================================================
-- [SECTION 4: CHUNK_DOCS]
-- =====================================================================================
-- Split documents into semantic chunks for RAG and vector search
-- Uses markdown headers to maintain document structure:
-- - # = Main sections
-- - ## = Subsections  
-- - ### = Detail sections
-- Chunk parameters: 2000 chars with 200 char overlap for context
CREATE OR REPLACE TABLE CARTA_DOCS_CHUNKED AS
SELECT 
    relative_path,
    SNOWFLAKE.CORTEX.SPLIT_TEXT_MARKDOWN_HEADER(
        raw_text::STRING,
        OBJECT_CONSTRUCT('#', 'main_section', '##', 'subsection', '###', 'detail'),
        2000,  -- 2000 character chunks
        200    -- 200 character overlap
    ) as chunks
FROM CARTA_DOCS_ENRICHED;

-- View chunked results
SELECT * FROM CARTA_DOCS_CHUNKED;

-- Flatten the chunked data into individual records for easier querying
CREATE OR REPLACE TABLE CARTA_DOCS_CHUNKS_FLAT AS
SELECT 
    relative_path,
    CONCAT(relative_path, '_chunk_', chunk_data.index::STRING) AS chunk_id,  -- Unique ID
    chunk_data.index AS chunk_number,
    chunk_data.value:chunk::STRING AS chunk_text,
    chunk_data.value:headers:main_section::STRING AS main_section,
    chunk_data.value:headers:subsection::STRING AS subsection,
    chunk_data.value:headers:detail::STRING AS detail_section,
    LENGTH(chunk_data.value:chunk::STRING) AS chunk_length
FROM 
    CARTA_DOCS_CHUNKED,
    LATERAL FLATTEN(input => chunks) AS chunk_data;

-- View flattened results
SELECT * FROM CARTA_DOCS_CHUNKS_FLAT;

-- =====================================================================================
-- [SECTION 5: FLATTEN_PAGES]
-- =====================================================================================
-- Transform page-split JSON into relational format for easy querying
-- Creates one record per page with extracted metadata
-- Automatically generates page titles from content or headers
CREATE OR REPLACE TABLE CARTA_DOCS_PAGES_FLAT AS
SELECT 
    relative_path,
    CONCAT(relative_path, '_page_', page_data.index::STRING) AS page_id,  -- Unique ID
    page_data.index AS page_number,
    page_data.value:content::STRING AS page_content,
    -- Extract title from first header (# or ##) or first 100 chars
    CASE 
        WHEN REGEXP_SUBSTR(page_data.value:content::STRING, '^#{1,6}\\s+(.+)$', 1, 1, 'm', 1) IS NOT NULL 
        THEN REGEXP_SUBSTR(page_data.value:content::STRING, '^#{1,6}\\s+(.+)$', 1, 1, 'm', 1)
        WHEN LENGTH(TRIM(SPLIT(page_data.value:content::STRING, '\n')[0])) > 0
        THEN LEFT(TRIM(SPLIT(page_data.value:content::STRING, '\n')[0]), 100)
        ELSE CONCAT('Page ', page_data.index::STRING)
    END AS page_title,
    LENGTH(page_data.value:content::STRING) AS content_length,
    raw_text_dict:metadata:pageCount::INT AS total_pages
FROM 
    CARTA_DOCS_ENRICHED,
    LATERAL FLATTEN(input => raw_text_dict:pages) AS page_data
WHERE raw_text_dict IS NOT NULL;

-- View flattened page results
SELECT * 
FROM CARTA_DOCS_PAGES_FLAT;