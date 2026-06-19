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

## Dataset

* Source: CSV file
* Source file: `marketing_ads_raw.csv`
* BigQuery table: `test.marketing_ads`
* Total records: 8,814
* Date range: 2024-01-02 to 2024-07-14
* Advertising channels: 3
* Unique ads: 10
* Unique campaigns: 6

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

### 1. Dataset Structure

I started by reviewing the table structure, checking column data types, and measuring the overall data volume.

Key findings:

* The dataset contains 8,814 rows.
* There are 10 unique ads and 6 advertising campaigns.
* The schema contains all expected identifiers, dates, timestamps, and marketing metrics.
* Numeric fields use appropriate BigQuery data types.

### 2. Categorical Value Analysis

I analyzed advertising channels, record distribution, and the number of unique ads by source.

Key findings:

* The dataset contains three expected channels: Meta, TikTok, and Google.
* No spelling inconsistencies or unexpected channel values were found.
* Meta has the largest number of records and 4 unique ads.
* TikTok and Google each contain 3 unique ads.
* Each ad has approximately 4.5 snapshots per reporting date on average.

### 3. Data Quality Check

I checked missing values, exact technical duplicates, and the cumulative behavior of advertising spend.

Key findings:

* No missing values were found in the checked key fields.
* No exact duplicates were found for the same ad, date, and timestamp.
* Cumulative spend does not decrease between consecutive snapshots within the same day.
* Multiple records for the same ad and date are expected snapshots rather than exact duplicates.

### 4. Time Range Analysis

I reviewed the reporting period and advertising activity across the available dates.

Key findings:

* The dataset covers the period from January 2, 2024, to July 14, 2024.
* The reporting period contains 195 calendar days inclusive.
* All three advertising channels are represented during the analyzed period.
* Raw cumulative spend cannot be interpreted as actual daily spend before data transformation.

### 5. Numerical Field Validation

I checked advertising spend and funnel metrics for negative values and logical inconsistencies.

The expected funnel relationship is:

`impressions ≥ clicks ≥ installs ≥ registrations`

Key findings:

* No negative values were found in advertising spend.
* No records were found where clicks exceeded impressions.
* No records were found where registrations exceeded installs.
* Mean and median spend values are close and do not indicate strong distribution skewness.

### 6. Snapshot Deduplication

For every combination of `ad_id` and `date`, I retained the latest available snapshot according to `timestamp`.

This prevents intermediate intraday snapshots from being counted more than once.

### 7. Daily Metric Calculation

I converted cumulative values into daily metrics using the `LAG()` window function.

The transformation was applied to:

* spend;
* impressions;
* clicks;
* installs;
* registrations.

The resulting dataset contains daily performance metrics for each individual ad.

### 8. Channel-Level Aggregation

The cleaned daily metrics were aggregated by advertising channel and reporting date.

Each row in the resulting dataset represents the daily performance of one channel and includes:

* daily spend;
* daily impressions;
* daily clicks;
* daily installs;
* daily registrations.

### 9. Marketing KPI Calculation

I calculated the following marketing KPIs for each channel:

* Total Spend
* CPM
* CTR
* Click-to-Install Conversion Rate
* Install-to-Registration Conversion Rate
* CAC
* LTV/CAC

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

TikTok remains economically viable because its LTV/CAC ratio is above 1, although it is less efficient than Meta.

Google has the highest CAC and an LTV/CAC ratio below 1. Under the current conditions, the expected customer value does not fully cover the acquisition cost.

## Recommendations

* Gradually increase the Meta budget while monitoring CAC and conversion rates.
* Test new TikTok audiences, creatives, and messages to improve Click-to-Install conversion.
* Review Google campaign settings, targeting, keyword strategy, and traffic quality.
* Analyze the App Store and Google Play pages to identify potential post-click friction.
* Compare performance at the campaign, ad set, and individual ad levels.
