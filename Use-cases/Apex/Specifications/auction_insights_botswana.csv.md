---
title: "auction_insights_botswana.csv"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# 📊 Data Spec: auction_insights_botswana.csv

This file powers the `auction_pressure_tracker.py` module inside Jarvis. It reveals competitive bidding dynamics across Botswana PPC campaigns.

---

## 🎯 PURPOSE

- Detect competitor incursions
- Rank by “Threat Score”
- Track overlap, outranking, and visibility losses over time

---

## 🧩 SOURCE

- **Platform**: Google Ads
- **Report Type**: **Auction Insights**
- **Scope**: **Ad Group** or **Keyword-level**
- **Filtered by**: Campaign name contains `"Botswana"`

---

## 📅 TIME RANGE & GRANULARITY

| Attribute     | Value      |
|---------------|------------|
| **Date Range**| **YTD**    |
| **Granularity** | **Daily** or **Weekly** (daily preferred for trend detection) |

---

## 📦 REQUIRED FIELDS

| Column Name             | Notes                                      |
|--------------------------|--------------------------------------------|
| `Date`                  | Needed for trend/volatility analysis       |
| `Campaign`              | Optional but helpful for debugging         |
| `Ad group`              | Optional                                   |
| `Keyword`               | Required if available                      |
| `Competitor Domain`     | Typically shown as "example.com"           |
| `Impression Share`      | % of available impressions seen by competitor |
| `Overlap Rate`          | % of auctions where both you and competitor appeared |
| `Position Above Rate`   | % of times competitor outranked you        |
| `Outranking Share`      | % of times you outranked the competitor    |

---

## 🔄 REFRESH SETTINGS

| Attribute     | Value              |
|---------------|--------------------|
| Frequency     | Daily              |
| Overwrite     | Yes (YTD snapshot) |
| Time          | 3AM–5AM GMT        |

---

## 📁 DESTINATION & FILE

- Output format: `.csv`
- Save as: `auction_insights_botswana.csv`
- Location: `/jarvis_botswana/data/`

---

## 🧠 Jarvis Uses This To:

- Score “Threat Level” by competitor
- Detect new entrants into auctions
- Explain CPC shifts due to pressure
- Track PPC market share trends over time

