# Banking Branch Network Semantic View

## Description
This semantic view combines financial institution data with branch network information, enabling analysis of bank geographic footprints, regulatory oversight, and operational characteristics. It joins entity-level bank data with branch locations and includes deposit metrics where available.

## Available Dimensions

### Bank-Level Dimensions
- **banks.NAME** - Legal name of the financial institution
- **banks.STATE_ABBREVIATION** - Headquarters state location
- **banks.CATEGORY** - Institution type (Bank, Credit Union, Thrift)
- **banks.IS_ACTIVE** - Current operational status
- **banks.FEDERAL_REGULATOR** - Primary regulator (OCC, FDIC, FED, NCUA)
- **banks.SPECIALIZATION_GROUP** - Business focus area (Commercial Lending, Agricultural, etc.)

### Branch-Level Dimensions
- **branches.BRANCH_NAME** - Individual branch location name
- **branches.CITY** - City where branch is located
- **branches.STATE_ABBREVIATION** - State where branch is located
- **branches.ZIP_CODE** - Branch postal code
- **branches.IS_ACTIVE** - Branch operational status

### Time Dimensions
- **deposits.DATE** - Reporting date for deposit data

## Available Metrics
- **branch_count** - Total number of branches
- **active_branches** - Number of currently operating branches
- **state_count** - Number of states with branch presence
- **city_count** - Number of cities with branches
- **bank_count** - Number of unique institutions
- **total_deposits** - Sum of deposit values (when available)
- **avg_deposits** - Average deposits per branch (when available)
- **max_deposits** - Highest branch deposit amount (when available)
- **min_deposits** - Lowest branch deposit amount (when available)

## What You Can Ask
- Branch network size by institution or state
- Geographic footprint and multi-state operations
- Comparisons between different regulators (OCC vs FDIC vs FED)
- Active versus inactive branch analysis
- Institution types comparison (Banks vs Credit Unions vs Thrifts)
- Bank specialization analysis (Commercial vs Agricultural)
- Branch concentration in specific cities or states
- Network expansion or contraction trends

## Query Guidance
- Specify institution names in quotes for specific banks ("Bank of America")
- Use state abbreviations for geographic queries ("TX", "CA", "NY")
- Filter by IS_ACTIVE = TRUE for current operations only
- Group by FEDERAL_REGULATOR for regulatory comparisons
- Use "top N" format for rankings ("top 10 banks by branch count")
- Combine dimensions for detailed analysis ("branches by state and regulator")

## Important Notes
- Data sources: FINANCIAL_INSTITUTION_ENTITIES and FINANCIAL_BRANCH_ENTITIES tables
- ID System: Uses RSSD identifiers (different from FDIC IDs)
- Deposit metrics may have limited availability due to ID system differences
- Branch counts include both active and inactive unless filtered
- Some institutions may not have complete branch location data
- Specialization groups help identify business focus areas