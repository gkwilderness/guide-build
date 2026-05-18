---
title: "Database_Schema"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# Database Schema

## Design Principles

1. **Business-agnostic core structure** with business-specific configuration
2. **Time-series optimization** for analytics performance
3. **Flexible tagging system** for campaign grouping
4. **Multi-attribution storage** for triangulation analysis
5. **Audit trails** for configuration and exclusion changes

## Core Schema

### Business Entities

```sql
-- Core business definitions
CREATE TABLE businesses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL, -- 'Wilderness', 'Jacada', 'Yellow Zebra'
    google_ads_account_id VARCHAR(20),
    config JSONB, -- Flexible business-specific settings
    created_at TIMESTAMPTZ DEFAULT NOW(),
    active BOOLEAN DEFAULT TRUE
);

-- Ad platforms (ready for Bing integration)
CREATE TABLE ad_platforms (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL, -- 'google_ads', 'bing_ads'
    business_id INTEGER REFERENCES businesses(id),
    account_id VARCHAR(50),
    api_credentials_env_key VARCHAR(100), -- Environment variable name
    active BOOLEAN DEFAULT TRUE
);

-- Campaign structure (platform-agnostic)
CREATE TABLE campaigns (
    id SERIAL PRIMARY KEY,
    platform_id INTEGER REFERENCES ad_platforms(id),
    business_id INTEGER REFERENCES businesses(id), -- Denormalized for performance
    external_id VARCHAR(50), -- Platform-specific campaign ID
    name VARCHAR(200),
    campaign_type VARCHAR(50), -- 'search', 'display', 'shopping'
    status VARCHAR(20), -- 'active', 'paused', 'removed'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Time-Series Metrics

```sql
-- Daily performance metrics (optimized for analytics)
CREATE TABLE daily_metrics (
    date DATE,
    campaign_id INTEGER REFERENCES campaigns(id),
    spend_micros BIGINT, -- Store in micros for precision
    conversions INTEGER,
    impressions BIGINT,
    clicks INTEGER,
    cost_per_click_micros BIGINT,
    conversion_rate DECIMAL(6,4),
    PRIMARY KEY (date, campaign_id)
);

-- Performance indexes
CREATE INDEX idx_daily_metrics_date ON daily_metrics(date DESC);
CREATE INDEX idx_daily_metrics_campaign ON daily_metrics(campaign_id, date DESC);
CREATE INDEX idx_daily_metrics_business_date ON daily_metrics(campaign_id, date DESC) 
    WHERE campaign_id IN (SELECT id FROM campaigns WHERE business_id = ?);
```

### Campaign Grouping & Filtering

```sql
-- Flexible campaign tagging system
CREATE TABLE campaign_tags (
    id SERIAL PRIMARY KEY,
    campaign_id INTEGER REFERENCES campaigns(id),
    tag_type VARCHAR(50), -- 'geography', 'keyword_intent', 'product', 'channel'
    tag_value VARCHAR(100), -- 'botswana', 'generics', 'luxury_lodges', 'search'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(50),
    UNIQUE(campaign_id, tag_type, tag_value)
);

-- Tag definitions and taxonomy
CREATE TABLE tag_definitions (
    tag_type VARCHAR(50),
    tag_value VARCHAR(100),
    description TEXT,
    business_id INTEGER REFERENCES businesses(id), -- NULL for global tags
    active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (tag_type, tag_value, COALESCE(business_id, -1))
);

-- Campaign exclusion system
CREATE TABLE campaign_exclusions (
    id SERIAL PRIMARY KEY,
    campaign_id INTEGER REFERENCES campaigns(id),
    exclusion_reason VARCHAR(100), -- 'brand_impression_share', 'always_on', 'test_campaign'
    excluded_from VARCHAR(50), -- 'yield_curves', 'attribution', 'all_analysis'
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(50)
);

