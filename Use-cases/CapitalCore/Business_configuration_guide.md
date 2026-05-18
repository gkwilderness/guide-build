---
title: "Business_configuration_guide"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# Business Configuration Guide

## Overview

The yield curve analytics system uses a flexible configuration framework that allows each business to define its own thresholds, preferences, and rules without requiring code changes. This guide explains how to configure and customize the system for different business needs.

## Configuration Philosophy

### Convention Over Configuration

- **Intelligent defaults** for common scenarios
- **Business-specific overrides** when needed
- **No code deployment** required for configuration changes
- **Audit trail** for all configuration modifications

### Business Contexts

Each business in the portfolio has unique characteristics:

- **Different deal values and sales cycles**
- **Varying market conditions and competition**
- **Distinct attribution patterns and customer journeys**
- **Specific campaign structures and naming conventions**

## Core Configuration Types

### 1. Yield Curve Thresholds

Controls when campaigns are considered eligible for yield curve analysis.

```json
{
    "yield_curve_thresholds": {
        "min_spend_usd": 500,
        "min_conversions": 3,
        "min_days": 30,
        "statistical_confidence": 0.8
    }
}
```

**Parameters:**

- `min_spend_usd`: Minimum total spend for campaign inclusion
- `min_conversions`: Minimum conversion count for statistical significance
- `min_days`: Minimum days with active spend
- `statistical_confidence`: Confidence level for yield curve calculations (0.0-1.0)

**Business-Specific Examples:**

```json
// Wilderness: High-value, low-volume
{
    "min_spend_usd": 500,
    "min_conversions": 3,
    "min_days": 30
}

// Jacada: Medium-value, moderate volume
{
    "min_spend_usd": 400,
    "min_conversions": 2,
    "min_days": 21
}

// Yellow Zebra: Lower-value, higher volume
{
    "min_spend_usd": 350,
    "min_conversions": 2,
    "min_days": 28
}
```

### 2. Booking Conversion Rates

Used for extrapolating lead conversions to actual bookings.

```json
{
    "booking_conversion_rate": {
        "rate": 0.11,
        "confidence": "high",
        "last_updated": "2024-01-15",
        "data_source": "crm_analysis",
        "seasonal_adjustments": {
            "q1": 0.95,
            "q2": 1.05,
            "q3": 1.10,
            "q4": 0.90
        }
    }
}
```

**Parameters:**

- `rate`: Base conversion rate from lead to booking (0.0-1.0)
- `confidence`: Data quality assessment ("high", "medium", "low", "estimated")
- `last_updated`: Date of last rate calculation
- `data_source`: Source of conversion rate data
- `seasonal_adjustments`: Quarterly multipliers for seasonal trends

**Business Examples:**

```json
// Wilderness: High-value safaris, strong conversion
{
    "rate": 0.11,
    "confidence": "high",
    "seasonal_adjustments": {
        "q1": 0.85,  // Post-holiday low
        "q2": 1.00,  // Spring planning
        "q3": 1.15,  // Summer booking peak
        "q4": 1.00   // Holiday planning
    }
}

// Jacada: Moderate conversion, established business
{
    "rate": 0.09,
    "confidence": "medium",
    "seasonal_adjustments": {
        "q1": 0.90,
        "q2": 1.05,
        "q3": 1.10,
        "q4": 0.95
    }
}

// Yellow Zebra: Newer business, estimated rates
{
    "rate": 0.08,
    "confidence": "estimated",
    "seasonal_adjustments": {
        "q1": 0.95,
        "q2": 1.00,
        "q3": 1.05,
        "q4": 1.00
    }
}
```

### 3. Attribution Preferences

Defines how attribution models are calculated and weighted.

```json
{
    "attribution_preferences": {
        "default_model": "time_decay",
        "decay_half_life": 30,
        "attribution_window": 180,
        "model_weights": {
            "time_decay": 0.30,
            "position_based": 0.25,
            "linear": 0.20,
            "first_touch": 0.10,
            "last_touch": 0.10,
            "custom_mmm_v1": 0.05
        },
        "touchpoint_decay_curve": "exponential",
        "position_based_config": {
            "first_touch_weight": 0.4,
            "last_touch_weight": 0.4,
            "middle_weight": 0.2
        }
    }
}
```

