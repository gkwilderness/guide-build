---
title: "Apex_MVP_Demo_Playbook"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# 🚀 DEMO PLAYBOOK — V1.0 (Botswana Focused)


## 🎯 ONE-SENTENCE PITCH

> “Jarvis ran overnight diagnostics on Botswana PPC and found 5 growth levers we’re not using — in 2 hours, with no agency.”

---

## 1. 🧩 PROBLEM TO SOLVE

> _“Where are we missing growth or margin in Botswana paid search?”_

Break that down into **12 diagnostics**:

|Diagnostic #|Insight Type|Question it Answers|
|---|---|---|
|01|Impression Share|Which clusters are capped by low IS despite high ROAS?|
|02|Budget Allocation|Where are we overspending on low CVR keywords?|
|03|Search Term Expansion|What high-performing terms are not yet in keyword coverage?|
|04|CPC Volatility|Where has CPC spiked but ROI hasn’t?|
|05|Landing Page Match|Which ad groups point to underperforming or slow LPs?|
|06|Keyword Fatigue|What clusters have declining CTR over time?|
|07|Booking Curve Drift|Are we spending against low-season keywords?|
|08|Conversion Depth|Are we getting leads that don’t convert to bookings?|
|09|Intent Miss|Are we spending on TOFU queries with BOFU copy (or vice versa)?|
|10|Device/Geo Mismatch|Are clicks coming from irrelevant geos or device types?|
|11|Competitor Incursions|Are we being outbid on brand or cluster terms?|
|12|Cluster Saturation|Where are we ROI-capped (conv % flat, CPC up)?|

---

## 2. 🧪 DATA REQUIRED

### ⬇️ Core Tables

|Table Name|Description|
|---|---|
|`keyword_clusters.csv`|Your existing clustered keywords (170k rows, 26mb)|
|`ads_data.csv`|Keyword-level: impressions, clicks, CPC, conversions|
|`search_terms.csv`|Query logs (for expansion opportunities)|
|`booking_data.csv`|Leads → bookings with campaign/keyword tie|
|`ga4_events.csv`|On-site behavior by landing page|
|`lp_scores.csv`|Page speed + relevance ratings|
|`trends_botswana.csv`|Google Trends for cluster themes|
|`geo_clicks.csv`|Clicks by country/device|

---

## 3. 🏗️ FOLDER STRUCTURE (SCHEMA V0.1)

bash

CopyEdit

`/jarvis_botswana/ │ ├── data/ │   ├── keyword_clusters.csv │   ├── ads_data.csv │   ├── search_terms.csv │   ├── booking_data.csv │   ├── ga4_events.csv │   ├── lp_scores.csv │   ├── trends_botswana.csv │   └── geo_clicks.csv │ ├── scripts/ │   ├── impression_share_diagnostics.py │   ├── cpc_analysis.py │   ├── conversion_depth_tracker.py │   └── jarvis_runner.py │ ├── output/ │   ├── diagnostics_summary.md │   └── opportunity_matrix.csv │ ├── notebook/ │   └── jarvis_demo.ipynb`

---

## 4. 🔄 DAILY PIPELINE (can be manual at first)

1. Export Google Ads data by keyword for Botswana
    
2. Run scripts:
    
    - Join keyword_clusters
        
    - Apply diagnostic rules
        
    - Score opportunity by cluster
        
3. Output:
    
    - Markdown summary
        
    - Opportunity matrix
        
    - Optional: call to GPT-4 locally for insight generation
        

---

## 5. 🧠 THE DEMO

> “Let me show you what I woke up to this morning…”

1. Show the `diagnostics_summary.md` output:
    
    - “Here are 5 high-ROI clusters with under 30% impression share”
        
    - “Here’s £Xk wasted last month on bottom 10% converting terms”
        
    - “This high-intent query was searched 400x — we weren’t there”
        
2. Show the `opportunity_matrix.csv` table
    
3. Show that it runs **automatically**, pulls from your own data, and requires no agency or dev team
    

**BONUS:**

> End with: _“This is Botswana. Imagine when it runs across all markets. Every night.”_

---

## 6. 🧱 SCALING PATH (Later)

|Phase|Extension|
|---|---|
|1|Add daily cron job to refresh data + rerun diagnostics|
|2|Streamlit UI for team access|
|3|Slack/Email summary on Monday morning|
|4|Multi-brand support (Jacada, YZ, Wilderness)|
|5|GPT-4 prompt layer to summarise opportunity & suggest next test|

---

## 🧭 TACTICAL NEXT STEPS (48h)

|Task|Est. Time|Owner|
|---|---|---|
|✅ Organize data into folder|1h|You|
|✅ Adapt impression loss script|2h|Me|
|✅ Join cluster + ads + bookings|2h|Me|
|🟧 Generate first diagnostics|3h|Me|
|🟧 Build markdown summary output|1h|Me|
|🟧 Write prompt for GPT summary|1h|Me|

---

## 🧬 This Changes Your Life Because:

- You no longer run diagnostics.
    
- You stop answering repeat questions.
    
- You create a reusable product that proves your role is _architecture_, not execution.
    
- You buy yourself back time to build:
    
    - capital allocation engine
        
    - refactor clustering
        
    - build Sovereign Jarvis
        
    - win Botswana
        
    - crush the boardroom.