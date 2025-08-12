# Snowflake Intelligence Tool Descriptions

## Overview
This directory contains custom DDL and DML tools for Snowflake Intelligence, enabling programmatic execution of database operations with formatted output suitable for AI/ML workloads.

## Files

### 01_SETUP.sql
**Purpose:** Complete infrastructure setup for Snowflake Intelligence platform

**What it creates:**
- **Role:** `SNOWFLAKE_INTELLIGENCE_ADMIN_RL` - Administrative role with full AI/ML resource access
- **Warehouse:** `SNOWFLAKE_INTELLIGENCE_WH` - X-Small warehouse optimized for AI workloads with auto-suspend/resume
- **Database:** `SNOWFLAKE_INTELLIGENCE` - Main database for the platform
- **Schemas:**
  - `AGENTS` - For AI agent definitions and configurations
  - `INTEGRATIONS` - For external service connections and API configs
  - `TOOLS` - For custom functions and stored procedures

**Key Features:**
- Automatic role grant to executing user
- Complete permission structure with ownership transfers
- Role hierarchy integration with SYSADMIN
- Optimized warehouse settings for Cortex operations

### 02_DDL.sql
**Purpose:** Data Definition Language operations handler

**Procedure:** `EXECUTE_DDL_PY`

**Description:**
Executes DDL statements (CREATE, ALTER, DROP, TRUNCATE, GRANT, REVOKE, SHOW, DESCRIBE) with intelligent result formatting. 

**Parameters:**
- `ddl_statement` (STRING): The DDL statement to execute
- `show_results` (BOOLEAN, default TRUE): Whether to format and display results for SHOW/DESCRIBE commands

**Features:**
- Validates DDL statement types
- Formats SHOW/DESCRIBE results as readable tables
- Handles up to 50 columns with auto-width calculation
- Returns execution status for non-query DDL
- Error handling with descriptive messages

**Output Format:**
- For SHOW/DESCRIBE: Formatted table with headers and data
- For other DDL: Success/failure message with statement

### 03_DML.sql
**Purpose:** Data Manipulation Language operations handler

**Procedure:** `EXECUTE_DML_PY`

**Description:**
Executes DML statements (SELECT, INSERT, UPDATE, DELETE, MERGE) with flexible output formatting options suitable for different consumers (human-readable, JSON for apps, summary for logs).

**Parameters:**
- `dml_statement` (STRING): The DML statement to execute
- `output_format` (STRING, default 'table'): Format options:
  - `'table'`: Human-readable table format
  - `'json'`: Structured JSON with metadata
  - `'summary'`: Brief execution summary

**Features:**
- Multi-format output support
- SELECT query result formatting with column width optimization
- Row count reporting
- Limits display to 100 rows (with indication of additional rows)
- JSON output includes statement metadata
- Error handling with descriptive messages

**Output Examples:**

**Table Format:**
```
Statement: SELECT * FROM users
Rows returned: 3

| id  | name     | email              |
|-----|----------|-------------------|
| 1   | John Doe | john@example.com  |
| 2   | Jane Doe | jane@example.com  |
```

**JSON Format:**
```json
{
  "statement": "SELECT * FROM users",
  "type": "SELECT",
  "row_count": 2,
  "data": [
    {"id": "1", "name": "John Doe", "email": "john@example.com"},
    {"id": "2", "name": "Jane Doe", "email": "jane@example.com"}
  ]
}
```

**Summary Format:**
```
SELECT executed successfully. Retrieved 2 rows.
```

## Usage Examples

### Setup
```sql
-- Run the entire setup script
-- This creates all necessary infrastructure
-- File: 01_SETUP.sql
```

### DDL Operations
```sql
-- Create a table
CALL EXECUTE_DDL_PY('CREATE TABLE test_table (id INT, name STRING)');

-- Show tables
CALL EXECUTE_DDL_PY('SHOW TABLES');

-- Describe a table with formatted output
CALL EXECUTE_DDL_PY('DESCRIBE TABLE test_table', TRUE);
```

### DML Operations
```sql
-- Query with table format
CALL EXECUTE_DML_PY('SELECT * FROM test_table', 'table');

-- Query with JSON format for application consumption
CALL EXECUTE_DML_PY('SELECT * FROM test_table', 'json');

-- Insert with summary
CALL EXECUTE_DML_PY('INSERT INTO test_table VALUES (1, ''Test'')', 'summary');
```

## Integration with Snowflake Intelligence

These tools are designed to work with Snowflake Intelligence features:

1. **Cortex Integration:** Formatted output suitable for AI model consumption
2. **Agent Compatibility:** JSON output format for agent-based workflows
3. **Error Handling:** Descriptive errors for debugging AI pipelines
4. **Performance:** Optimized for quick execution in AI workloads

## Security Notes

- All procedures validate input to prevent injection
- DDL procedure restricts to known DDL keywords
- DML procedure restricts to known DML operations
- Error messages are sanitized to avoid information leakage

## Best Practices

1. Use `output_format='json'` when integrating with applications
2. Use `output_format='table'` for human review
3. Use `show_results=FALSE` for bulk DDL operations
4. Always handle errors in calling code
5. Set appropriate warehouse size for expected workload