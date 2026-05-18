---
title: "ads_data_spec"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# 📄 Data Spec: ads_data.csv

This is the **core input file** for the Jarvis diagnostic engine, used by multiple modules to analyze Botswana PPC campaign performance.

---

## 🎯 PURPOSE

- Feed real-time performance data into 12+ diagnostics
- Detect impression share gaps, CPC inflation, conversion drops
- Join with `keyword_clusters.csv` to power cluster-level insights

---

## 📁 FILE LOCATION

`/jarvis_botswana/data/ads_data.csv`

---

## 📅 TIME RANGE & GRANULARITY

| Attribute     | Value      |
|---------------|------------|
| **Date Range**| **YTD**    |
| **Granularity** | **Daily** |

Why?
- Needed for CTR/CVR decay, seasonality overlays, and lead-to-booking trails

---

## 📦 REQUIRED COLUMNS

| Column Name                 | Description                                             |
|-----------------------------|---------------------------------------------------------|
| `Date`                      | Campaign data date                                      |
| `Campaign`                  | Campaign name (filtered for "Botswana")                 |
| `Ad group`                  | Ad group name                                           |
| `Keyword`                   | Keyword text                                            |
| `Match type`                | Match type (broad, phrase, exact)                       |
| `Impressions`               | Daily impressions                                       |
| `Clicks`                    | Daily clicks                                            |
| `Avg. CPC`                  | Average cost-per-click (in £)                           |
| `CTR`                       | Click-through rate (%)                                  |
| `Cost`                      | Total cost (in £)                                       |
| `Conversions`               | Total conversions                                       |
| `Conversion rate`           | Conversions ÷ clicks (%)                                |
| `Search Lost IS (rank)`     | % of impressions lost due to ad rank                    |
| `Search Lost IS (budget)`   | % of impressions lost due to budget                     |
| `Quality Score` (if available) | Google-assigned keyword quality rating (1–10)        |

---

## 🛠️ FORMAT NOTES

- File type: `.csv`
- Encoding: UTF-8
- Decimal format: `.` (not `,`)
- Headers must match above names (case-sensitive)
- Missing values = blank or `0` (no `N/A` or `-`)

---

## 🧠 USED BY MODULES

| Module Name                      | Purpose                              |
|----------------------------------|--------------------------------------|
| `impression_share_diagnostics`   | Detect underexposed high-converting clusters |
| `cpc_analysis`                   | Track CPC volatility                 |
| `conversion_depth_tracker`       | Map cost-to-conversion efficiency    |
| `cluster_performance_tracker`    | Aggregate ROI per cluster            |
| `geo_click_analysis`             | Join with geo data to surface waste  |

---

## 🔄 REFRESH LOGIC

- Pull via Supermetrics every morning (3–5AM GMT)
- Overwrite previous version (YTD)
- Always save as `ads_data.csv`

---

## ✅ Sample Row

```
Date,Campaign,Ad group,Keyword,Match type,Impressions,Clicks,Avg. CPC,CTR,Cost,Conversions,Conversion rate,Search Lost IS (rank),Search Lost IS (budget),Quality Score
2025-05-27,Botswana | Luxury Camps,Safari Intent,"luxury okavango delta safari",Exact,164,24,3.12,14.63%,74.88,3,12.5%,65.4%,28.7%,9
```
