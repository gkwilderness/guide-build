---
title: "Supermetrics Export Configuration"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# ⚙️ Supermetrics Export Configuration — GUIDE (Botswana PPC)

This document defines the Supermetrics settings required to feed clean, consistent data into Jarvis for daily diagnostics across Botswana paid search.

---

## 📁 Export 1: Keyword Performance → `ads_data.csv`

### ✅ Settings

| Parameter               | Value                                      |
|-------------------------|--------------------------------------------|
| **Data Source**         | Google Ads                                 |
| **Report Type**         | Keyword Performance                        |
| **Filter**              | Campaign Name contains `"Botswana"`        |
| **Date Range**          | Year-to-Date (YTD)                         |
| **Granularity**         | Daily                                      |
| **Export Format**       | `.csv` or Google Sheet                     |
| **Refresh Frequency**   | Daily                                      |
| **Overwrite**           | Yes                                        |
| **Scheduled Time**      | 3AM–5AM GMT                                |

### 📊 Fields to Include

- `Date`
- `Campaign`
- `Ad group`
- `Keyword`
- `Match type`
- `Impressions`
- `Clicks`
- `Avg. CPC`
- `CTR`
- `Cost`
- `Conversions`
- `Conversion rate`
- `Search Lost IS (rank)`
- `Search Lost IS (budget)`
- `Quality Score` (if available)

### 📁 Output File

| File Name          | Path                                 |
|--------------------|--------------------------------------|
| `ads_data.csv`     | `/jarvis_botswana/data/ads_data.csv` |

---

## 📁 Export 2: Auction Insights → `auction_insights_botswana.csv`

### ✅ Settings

| Parameter               | Value                                      |
|-------------------------|--------------------------------------------|
| **Data Source**         | Google Ads                                 |
| **Report Type**         | Auction Insights (Ad group or Keyword level) |
| **Filter**              | Campaign Name contains `"Botswana"`        |
| **Date Range**          | Year-to-Date (YTD)                         |
| **Granularity**         | Daily or Weekly                            |
| **Export Format**       | `.csv` or Google Sheet                     |
| **Refresh Frequency**   | Daily                                      |
| **Overwrite**           | Yes                                        |
| **Scheduled Time**      | 3AM–5AM GMT                                |

### 📊 Fields to Include

- `Date`
- `Keyword` (if available)
- `Competitor Domain`
- `Impression Share`
- `Overlap Rate`
- `Position Above Rate`
- `Outranking Share`

### 📁 Output File

| File Name                       | Path                                           |
|--------------------------------|------------------------------------------------|
| `auction_insights_botswana.csv`| `/jarvis_botswana/data/auction_insights_botswana.csv` |

---

## 🛠️ Upload Notes

- Always export as UTF-8 CSV
- Save with consistent headers
- Drop into `/data/` folder manually or sync from GDrive/Sheets

---

## 🧠 Why This Matters

Jarvis reads these files nightly to:
- Detect missed opportunities
- Diagnose CPC shifts
- Track competitor movements
- Score clusters for growth actions

One clean export = hundreds of decisions automated.

