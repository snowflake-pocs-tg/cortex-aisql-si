-- =====================================================================================
-- SNOWFLAKE CORTEX SEARCH SERVICE FOR 409A DOCUMENTS
-- =====================================================================================
-- Purpose: Enable semantic search across valuation documents
-- Database: EQUITY_INTEL_POC
-- Schema: PROCESSED
-- Last Updated: 2025
-- 
-- OVERVIEW:
-- ---------
-- This script creates a Cortex Search Service that enables intelligent semantic
-- search across parsed 409A valuation documents. Unlike traditional keyword search,
-- this uses vector embeddings to understand context and meaning, returning
-- semantically relevant results even when exact terms don't match.
--
-- TABLE OF CONTENTS:
-- ------------------
-- Use CTRL+F to search for these section markers:
--
-- [SECTION 1: SETUP]          - Database and warehouse configuration
-- [SECTION 2: CREATE_SERVICE] - Build the Cortex Search Service
-- [SECTION 3: TEST_SEARCH]    - Test query for table of contents
-- [SECTION 4: VALUATION_SEARCH] - Search for valuation methodologies
--
-- SERVICE CREATED:
-- ----------------
-- CARTA_DOCS_SEARCH_SERVICE - Semantic search index on document pages
--
-- KEY FEATURES:
-- -------------
-- - Semantic understanding beyond keyword matching
-- - Page-level search granularity
-- - Boolean operators (AND, OR) for complex queries
-- - Numeric filters for page ranges
-- - Highlighted search results with context
-- - 1-hour refresh lag for updated documents
--
-- INDEXED FIELDS:
-- ---------------
-- - page_content: Full text of each document page (searchable)
-- - page_id: Unique identifier for tracking
-- - page_number: For page-range filtering
-- - page_title: Extracted page headers
-- - relative_path: Source PDF filename
--
-- SEARCH CAPABILITIES:
-- --------------------
-- 1. Natural language queries: "What is the company's valuation?"
-- 2. Technical term search: "DLOM discount rate WACC"
-- 3. Boolean combinations: "revenue OR EBITDA AND growth"
-- 4. Page filtering: Search only specific page ranges
-- 5. Multi-document search: Query across all uploaded PDFs
--
-- PREREQUISITES:
-- --------------
-- - Run 02_parse_document.sql first
-- - CARTA_DOCS_PAGES_FLAT table must exist
-- - Cortex Search feature enabled
-- - EQUITY_INTEL_WH warehouse running
--
-- USE CASES:
-- -----------
-- - Find comparable company analyses
-- - Locate specific financial metrics
-- - Extract discount rates and assumptions
-- - Search for option pricing parameters
-- - Identify risk factors and adjustments
-- - Retrieve industry benchmarks
--
-- PERFORMANCE NOTES:
-- ------------------
-- - Initial index creation may take several minutes
-- - Searches typically return in <1 second
-- - TARGET_LAG of 1 hour balances freshness vs compute
-- - Use filters to improve search precision
--
-- =====================================================================================

-- =====================================================================================
-- [SECTION 1: SETUP]
-- =====================================================================================
-- Configure database context for search service creation

USE DATABASE EQUITY_INTEL_POC;
USE SCHEMA PROCESSED;
USE WAREHOUSE EQUITY_INTEL_WH;

-- =====================================================================================
-- [SECTION 2: CREATE_SERVICE]
-- =====================================================================================
-- Create the Cortex Search Service with semantic indexing
-- This service will index all document pages for intelligent search
CREATE OR REPLACE CORTEX SEARCH SERVICE CARTA_DOCS_SEARCH_SERVICE
ON page_content
ATTRIBUTES page_id, page_number, page_title
WAREHOUSE = EQUITY_INTEL_WH
TARGET_LAG = '1 hour'
AS (
    SELECT 
        page_id,
        relative_path,
        page_number,
        page_title,
        page_content
    FROM CARTA_DOCS_PAGES_FLAT
    WHERE page_content IS NOT NULL
);

-- =====================================================================================
-- [SECTION 3: TEST_SEARCH]
-- =====================================================================================
-- Test the search service by finding table of contents
-- Should return pages 1-3 with contents listings
-- Search for table of contents with filter to get only first few pages
SELECT 
    PARSE_JSON(
        SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
            'CARTA_DOCS_SEARCH_SERVICE',
            '{
                "query": "table of contents",
                "columns": ["page_title", "page_content", "page_id", "relative_path", "page_number"],
                "filter": {
                    "@lte": {"page_number": 3}
                },
                "limit": 5
            }'
        )
    )['results'] AS results;

-- =====================================================================================
-- [SECTION 4: VALUATION_SEARCH]
-- =====================================================================================
-- Search for valuation methodologies and comparable company analysis
-- Uses boolean OR to find any mention of these key valuation concepts
-- Search for valuation methodology discussions with focus on market approach
SELECT 
    PARSE_JSON(
        SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
            'CARTA_DOCS_SEARCH_SERVICE',
            '{
                "query": "guideline public company method OR comparable companies OR market approach valuation multiples",
                "columns": ["page_title", "page_content", "page_id", "relative_path", "page_number"],
                "filter": {
                    "@and": [
                        {"@gte": {"page_number": 8}},
                        {"@lte": {"page_number": 20}}
                    ]
                },
                "limit": 10
            }'
        )
    )['results'] AS valuation_methodology_results;