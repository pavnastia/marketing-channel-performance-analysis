-- 1. Table Structure and Volume

-- Preview the first 10 rows
SELECT * 
FROM `test.marketing_ads` 
LIMIT 10;

-- Count total rows, unique ads, and unique campaigns
SELECT 
  COUNT(*) AS rows_total, 
  COUNT(DISTINCT ad_id) AS unique_ads,
  COUNT(DISTINCT campaign_id) AS unique_campaigns
FROM `test.marketing_ads`;

-- Review field types using BigQuery Information Schema
SELECT column_name, data_type, is_nullable
FROM `test`.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'marketing_ads'
ORDER BY ordinal_position;

--2. Categorical Values and Record Distribution

-- Review advertising channels
SELECT
  source,
  COUNT(*) AS snapshot_count,
  COUNT(DISTINCT ad_id) AS unique_ads_count
FROM `test.marketing_ads`
GROUP BY 1
ORDER BY 2 DESC;

-- Estimate the average number of snapshots per ad per day
SELECT
  source,
  COUNT(*) / COUNT(DISTINCT CONCAT(ad_id, date)) AS avg_snapshots_per_ad_day
FROM `test.marketing_ads`
GROUP BY 1;

-- 3.  NULL Values, Technical Duplicates, and Cumulative Behavior

-- Check required fields for NULL values
SELECT
  COUNTIF(source IS NULL) AS null_source,
  COUNTIF(ad_id IS NULL) AS null_ad_id,
  COUNTIF(date IS NULL) AS null_date,
  COUNTIF(spend IS NULL) AS null_spend,
  COUNTIF(timestamp IS NULL) AS null_ts
FROM `test.marketing_ads`;

-- Search for technical duplicates:
-- two rows recorded for the same ad at the same date and timestamp
SELECT
  ad_id, date, timestamp,
  COUNT(*) AS cnt
FROM `test.marketing_ads`
GROUP BY 1, 2, 3
HAVING cnt > 1
LIMIT 20;

-- Check whether cumulative spend decreases within the same day
WITH lags AS (
  SELECT 
    ad_id, 
    date, 
    timestamp,
    spend,
    LAG(spend) OVER (PARTITION BY ad_id, date ORDER BY timestamp) AS prev_spend
  FROM `test.marketing_ads`
)

SELECT * FROM lags 
WHERE spend < prev_spend
LIMIT 20;

-- 4. Time Coverage

-- Identify the reporting period
SELECT
  MIN(date) AS first_report_date,
  MAX(date) AS last_report_date,
  DATE_DIFF(MAX(date), MIN(date), DAY) AS days_diff
FROM `test.marketing_ads`;

-- Review daily channel activity using raw cumulative snapshots
SELECT
  date,
  source,
  COUNT(DISTINCT ad_id) AS active_ads,
  MAX(spend) AS cumulative_spend_raw -- this is not actual daily spend
FROM `test.marketing_ads`
GROUP BY 1, 2
ORDER BY 1, 2;

-- 5. Numeric Validation

-- Basic spend statistics using the final snapshot for each ad and date
WITH daily_final AS (
  SELECT * EXCEPT(rn)
  FROM (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY ad_id, date ORDER BY timestamp DESC) as rn
    FROM `test.marketing_ads`
  ) WHERE rn = 1
)
SELECT
  source,
  MIN(spend) AS min_spend,
  MAX(spend) AS max_spend,
  AVG(spend) AS avg_spend,
  APPROX_QUANTILES(spend, 100)[OFFSET(50)] AS median_spend,
  SUM(registrations) / NULLIF(SUM(installs), 0) AS global_cr_install_to_reg
FROM daily_final
GROUP BY 1;

-- Search for negative spend and funnel logic violations
SELECT
  COUNTIF(spend < 0) AS negative_spend,
  COUNTIF(clicks > impressions) AS broken_ctr_logic,
  COUNTIF(registrations > installs) AS broken_cr_logic
FROM `test.marketing_ads`;