**Parameters:**

- `default_model`: Primary attribution model for reporting
- `decay_half_life`: Days for time-decay model half-life
- `attribution_window`: Maximum days to look back for touchpoints
- `model_weights`: Relative importance of each model in ensemble scoring
- `touchpoint_decay_curve`: Shape of decay function ("exponential", "linear", "custom")
- `position_based_config`: Weights for position-based attribution

**Business Examples:**

```json
// Wilderness: Long consideration cycle
{
    "default_model": "time_decay",
    "decay_half_life": 30,
    "attribution_window": 180,
    "model_weights": {
        "time_decay": 0.35,      // Emphasize recent touchpoints
        "position_based": 0.30,  // First/last touch importance
        "linear": 0.15,
        "first_touch": 0.10,
        "last_touch": 0.10
    }
}

// Jacada: Balanced approach
{
    "default_model": "time_decay",
    "decay_half_life": 45,       // Longer decay for luxury travel
    "attribution_window": 180,
    "model_weights": {
        "time_decay": 0.25,
        "position_based": 0.25,
        "linear": 0.20,
        "first_touch": 0.15,
        "last_touch": 0.15
    }
}

// Yellow Zebra: Position-based preference
{
    "default_model": "position_based",
    "decay_half_life": 21,
    "attribution_window": 120,   // Shorter cycle
    "model_weights": {
        "position_based": 0.40,  // Strong first/last preference
        "time_decay": 0.25,
        "linear": 0.15,
        "first_touch": 0.10,
        "last_touch": 0.10
    }
}
```

### 4. Campaign Type Multipliers

Adjusts efficiency scoring based on campaign types and strategic importance.

```json
{
    "campaign_type_multipliers": {
        "search_brand": 1.2,
        "search_generic": 1.0,
        "search_competitor": 0.9,
        "display_remarketing": 1.1,
        "display_prospecting": 0.8,
        "shopping": 1.0,
        "video": 0.7,
        "custom_multipliers": {
            "high_intent_keywords": 1.3,
            "luxury_audiences": 1.2,
            "geographic_priority": {
                "botswana": 1.1,
                "rwanda": 1.0,
                "tanzania": 0.9
            }
        }
    }
}
```

**Parameters:**

- Standard campaign type multipliers for efficiency scoring
- `custom_multipliers`: Business-specific adjustments
- `geographic_priority`: Location-based efficiency adjustments

### 5. Alert Configuration

Defines automated monitoring and notification rules.

```json
{
    "alert_configuration": {
        "efficiency_drop_threshold": 0.15,
        "spend_spike_threshold": 2.0,
        "conversion_drop_threshold": 0.30,
        "attribution_anomaly_threshold": 0.25,
        "notification_channels": {
            "email": ["marketing@business.com", "cmo@business.com"],
            "slack": "#marketing-alerts",
            "frequency": "daily_digest"
        },
        "alert_types": {
            "efficiency_drop": {
                "enabled": true,
                "threshold": 0.15,
                "lookback_days": 7,
                "min_spend_usd": 100
            },
            "spend_anomaly": {
                "enabled": true,
                "threshold": 2.0,
                "comparison_period": "previous_week"
            },
            "attribution_shift": {
                "enabled": false,
                "threshold": 0.20,
                "models_to_compare": ["time_decay", "last_touch"]
            }
        }
    }
}
```

## Configuration Management Interface

### Via Streamlit Dashboard

**Navigation:** Settings → Business Configuration

**Features:**

- Visual configuration editor with validation
- Preview changes before applying
- Configuration diff showing changes
- Rollback to previous configurations
- Export/import configuration sets

### Via Database Direct

```sql
-- View current configuration
SELECT config_name, config_value, updated_at, updated_by
FROM business_config 
WHERE business_id = 1
ORDER BY config_name;

-- Update configuration
INSERT INTO business_config (business_id, config_name, config_value, updated_by)
VALUES (1, 'yield_curve_thresholds', '{
    "min_spend_usd": 600,
    "min_conversions": 4,
    "min_days": 35
}', 'admin@business.com')
ON CONFLICT (business_id, config_name) 
DO UPDATE SET 
    config_value = EXCLUDED.config_value,
    updated_at = NOW(),
    updated_by = EXCLUDED.updated_by;
```

