/*
===============================================================================
SNOWFLAKE CORTEX SEARCH SERVICE FOR 409A DOCUMENTS
===============================================================================
Purpose: Create a searchable index on parsed 409A valuation documents
         enabling semantic search across all document content
         
Prerequisites:
- CARTA_DOCS_PAGES_FLAT table from 02_parse_document.sql
- Cortex Search enabled in Snowflake account
===============================================================================
*/

-- Initial setup
USE DATABASE EQUITY_INTEL_POC;
USE SCHEMA PROCESSED;
USE WAREHOUSE EQUITY_INTEL_WH;

/*
===============================================================================
CREATE CORTEX SEARCH SERVICE: CARTA_DOCS_SEARCH_SERVICE

Description:
This Cortex Search Service enables intelligent semantic search across 409A 
valuation documents. It indexes the full text content of all parsed PDF pages,
allowing users to quickly find specific valuation methodologies, financial data,
comparable company analyses, and other key information within 409A reports.

Key Features:
- Semantic search across all document pages
- Filters by page number for targeted searches
- Returns relevant context with search highlights
- Supports complex queries with boolean operators (AND, OR)
- Enables extraction of specific valuation components

Use Cases:
1. Find comparable company analyses and valuation multiples
2. Locate specific financial metrics (revenue, EBITDA, growth rates)
3. Extract discount rates and risk-free rates
4. Search for industry-specific valuation considerations
5. Identify option pricing model parameters

Indexed Fields:
- page_content: Full text of each document page
- page_id: Unique identifier for each page
- page_number: Page number within the document
- relative_path: Source PDF file name
===============================================================================
*/
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

/*
===============================================================================
TEST QUERY: Search for Table of Contents
Purpose: Test the search service by finding table of contents pages
===============================================================================
*/
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

/*
===============================================================================
QUERY: Search for Valuation Methods and Comparable Companies
Purpose: Find pages discussing valuation methodologies and comparable company analysis
===============================================================================
*/
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