# Equity Intelligence POC - Query Scripts

## Overview
These scripts set up and demonstrate document processing and equity intelligence capabilities using Snowflake's Cortex Suite.

## Setup Order

### 1. Environment Setup (`01_environment_setup.sql`)
Run this complete script to create:
- **Database**: `EQUITY_INTEL_POC`
- **Schemas**: 
  - `DOCUMENTS` - Raw document storage
  - `PROCESSED` - Enriched/extracted data
- **Warehouse**: `EQUITY_INTEL_WH` (XSMALL)
- **Stages**: 
  - `ETON_DOCS_STAGE` - Eton Venture Services documents
  - `EQVISTA_DOCS_STAGE` - Eqvista valuation reports
  - `MELD_DOCS_STAGE` - Meld Valuation reports
  - `STANDARD_DOCS_STAGE` - Industry standard reports
- **PUT Commands**: Uploads PDFs from `_pdfs/` directory

## Quick Start

```sql
-- Run the complete environment setup from SnowSQL
snowsql -a <account> -u <username> -f 01_environment_setup.sql

-- Verify uploads
LIST @ETON_DOCS_STAGE;
LIST @EQVISTA_DOCS_STAGE;
LIST @MELD_DOCS_STAGE;
LIST @STANDARD_DOCS_STAGE;
```

## Database Structure

```
EQUITY_INTEL_POC (Database)
├── DOCUMENTS (Schema)
│   ├── ETON_DOCS_STAGE
│   ├── EQVISTA_DOCS_STAGE
│   ├── MELD_DOCS_STAGE
│   └── STANDARD_DOCS_STAGE
└── PROCESSED (Schema)
    ├── ETON_DOCS_ENRICHED
    ├── EQVISTA_DOCS_ENRICHED
    ├── MELD_DOCS_ENRICHED
    └── STANDARD_DOCS_ENRICHED
```

## Key Tables

- **ETON_DOCS_ENRICHED**: Parsed and enriched Eton documents
- **EQVISTA_DOCS_ENRICHED**: Parsed and enriched Eqvista documents  
- **MELD_DOCS_ENRICHED**: Parsed and enriched Meld documents
- **STANDARD_DOCS_ENRICHED**: Parsed and enriched standard format documents

## Notes

- The database/schema names are generic (no company-specific references)
- PUT commands must be run from SnowSQL, not the web UI
- Set `AUTO_COMPRESS=FALSE` for PDFs to maintain readability
- Focus is on unstructured document processing

## Next Steps

After setup:
1. Upload your PDF documents
2. Test PARSE_DOCUMENT functionality
3. Extract and enrich document data into PROCESSED schema