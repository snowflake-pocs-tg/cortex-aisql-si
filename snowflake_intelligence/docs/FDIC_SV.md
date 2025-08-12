# FDIC Deposits Semantic View

## Description
This semantic view analyzes FDIC Summary of Deposits timeseries data, providing branch-level deposit information across U.S. financial institutions. It's the primary source for deposit trends and institutional comparisons with actual numerical values.

## Available Dimensions
- **DATE** - Deposit reporting date (quarterly/annual periods)
- **FDIC_INSTITUTION_ID** - Unique identifier for each institution
- **FDIC_BRANCH_ID** - Unique identifier for each branch location
- **VARIABLE** - FDIC metric code for different deposit types
- **VARIABLE_NAME** - Human-readable description of the metric
- **UNIT** - Measurement unit (typically USD)

## Available Metrics
- **total_deposits** - Sum of all deposit values
- **avg_deposits** - Average deposits per branch
- **max_deposits** - Highest single branch deposit amount
- **min_deposits** - Lowest single branch deposit amount
- **branch_count** - Number of unique branches
- **institution_count** - Number of unique institutions
- **record_count** - Total data points available

## What You Can Ask
- Deposit trends over time (yearly, quarterly, or by specific dates)
- Rankings of institutions by total or average deposits
- Branch network sizes and deposit concentrations
- Deposit ranges showing max/min values
- Data coverage and reporting completeness by period
- Year-over-year or quarter-over-quarter comparisons

## Query Guidance
- Always specify time periods for trend analysis ("last 5 years", "since 2020", "Q1 2023")
- Use "top N" format for rankings ("top 10 institutions", "top 20 branches")
- Request specific metrics to avoid ambiguity ("total deposits" vs "average deposits")
- Combine dimensions for detailed breakdowns ("by institution and year")
- Include filters when needed ("where deposits > 1 million")

## Important Notes
- Data source: FINANCE_ECONOMICS.CYBERSYN.FDIC_SUMMARY_OF_DEPOSITS_TIMESERIES
- Updates: Quarterly based on FDIC reporting cycles
- Coverage: Not all institutions report every period
- IDs: Uses FDIC identifiers, not RSSD numbers
- Values: Deposit amounts are typically in thousands of USD