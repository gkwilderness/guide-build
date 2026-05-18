---
title: "README"
type: reference
area: wilderness
project: "Wilderness"
status: active
---
# Yield Curve Analytics System

## Executive Summary

**Private Equity Portfolio Optimization Platform** for sophisticated capital allocation across Google Ads campaigns. Built for luxury travel companies with high-value, long-cycle sales processes.

**Target Audience:** PE stakeholders, portfolio company executives, and marketing teams requiring mathematical rigor in budget allocation decisions.

## Business Problem

### The Capital Allocation Challenge

PE-backed portfolio companies struggle with optimal capital allocation across marketing channels due to:

- **Attribution Complexity:** 180-day consideration cycles with multiple touchpoints
- **Cross-Business Comparison:** Different markets, deal values, and conversion rates
- **Yield Curve Blindness:** Linear budget thinking vs. marginal efficiency analysis
- **Historical Opportunity Loss:** "Money left on table" from suboptimal allocation

### Current State: Portfolio Overview

|Business|Monthly Revenue|Booking Value|Current CPL|Booking Rate|
|---|---|---|---|---|
|**Wilderness**|$3.68M|$40,000|$350|11%|
|**Jacada**|$2.1M|$25,000|$280|9%|
|**Yellow Zebra**|$1.8M|$18,000|$310|8%|

**Problem:** Marketing teams optimize campaigns in isolation. PE oversight lacks visibility into cross-business reallocation opportunities.

## Solution: Mathematical Capital Allocation

### Core Innovation: Yield Curve Analysis

**Traditional Approach:**

- Linear budget allocation based on historical spend
- Campaign-level optimization without portfolio view
- Attribution assumptions without triangulation

**Our Approach:**

- **Marginal CPL curves** showing efficiency zones across spend levels
- **Cross-business efficiency scoring** for capital reallocation
- **Multi-attribution triangulation** (6 models) for assumption validation

### Key Capabilities

#### 1. Portfolio Overview Dashboard

- Cross-business yield curve comparisons
- Capital allocation efficiency scoring
- Reallocation recommendations with projected ROI

#### 2. Attribution Analysis Engine

- 6 attribution models: time-decay, position-based, linear, first/last-touch, custom
- Bias detection and model consistency analysis
- Long-cycle attribution (180-day windows) for luxury travel

#### 3. Historical Opportunity Analysis

- "Money left on table" calculations across 12+ months
- Dollar-impact quantification for PE presentations
- Booking extrapolation using business-specific conversion rates

#### 4. Campaign Intelligence Platform

- Flexible campaign grouping: geography × keyword intent analysis
- Automated exclusion rules (brand campaigns, impression share bidding)
- Campaign restructure recommendations for insufficient data

#### 5. Business-Specific Configuration

- Individual thresholds: minimum spend, conversions, analysis periods
- Attribution preferences: decay rates, model weights, custom rules
- Booking conversion rates with confidence scoring

## Technical Architecture

### Design Philosophy

**"No API Over-Engineering"** - Direct database access for MVP speed, API migration path ready when team scales.

**Business-Agnostic Core** - Multi-tenant architecture supporting unlimited portfolio companies.

**Configuration-Driven** - Business rules externalized, no code changes for operational adjustments.

### Technology Stack

```
Google Ads API → PostgreSQL → Streamlit Dashboard
                    ↑
              Celery Workers
                    ↑
              Redis Task Queue
```

**Backend:**

- **FastAPI** (Python) - Rapid development with auto-documentation
- **PostgreSQL** - Time-series optimization, JSONB flexibility
- **Celery + Redis** - API rate limit handling, batch processing

**Frontend:**

- **Streamlit** - Purpose-built for data dashboards
- **Plotly** - Interactive yield curve visualizations
- **Pandas** - Data manipulation and analysis

**Infrastructure:**

- **Docker** - Containerized deployment
- **nginx** - Reverse proxy with SSL
- **Ubuntu** - Cloud server deployment

### Data Processing Pipeline

```
1. Google Ads API Collection (Nightly batch)
   ↓
2. Data Validation & Business Rule Application
   ↓
3. Campaign Eligibility Assessment
   ↓
4. Yield Curve Calculations
   ↓
5. Multi-Attribution Processing
   ↓
6. Cross-Business Analysis & Recommendations
   ↓
7. Dashboard Data Preparation
```

## Dashboard Structure

### Page 0: System Overview

**Audience:** PE stakeholders, new users **Purpose:** Methodology explanation and business context

### Page 1: Portfolio Overview

**Audience:** PE/executive leadership  
**Purpose:** Cross-business capital allocation decisions

- Yield curve comparisons
- Efficiency scoring matrix
- Reallocation recommendations

### Page 2: Attribution Analysis

**Audience:** Analytics teams, consultants **Purpose:** Attribution assumption validation

- Multi-model comparison
- Bias detection analysis
- Custom attribution playground

### Page 3: Money Left on Table

**Audience:** PE stakeholders (board presentations) **Purpose:** Historical opportunity quantification

