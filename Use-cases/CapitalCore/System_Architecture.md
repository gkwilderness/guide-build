---
title: "System_Architecture"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# System Architecture

## Overview

PE-backed yield curve analytics system for optimizing capital allocation across 3 businesses (Wilderness, Jacada, Yellow Zebra) using Google Ads performance data and sophisticated attribution modeling.

## Business Context

- **Target:** Impress PE stakeholder "Nick" with mathematical rigor in budget allocation
- **Timeline:** 7-10 day MVP for live demo
- **Scope:** Google Ads initially, Bing integration post-MVP
- **Deal Economics:** $40k deal value, $2k booking target, $350 current CPL, 180-day consideration cycles

## System Architecture

### Core Principles

1. **No API Over-Engineering:** Direct database access, swap to API when actually needed
2. **Business-Specific Configuration:** Each business has unique characteristics and config
3. **Flexible Campaign Grouping:** Tag-based system for real-world analysis needs
4. **Multi-Attribution Triangulation:** Multiple models for bias detection and validation
5. **MVP-Focused:** Build what impresses Nick, extend what teams need operationally

### Technology Stack

```
Google Ads API → PostgreSQL → Streamlit Dashboard
                    ↑
             Nightly Batch Jobs
```

**Core Technologies:**

- **Backend:** FastAPI (Python) - rapid development, auto-docs
- **Database:** PostgreSQL - time-series optimization, mature ecosystem
- **Frontend:** Streamlit - purpose-built for data dashboards
- **Task Queue:** Celery with Redis - handle API rate limits
- **Deployment:** Docker + nginx on Ubuntu cloud server

### System Components

#### 1. Data Ingestion Layer

- **Business-specific collectors** for each Google Ads account
- **Batch ETL processes** with overnight refresh cycles
- **API rate limit handling** via Celery task queue
- **Data validation and cleaning** with error logging

#### 2. Analytics Engine

- **Yield curve calculations** with business-specific thresholds
- **Multi-attribution modeling** (6 different models)
- **Campaign grouping and filtering** via flexible tag system
- **Cross-business efficiency analysis** for capital allocation

#### 3. Configuration Management

- **Business-specific settings** stored in PostgreSQL JSONB
- **Convention over configuration** with sensible defaults
- **Runtime configuration updates** via Streamlit interface
- **Audit trail** for all configuration changes

#### 4. Dashboard Layer

- **5 main pages** for different audiences (Nick, board, operational teams)
- **Direct database access** for performance at current volumes
- **Interactive filtering and grouping** for analysis flexibility
- **Export capabilities** for board presentations

#### 5. Alert Framework (Post-MVP)

- **Event-driven alert system** with configurable triggers
- **Hook-based architecture** for extensible alert types
- **Multi-channel notifications** (email, Slack, etc.)

## Data Flow

### Primary Data Pipeline

```
1. Google Ads API Collection (Nightly)
   ↓
2. Data Validation & Cleaning
   ↓  
3. Campaign Eligibility Assessment
   ↓
4. Yield Curve Calculations
   ↓
5. Attribution Model Processing
   ↓
6. Cross-Business Analysis
   ↓
7. Dashboard Data Preparation
```

### Business Logic Flow

```
Raw Metrics → Eligibility Check → Yield Curves → Attribution → Recommendations
     ↓              ↓               ↓            ↓             ↓
Configuration → Thresholds →  Grouping → Models → Reallocation
```

## Scalability Considerations

### Current MVP Constraints

- **3 businesses only** - designed for easy extension
- **Google Ads only** - platform-agnostic data model ready for Bing
- **Direct database access** - can swap to API calls when needed
- **Single server deployment** - Docker-ready for multi-server scaling

### Post-MVP Extension Points

- **Additional businesses** - configuration-driven onboarding
- **Multiple ad platforms** - existing data model supports it
- **Real-time processing** - batch job architecture easily extended
- **Advanced analytics** - ML model integration points identified

## Security & Maintenance

### Data Security

- **API credentials** stored in environment variables
- **Database access** via connection pooling and prepared statements
- **No external API exposure** in MVP - internal access only

### Maintenance Strategy

- **Modular architecture** for independent component updates
- **Comprehensive logging** for debugging and monitoring
- **Configuration management** for business rule changes
- **Database migrations** for schema evolution

## Development Approach

### AI-Assisted Development Strategy

- **Claude for architecture and complex algorithms**
- **Local AI tools for real-time debugging**
- **Direct database access** eliminates API complexity
- **Streamlit for rapid UI development**

### Quality Assurance

- **Business-specific testing** with real campaign structures
- **Attribution model validation** across multiple approaches
- **Performance testing** with expected data volumes
- **Demo scenario preparation** for PE presentation

## Success Metrics

### Technical Success

- **Sub-second dashboard response times**
- **99%+ data processing reliability**
- **Configurable business rules** without code changes

### Business Success

- **PE stakeholder engagement** - Nick funding approval
- **Capital allocation optimization** - quantified reallocation opportunities
- **Attribution bias detection** - validation of current assumptions
- **Operational efficiency** - team adoption of recommendations