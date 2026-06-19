WITH daily_snapshots AS (
  SELECT * EXCEPT(rn)
  FROM (
    SELECT *,
      ROW_NUMBER() OVER (PARTITION BY ad_id, date ORDER BY timestamp DESC) AS rn
    FROM `test.marketing_ads`
  )
  WHERE rn = 1
),

cleaned_daily_metrics AS (
  SELECT
    source,
    date,
    COALESCE(spend - LAG(spend) OVER (PARTITION BY ad_id ORDER BY date ASC), spend) AS daily_spend,
    COALESCE(impressions - LAG(impressions) OVER (PARTITION BY ad_id ORDER BY date ASC), impressions) AS daily_impressions,
    COALESCE(clicks - LAG(clicks) OVER (PARTITION BY ad_id ORDER BY date ASC), clicks) AS daily_clicks,
    COALESCE(installs - LAG(installs) OVER (PARTITION BY ad_id ORDER BY date ASC), installs) AS daily_installs,
    COALESCE(registrations - LAG(registrations) OVER (PARTITION BY ad_id ORDER BY date ASC), registrations) AS daily_registrations
  FROM daily_snapshots
)

SELECT
  source,
  -- 1. Total spend
  ROUND(SUM(daily_spend), 2) AS total_spend,
  
  -- 2. CPM (Cost per 1,000 impressions)
  ROUND((SUM(daily_spend) / NULLIF(SUM(daily_impressions), 0)) * 1000, 2) AS cpm,
  
  -- 3. CTR (Percentage of impressions that resulted in clicks)
  ROUND((SUM(daily_clicks) / NULLIF(SUM(daily_impressions), 0)) * 100, 2) AS ctr,
  
  -- 4. CR Click -> Install
  ROUND((SUM(daily_installs) / NULLIF(SUM(daily_clicks), 0)) * 100, 2) AS cr_click_to_install,
  
  -- 5. CR Install -> Reg
  ROUND((SUM(daily_registrations) / NULLIF(SUM(daily_installs), 0)) * 100, 2) AS cr_install_to_reg,
  
  -- 6. CAC (Cost per registered user)
  ROUND(SUM(daily_spend) / NULLIF(SUM(daily_registrations), 0), 2) AS cac
FROM cleaned_daily_metrics
GROUP BY 1
ORDER BY total_spend DESC;
