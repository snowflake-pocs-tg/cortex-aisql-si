# Cortex Analyst Test Questions

## Overview
This document contains test questions for validating the Cortex Search Service and Semantic Views when integrated with Cortex Analyst. These questions test natural language understanding, data retrieval accuracy, and the system's ability to provide meaningful insights from both structured and unstructured data.

---

## 🔍 Cortex Search Service Questions
*These questions test the semantic search capabilities across 409A valuation documents*

### 1. Valuation Methodology Search
**Question:** "What valuation methods were used in the 409A reports and which one was given the most weight?"

**Expected Response:**
- Should identify income approach, market approach, and asset approach
- Extract weighting percentages if available
- Locate specific pages discussing methodology selection
- Highlight any discounts applied (DLOM, minority discount)

### 2. Comparable Company Analysis
**Question:** "Show me all the comparable companies used in the valuation analysis with their revenue multiples"

**Expected Response:**
- List of guideline public companies
- Revenue and EBITDA multiples for each comparable
- Industry classification of comparables
- Explanation of selection criteria

### 3. Financial Metrics Extraction
**Question:** "What are the company's historical revenue figures and projected growth rates?"

**Expected Response:**
- Historical revenue for past 3-5 years
- Year-over-year growth percentages
- Projected revenue for next 2-3 years
- Key assumptions driving projections

### 4. Risk Factor Identification
**Question:** "What are the main risk factors and company-specific considerations mentioned in the valuation?"

**Expected Response:**
- Stage of company development
- Market and competitive risks
- Regulatory considerations
- Management and key person risks
- Financial and liquidity risks

### 5. Option Pricing Parameters
**Question:** "Find the Black-Scholes inputs used for option valuation including volatility and risk-free rate"

**Expected Response:**
- Volatility percentage and how it was determined
- Risk-free rate and source (Treasury yields)
- Expected term/time to liquidity event
- Exercise price and current FMV
- Dividend yield assumptions

---

## 📊 FDIC Deposits Analytics Questions
*These questions test the FDIC_DEPOSITS_ANALYTICS semantic view*

### 1. Deposit Trends Analysis
**Question:** "Show me the total deposits trend over the last 5 years broken down by year"

**Expected Response:**
- Annual deposit totals for the past 5 years
- Year-over-year growth or decline percentages
- Number of reporting institutions each year
- Clear trend visualization showing increases or decreases
- Any significant changes or anomalies in the data

### 2. Top Institutions by Deposits
**Question:** "Which 10 banks have the highest average deposits per branch?"

**Expected Response:**
- List of top 10 institutions by average branch deposits
- FDIC institution IDs and names (if available)
- Average deposit amount per branch for each institution
- Total deposits and branch count for context
- Comparison showing the range between highest and lowest

### 3. Branch Network Size
**Question:** "How many unique branches report deposits each year?"

**Expected Response:**
- Annual count of unique branches reporting
- Trend showing growth or consolidation in branch networks
- Breakdown by year for historical comparison
- Identification of peak years for branch counts
- Recent trends in branch network expansion or contraction

### 4. Deposit Concentration
**Question:** "What's the maximum and minimum deposit size across all branches in 2023?"

**Expected Response:**
- Maximum deposit value and the branch holding it
- Minimum deposit value and the branch holding it
- Average deposit size for context
- Range and standard deviation if available
- Comparison to previous years' extremes

### 5. Data Coverage Analysis
**Question:** "How many deposit records exist for each quarter in the database?"

**Expected Response:**
- Quarterly record counts showing data completeness
- Number of unique institutions reporting each quarter
- Identification of any gaps in data coverage
- Seasonal patterns in reporting frequency
- Most recent quarter with complete data

---

## 🏦 Banking Branch Network Analytics Questions
*These questions test the BANKING_BRANCH_NETWORK_ANALYTICS semantic view*

### 1. Geographic Footprint
**Question:** "Which states have the most bank branches and what are the top banks in each state?"

**Expected Response:**
- Ranking of states by total branch count
- Top 3-5 banks in each high-branch state
- Number of active versus inactive branches per state
- Geographic concentration patterns
- States with fastest growing branch networks

### 2. Regulatory Comparison
**Question:** "Compare the branch networks of banks regulated by OCC versus FDIC"

**Expected Response:**
- Total branch counts by federal regulator (OCC, FDIC, FED, NCUA)
- Average branches per bank for each regulator
- Geographic spread (state count) by regulator
- Number of institutions under each regulator
- Breakdown of active vs inactive branches by regulator

### 3. Bank Specialization Analysis
**Question:** "How do commercial lending banks compare to agricultural banks in terms of branch network size?"

**Expected Response:**
- Average branch count for commercial lending specialists
- Average branch count for agricultural specialists
- Geographic distribution differences between specializations
- Number of cities served by each specialization type
- Total banks in each specialization category

### 4. Active vs Inactive Analysis
**Question:** "What percentage of branches are currently active for each institution type?"

**Expected Response:**
- Active branch percentage for Banks
- Active branch percentage for Credit Unions
- Active branch percentage for Thrifts
- Total branch counts for context
- Trends in branch closures by institution type

### 5. Multi-State Operations
**Question:** "Which banks operate in the most states and how many branches do they have in each?"

**Expected Response:**
- List of banks operating in 5+ states
- Number of states for each multi-state bank
- Total branch count for each multi-state operator
- Number of cities served by these banks
- Comparison of regional vs national operators

---

## 🎯 Testing Guidelines

### For Cortex Search Service:
1. **Verify Semantic Understanding**: Questions should return relevant results even without exact keyword matches
2. **Check Context Extraction**: Responses should include surrounding context, not just matching sentences
3. **Test Boolean Logic**: Complex queries with AND/OR should filter appropriately
4. **Validate Page References**: Results should include accurate page numbers for source verification
5. **Assess Ranking Quality**: Most relevant results should appear first

### For Semantic Views:
1. **Natural Language Translation**: Questions should correctly translate to SQL with appropriate dimensions and metrics
2. **Aggregation Accuracy**: Verify SUM, AVG, COUNT calculations are correct
3. **Filter Application**: WHERE clauses should be properly generated from natural language
4. **Join Integrity**: Multi-table views should maintain proper relationships
5. **Performance**: Queries should return within reasonable time (<5 seconds)

### Success Criteria:
- ✅ All questions return meaningful, non-empty results
- ✅ Numeric values match when verified against raw data
- ✅ Natural language is correctly interpreted into SQL
- ✅ Search results are relevant and properly ranked
- ✅ Response time is acceptable for interactive use

### Common Issues to Watch For:
- ⚠️ Empty results due to data type mismatches
- ⚠️ Incorrect date filtering or formatting
- ⚠️ Missing relationships between tables
- ⚠️ Case sensitivity in string comparisons
- ⚠️ NULL value handling in aggregations

---

## 📝 Notes for Implementation

When integrating with Cortex Analyst, ensure:

1. **Semantic View Registration**: Both views are properly registered with Cortex Analyst
2. **Search Service Endpoint**: CARTA_DOCS_SEARCH_SERVICE is accessible to Analyst
3. **Proper Permissions**: Service account has SELECT access to all referenced tables
4. **Warehouse Sizing**: EQUITY_INTEL_WH is appropriately sized for concurrent queries
5. **Monitoring Setup**: Query performance and error rates are tracked

These questions provide comprehensive coverage of both structured data queries (semantic views) and unstructured document search (Cortex Search), validating the full intelligence platform capabilities.