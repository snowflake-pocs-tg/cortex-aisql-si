# Banking Intelligence POC with Snowflake Cortex

## Overview
This project demonstrates how to build an intelligent banking analytics platform using Snowflake's Cortex AI capabilities. It transforms complex financial institution data into business-friendly insights through natural language queries.

## What This Does
- Enables business users to ask questions about banking data in plain English
- Analyzes bank performance, market trends, and risk metrics without writing SQL
- Provides instant insights on profitability, branch networks, mergers & acquisitions, and regulatory compliance

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

### Step 2: Run Setup Scripts
Navigate to the `queries/carta/` directory and execute the SQL files in numbered order:

1. **01_environment_setup.sql** - Creates your database, schemas, and warehouse
2. **02_parse_document.sql** - Sets up document parsing capabilities
3. **03_ai_classify.sql** - Configures AI classification for documents
4. **04_ai_complete.sql** - Enables AI completion and insights
5. **05_cortex_search.sql** - Creates semantic search functionality
6. **06_semantic_views.sql** - Builds the three main intelligence views

### Step 3: Configure Snowflake Intelligence
1. Navigate to Snowflake Intelligence in your Snowflake interface
2. Import the agent configuration from `snowflake_intelligence/docs/`
3. Use the provided agent descriptions and tool configurations

### Step 4: Start Asking Questions
Once setup is complete, you can ask natural language questions like:
- "Show me the top performing banks in Texas"
- "Which banks have the highest capital ratios?"
- "What's the branch density by state?"
- "Show recent merger and acquisition activity"
- "Which institutions have high risk indicators?"

## Project Structure
- **_data/** - Sample financial data for testing
- **_pdfs/** - Example valuation documents
- **queries/carta/** - SQL setup scripts (run these in order)
- **snowflake_intelligence/** - Agent configurations for natural language queries

## The Three Intelligence Views

### 1. Banking Performance Analytics
Analyzes profitability, efficiency, and capital strength across financial institutions.

### 2. Banking Market Intelligence
Tracks branch networks, M&A activity, and market concentration.

### 3. Banking Risk Analytics
Monitors credit risk, capital adequacy, and regulatory compliance.

## Support
For questions or issues, please refer to the documentation in the `_docs/` directory or contact your Snowflake administrator.

## Next Steps
After successful setup:
1. Test sample queries from the semantic views documentation
2. Customize the agent configuration for your specific use cases
3. Expand the analysis with additional metrics as needed