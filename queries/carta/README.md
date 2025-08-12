# Snowflake Setup Scripts

## Purpose
This folder contains the SQL scripts needed to set up the banking intelligence platform in your Snowflake environment. Scripts are numbered to indicate the order in which they should be run.

## Setup Sequence

### 1. Environment Setup (01_environment_setup.sql)
Creates the foundation for your intelligence platform:
- Sets up a dedicated database for the project
- Creates schemas to organize different types of data
- Establishes a compute warehouse for processing
- Configures storage locations for document uploads

### 2. Document Parsing (02_parse_document.sql)
Enables the system to read and understand PDF documents:
- Extracts text content from uploaded documents
- Identifies tables and structured data within PDFs
- Prepares content for analysis and classification

### 3. AI Classification (03_ai_classify.sql)
Teaches the system to recognize different types of information:
- Categorizes document sections automatically
- Identifies financial statements, valuations, and risk assessments
- Tags content for easier retrieval and analysis

### 4. AI Insights (04_ai_complete.sql)
Generates intelligent summaries and answers:
- Creates executive summaries of complex documents
- Answers specific questions about document contents
- Provides comparative analysis across multiple documents

### 5. Semantic Search (05_cortex_search.sql)
Builds powerful search capabilities:
- Enables natural language search across all documents
- Finds relevant information based on meaning, not just keywords
- Ranks results by relevance to your query

### 6. Semantic Views (06_semantic_views.sql)
Creates three comprehensive intelligence views:
- **Performance Analytics** - Track profitability and efficiency
- **Market Intelligence** - Monitor branches and M&A activity  
- **Risk Analytics** - Assess credit risk and compliance

## How to Run These Scripts

1. Open Snowflake's SQL worksheet interface
2. Copy and paste each script in order
3. Run the script completely before moving to the next
4. Verify successful completion of each step
5. Check for any error messages and resolve before proceeding

## Required Permissions
You need SYSADMIN role or equivalent to:
- Create databases and schemas
- Set up warehouses
- Create stages and file formats
- Build views and tables

## Time Required
Complete setup typically takes 15-30 minutes depending on your Snowflake environment.

## Verification
After running all scripts, verify success by:
- Checking that all three semantic views exist
- Running the sample queries included in script 06
- Confirming the Cortex search service is active

## Troubleshooting
If any script fails:
- Check you have the required Snowflake Finance & Economics data installed
- Verify you have appropriate permissions
- Ensure Cortex AI features are enabled in your account
- Review error messages for specific issues