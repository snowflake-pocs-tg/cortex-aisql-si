-- Explore the actual metrics available in the Financial Institution Timeseries data
-- This will help us understand what questions the semantic view can answer

USE DATABASE FINANCE_ECONOMICS;
USE SCHEMA CYBERSYN;

-- 1. Get distinct variable names and their counts
SELECT 
    VARIABLE_NAME,
    COUNT(*) as record_count,
    MIN(DATE) as earliest_date,
    MAX(DATE) as latest_date,
    COUNT(DISTINCT ID_RSSD) as bank_count
FROM FINANCIAL_INSTITUTION_TIMESERIES
WHERE VALUE IS NOT NULL
  AND DATE >= '2020-01-01'
GROUP BY VARIABLE_NAME
ORDER BY record_count DESC
LIMIT 50;

-- 2. Check for the specific metrics mentioned in the semantic view
SELECT DISTINCT VARIABLE_NAME
FROM FINANCIAL_INSTITUTION_TIMESERIES
WHERE VALUE IS NOT NULL
  AND (
    VARIABLE_NAME ILIKE '%total%assets%'
    OR VARIABLE_NAME ILIKE '%return%on%average%assets%'
    OR VARIABLE_NAME ILIKE '%return%on%average%equity%'
    OR VARIABLE_NAME ILIKE '%net%interest%margin%'
    OR VARIABLE_NAME ILIKE '%efficiency%ratio%'
    OR VARIABLE_NAME ILIKE '%tier%1%capital%'
    OR VARIABLE_NAME ILIKE '%nonperforming%loans%'
    OR VARIABLE_NAME ILIKE '%total%deposits%'
    OR VARIABLE_NAME ILIKE '%total%loans%'
  )
ORDER BY VARIABLE_NAME;

-- 3. Sample actual data with values for specific banks
SELECT 
    b.NAME as BANK_NAME,
    b.STATE_ABBREVIATION,
    t.VARIABLE_NAME,
    t.VALUE,
    t.UNIT,
    t.DATE
FROM FINANCIAL_INSTITUTION_TIMESERIES t
JOIN FINANCIAL_INSTITUTION_ENTITIES b ON t.ID_RSSD = b.ID_RSSD
WHERE t.VALUE IS NOT NULL
  AND t.DATE >= '2023-01-01'
  AND b.IS_ACTIVE = TRUE
  AND b.CATEGORY = 'Bank'
  AND t.VARIABLE_NAME IN (
    SELECT VARIABLE_NAME
    FROM FINANCIAL_INSTITUTION_TIMESERIES
    WHERE VALUE IS NOT NULL
    GROUP BY VARIABLE_NAME
    HAVING COUNT(*) > 1000
    LIMIT 10
  )
LIMIT 100;

-- 4. Check available categories and specializations
SELECT 
    CATEGORY,
    SPECIALIZATION_GROUP,
    COUNT(*) as bank_count
FROM FINANCIAL_INSTITUTION_ENTITIES
WHERE IS_ACTIVE = TRUE
GROUP BY CATEGORY, SPECIALIZATION_GROUP
ORDER BY bank_count DESC;