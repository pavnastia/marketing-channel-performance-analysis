# Marketing Channel Performance Analysis

## Project Overview

This project analyzes advertising performance across three paid media channels: Meta, TikTok, and Google.

The source dataset contains 8,814 snapshot records and includes information about advertising channels, campaigns, ad sets, individual ads, reporting dates, advertising spend, impressions, clicks, app installs, registrations, and ETL load timestamps.

The advertising metrics are cumulative, and the dataset may contain several snapshots for the same ad and reporting date. Because of this structure, the raw values cannot be aggregated directly without overstating the results.

The main goal of this project is to practice SQL and BigQuery skills while exploring data quality, snapshot deduplication, cumulative-to-daily metric transformation, marketing funnel performance, customer acquisition cost, and channel economics.

## Documentation

Detailed project documentation is available in Notion in two languages:

* [Documentation in Ukrainian](https://app.notion.com/p/Marketing-Channel-Performance-Analysis-UA-382fe3d520048079a424e676692f5f56?source=copy_link)
* [Documentation in English](https://app.notion.com/p/Marketing-Channel-Performance-Analysis-ENG-382fe3d52004800eb9aed3d4a1f9d096?source=copy_link)

## Tools Used

* Google BigQuery
* SQL
* Notion

## Dataset Description

* **`source`** — advertising channel: Meta, TikTok, or Google
* **`campaign_id`** — unique campaign identifier
* **`adset_id`** — unique ad set identifier
* **`ad_id`** — unique ad identifier
* **`date`** — reporting date
* **`spend`** — cumulative advertising spend in USD
* **`impressions`** — cumulative number of ad impressions
* **`clicks`** — cumulative number of ad clicks
* **`installs`** — cumulative number of app installs
* **`registrations`** — cumulative number of registered users
* **`timestamp`** — UTC timestamp showing when the ETL process loaded the record

## Analysis Steps

### 1. Initial Data Audit

Reviewed the table structure, data types, record volume, missing values, duplicates, time coverage, and metric validity.

### 2. Data Cleaning

Kept the latest snapshot for each `ad_id` and `date`, then converted cumulative metrics into daily values using `LAG()`.

### 3. Daily Channel-Level Dataset

Aggregated the cleaned daily metrics by advertising channel and reporting date.

### 4. Marketing KPI Analysis

Calculated Total Spend, CPM, CTR, conversion rates, CAC, and LTV/CAC, then compared the performance of Meta, TikTok, and Google.


## Final Results

| Channel | Total Spend, USD | CPM, USD | CTR, % | Click-to-Install CR, % | Install-to-Registration CR, % | CAC, USD | LTV, USD | LTV/CAC |
| ------- | ---------------: | -------: | -----: | ---------------------: | ----------------------------: | -------: | -------: | ------: |
| Google  |        15,000.00 |    40.00 |   0.80 |                  36.96 |                         95.94 |    14.11 |    12.40 |    0.88 |
| Meta    |        50,000.00 |    14.00 |   1.20 |                  39.99 |                         93.98 |     3.10 |     6.20 |    2.00 |
| TikTok  |        15,000.00 |    22.00 |   1.50 |                  30.97 |                         87.97 |     5.39 |     8.50 |    1.58 |

## Main Insights

Meta is the most efficient channel in terms of acquisition cost. It has the lowest CAC at $3.10 per registered user and the strongest LTV/CAC ratio at 2.00.

The largest funnel drop-off occurs between click and app installation. Click-to-Install conversion ranges from approximately 31% to 40%, meaning that around 60–69% of users who click an ad do not proceed to install the app.

Meta also performs efficiently at the highest spend level. Despite having a substantially larger total budget, it maintains the lowest CAC, the lowest CPM, and the highest Click-to-Install conversion rate.

TikTok shows positive unit economics based on the available LTV/CAC estimate, although it is less efficient than Meta.

Google has the highest CAC and an LTV/CAC ratio below 1. Under the current conditions, the expected customer value does not fully cover the acquisition cost.

## Recommendations

* Gradually increase the Meta budget while monitoring CAC and conversion rates.
* Test new TikTok audiences, creatives, and messages to improve Click-to-Install conversion.
* Review Google campaign settings, targeting, keyword strategy, and traffic quality.
* Analyze the App Store and Google Play pages to identify potential post-click friction.
* Compare performance at the campaign, ad set, and individual ad levels.
