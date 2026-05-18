---
title: "Development_Phases"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# Development Phases - 7-10 Day MVP

## Overview

Aggressive timeline to build PE-quality yield curve system for Nick demo. Working nights & weekends with AI assistance for maximum velocity.

## Success Criteria

- **Live demo ready** for Nick in 7-10 days
- **Portfolio overview** showing cross-business capital allocation opportunities
- **"Money left on table"** historical analysis (PE catnip)
- **Attribution triangulation** to validate current assumptions
- **Business-specific configurations** operational for teams

## Development Strategy

### AI-Assisted Development Stack

- **Claude Max:** Unlimited conversations for architecture & complex algorithms
- **PyCharm + Local AI:** Real-time code completion and debugging
- **Direct database access:** No API over-engineering, swap later when needed
- **Streamlit for UI:** Purpose-built for data dashboards, rapid development

### Risk Mitigation

- **Google Ads API first:** Start with API integration on Day 1 (biggest risk)
- **CSV backup plan:** Manual data export if API issues block progress
- **Incremental demos:** Daily progress validation with working components
- **Booking extrapolation:** Use lead-to-booking ratios vs waiting for full booking data

---

## Phase 1: Foundation (Days 1-2)

**Goal:** Data flowing from Google Ads into PostgreSQL with basic yield curve calculations

### Day 1: Data Pipeline

**Morning (4 hours):**

- PostgreSQL schema creation and migrations
- Business configuration setup (3 businesses with defaults)
- Google Ads API authentication and basic connection testing

**Evening (4 hours):**

- Google Ads data collectors for all 3 businesses
- Basic campaign and daily metrics ingestion
- Data validation and error handling

**Milestone:** Historical Google Ads data populating PostgreSQL tables

### Day 2: Core Analytics

**Morning (4 hours):**

- Campaign eligibility assessment with business-specific thresholds
- Basic yield curve calculation algorithms
- Cross-business efficiency scoring

**Evening (4 hours):**

- Attribution touchpoint data collection
- Multi-attribution model calculations (time-decay, position-based, linear, first/last touch)
- Database performance optimization with proper indexes

**Milestone:** Yield curves calculating correctly with real data

---

## Phase 2: PE Demo Features (Days 3-4)

**Goal:** Core dashboard pages that impress Nick with sophisticated analysis

### Day 3: Portfolio Overview Dashboard

**Morning (4 hours):**

- Streamlit app structure and navigation
- Page 0: System Overview (fancy README for demo context)
- Page 1: Portfolio Overview with cross-business yield curve comparisons

**Evening (4 hours):**

- Interactive filtering by business, date ranges
- Capital allocation efficiency scoring
- Reallocation recommendation calculations

**Milestone:** Portfolio dashboard showing all 3 businesses with yield curves

### Day 4: Money Left on Table Analysis

**Morning (4 hours):**

- Historical opportunity analysis algorithms
- Page 3: Money Left on Table dashboard (Nick catnip)
- 12-month default analysis with custom date range options

**Evening (4 hours):**

- Dollar-based metrics (American PE presentation)
- Lead and booking extrapolation calculations
- Executive summary visualizations for board presentations

**Milestone:** "Money left on table" analysis showing historical reallocation opportunities

---

## Phase 3: Attribution & Business Tools (Days 5-6)

**Goal:** Attribution triangulation and operational tools for marketing teams

### Day 5: Attribution Analysis

**Morning (4 hours):**

- Page 2: Attribution Analysis dashboard
- Multi-model comparison visualizations
- Attribution bias detection (validate 15% last-click advantage assumption)

**Evening (4 hours):**

- Attribution confidence scoring
- Model consistency analysis across businesses
- Custom attribution rules playground framework

**Milestone:** Attribution triangulation showing bias analysis across 6 models

### Day 6: Business Deep Dives

**Morning (4 hours):**

- Page 4: Business Deep Dives dashboard
- Campaign-level yield curve analysis
- Campaign grouping by tags (geography, keyword intent, etc.)

**Evening (4 hours):**

- Campaign exclusion management (brand campaigns with impression share bidding)
- Business-specific configuration interface
- Campaign restructure recommendations

**Milestone:** Operational tools ready for marketing team usage

---

## Phase 4: Campaign Management & Polish (Days 7-8)

**Goal:** Real-world campaign management features and demo preparation

### Day 7: Campaign Grouping & Filtering

**Morning (4 hours):**

- Flexible campaign tagging system implementation
- Geography vs keyword intent analysis ("botswana generics" vs "rwanda generics")
- Grouped yield curve calculations

