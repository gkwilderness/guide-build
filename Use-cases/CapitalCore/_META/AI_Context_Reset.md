---
title: "AI_Context_Reset"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# AI Context Reset Template

## Quick Context Summary

**Project:** PE portfolio yield curve analytics system for capital allocation optimization  
**Timeline:** 7-10 day MVP for Nick (PE stakeholder) demo  
**Developer:** Solo CTO (former, rusty but competent) + AI assistance  
**Stack:** FastAPI, PostgreSQL, Streamlit, Docker on Ubuntu

## Business Context

- **3 Businesses:** Wilderness, Jacada, Yellow Zebra (PE-backed portfolio)
- **Current Metrics:** $40k deal value, $2k booking target, $350 CPL, 180-day sales cycles
- **Goal:** Impress Nick with sophisticated mathematical approach to budget reallocation
- **Data Sources:** Google Ads (MVP), Bing Ads (post-MVP for Wilderness)

## Key Architectural Decisions Made

### 1. No API Over-Engineering (CTO Decision)

- **Direct database access** for MVP - swap to API calls when actually needed
- **Rationale:** Faster development, simpler debugging, better performance at current volumes
- **Future:** Easy migration path when team growth requires API

### 2. Business-Specific Configuration

- **Each business is different** - config tables with JSON flexibility
- **Convention over configuration** - sensible defaults, business overrides available
- **Examples:** Different booking conversion rates, yield curve thresholds, attribution preferences

### 3. Flexible Campaign Grouping

- **Tag-based system:** geography, keyword_intent, product, channel tags
- **Real-world analysis:** "botswana generics" vs "rwanda generics" comparisons
- **Grouped yield curves** for more realistic portfolio analysis

### 4. Campaign Filtering System

- **Exclusion rules:** Brand campaigns with impression share bidding excluded from yield curves
- **Automatic tagging:** Business rules for campaign exclusions
- **Manual overrides:** Individual campaign exclusion management

### 5. Multi-Attribution Triangulation

- **6 attribution models:** time_decay, position_based, linear, first_touch, last_touch, custom_rules
- **Bias detection:** Validate assumption that last-click has 15% more attribution than first-click
- **Custom playground:** Framework for MMM evolution and attribution experimentation

### 6. Booking Extrapolation

- **Limited booking data:** Not all businesses have booking data in Google Ads
- **Lead-to-booking ratios:** Business-specific conversion rates for estimation
- **American presentation:** All metrics in dollars, not pounds

## Current Development Phase

**Phase:** [UPDATE THIS - which phase you're currently in]  
**Days Completed:** [UPDATE THIS - how many days into development]  
**Last Milestone:** [UPDATE THIS - what was last completed]  
**Current Task:** [UPDATE THIS - specific task for this AI session]

## Active Development Status

**Recently Completed:**

- [UPDATE THIS - what was finished in last session]

**Current Blockers:**

- [UPDATE THIS - any issues encountered]

**Next Priority:**

- [UPDATE THIS - what needs to happen next]

## Database Schema Status

**Core Tables:** businesses, campaigns, daily_metrics, yield_analysis ✓  
**Attribution:** conversions, attribution_touchpoints, attribution_results ✓  
**Grouping:** campaign_tags, tag_definitions, campaign_exclusions ✓  
**Config:** business_config, campaign_restructure_recommendations ✓  
**Alerts:** alert_definitions, alert_events (post-MVP) ⏳

## Dashboard Pages Status

- **Page 0:** System Overview (Fancy README) - [STATUS]
- **Page 1:** Portfolio Overview (Board deck gold) - [STATUS]
- **Page 2:** Attribution Analysis (Research tool) - [STATUS]
- **Page 3:** Money Left on Table (Nick catnip) - [STATUS]
- **Page 4:** Business Deep Dives (Operational tool) - [STATUS]

## Business Configurations Set

**Wilderness (ID: 1):**

- min_spend_usd: 500, min_conversions: 3, booking_rate: 0.11
- attribution: time_decay (30d half-life)

**Jacada (ID: 2):**

- min_spend_usd: 400, min_conversions: 2, booking_rate: 0.09
- attribution: time_decay (45d half-life)

**Yellow Zebra (ID: 3):**

- min_spend_usd: 350, min_conversions: 2, booking_rate: 0.08
- attribution: position_based

## Code Standards Established

- **Python:** Snake_case, descriptive variables, business prefixes (wilderness_, jacada_, yellowzebra_)
- **Architecture:** Repository pattern, service layer, DTO boundaries
- **Error Handling:** Structured logging, custom exceptions, graceful degradation
- **Database:** Direct access with connection pooling, prepared statements
- **Testing:** Unit tests for calculations, integration tests for APIs, mock external services

## Key Algorithms Implemented

**Yield Curve Calculation:**

- Statistical significance gating (minimum spend/conversions before curve generation)
- Spend bucketing with marginal CPL calculation
- Cross-business efficiency scoring
- Campaign restructure recommendations for insufficient data

**Attribution Processing:**

- Multi-model calculation in single batch job
- Time-decay with configurable half-life
- Attribution weight normalization and storage
- Bias analysis across model results

## Current Task Context

**Immediate Deliverable:** [SPECIFY WHAT YOU NEED FROM THIS AI SESSION]

**Expected Output Format:** [CODE/DOCUMENTATION/ANALYSIS/etc.]

**Constraints:**

- MVP focus - build what impresses Nick, extend what teams need
- Direct database access - no API complexity
- Business-specific flexibility with sensible defaults
- 7-10 day timeline pressure

**Files to Reference:**

- system-architecture.md
- database-schema.md
- development-phases.md
- [Any other relevant docs]

## Context for AI Assistance

**What's Working Well:**

- [UPDATE - what's going smoothly]

**What Needs Problem-Solving:**

- [UPDATE - specific technical challenges]

**Decision Points:**

- [UPDATE - any architectural decisions needed]

**Integration Points:**

- [UPDATE - how current work connects to existing components]

---

## Template Usage Instructions

1. **Update Phase Status** before each AI session
2. **Copy relevant sections** to new chat context
3. **Specify immediate deliverable** clearly
4. **Reference completed work** to avoid duplication
5. **Track decisions made** for consistency across sessions

## Session Handoff Template

After each AI session, update:

- **Current Phase** progress
- **Completed deliverables**
- **Decisions made**
- **Next session priorities**
- **Code changes** committed