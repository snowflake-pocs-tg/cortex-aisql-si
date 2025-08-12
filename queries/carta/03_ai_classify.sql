/*
===============================================================================
SNOWFLAKE CORTEX AI CLASSIFICATION PIPELINE
===============================================================================
Purpose: Use Snowflake's Cortex AI functions to classify and analyze document
         chunks for specific content patterns and data structures
         
TABLE OF CONTENTS:
------------------
QUERY 1: Data Table Detection
         - Identifies chunks containing tabular data
         - Uses AI to detect table structures in text
         
Prerequisites:
- CARTA_DOCS_CHUNKS_FLAT table created from 02_parse_document.sql
- Cortex AI functions enabled in Snowflake account
===============================================================================
*/

-- Initial setup: Configure database context
USE DATABASE EQUITY_INTEL_POC;
USE SCHEMA PROCESSED;
USE WAREHOUSE EQUITY_INTEL_WH;

/*
===============================================================================
QUERY 1: Data Table Detection in Document Chunks
Purpose: Analyze each document chunk to determine if it contains a data table
         using Cortex AI classification capabilities.
         
Details:
- Input: CARTA_DOCS_CHUNKS_FLAT from previous processing
- AI Analysis: Detects presence of tabular data structures
- Boolean Classification: TRUE if table detected, FALSE otherwise
- Pattern Recognition: Identifies various table formats including:
  - Markdown tables with pipe delimiters
  - Financial statements with columns
  - Structured data with headers and rows
  - Statistical tables with numeric data

Output Table: CHUNKS_WITH_TABLE_CLASSIFICATION
Columns: All original columns plus has_data_table boolean
===============================================================================
*/
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