## Business Onboarding Process

### Step 1: Basic Business Setup

```sql
-- Create new business
INSERT INTO businesses (name, google_ads_account_id, active)
VALUES ('New Business', '123-456-7890', true);

-- Set default configurations
INSERT INTO business_config (business_id, config_name, config_value, updated_by)
VALUES 
(4, 'yield_curve_thresholds', '{
    "min_spend_usd": 400,
    "min_conversions": 2,
    "min_days": 28
}', 'system'),
(4, 'booking_conversion_rate', '{
    "rate": 0.10,
    "confidence": "estimated"
}', 'system'),
(4, 'attribution_preferences', '{
    "default_model": "time_decay",
    "decay_half_life": 30,
    "attribution_window": 180
}', 'system');
```

### Step 2: Campaign Tag Setup

```sql
-- Define business-specific tags
INSERT INTO tag_definitions (tag_type, tag_value, description, business_id)
VALUES 
('geography', 'kenya', 'Kenya market campaigns', 4),
('geography', 'south_africa', 'South Africa market campaigns', 4),
('product', 'adventure', 'Adventure travel product focus', 4),
('product', 'luxury', 'Luxury travel product focus', 4);
```

### Step 3: Exclusion Rules

```sql
-- Set up automatic exclusions
INSERT INTO exclusion_rules (business_id, rule_type, rule_value, exclusion_reason, excluded_from)
VALUES 
(4, 'campaign_name_contains', 'brand', 'Brand campaigns exclude from yield curves', 'yield_curves'),
(4, 'bid_strategy_equals', 'target_impression_share', 'Impression share campaigns', 'yield_curves');
```

## Advanced Configuration Scenarios

### Multi-Market Business

```json
{
    "market_specific_config": {
        "markets": {
            "botswana": {
                "booking_conversion_rate": 0.12,
                "attribution_window": 210,
                "seasonal_multipliers": {
                    "dry_season": 1.3,
                    "wet_season": 0.8
                }
            },
            "rwanda": {
                "booking_conversion_rate": 0.09,
                "attribution_window": 150,
                "seasonal_multipliers": {
                    "dry_season": 1.1,
                    "wet_season": 0.9
                }
            }
        },
        "market_priority_weights": {
            "botswana": 1.2,
            "rwanda": 1.0,
            "tanzania": 0.9
        }
    }
}
```

### Custom Attribution Model

```json
{
    "custom_attribution_models": {
        "mmm_v1": {
            "algorithm": "custom_regression",
            "parameters": {
                "decay_function": "power_law",
                "decay_exponent": 0.7,
                "interaction_effects": true,
                "channel_saturation_curves": {
                    "search": {"alpha": 2.5, "gamma": 0.3},
                    "display": {"alpha": 1.8, "gamma": 0.4}
                }
            },
            "training_data_requirements": {
                "min_touchpoints": 1000,
                "min_conversions": 50,
                "lookback_days": 365
            }
        }
    }
}
```

### A/B Testing Configuration

```json
{
    "ab_testing_config": {
        "yield_curve_experiments": {
            "enabled": true,
            "test_groups": {
                "control": {
                    "percentage": 50,
                    "configuration": "current_default"
                },
                "treatment": {
                    "percentage": 50,
                    "configuration": "aggressive_thresholds"
                }
            },
            "success_metrics": [
                "efficiency_improvement",
                "booking_conversion_rate",
                "total_portfolio_roi"
            ],
            "experiment_duration_days": 30
        }
    }
}
```

## Configuration Validation

### Validation Rules

