---
title: "00_AI Project Brief — Capital Efficiency Cockpit"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# 📊 Project Brief — Capital Efficiency Cockpit

## 🎯 Purpose

Build a modular, intelligent data system that enables precision capital deployment decisions across paid marketing channels (Google Ads, Bing, Meta), CRM (HubSpot), and analytics (GA4). The system will:

- Track cost per booking, cost per lead, and capital yield trends over time
    
- Detect breakouts, underperformance, and inflection points
    
- Power real-time visualisation in Metabase for Wilderness and Jacada
    
- Replace bloated dashboards with slope-aware intelligence
    
- Create a performance governance layer across both brands
    

## 🧠 Strategic Framing

This system is not a reporting tool — it's a capital intelligence engine. It exists to:

- Shift capital faster than competitors
    
- Defend PPC strategy politically (Jacada)
    
- Unlock scale opportunities (Wilderness)
    
- Establish Gareth’s team as the most strategically mature digital operation in luxury travel
    

## 🛠️ Stack

- **Extract**: Python SDKs for Google Ads, HubSpot, GA4
    
- **Transform**: `pandas`, custom logic for rolling averages, z-scores, slope
    
- **Load**: PostgreSQL (Metabase-ready schema)
    
- **Visualise**: Metabase (time-series, yield curves, breakout alerts)
    

## 🔧 Module Prioritisation

|Priority|Module|Purpose|
|---|---|---|
|🔥 High|`google_ads.py`|Core spend vs outcome tracking|
|🔥 High|`metrics.py`|Cost per booking, slope, rolling avg|
|🔥 High|`load_to_postgres.py`|Persist data for Metabase views|
|✅ Med|`hubspot.py`|CRM-based outcome validation|
|✅ Med|`ga4.py`|Channel attribution shifts|
|💤 Low|`gsc.py`|Optional SEO layer|

## 📊 Visual Output

- Metabase dashboard: time-series CPL, CPB, yield slope
    
- Campaign breakout board: top gainers/losers by efficiency delta
    
- Cross-brand comparison: Wilderness vs Jacada performance overlay
    

## 🧬 Strategic Impact

- Politically neutralises performance bias
    
- Drives investor-grade capital allocation
    
- Aligns digital spend to real booking yield
    
- Creates strategic memory across campaigns over time
    

## 🔁 Execution Format

- All files delivered in markdown or Python
    
- CLI-run pipeline (`run_pipeline.py`) with config for credentials
    
- Outputs structured for ongoing evolution
    

> This cockpit becomes a legacy asset and potential moat. No other operator in luxury travel has it. Let’s build it right.