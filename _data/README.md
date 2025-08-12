# Sample Financial Data

## Purpose
This folder contains sample data from real financial institutions used to test and demonstrate the banking intelligence platform. All data is sourced from Snowflake's Cybersyn public datasets.

## What's Inside

### Institution Information
- **Basic bank details** - Names, locations, and regulatory information for financial institutions
- **Branch locations** - Physical office and ATM locations across the United States
- **Ownership structures** - Parent company and subsidiary relationships

### Financial Metrics
- **Performance data** - Quarterly financial metrics including profitability, efficiency, and capital ratios
- **Time series data** - Historical trends for key banking indicators
- **FDIC deposits** - Official deposit data for market share analysis

### Business Events
- **Mergers and acquisitions** - Historical M&A transactions in the banking sector
- **Bank failures** - Records of failed institutions and resolutions

### Analysis Results
Pre-computed analysis files showing:
- Distribution of banks by asset size
- Available performance metrics
- Branch network patterns
- Recent M&A activity with transaction sizes
- Deposit trends over time

## How This Data Is Used
The platform reads this sample data to:
- Demonstrate natural language queries without requiring full database access
- Test semantic view functionality before production deployment
- Provide examples of the types of insights available

## Data Freshness
Sample data represents a snapshot for demonstration purposes. In production, the platform connects to live Snowflake data that updates quarterly.

## Privacy Note
All data is publicly available through official regulatory filings and contains no private customer information.