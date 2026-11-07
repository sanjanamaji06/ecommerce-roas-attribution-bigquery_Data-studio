
# E-Commerce ROAS Optimization & Campaign Attribution Dashboard

[![BigQuery](https://img.shields.io/badge/Google_Cloud-BigQuery-blue?logo=googlecloud)](https://cloud.google.com/bigquery)
[![Looker Studio](https://img.shields.io/badge/Visualization-Looker_Studio-blue)](https://lookerstudio.google.com/)
[![SQL](https://img.shields.io/badge/Data-SQL_Aggregations-orange)](https://cloud.google.com/)

An end-to-end analytics project leveraging Google Cloud BigQuery and Looker Studio on the Google Analytics 4 (GA4) sample e-commerce dataset. The objective is to identify high-converting acquisition channels, evaluate cross-device conversion efficiency, and formulate data-driven budget allocation strategies to maximize Return on Ad Spend (ROAS).

---

## 📌 Executive Summary & Key Results
* **Data Scale:** Aggregated and evaluated **360,115 sessions** and **$362,165.00 in total revenue** across global traffic.
* **Top Channel Driver:** Identified Google Search/Organic as the primary revenue generator (**$104,831.00**, ~29% of gross revenue).
* **Device Asymmetry:** Desktop accounted for over **$210K+** of total revenue, whereas Mobile generated substantial traffic (~143K sessions) but exhibited lower conversion yield ($146.7K revenue).
* **Projected Impact:** Formulated a re-allocation strategy using device bid modifiers (+20% Desktop / -20% Mobile) projected to increase blended ROAS by **+18% to +24%** and cut wasted spend on under-converting segments.

---

## 📊 Dashboard Preview

![Executive Dashboard Overview](dashboard_screenshot.png)
*(Click [here](presentation_deck.pdf) to view the complete 3-slide executive presentation deck)*

---

## 🛠️ Tech Stack & Workflow
1. **Google Cloud BigQuery (SQL):** Extracted, cleaned, and aggregated event-level nested GA4 records.
2. **Looker Studio:** Modeled and deployed an executive dashboard showcasing core KPIs, source attribution tables with in-line bars, and device breakdowns.
3. **Strategic Marketing Analysis:** Derived actionable budget shifts and bid modifiers based on conversion rate and revenue distribution.

---

## 🔍 SQL Engineering Highlights
The raw GA4 dataset stores event parameters as nested arrays. The analysis required:
* **Unnesting Nested Records:** Extracted `ga_session_id` using `UNNEST(event_params)` paired with `user_pseudo_id` to establish distinct session tracking.
* **Attribution Standardization:** Cleaned traffic sources and media with `IFNULL()` to ensure zero unattributed traffic.
* **Conditional Metrics & Safe Arithmetic:** Applied conditional aggregation to isolate `purchase` events and calculated conversion rates with `SAFE_DIVIDE()` to prevent division-by-zero exceptions.

```sql
-- Sample of Core Aggregation Logic
SELECT 
  IFNULL(source, '(direct)') AS traffic_source,
  IFNULL(medium, '(none)') AS traffic_medium,
  device_category,
  COUNT(DISTINCT session_id) AS total_sessions,
  COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN session_id END) AS total_purchases,
  ROUND(
    SAFE_DIVIDE(
      COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN session_id END),
      COUNT(DISTINCT session_id)
    ) * 100, 2
  ) AS conversion_rate_pct,
  ROUND(SUM(CASE WHEN event_name = 'purchase' THEN event_value_in_usd ELSE 0 END), 2) AS total_revenue_usd
FROM session_data
GROUP BY 1, 2, 3;
