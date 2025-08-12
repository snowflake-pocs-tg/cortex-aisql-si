# Snowflake Banking Intelligence Platform

## Overview
This directory contains SQL scripts and documentation for setting up a comprehensive banking intelligence platform using Snowflake's Cortex AI capabilities. The platform combines document processing for 409A valuations with structured data analysis for FDIC deposits and branch networks.

## 📁 Directory Contents

### SQL Scripts (Run in Order)
1. **01_environment_setup.sql** - Database, schema, warehouse, and stage creation
2. **02_parse_document.sql** - PDF document parsing and chunking pipeline
3. **03_ai_classify.sql** - AI classification for table detection
4. **04_ai_complete.sql** - Table extraction using generative AI
5. **05_cortex_search.sql** - Semantic search service for documents
6. **06_semantic_views.sql** - Two semantic views for banking analytics

### Documentation
- **QUESTIONS.md** - Test questions for Cortex Analyst integration
- **README.md** - This file

## 🏗️ Setup Sequence

### 1. Environment Setup (01_environment_setup.sql)
Creates the foundation:
- Database: `EQUITY_INTEL_POC`
- Schemas: `DOCUMENTS`, `PROCESSED`, `TOOLS`
- Warehouse: `EQUITY_INTEL_WH` (XSMALL)
- Stages for PDF storage with sample uploads

### 2. Document Processing (02_parse_document.sql)
Processes PDF documents:
- Parses PDFs using PARSE_DOCUMENT
- Creates page-level and chunk-level tables
- Implements semantic chunking for RAG
- Tables: `CARTA_DOCS_ENRICHED`, `CARTA_DOCS_CHUNKS_FLAT`, `CARTA_DOCS_PAGES_FLAT`

### 3. AI Classification (03_ai_classify.sql)
Identifies structured content:
- Detects tables within document chunks
- Uses AI_CLASSIFY for pattern recognition
- Table: `CHUNKS_WITH_TABLE_CLASSIFICATION`

### 4. Table Extraction (04_ai_complete.sql)
Extracts structured data:
- Converts tables to JSON objects
- Uses Mistral Large 2 model
- Table: `EXTRACTED_TABLE_OBJECTS`

### 5. Semantic Search (05_cortex_search.sql)
Enables document search:
- Creates Cortex Search Service
- Indexes all document pages
- Service: `CARTA_DOCS_SEARCH_SERVICE`

### 6. Semantic Views (06_semantic_views.sql)
Creates two banking analytics views:
- **FDIC_DEPOSITS_ANALYTICS** - Deposit trends and institution metrics
- **BANKING_BRANCH_NETWORK_ANALYTICS** - Branch locations and geographic analysis

## 🚀 Quick Start

### Prerequisites
- Snowflake account with Cortex AI enabled
- SYSADMIN role or equivalent permissions
- Access to FINANCE_ECONOMICS.CYBERSYN data share
- PDF files in `_pdfs/` directory (optional)

### Installation Steps
1. Open Snowflake SQL worksheet
2. Run scripts in numbered order (01 through 06)
3. Each script is self-contained and idempotent
4. Verify each step completes successfully before proceeding

### Time Required
- Full setup: 15-30 minutes
- Individual scripts: 1-5 minutes each
- Semantic view creation: < 1 minute

## 📊 Key Features

### Document Intelligence
- **PDF Processing**: Parse and chunk 409A valuation documents
- **Table Extraction**: AI-powered extraction of financial tables
- **Semantic Search**: Natural language search across documents
- **Page-Level Access**: Query specific pages or sections

### Banking Analytics
- **FDIC Deposits**: Analyze deposit trends across institutions
- **Branch Networks**: Geographic footprint and regulatory analysis
- **Time Series**: Historical trends and comparisons
- **Aggregations**: Institution, state, and regulator-level metrics

## 🔍 Data Sources

### Structured Data (Cybersyn)
- `FINANCIAL_INSTITUTION_ENTITIES` - Bank information
- `FINANCIAL_BRANCH_ENTITIES` - Branch locations
- `FDIC_SUMMARY_OF_DEPOSITS_TIMESERIES` - Deposit values
- `FINANCIAL_INSTITUTION_EVENTS` - M&A activity
- `FINANCIAL_INSTITUTION_HIERARCHY` - Ownership structures

### Unstructured Data (Your PDFs)
- 409A valuation reports
- Financial statements
- Comparable company analyses
- Industry research documents

## ✅ Verification

After setup, verify:
1. **Database exists**: `SHOW DATABASES LIKE 'EQUITY_INTEL_POC'`
2. **Tables created**: `SHOW TABLES IN PROCESSED`
3. **Semantic views active**: Run sample queries from `06_semantic_views.sql`
4. **Search service ready**: `SHOW CORTEX SEARCH SERVICES`
5. **Data available**: Check row counts in key tables

## 🛠️ Troubleshooting

### Common Issues
- **Missing Cybersyn data**: Ensure FINANCE_ECONOMICS share is mounted
- **Cortex not available**: Verify Cortex AI is enabled for your account
- **Parse errors**: Check PDF files are not compressed (AUTO_COMPRESS=FALSE)
- **No results**: Confirm data exists for queried time periods

### Getting Help
- Review section markers in each SQL file (search for `[SECTION`)
- Check QUESTIONS.md for example queries
- Examine table schemas with `DESCRIBE TABLE`
- Use `SELECT COUNT(*)` to verify data presence

## 📝 Additional Resources

### Test Queries
See **QUESTIONS.md** for:
- 5 Cortex Search Service questions
- 5 FDIC Deposits Analytics questions
- 5 Banking Branch Network questions

