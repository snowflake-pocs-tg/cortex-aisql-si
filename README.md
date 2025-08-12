# Cortex AI SQL Intelligence Platform

## Overview
A comprehensive Snowflake Cortex AI platform that combines **banking intelligence analytics** with **equity document processing capabilities**. This project demonstrates how to build production-ready AI-powered data analysis solutions using Snowflake's Cortex Suite for both structured financial data and unstructured documents (PDFs).

## What This Does
- **Document Intelligence**: Automatically processes and extracts data from 409A valuation reports and financial documents
- **Banking Analytics**: Enables natural language queries on FDIC deposits, branch networks, and institutional performance
- **Semantic Search**: Provides AI-powered search across documents and structured data
- **Natural Language Interface**: Business users can ask questions in plain English without writing SQL

## Prerequisites
1. **Snowflake Account** with Cortex AI features enabled
2. **Snowflake Finance & Economics Data** - Install from Snowflake Marketplace:
   https://app.snowflake.com/marketplace/listing/GZTSZAS2KF7/snowflake-public-data-products-finance-economics
3. **Database Access** with SYSADMIN role or equivalent permissions

## Quick Start Guide

### Step 1: Install Required Data
1. Log into your Snowflake account
2. Navigate to the Marketplace
3. Search for "Snowflake Finance & Economics Data"
4. Click "Get" to install the dataset
5. Grant access to the FINANCE_ECONOMICS database

### Step 2: Setup Platform Infrastructure
Execute the platform setup scripts in order:

```sql
-- 1. Run platform infrastructure setup
snowflake_intelligence/01_SETUP.sql  -- Creates roles, warehouse, database
snowflake_intelligence/02_DDL.sql    -- DDL procedures
snowflake_intelligence/03_DML.sql    -- DML procedures
```

### Step 3: Deploy Document Processing & Analytics
Navigate to `queries/carta/` and execute in numbered order:

1. **01_environment_setup.sql** - Creates POC database, schemas, stages, uploads sample PDFs
2. **02_parse_document.sql** - Document parsing with chunking capabilities
3. **03_ai_classify.sql** - AI classification for document sections
4. **04_ai_complete.sql** - Data extraction from unstructured content
5. **05_cortex_search.sql** - Semantic search service creation
6. **06_semantic_views.sql** - Banking analytics semantic views

### Step 4: Configure Snowflake Intelligence Agent
1. Navigate to Snowflake Intelligence in your interface
2. Import agent configurations from `snowflake_intelligence/docs/`
3. Configure semantic views using provided specifications

## Project Structure

### Core Implementation
- **`queries/carta/`** - 6-script sequential workflow for document processing and analytics
  - Environment setup, document parsing, AI classification, data extraction, search, views
- **`snowflake_intelligence/`** - Platform infrastructure and agent configurations
  - Setup scripts (01_SETUP, 02_DDL, 03_DML)
  - Agent documentation and semantic view specifications

### Data & Documents
- **`_data/`** - Sample CSV files with real banking data (FDIC deposits, institutions, branches)
- **`_pdfs/`** - 409A valuation documents from Carta, Eqvista, Meld Valuation

### Documentation
- **`_docs/`** - Generated POC documentation (RESEARCH, GAMEPLAN, WORKFLOW)
- **`snowflake_intelligence/docs/`** - Agent configurations and semantic view specs

## Key Capabilities

### Document Intelligence
- **PDF Processing**: Automated extraction from 409A valuations and financial documents
- **AI Classification**: Intelligent categorization of document sections
- **Table Extraction**: Convert unstructured tables to structured JSON
- **Semantic Search**: Natural language queries across all documents

### Banking Analytics
- **FDIC Deposit Analysis**: Trends across thousands of institutions
- **Branch Network Intelligence**: Geographic footprint and efficiency metrics
- **Regulatory Comparisons**: OCC vs FDIC vs FED oversight analysis
- **Market Concentration**: State-by-state banking market analysis

### Semantic Views
1. **FDIC_DEPOSITS_ANALYTICS** - Deposit trends and institutional rankings
2. **BANKING_BRANCH_NETWORK_ANALYTICS** - Geographic and operational analysis

## Technology Stack

### Snowflake Cortex AI Suite
- **PARSE_DOCUMENT()** - Extract text and tables from PDFs
- **AI_CLASSIFY()** - Categorize document content
- **AI_COMPLETE()** - Generate insights and extract data
- **CORTEX_SEARCH** - Semantic search service
- **Cortex Analyst** - Natural language to SQL interface

### Python Integration
- **Snowpark Python 3.12** - Stored procedure runtime
- **Dynamic SQL Execution** - DDL/DML procedures with formatted output
- **Error Handling** - Comprehensive exception management

## Sample Use Cases

### Document Processing
```sql
-- Parse a 409A valuation document
SELECT PARSE_DOCUMENT('@EQUITY_INTEL_POC.DOCUMENTS.PDF_STAGE/carta.pdf');

-- Search across all documents
SELECT CORTEX_SEARCH('What is the company valuation?');
```

### Banking Analytics
```sql
-- Natural language queries through Cortex Analyst
"Show me the top 10 banks by total deposits in Texas"
"Compare branch networks between OCC and FDIC regulated banks"
"What's the deposit growth trend for credit unions?"
```

## Best Practices
- **Security**: Uses dedicated roles and isolated infrastructure
- **Performance**: Auto-suspend warehouses for cost optimization
- **Documentation**: Comprehensive inline comments and section markers
- **Modularity**: Separated infrastructure, tools, and agent configurations

## Support & Documentation
- **Setup Guide**: Follow numbered SQL scripts in `queries/carta/`
- **Agent Config**: See `snowflake_intelligence/docs/` for specifications
- **Platform Details**: Review `snowflake_intelligence/README.md`
- **Sample Data**: Test with files in `_data/` and `_pdfs/`

## Next Steps
After successful setup:
1. Test document processing with sample PDFs
2. Query banking data using semantic views
3. Configure agents for your specific use cases
4. Extend with additional data sources as needed