- 12-month reallocation analysis
- Dollar impact calculations
- Booking extrapolation scenarios

### Page 4: Business Deep Dives

**Audience:** Marketing teams, operational management **Purpose:** Campaign-level optimization

- Individual business analysis
- Campaign grouping and filtering
- Restructure recommendations

## Business Applications

### For PE Stakeholders

**Investment Thesis Validation:**

- Mathematical proof of marketing efficiency opportunities
- Cross-portfolio optimization potential quantification
- Historical performance analysis for due diligence

**Board Presentation Materials:**

- Dollar-impact reallocation recommendations
- Risk-adjusted ROI projections
- Portfolio-level KPI tracking

### For Portfolio Companies

**Marketing Team Empowerment:**

- Campaign restructure recommendations
- Attribution bias detection
- Performance benchmarking across businesses

**Executive Decision Support:**

- Budget allocation optimization
- Market expansion analysis (geography × intent)
- Consultant performance evaluation

## ROI Projections

### Conservative Estimates (Based on Historical Data)

**Portfolio-Level Improvements:**

- **15-25% efficiency gain** through optimal capital allocation
- **$2-3M annual impact** across 3-business portfolio
- **6-month payback period** on development investment

**Business-Specific Opportunities:**

- **Wilderness:** $400k annual improvement via attribution optimization
- **Jacada:** $350k via campaign restructuring recommendations
- **Yellow Zebra:** $280k via cross-business best practice application

## Development Timeline

### MVP Phase (7-10 Days)

- [x] Data pipeline architecture
- [x] Database schema with multi-business support
- [x] Core yield curve algorithms
- [x] Attribution engine (6 models)
- [ ] Streamlit dashboard (5 pages)
- [ ] Google Ads API integration
- [ ] Demo environment preparation

### Post-MVP Extensions (Weeks 3-4)

- Bing Ads integration (Wilderness complete platform view)
- Alert framework with configurable triggers
- Advanced statistical significance testing
- Export functionality for board presentations

## Getting Started

### Local Development Setup

```bash
# Clone repository
git clone [repository-url]
cd yield-curve-system

# Environment setup
cp .env.template .env.local
# Edit .env.local with Google Ads API credentials

# Docker deployment
docker-compose up -d

# Access dashboard
open http://localhost:8501
```

### Production Deployment

```bash
# Server setup (Ubuntu)
./scripts/setup_production.sh

# Deploy application
./scripts/deploy_prod.sh

# Configure SSL
./scripts/setup_ssl.sh your-domain.com
```

## Configuration Management

### Business Setup Example

```python
# Wilderness configuration
{
    "yield_curve_thresholds": {
        "min_spend_usd": 500,
        "min_conversions": 3,
        "min_days": 30
    },
    "booking_conversion_rate": {
        "rate": 0.11,
        "confidence": "high"
    },
    "attribution_preferences": {
        "default_model": "time_decay",
        "decay_half_life": 30
    }
}
```

### Campaign Exclusion Rules

```python
# Automatic exclusions
{
    "campaign_name_contains": ["brand", "trademark"],
    "bid_strategy_equals": ["target_impression_share"],
    "exclusion_reason": "Brand impression share campaigns"
}
```

## Technical Specifications

### System Requirements

- **Minimum:** 2 vCPU, 4GB RAM, 20GB storage
- **Recommended:** 4 vCPU, 8GB RAM, 40GB storage
- **Database:** PostgreSQL 15+ with time-series optimization

### API Integration Limits

- **Google Ads API:** Rate limit handling via Celery queue
- **Data Refresh:** Nightly batch processing
- **Attribution Window:** 180 days (configurable per business)

### Performance Targets

- **Dashboard Response:** Sub-2 second page loads
- **Data Processing:** 99%+ reliability for nightly jobs
- **Attribution Processing:** 100k touchpoints per business

## Security & Compliance

### Data Protection

- API credentials stored in environment variables
- Database access via connection pooling
- No external API exposure (internal-only access)

### Business Data Isolation

- Multi-tenant architecture with business-level security
- Configuration isolation per business
- Audit trails for all configuration changes

## Support & Maintenance

### Monitoring

- Automated health checks for all services
- Performance monitoring with alerting
- Data quality validation and error reporting

### Backup Strategy

- Daily automated database backups
- 7-day retention policy
- Point-in-time recovery capability

## Future Roadmap

### SaaS Platform Evolution

- **Multi-tenant SaaS architecture**
- **Self-service business onboarding**
- **Advanced ML attribution models**
- **API ecosystem for third-party integrations**

### Market Expansion

- **Additional ad platforms** (Facebook, Microsoft, etc.)
- **E-commerce attribution models**
- **Cross-channel attribution (email, organic, direct)**
- **Predictive budget optimization**

---

## Contact & Support

**Development Team:** [Your contact information]  
**Documentation:** See `/docs` directory for detailed technical specifications  
**Issues:** Use GitHub issues for bug reports and feature requests

---

_Built for PE portfolio optimization with mathematical rigor and operational practicality._