-- Business-level exclusion rules (automatic application)
CREATE TABLE exclusion_rules (
    id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES businesses(id),
    rule_type VARCHAR(50), -- 'campaign_name_contains', 'bid_strategy_equals'
    rule_value VARCHAR(100), -- 'brand', 'target_impression_share'
    exclusion_reason VARCHAR(100),
    excluded_from VARCHAR(50),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Analytics & Calculations

```sql
-- Campaign eligibility for yield curves
CREATE TABLE campaign_eligibility (
    campaign_id INTEGER REFERENCES campaigns(id),
    calculation_date DATE,
    total_spend_micros BIGINT,
    total_conversions INTEGER,
    days_active INTEGER,
    is_eligible BOOLEAN,
    reason_if_not VARCHAR(200),
    thresholds_used JSONB, -- Business-specific thresholds applied
    PRIMARY KEY (campaign_id, calculation_date)
);

-- Pre-calculated yield curve data
CREATE TABLE yield_analysis (
    calculation_date DATE,
    campaign_id INTEGER REFERENCES campaigns(id),
    spend_bucket INTEGER, -- 0-500, 500-1000, etc.
    bucket_start_micros BIGINT,
    bucket_end_micros BIGINT,
    total_spend_micros BIGINT,
    total_conversions INTEGER,
    marginal_cpl_micros BIGINT, -- Cost per lead for this bucket
    efficiency_score DECIMAL(5,3), -- Relative efficiency vs portfolio
    PRIMARY KEY (calculation_date, campaign_id, spend_bucket)
);

-- Grouped yield curves (for campaign tags)
CREATE TABLE grouped_yield_analysis (
    calculation_date DATE,
    business_id INTEGER REFERENCES businesses(id),
    tag_filters JSONB, -- {"geography": ["botswana"], "keyword_intent": ["generics"]}
    group_name VARCHAR(100), -- Human-readable group identifier
    spend_bucket INTEGER,
    bucket_start_micros BIGINT,
    bucket_end_micros BIGINT,
    total_spend_micros BIGINT,
    total_conversions INTEGER,
    campaign_count INTEGER,
    marginal_cpl_micros BIGINT,
    efficiency_score DECIMAL(5,3),
    PRIMARY KEY (calculation_date, business_id, group_name, spend_bucket)
);
```

### Attribution Framework

```sql
-- Conversion tracking with full attribution paths
CREATE TABLE conversions (
    id SERIAL PRIMARY KEY,
    conversion_date DATE,
    conversion_value_micros BIGINT,
    business_id INTEGER REFERENCES businesses(id),
    attribution_window_days INTEGER DEFAULT 180,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Attribution touchpoints
CREATE TABLE attribution_touchpoints (
    id SERIAL PRIMARY KEY,
    conversion_id INTEGER REFERENCES conversions(id),
    campaign_id INTEGER REFERENCES campaigns(id),
    touchpoint_date DATE,
    touchpoint_sequence INTEGER, -- Order in conversion path
    days_before_conversion INTEGER,
    interaction_type VARCHAR(50) -- 'click', 'impression', 'view'
);

-- Multi-attribution model results
CREATE TABLE attribution_results (
    conversion_id INTEGER REFERENCES conversions(id),
    campaign_id INTEGER REFERENCES campaigns(id),
    touchpoint_sequence INTEGER,
    attribution_model VARCHAR(20), -- 'time_decay', 'position_based', 'linear', etc.
    attribution_weight DECIMAL(8,6),
    attributed_value_micros BIGINT,
    calculation_date DATE,
    model_parameters JSONB, -- Store decay rates, rules, etc.
    PRIMARY KEY (conversion_id, campaign_id, touchpoint_sequence, attribution_model)
);

-- Attribution comparison aggregates
CREATE TABLE attribution_comparison (
    date_range_start DATE,
    date_range_end DATE,
    campaign_id INTEGER REFERENCES campaigns(id),
    attribution_model VARCHAR(20),
    total_attributed_conversions DECIMAL(10,3),
    total_attributed_value_micros BIGINT,
    model_config JSONB,
    PRIMARY KEY (date_range_start, date_range_end, campaign_id, attribution_model)
);
```

### Configuration Management

```sql
-- Business-specific configuration
CREATE TABLE business_config (
    business_id INTEGER REFERENCES businesses(id),
    config_name VARCHAR(50),
    config_value JSONB,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by VARCHAR(50),
    PRIMARY KEY (business_id, config_name)
);

-- Campaign restructure recommendations
CREATE TABLE campaign_restructure_recommendations (
    id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES businesses(id),
    recommendation_date DATE,
    current_campaign_ids INTEGER[],
    recommended_action VARCHAR(50), -- 'merge', 'pause', 'increase_budget'
    rationale TEXT,
    projected_efficiency_gain DECIMAL(5,3),
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'implemented', 'rejected'
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Alert Framework (Post-MVP)

```sql
-- Alert definitions
CREATE TABLE alert_definitions (
    id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES businesses(id),
    alert_type VARCHAR(50), -- 'efficiency_drop', 'spend_threshold', 'attribution_anomaly'
    conditions JSONB, -- Flexible condition definitions
    notification_config JSONB, -- Email, Slack, etc.
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Alert events log
CREATE TABLE alert_events (
    id SERIAL PRIMARY KEY,
    alert_definition_id INTEGER REFERENCES alert_definitions(id),
    triggered_at TIMESTAMPTZ DEFAULT NOW(),
    trigger_data JSONB,
    resolved_at TIMESTAMPTZ,
    notification_sent BOOLEAN DEFAULT FALSE
);
```

## Initial Data Setup

### Default Business Configurations

```sql
-- Wilderness configuration
INSERT INTO business_config VALUES 
(1, 'yield_curve_thresholds', '{"min_spend_usd": 500, "min_conversions": 3, "min_days": 30}'),
(1, 'booking_conversion_rate', '{"rate": 0.11, "confidence": "high", "last_updated": "2024-01-15"}'),
(1, 'attribution_preferences', '{"default_model": "time_decay", "decay_half_life": 30}'),
(1, 'campaign_type_multipliers', '{"search_brand": 1.2, "search_generic": 1.0, "display": 0.9}');

-- Jacada configuration  
INSERT INTO business_config VALUES
(2, 'yield_curve_thresholds', '{"min_spend_usd": 400, "min_conversions": 2, "min_days": 21}'),
(2, 'booking_conversion_rate', '{"rate": 0.09, "confidence": "estimated"}'),
(2, 'attribution_preferences', '{"default_model": "time_decay", "decay_half_life": 45}'),
(2, 'campaign_type_multipliers', '{"search_brand": 1.1, "search_generic": 1.0, "display": 0.7}');

-- Yellow Zebra configuration
INSERT INTO business_config VALUES
(3, 'yield_curve_thresholds', '{"min_spend_usd": 350, "min_conversions": 2, "min_days": 28}'),
(3, 'booking_conversion_rate', '{"rate": 0.08, "confidence": "estimated"}'),
(3, 'attribution_preferences', '{"default_model": "position_based"}'),
(3, 'campaign_type_multipliers', '{"search_brand": 1.0, "search_generic": 1.1, "display": 0.8}');
```

### Sample Tag Definitions

```sql
-- Global tag taxonomy
INSERT INTO tag_definitions VALUES
('geography', 'botswana', 'Botswana market campaigns', NULL),
('geography', 'rwanda', 'Rwanda market campaigns', NULL),
('geography', 'tanzania', 'Tanzania market campaigns', NULL),
('keyword_intent', 'brand', 'Brand keyword campaigns', NULL),
('keyword_intent', 'generics', 'Generic keyword campaigns', NULL),
('keyword_intent', 'competitors', 'Competitor keyword campaigns', NULL),
('product', 'luxury_safari', 'Luxury safari product focus', NULL),
('product', 'family_safari', 'Family safari product focus', NULL),
('channel', 'search', 'Search advertising', NULL),
('channel', 'display', 'Display advertising', NULL);
```

## Performance Optimization

### Key Indexes

```sql
-- Time-series query optimization
CREATE INDEX idx_daily_metrics_business_date_perf ON daily_metrics(campaign_id, date DESC) 
    INCLUDE (spend_micros, conversions, clicks);

-- Attribution analysis optimization  
CREATE INDEX idx_attribution_touchpoints_conversion ON attribution_touchpoints(conversion_id, touchpoint_sequence);
CREATE INDEX idx_attribution_results_model_campaign ON attribution_results(attribution_model, campaign_id, calculation_date);

-- Campaign grouping optimization
CREATE INDEX idx_campaign_tags_type_value ON campaign_tags(tag_type, tag_value);
CREATE INDEX idx_campaign_tags_campaign ON campaign_tags(campaign_id);

-- Yield curve analysis optimization
CREATE INDEX idx_yield_analysis_business_date ON yield_analysis(calculation_date DESC, campaign_id)
    WHERE campaign_id IN (SELECT id FROM campaigns WHERE business_id IN (1,2,3));
```

### Partitioning Strategy (Future)

```sql
-- Partition daily_metrics by date for large-scale data
CREATE TABLE daily_metrics_y2024m01 PARTITION OF daily_metrics
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

## Migration Strategy

### Development to Production

1. **Schema deployment** via migration scripts
2. **Configuration seeding** with business defaults
3. **Historical data import** from Google Ads API
4. **Yield curve initialization** with batch calculations
5. **Dashboard validation** with real data