```python
class ConfigurationValidator:
    def validate_yield_curve_thresholds(self, config):
        """Validate yield curve threshold configuration"""
        required_fields = ['min_spend_usd', 'min_conversions', 'min_days']
        
        for field in required_fields:
            if field not in config:
                raise ValidationError(f"Missing required field: {field}")
        
        if config['min_spend_usd'] < 0:
            raise ValidationError("min_spend_usd must be positive")
        
        if config['min_conversions'] < 1:
            raise ValidationError("min_conversions must be at least 1")
        
        if config['min_days'] < 7:
            raise ValidationError("min_days must be at least 7")
    
    def validate_booking_conversion_rate(self, config):
        """Validate booking conversion rate configuration"""
        if not 0 <= config['rate'] <= 1:
            raise ValidationError("Booking rate must be between 0 and 1")
        
        valid_confidence_levels = ['high', 'medium', 'low', 'estimated']
        if config.get('confidence') not in valid_confidence_levels:
            raise ValidationError(f"Invalid confidence level: {config.get('confidence')}")
```

### Configuration Health Checks

```python
def run_configuration_health_check(business_id):
    """Comprehensive configuration health check"""
    checks = [
        check_required_configurations(business_id),
        check_configuration_consistency(business_id),
        check_threshold_reasonableness(business_id),
        check_attribution_model_completeness(business_id)
    ]
    
    return ConfigurationHealthReport(
        business_id=business_id,
        checks=checks,
        overall_status='healthy' if all(c.passed for c in checks) else 'issues_found',
        recommendations=generate_configuration_recommendations(checks)
    )
```

## Configuration Migration

### Version Control

```sql
-- Configuration versioning table
CREATE TABLE business_config_history (
    id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES businesses(id),
    config_name VARCHAR(50),
    config_value JSONB,
    version INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(50),
    migration_reason TEXT
);

-- Track configuration changes
CREATE OR REPLACE FUNCTION track_config_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO business_config_history 
    (business_id, config_name, config_value, version, created_by, migration_reason)
    VALUES 
    (OLD.business_id, OLD.config_name, OLD.config_value, 
     COALESCE((SELECT MAX(version) + 1 FROM business_config_history 
               WHERE business_id = OLD.business_id AND config_name = OLD.config_name), 1),
     OLD.updated_by, 'automatic_backup');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Configuration Rollback

```python
def rollback_configuration(business_id, config_name, target_version=None):
    """Rollback configuration to previous version"""
    if target_version is None:
        # Get most recent version
        target_version = get_latest_config_version(business_id, config_name) - 1
    
    historical_config = get_config_by_version(business_id, config_name, target_version)
    
    update_business_config(
        business_id=business_id,
        config_name=config_name,
        config_value=historical_config.config_value,
        updated_by=f"rollback_to_v{target_version}"
    )
    
    return ConfigurationRollbackResult(
        success=True,
        rolled_back_to_version=target_version,
        config_name=config_name
    )
```

## Best Practices

### Configuration Management

1. **Always test configuration changes** in a development environment first
2. **Document the business rationale** for configuration changes
3. **Monitor system performance** after configuration updates
4. **Use configuration versioning** for important changes
5. **Validate configurations** before applying to production

### Business Alignment

1. **Involve stakeholders** in configuration decisions
2. **Regular configuration reviews** (monthly/quarterly)
3. **Align configurations** with business strategy changes
4. **Document configuration dependencies** between businesses
5. **Track configuration effectiveness** over time

### Troubleshooting Common Issues

#### Low Campaign Eligibility

**Problem:** Too few campaigns meeting yield curve thresholds **Solution:** Adjust `min_spend_usd` or `min_conversions` based on business volume

#### Attribution Model Inconsistency

**Problem:** Large variance between attribution models **Solution:** Review `attribution_window` and `model_weights` configuration

#### Seasonal Performance Issues

**Problem:** Booking rates fluctuate significantly by season **Solution:** Implement `seasonal_adjustments` in booking conversion configuration

#### Cross-Business Comparison Problems

**Problem:** Efficiency scoring inconsistent across businesses **Solution:** Adjust `campaign_type_multipliers` for business-specific factors

## Support and Documentation

### Configuration Support Channels

- **Documentation:** This guide and technical documentation
- **Dashboard Help:** In-app configuration guidance and validation
- **Technical Support:** Contact development team for complex configurations
- **Business Support:** Work with analytics team for business rule definitions

### Additional Resources

- **API Documentation:** For programmatic configuration management
- **Database Schema:** Understanding underlying configuration storage
- **Development Guide:** Custom configuration development
- **Migration Guide:** Configuration updates and versioning procedures