**Evening (4 hours):**

- Campaign exclusion rules (automatic tagging for brand campaigns)
- Filter management interface
- Cross-business campaign comparison tools

**Milestone:** Campaign grouping operational with real marketing insights

### Day 8: Demo Preparation & Polish

**Morning (4 hours):**

- End-to-end testing with full data pipeline
- Performance optimization for demo responsiveness
- Error handling and edge case management

**Evening (4 hours):**

- Demo script preparation and flow testing
- Executive summary page polish
- Key metric definitions and methodology explanations

**Milestone:** Complete system ready for Nick demo

---

## Phase 5: Demo & Buffer (Days 9-10)

**Goal:** Demo readiness with contingency for unexpected issues

### Day 9: Demo Rehearsal

**Morning (4 hours):**

- Full demo run-through with realistic data
- Performance validation under demo conditions
- Backup data scenarios preparation

**Evening (4 hours):**

- Dashboard responsiveness optimization
- Key insight preparation (talking points for Nick)
- Alternative demo flows for different conversation directions

**Milestone:** Confident demo delivery capability

### Day 10: Contingency & Final Polish

**Morning (4 hours):**

- Buffer time for any critical issues discovered
- Final data validation and accuracy checks
- Demo environment preparation

**Evening (4 hours):**

- Last-minute polish based on full system testing
- Backup plans for potential demo issues
- Success metrics validation

**Milestone:** Production-ready demo system

---

## Daily Development Workflow

### 6-8 Hour Work Sessions

**Structure:**

- **4-hour morning block:** Deep work on core functionality
- **4-hour evening block:** Integration, testing, and polish
- **AI collaboration:** Continuous Claude/local AI assistance
- **Daily milestones:** Concrete deliverable each day

### AI Collaboration Strategy

**Claude Sessions:**

- Architecture decisions and complex algorithm design
- Code review and optimization suggestions
- Problem-solving for blocked issues
- Documentation and methodology validation

**Local AI (PyCharm):**

- Real-time code completion and debugging
- Syntax error resolution and quick fixes
- Refactoring and code organization
- Database query optimization

### Progress Tracking

**Daily Commits:**

- Functional code with working features
- Updated documentation with decisions made
- Demo script updates with new capabilities
- Issue log with solutions for future reference

## Critical Path Management

### Biggest Risks

1. **Google Ads API Integration:** Start Day 1, have CSV backup ready
2. **Data Quality Issues:** Build validation, start with 90-day windows if needed
3. **Performance Problems:** Direct DB access, optimize queries early
4. **Complex Attribution:** Start simple, add sophistication incrementally

### Success Dependencies

1. **Real campaign data** available from all 3 businesses
2. **Google Ads API credentials** configured and working
3. **PostgreSQL performance** adequate for dashboard responsiveness
4. **Streamlit deployment** working on demo machine

### Backup Plans

- **CSV data import** if Google Ads API problematic
- **Simplified attribution** if multi-model calculation too complex
- **Static screenshots** if live demo has technical issues
- **Pre-calculated results** if real-time calculation too slow

## Post-MVP Extension Planning

### Immediate Next Steps (Days 11-15)

- **Bing Ads integration** for Wilderness complete platform view
- **Alert framework implementation** with configurable triggers
- **Advanced grouping analytics** with statistical significance testing
- **Export functionality** for board presentation materials

### Future Roadmap (Weeks 3-4)

- **Multi-user access** with business-specific permissions
- **API development** when team growth requires it
- **Advanced attribution modeling** with machine learning
- **Automated budget recommendations** with confidence intervals

## Quality Assurance Strategy

### Testing Approach

- **Unit tests** for yield curve calculations
- **Integration tests** for Google Ads API data flow
- **Performance tests** for dashboard responsiveness under load
- **Demo scenario tests** for Nick presentation flow

### Data Validation

- **Historical data accuracy** vs Google Ads interface
- **Attribution calculation validation** vs known attribution tools
- **Cross-business comparison sanity checks**
- **Edge case handling** for low-volume campaigns

### Demo Readiness Checklist

- [ ] All 3 businesses showing data in portfolio view
- [ ] Historical "money left on table" calculations accurate
- [ ] Attribution bias analysis showing meaningful insights
- [ ] Campaign grouping working with real marketing scenarios
- [ ] System overview page explains methodology clearly
- [ ] Performance acceptable for live demo (sub-2 second page loads)
- [ ] Backup plans ready for potential technical issues
- [ ] Key talking points prepared for PE stakeholder engagement