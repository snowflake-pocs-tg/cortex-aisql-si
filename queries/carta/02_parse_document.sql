/*
===============================================================================
SNOWFLAKE CORTEX DOCUMENT PROCESSING PIPELINE
===============================================================================
Purpose: Demonstrate end-to-end document processing workflow using Snowflake's
         Cortex Suite for parsing, chunking, and structuring PDF documents
         
TABLE OF CONTENTS:
------------------
QUERY 1: Single Document Parse Test
         - Tests PARSE_DOCUMENT with LAYOUT mode and page splitting
         - Validates Cortex functionality on a single PDF
         
QUERY 2: Batch Document Processing  
         - Creates enriched table from all documents in stage
         - Stores both page-split and full document versions
         
QUERY 3: Semantic Chunking with Flattening
         - Splits documents by markdown headers for RAG applications
         - Creates overlapping chunks for better context preservation
         - Flattens nested JSON into relational format
         
QUERY 4: Page-Level Flattening
         - Flattens page-split JSON into relational format
         - One record per page for granular analysis

Prerequisites:
- Documents uploaded to stages via 01_environment_setup.sql
- PROCESSED schema created with enriched tables
- Cortex Suite enabled in Snowflake account

Key Tables Created:
- CARTA_DOCS_ENRICHED: Raw parsed documents with metadata
- CARTA_DOCS_CHUNKED: Documents split by headers
- CARTA_DOCS_CHUNKS_FLAT: Flattened chunks for querying
- CARTA_DOCS_PAGES_FLAT: Individual pages as records
===============================================================================
*/

-- Initial setup: Configure database context for document processing
USE DATABASE EQUITY_INTEL_POC;
USE SCHEMA PROCESSED;
USE WAREHOUSE EQUITY_INTEL_WH;

/*
===============================================================================
QUERY 1: Single Document Parse Test
Purpose: Validate PARSE_DOCUMENT functionality on a single PDF before batch
         processing. Tests both LAYOUT mode for table extraction and page
         splitting for handling large documents.
         
Details:
- LAYOUT mode: Preserves document structure including tables and formatting
- page_split: TRUE splits large documents into manageable page-sized chunks
- TO_VARIANT: Converts output to queryable JSON format
         
Expected Output: JSON object with pages array containing content and metadata
Use Case: Initial testing and debugging of document parsing parameters
===============================================================================
*/
SELECT 
    TO_VARIANT(
        SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
            '@DOCUMENTS.CARTA_DOCS_STAGE',
            'carta.pdf',
            {'mode': 'LAYOUT', 'page_split': TRUE}
        )
    ) AS parsed_document;

/*
===============================================================================
QUERY 2: Batch Document Processing - Create Enriched Table
Purpose: Process all PDF documents in the stage and create a comprehensive
         enriched table with multiple parsing strategies for flexibility.
         
Details:
- Processes all files in CARTA_DOCS_STAGE automatically
- Creates two parsing versions:
  1. raw_text_dict: Page-split version for page-level analysis
  2. raw_text_layout: Full document for complete text extraction
- GET_PRESIGNED_URL: Generates secure URLs for document access
- DIRECTORY function: Iterates through all stage files

Output Table: CARTA_DOCS_ENRICHED
Columns: relative_path, scoped_file_url, raw_text_dict, raw_text_layout, raw_text
===============================================================================
*/
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

/*
===============================================================================
QUERY 3: Semantic Chunking with Hierarchical Headers
Purpose: Split documents into semantic chunks based on markdown headers for
         RAG (Retrieval Augmented Generation) and intelligent search indexing.
         
Details:
- SPLIT_TEXT_MARKDOWN_HEADER: Cortex function for intelligent splitting
- Header Hierarchy:
  - '#': Main sections (top-level topics)
  - '##': Subsections (detailed topics)
  - '###': Detail sections (specific points)
- Chunk Size: 2000 characters (optimal for embedding models)
- Overlap: 200 characters (preserves context between chunks)

Processing Steps:
1. Create chunked table with nested JSON
2. Flatten JSON array into individual chunk records
3. Extract header hierarchy for semantic navigation

Output Tables: 
- CARTA_DOCS_CHUNKED: Nested chunks array
- CARTA_DOCS_CHUNKS_FLAT: One record per chunk with metadata
===============================================================================
*/
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

/*
===============================================================================
QUERY 4: Page-Level Document Flattening
Purpose: Transform page-split JSON structure into a relational table with
         one record per page for granular document analysis and processing.
         
Details:
- LATERAL FLATTEN: Expands nested pages array into rows
- Page Identification: Creates unique page_id for tracking
- Metadata Extraction: Captures total page count from document metadata
- Content Length: Tracks page content size for analysis

Use Cases:
- Page-specific search and retrieval
- Document navigation and pagination
- Content density analysis
- Page-level annotation and tagging

Output Table: CARTA_DOCS_PAGES_FLAT
Columns: relative_path, page_id, page_number, page_content, page_title, content_length, total_pages
===============================================================================
*/
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