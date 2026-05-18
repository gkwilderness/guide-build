---
title: "00_Project-Brief"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# 🧭 Project Brief: Capital Deployment Cockpit

## 🎯 Objective
Build a modular data pipeline and visualisation layer that enables high-leverage capital allocation decisions across paid media channels (Google Ads, Bing, Meta), CRMs (HubSpot), and analytics (GA4), with a focus on:

- Identifying **growth pockets** and **underperformance zones**
- Tracking **cost per booking**, **trend velocity**, and **slope**
- Reallocating budget *before* performance decays
- Neutralising political ambiguity across Wilderness and Jacada

## 🧠 Strategic Context
- Wilderness is scaling B2C to 300+ bookings/month.
- Jacada carries political risk and higher PPC spend.
- Gareth operates at strategic altitude, prioritising velocity, yield, and clarity.
- No other luxury travel operator has a cockpit like this — this is IP, leverage, and legacy.

## 🏗️ Deliverables
1. Modular Python-based ETL pipeline (extract → transform → load)
2. PostgreSQL data layer with time-series schema
3. Metabase dashboard for trendlines, breakout detection, yield curves
4. Optional Streamlit CLI cockpit for internal use
5. Alerting system (e.g. Z-score triggers) for wasted capital or breakout growth

## 🔁 Workflow
- Build one module at a time (starting with Google Ads)
- Output in markdown + Python scripts
- Integrate into Obsidian + Metabase
- Test with Wilderness first, then roll to Jacada

## 🔗 Related Zettelkasten

- [[Z20250602-framing]] — "CapitalCore is our commercial OS — Apex is our frontline command layer"
- [[Z20250602-digital-capital-work-harder]] — "The engine that makes our capital work harder"
- [[Z20250602-system-importance]] — "The board would feel it before the team did"
- [[Z20250507-wilderness-cohorts]] — Use cohorts and time-series, not first/last click attribution
- [[Z20260326-lead-quality-over-volume]] — CapitalCore is the intelligence layer that enables LQS measurement
- [[Z20260326-compound-returns]] — Compounding capability is the goal — one-off optimisation is not enough
