# Snowflake Intelligence Platform

## Overview
Snowflake Intelligence is a comprehensive AI-powered analytics platform that provides intelligent data analysis capabilities using Snowflake Cortex AI. Currently focused on banking and financial intelligence, the platform enables natural language queries against complex financial datasets including FDIC deposits, branch networks, and institutional performance metrics.

## Architecture

### Core Components

#### 1. Infrastructure Setup (`01_SETUP.sql`)
Establishes the foundational infrastructure for Snowflake Intelligence:
- **Custom Role**: `SNOWFLAKE_INTELLIGENCE_ADMIN_RL` - Administrative role with full AI/ML resource access
- **Dedicated Warehouse**: `SNOWFLAKE_INTELLIGENCE_WH` - Optimized for AI workloads and Cortex Search
- **Database**: `SNOWFLAKE_INTELLIGENCE` - Main database for all platform components
- **Schemas**:
  - `AGENTS` - AI agent configurations and orchestration
  - `INTEGRATIONS` - External service integrations and API configurations
  - `TOOLS` - Custom functions and stored procedures

#### 2. DDL Operations (`02_DDL.sql`)
Python-based stored procedure for Data Definition Language operations:
- **EXECUTE_DDL_PY**: Universal DDL execution with formatted results
- Supports CREATE, ALTER, DROP, TRUNCATE, GRANT, REVOKE operations
- Special handling for SHOW and DESCRIBE commands with table formatting
- Error handling and validation for DDL statements

#### 3. DML Operations (`03_DML.sql`)
Python-based stored procedure for Data Manipulation Language operations:
- **EXECUTE_DML_PY**: Flexible DML execution with multiple output formats
- Supports SELECT, INSERT, UPDATE, DELETE, MERGE operations
- Output formats: table, JSON, summary
- Intelligent result formatting with pagination for large datasets

## Agent Configuration

### Banking Intelligence Agent
An AI-powered analyst specializing in banking and financial institution data analysis.

#### Capabilities
- **Instant Data Analysis**
  - Query deposit trends across thousands of institutions
  - Analyze branch network sizes and geographic distribution
  - Compare performance metrics between banks, credit unions, and thrifts
  - Track deposit growth patterns over time

- **Smart Comparisons**
  - Benchmark institutions against peer groups
  - Compare regulatory oversight impacts (OCC vs FDIC vs FED)
  - Analyze state-by-state banking concentration
  - Identify market leaders by deposits or branch count

- **Strategic Insights**
  - Assess branch network efficiency (deposits per branch)
  - Evaluate geographic expansion strategies
  - Understand specialization impacts (Commercial vs Agricultural)
  - Monitor active vs inactive branch trends

#### Communication Guidelines
- **Tone**: Conversational and approachable, using accurate financial terminology
- **Structure**: Direct answers → Context → Follow-up questions
- **Engagement**: Always end with 2-3 relevant follow-up questions
- **Citations**: Always cite sources with page numbers when available

## Semantic Views

### 1. Banking Branch Network View
Combines financial institution data with branch network information for comprehensive geographic and operational analysis.

**Key Dimensions**:
- Bank-level: Name, State, Category, Regulator, Specialization
- Branch-level: Location, City, State, ZIP, Active Status
- Time: Reporting dates for deposit data

**Available Metrics**:
- Branch counts (total, active)
- Geographic spread (states, cities)
- Deposit metrics (total, average, min, max)

**Use Cases**:
- Network size analysis by institution or state
- Regulatory comparison (OCC vs FDIC vs FED)
- Geographic footprint assessment
- Active/inactive branch analysis

### 2. FDIC Deposits View
Analyzes FDIC Summary of Deposits timeseries data for branch-level deposit information.

**Key Dimensions**:
- DATE - Quarterly/annual reporting periods
- FDIC_INSTITUTION_ID - Unique institution identifier
- FDIC_BRANCH_ID - Unique branch identifier
- VARIABLE/VARIABLE_NAME - Deposit metric types

**Available Metrics**:
- Total/average/min/max deposits
- Branch and institution counts
- Record counts for data coverage

**Use Cases**:
- Deposit trend analysis over time
- Institution rankings by deposits
- Branch concentration analysis
- Year-over-year comparisons

## Tool Orchestration

### When to Use Each Tool

#### CORTEX_SEARCH_SERVICE
Use for:
- Finding specific companies or valuations
- Understanding methodologies or concepts
- Locating information in documents
- Finding specific sections

#### CORTEX_ANALYST
Use for:
- Calculations and analysis
- Company comparisons
- Trend analysis
- Aggregated insights

