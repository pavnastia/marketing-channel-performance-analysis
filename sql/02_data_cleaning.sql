WITH daily_snapshots AS (
  -- Keep one record: the latest snapshot for each ad and date
  SELECT * EXCEPT(rn)
  FROM (
    SELECT *,
      ROW_NUMBER() OVER (PARTITION BY ad_id, date ORDER BY timestamp DESC) AS rn
    FROM `test.marketing_ads`
  )
  WHERE rn = 1
),

cleaned_daily_metrics AS (
  -- Convert cumulative values into daily metrics
  SELECT
    source,
    campaign_id,
    adset_id,
    ad_id,
    date,
    timestamp,
    
    -- Calculate incremental daily spend
    COALESCE(spend - LAG(spend) OVER (PARTITION BY ad_id ORDER BY date ASC), spend) AS daily_spend,
    
    -- Calculate incremental daily impressions
    COALESCE(impressions - LAG(impressions) OVER (PARTITION BY ad_id ORDER BY date ASC), impressions) AS daily_impressions,
    
    -- Calculate incremental daily clicks
    COALESCE(clicks - LAG(clicks) OVER (PARTITION BY ad_id ORDER BY date ASC), clicks) AS daily_clicks,
    
    -- Calculate incremental daily installs
    COALESCE(installs - LAG(installs) OVER (PARTITION BY ad_id ORDER BY date ASC), installs) AS daily_installs,
    
    -- Calculate incremental daily registrations
    COALESCE(registrations - LAG(registrations) OVER (PARTITION BY ad_id ORDER BY date ASC), registrations) AS daily_registrations
  FROM daily_snapshots
)

-- Continue working with fully cleaned daily data
SELECT * FROM cleaned_daily_metrics
ORDER BY ad_id, date;
