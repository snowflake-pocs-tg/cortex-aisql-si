/*
===============================================================================
SNOWFLAKE CORTEX AI_COMPLETE FOR TABLE EXTRACTION WITH KEY-VALUE PAIRS
===============================================================================
Purpose: Extract tables and convert rows to objects with headers as keys
         
Prerequisites:
- CHUNKS_WITH_TABLE_CLASSIFICATION table from 03_ai_classify.sql
- Chunks identified as containing tables (has_data_table = true)
===============================================================================
*/

-- Initial setup
USE DATABASE EQUITY_INTEL_POC;
USE SCHEMA PROCESSED;
USE WAREHOUSE EQUITY_INTEL_WH;

/*
===============================================================================
QUERY: Extract Tables as List of Row Objects
Purpose: Convert each table row into an object with column headers as keys
===============================================================================
*/
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

-- View ALL extracted table objects (flattened)
-- Run this entire SELECT statement as one query
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