### Handling Ambiguity
Common term mappings:
- "latest" → most recent valuation date
- "comps" → comparable companies
- "discount" → DLOM (Discount for Lack of Marketability)
- "multiple" → valuation multiple (EV/Revenue, EBITDA, P/E)

## Data Sources
- ✅ FDIC Summary of Deposits (quarterly reports)
- ✅ Financial Institution Entity data (RSSD system)
- ✅ Branch location and status information
- ✅ Federal regulatory classifications
- ✅ Historical time series from multiple years

## Best Practices

### Query Guidelines
1. **Specify Time Periods**: Use clear date ranges for trend analysis
2. **Use Standard Abbreviations**: State codes, regulatory acronyms
3. **Request Rankings**: Use "top N" format for clear results
4. **Be Metric-Specific**: Distinguish between total vs average
5. **Filter Appropriately**: Use active status filters for current operations

### Critical Rules
**MUST DO**:
- Validate data ranges (DLOM: 10-40%, Revenue multiples: 1-15x)
- Ask follow-up questions to encourage deeper analysis
- Cite sources with page numbers when available

**NEVER DO**:
- Assume meanings without context
- Skip follow-up questions
- Present unvalidated numbers

## Setup Instructions

### Prerequisites
- ACCOUNTADMIN role access in Snowflake
- Ability to create roles, warehouses, databases, and schemas

### Installation
1. **Run Infrastructure Setup**:
   ```sql
   -- Execute 01_SETUP.sql in Snowflake worksheet
   -- This creates all necessary roles, warehouses, and schemas
   ```

2. **Deploy DDL Procedures**:
   ```sql
   -- Execute 02_DDL.sql to create DDL management procedures
   USE SCHEMA SNOWFLAKE_INTELLIGENCE.TOOLS;
   ```

3. **Deploy DML Procedures**:
   ```sql
   -- Execute 03_DML.sql to create DML execution procedures
   USE SCHEMA SNOWFLAKE_INTELLIGENCE.TOOLS;
   ```

### Verification
After setup, verify the installation:
```sql
-- Check created objects
SHOW DATABASES LIKE 'SNOWFLAKE_INTELLIGENCE';
SHOW SCHEMAS IN DATABASE SNOWFLAKE_INTELLIGENCE;
SHOW PROCEDURES IN SCHEMA SNOWFLAKE_INTELLIGENCE.TOOLS;
```

## Usage Examples

### DDL Operations
```sql
-- Execute DDL with formatted output
CALL SNOWFLAKE_INTELLIGENCE.TOOLS.EXECUTE_DDL_PY(
    'SHOW TABLES IN DATABASE SNOWFLAKE_INTELLIGENCE',
    TRUE  -- show_results
);
```

### DML Operations
```sql
-- Query with table format
CALL SNOWFLAKE_INTELLIGENCE.TOOLS.EXECUTE_DML_PY(
    'SELECT * FROM my_table LIMIT 10',
    'table'
);

-- Query with JSON format
CALL SNOWFLAKE_INTELLIGENCE.TOOLS.EXECUTE_DML_PY(
    'SELECT * FROM my_table LIMIT 10',
    'json'
);
```

## Technical Details

### Warehouse Configuration
- **Size**: X-SMALL (optimized for cost and performance)
- **Auto-Suspend**: 300 seconds (5 minutes)
- **Auto-Resume**: Enabled
- **Scaling**: Standard policy with single cluster
- **Initial State**: Suspended

### Python Runtime
- **Version**: 3.12
- **Package**: snowflake-snowpark-python
- **Error Handling**: Comprehensive exception management
- **Output Limits**: 100 rows for table display, configurable

## Maintenance

### Regular Tasks
1. Monitor warehouse usage and adjust size if needed
2. Review agent performance and update prompts
3. Update semantic views as new data sources become available
4. Audit role permissions periodically

### Troubleshooting
- **Permission Issues**: Ensure SNOWFLAKE_INTELLIGENCE_ADMIN_RL is granted
- **Warehouse Errors**: Check warehouse is resumed and sized appropriately
- **Procedure Failures**: Review error messages and validate input statements

## Future Enhancements
- Additional semantic views for equity intelligence
- Extended agent capabilities for 409A valuations
- Integration with external data providers
- Advanced visualization tools
- Automated report generation

## Support
For issues or questions:
- Review agent documentation in `/docs` directory
- Check semantic view specifications
- Validate data source availability
- Ensure proper role and warehouse configuration