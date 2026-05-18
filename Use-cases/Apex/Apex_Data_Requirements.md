---
title: "Apex_Data_Requirements"
type: project
area: wilderness
project: "Wilderness"
status: active
---
To operate **Jarvis as a full-stack Paid Media Intelligence Engine**, we’d need to architect a **data backbone** with the following categories, sources, and formats — optimized for local processing and privacy.

---

## 🔧 CORE DATA REQUIREMENTS

|Category|Description|Primary Sources|Format Needed|
|---|---|---|---|
|**Ad Performance**|All account-level data from paid platforms|Google Ads, Meta Ads, TikTok, LinkedIn, DV360|CSV / JSON / API dumps|
|**Web Analytics**|User behavior & goal conversion across site|GA4, server logs, HubSpot, Hotjar|BigQuery exports, CSV, JSON|
|**CRM / Lead Funnel**|Lead status, sales outcomes, revenue attribution|HubSpot, Salesforce, Pipedrive, etc.|CSV / API|
|**Creative Assets**|All ads run (image/video/copy) w/ metadata|Manual folders, Meta Ad Library, naming logic|Folder with YAML/JSON manifest per asset|
|**Keyword Structures**|Campaign + ad group + keyword hierarchy|Google Ads exports, custom taxonomies|CSV / JSON|
|**Test Logs**|Past tests + performance + rationale|Manual notes, Obsidian, Airtable, Docs|Markdown / YAML / CSV|
|**Budget Plans**|Planned vs actual spend + pacing per channel|Excel, PM tools, media plans|CSV / JSON / Markdown|
|**UTM/Tracking Data**|UTM structures, click IDs, parameters, channel mappings|Ad platform URLs, GA4|CSV / Regex rules|
|**Competitor Ads**|Scraped ad copy/images/videos from top rivals|Meta Ad Library, PPC spy tools, Wayback|HTML, JSON, image/video assets|

---

## 🧠 OPTIONAL (but powerful) ADD-ONS

|Category|Purpose|Source|Use Case|
|---|---|---|---|
|**Creative Tags**|Hooks, angles, CTAs, emotions tagged per ad|Manual annotation or GPT tagging|Predicting creative fatigue/winners|
|**Audience Insights**|Who’s converting, by segment, by channel|Meta, Google, CRM export|Micro-funnel optimization|
|**Attribution Models**|Last click vs multi-touch revenue pathing|GA4, Segment, Rockerbox, custom|Spend shifting by true impact|
|**Geo Data**|Region/country-specific performance|Ad platforms + CRM + GA4|International scaling & holdouts|
|**Seasonality Curves**|Historical volume, cost, and ROAS curves by period|Ad platforms + external trends|Forecasting, budget allocation|
|**Voice-of-Customer**|Real customer language & objections|Surveys, reviews, sales calls|Ad copy and offer creation|

---

## 📂 HOW TO STORE IT LOCALLY FOR JARVIS

1. **Raw Data Lake** (flat files or folders)
    
    - `/data/ad_platform/google_ads/YYYY-MM-DD/`
        
    - `/data/crm/hubspot_leads.csv`
        
    - `/data/creative/manifest.yaml + assets/`
        
2. **Processed Indexes**
    
    - `/jarvis_index/creative_performance.json`
        
    - `/jarvis_index/keyword_clusters.json`
        
    - `/jarvis_index/conversion_paths.json`
        
3. **Jarvis Knowledge Memory**
    
    - Markdown or YAML logs of all campaign decisions, tests, and insights
        
    - Versioned: `/jarvis_memory/2025_Q1_test_log.md`
        

---

## 🚀 With This Data, Jarvis Could:

- Auto-pull best-performing copy for any funnel stage
    
- Alert on spend anomalies or rising CPCs before it hurts
    
- Identify creative fatigue before CTR drops
    
- Suggest next creative format based on fatigue curve
    
- Simulate CAC if Meta budget was reallocated to YouTube
    
- Auto-cluster keywords by intent and match types
    
- Build decks for board meetings based on latest data
    
- Compare your ROAS vs category benchmarks using scraped data