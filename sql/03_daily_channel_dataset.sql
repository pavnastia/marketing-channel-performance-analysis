WITH daily_snapshots AS (
  SELECT * EXCEPT(rn)
  FROM (
    SELECT *,
      ROW_NUMBER() OVER (PARTITION BY ad_id, date ORDER BY timestamp DESC) AS rn
    FROM `test.marketing_ads`
  )
  WHERE rn = 1
),

cleaned_metrics AS (
  SELECT
    source,
    date,
    ad_id,
    -- Calculate daily metrics separately for each ad_id
    COALESCE(spend - LAG(spend) OVER (PARTITION BY ad_id ORDER BY date ASC), spend) AS new_spend,
    COALESCE(impressions - LAG(impressions) OVER (PARTITION BY ad_id ORDER BY date ASC), impressions) AS new_impressions,
    COALESCE(clicks - LAG(clicks) OVER (PARTITION BY ad_id ORDER BY date ASC), clicks) AS new_clicks,
    COALESCE(installs - LAG(installs) OVER (PARTITION BY ad_id ORDER BY date ASC), installs) AS new_installs,
    COALESCE(registrations - LAG(registrations) OVER (PARTITION BY ad_id ORDER BY date ASC), registrations) AS new_registrations
  FROM daily_snapshots
)

-- Aggregate the cleaned daily data by source and date
SELECT
  source,
  date,
  SUM(new_spend) AS daily_spend,
  SUM(new_impressions) AS daily_impressions,
  SUM(new_clicks) AS daily_clicks,
  SUM(new_installs) AS daily_installs,
  SUM(new_registrations) AS daily_registrations
FROM cleaned_metrics
GROUP BY source, date
ORDER BY date, source;
