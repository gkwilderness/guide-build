---
tags: [capital-efficiency-cockpit, project-status, obsidian-log]
aliases: ["Cockpit System Status", "Yield Curve Project Snapshot"]
---

# 🧭 Capital Efficiency Cockpit — Project State Log

## ✅ Summary Snapshot

| Field | Description |
|---|---|
| **Project** | Capital Efficiency Cockpit (Yield Curve Analytics) |
| **Owner** | Gareth Knight |
| **Audience** | PE stakeholders (Nick), executive team, marketing ops |
| **MVP Duration** | 7–10 Days |
| **Development Style** | AI-assisted, solo dev with modular Python stack |
| **Current Phase** | 🚧 Phase 2 (PE Demo Features) |

...


## 🎯 Objectives

- High-leverage capital reallocation across Wilderness, Jacada, Yellow Zebra
    
- Detect yield breakouts, underperformance zones, slope changes
    
- Visualize campaign-level and portfolio-level marginal CPL trends
    
- Validate attribution assumptions with multi-model analysis
    
- Neutralize internal politics with hard math
    

---

## 🧠 Strategic Context

- **Wilderness** scaling B2C → 300 bookings/month target
    
- **Jacada** politically sensitive, high PPC risk exposure
    
- **Nick (PE)** needs reallocation clarity + board-level insights
    
- **Gareth** builds IP to permanently outperform competitors
    

---

## 🛠️ System Components

### Backend

- ✅ PostgreSQL time-series schema with JSONB config
    
- ✅ Celery workers for nightly data collection
    
- ✅ Redis task queue
    
- ⏳ FastAPI (planned post-MVP)
    

### ETL Modules

- ✅ `google_ads.py` — campaign + daily metrics
    
- ⏳ `bing_ads.py` — post-MVP, Wilderness only
    
- ⏳ `hubspot.py` / `ga4.py` — CRM + attribution enrichment
    

### Dashboard

- ✅ Streamlit MVP with 5-page architecture
    
    - Page 0: System Overview
        
    - Page 1: Portfolio Overview
        
    - Page 2: Attribution Analysis
        
    - Page 3: Money Left on Table
        
    - Page 4: Business Deep Dives
        

---

## 📊 Features Implemented

- ✅ Yield Curve Analysis (marginal CPL by spend bucket)
    
- ✅ Multi-Attribution Engine (6 models)
    
- ✅ Booking Extrapolation using lead-to-booking ratios
    
- ✅ Campaign Restructure Recommendations (data sufficiency)
    
- ✅ Exclusion Framework (brand + bid strategy rules)
    
- ✅ Configurable Business Thresholds (stored in DB)
    
- ✅ Portfolio-Level Opportunity Analysis
    
- ✅ Streamlit Config Editor (via dashboard)
    

---

## 🧩 Configuration Status

|Business|Min Spend|Min Conv|Booking Rate|Attribution Model|
|---|---|---|---|---|
|Wilderness|$500|3|0.11 (high)|time_decay (30d)|
|Jacada|$400|2|0.09 (medium)|time_decay (45d)|
|Yellow Zebra|$350|2|0.08 (est.)|position_based|

---

## 🔍 Outstanding Questions

(From `03_Active-Questions.md`)

### Technical

- Hosted vs local Postgres?
    
- Cron vs Airflow for orchestration?
    

### Data Integrity

- Offline bookings — can we validate CRM data fully?
    
- Lag between click → booking for long-tail campaigns?
    

### Attribution

- Should first vs last-click be split in Metabase by default?
    

### Governance

- Who has dashboard access at exec vs analyst level?
    
- Can we offer a redacted board version?
    

---

## ⚠️ Gaps / Missing Elements

1. **Current Phase Tracking** → AI context file missing live progress updates
    
2. **Metabase Integration Notes** → No config or SQL exports yet
    
3. **HubSpot / GA4 ETL** → Placeholder only, no schema or ingestion
    
4. **Testing / CI** → No pytest/coverage strategy documented
    
5. **Sharing Strategy** → No LICENSE.md or redacted export doc for board decks
    

---

## 📆 Development Milestones (from `Development_Phases.md`)

### Phase 1 ✅ (Foundation)

- Google Ads data in Postgres
    
- Yield curves and attribution logic working
    

### Phase 2 🚧 (PE Demo Features)

- Streamlit MVP pages active
    
- Efficiency scoring & reallocation working
    

### Phase 3+ ⏳ (Post MVP)

- Bing Ads
    
- Alerts (Z-score, slope drop)
    
- Attribution playground
    
- Export/share packs
    

---

## 📁 Suggested Next Files To Create

-  `hubspot.py` placeholder + schema map
    
-  `metabase/` folder with saved SQL
    
-  `tests/` folder with pytest starter
    
-  `docs/sharing.md` with IP protection guidance
    
-  `LICENSE.md` or README note on usage rights