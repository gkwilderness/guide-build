---
title: "API_Specifications"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# API Specifications

## Architecture Decision: No API for MVP

**Rationale:** Based on CTO-level pragmatic decision-making, we are **NOT** building a REST API for MVP. Direct database access provides:

- Faster development (2-3 days saved)
- Simpler debugging and optimization
- Better performance at current volumes
- Easier maintenance with fewer layers

**Future Migration:** When API becomes necessary (team growth, external access), simple refactoring from direct database calls to API calls.

## Data Access Patterns

### Direct Database Service Layer

```python
# data_service.py - Direct database access patterns
class YieldCurveDataService:
    def __init__(self, db_connection):
        self.db = db_connection
    
    def get_business_comparison(self, date_range: tuple, attribution_model: str = 'time_decay'):
        """Get cross-business yield curve comparison"""
        return pd.read_sql("""
            SELECT 
                b.name as business_name,
                yc.spend_bucket,
                yc.marginal_cpl_micros / 1000000.0 as marginal_cpl_usd,
                yc.efficiency_score,
                yc.total_conversions
            FROM yield_analysis yc
            JOIN campaigns c ON yc.campaign_id = c.id
            JOIN businesses b ON c.business_id = b.id
            WHERE yc.calculation_date BETWEEN %s AND %s
            ORDER BY b.name, yc.spend_bucket
        """, self.db, params=date_range)
    
    def get_reallocation_recommendations(self, business_ids: List[int], min_efficiency_gain: float = 0.1):
        """Get capital reallocation opportunities"""
        return pd.read_sql("""
            SELECT 
                cr.business_id,
                b.name as business_name,
                cr.recommended_action,
                cr.rationale,
                cr.projected_efficiency_gain,
                array_length(cr.current_campaign_ids, 1) as campaigns_affected
            FROM campaign_restructure_recommendations cr
            JOIN businesses b ON cr.business_id = b.id
            WHERE cr.business_id = ANY(%s)
            AND cr.projected_efficiency_gain >= %s
            AND cr.status = 'pending'
            ORDER BY cr.projected_efficiency_gain DESC
        """, self.db, params=[business_ids, min_efficiency_gain])
```

### Attribution Analysis Service

```python
class AttributionDataService:
    def __init__(self, db_connection):
        self.db = db_connection
    
    def get_attribution_comparison(self, campaign_ids: List[int], date_range: tuple):
        """Get attribution model comparison for campaigns"""
        return pd.read_sql("""
            SELECT 
                c.name as campaign_name,
                b.name as business_name,
                ac.attribution_model,
                ac.total_attributed_conversions,
                ac.total_attributed_value_micros / 1000000.0 as attributed_value_usd
            FROM attribution_comparison ac
            JOIN campaigns c ON ac.campaign_id = c.id
            JOIN businesses b ON c.business_id = b.id
            WHERE ac.campaign_id = ANY(%s)
            AND ac.date_range_start >= %s 
            AND ac.date_range_end <= %s
            ORDER BY b.name, c.name, ac.attribution_model
        """, self.db, params=[campaign_ids, date_range[0], date_range[1]])
    
    def get_attribution_bias_analysis(self, business_id: int, date_range: tuple):
        """Analyze attribution bias between models"""
        return pd.read_sql("""
            WITH model_totals AS (
                SELECT 
                    attribution_model,
                    SUM(total_attributed_conversions) as total_conversions,
                    SUM(total_attributed_value_micros) as total_value
                FROM attribution_comparison ac
                JOIN campaigns c ON ac.campaign_id = c.id
                WHERE c.business_id = %s
                AND ac.date_range_start >= %s
                AND ac.date_range_end <= %s
                GROUP BY attribution_model
            ),
            first_last_comparison AS (
                SELECT 
                    (SELECT total_conversions FROM model_totals WHERE attribution_model = 'last_touch') as last_touch_conversions,
                    (SELECT total_conversions FROM model_totals WHERE attribution_model = 'first_touch') as first_touch_conversions
            )
            SELECT 
                mt.*,
                CASE 
                    WHEN mt.attribution_model = 'last_touch' 
                    THEN ((mt.total_conversions / flc.first_touch_conversions - 1) * 100)
                    ELSE NULL 
                END as last_touch_advantage_pct
            FROM model_totals mt
            CROSS JOIN first_last_comparison flc
            ORDER BY mt.total_conversions DESC
        """, self.db, params=[business_id, date_range[0], date_range[1]])
```

### Campaign Grouping Service

```python
class CampaignGroupingService:
    def __init__(self, db_connection):
        self.db = db_connection
    
    def get_grouped_yield_curves(self, tag_filters: Dict[str, List[str]], date_range: tuple):
        """Get yield curves for tagged campaign groups"""
        
        # Build dynamic WHERE clause for tag filtering
        tag_conditions = []
        params = []
        
        for tag_type, tag_values in tag_filters.items():
            placeholders = ','.join(['%s'] * len(tag_values))
            tag_conditions.append(f"(ct.tag_type = %s AND ct.tag_value IN ({placeholders}))")
            params.extend([tag_type] + tag_values)
        
        where_clause = ' OR '.join(tag_conditions)
        params.extend(date_range)
        
        return pd.read_sql(f"""
            SELECT 
                gya.group_name,
                gya.spend_bucket,
                gya.bucket_start_micros / 1000000.0 as bucket_start_usd,
                gya.bucket_end_micros / 1000000.0 as bucket_end_usd,
                gya.total_spend_micros / 1000000.0 as total_spend_usd,
                gya.total_conversions,
                gya.campaign_count,
                gya.marginal_cpl_micros / 1000000.0 as marginal_cpl_usd,
                gya.efficiency_score
            FROM grouped_yield_analysis gya
            WHERE gya.calculation_date BETWEEN %s AND %s
            AND EXISTS (
                SELECT 1 FROM campaign_tags ct 
                WHERE ({where_clause})
                AND ct.campaign_id IN (
                    SELECT UNNEST(gya.tag_filters->'campaign_ids')::INTEGER
                )
            )
            ORDER BY gya.group_name, gya.spend_bucket
        """, self.db, params=params)
    
    def get_geography_vs_intent_analysis(self, business_id: int, date_range: tuple):
        """Compare geography vs keyword intent performance"""
        return pd.read_sql("""
            WITH geo_intent_combinations AS (
                SELECT DISTINCT
                    ct1.tag_value as geography,
                    ct2.tag_value as keyword_intent,
                    COUNT(DISTINCT ct1.campaign_id) as campaign_count
                FROM campaign_tags ct1
                JOIN campaign_tags ct2 ON ct1.campaign_id = ct2.campaign_id
                JOIN campaigns c ON ct1.campaign_id = c.id
                WHERE ct1.tag_type = 'geography'
                AND ct2.tag_type = 'keyword_intent'  
                AND c.business_id = %s
                GROUP BY ct1.tag_value, ct2.tag_value
                HAVING COUNT(DISTINCT ct1.campaign_id) >= 2
            )
            SELECT 
                gic.geography,
                gic.keyword_intent, 
                gic.campaign_count,
                AVG(dm.spend_micros / NULLIF(dm.conversions, 0)) / 1000000.0 as avg_cpl_usd,
                SUM(dm.conversions) as total_conversions,
                SUM(dm.spend_micros) / 1000000.0 as total_spend_usd
            FROM geo_intent_combinations gic
            JOIN campaign_tags ct1 ON ct1.tag_value = gic.geography AND ct1.tag_type = 'geography'
            JOIN campaign_tags ct2 ON ct2.campaign_id = ct1.campaign_id AND ct2.tag_value = gic.keyword_intent AND ct2.tag_type = 'keyword_intent'
            JOIN daily_metrics dm ON dm.campaign_id = ct1.campaign_id
            WHERE dm.date BETWEEN %s AND %s
            GROUP BY gic.geography, gic.keyword_intent, gic.campaign_count
            ORDER BY avg_cpl_usd ASC
        """, self.db, params=[business_id, date_range[0], date_range[1]])
```

### Configuration Management Service

```python
class ConfigurationService:
    def __init__(self, db_connection):
        self.db = db_connection
    
    def get_business_config(self, business_id: int, config_name: str):
        """Get business-specific configuration with fallback to defaults"""
        result = pd.read_sql("""
            SELECT config_value 
            FROM business_config 
            WHERE business_id = %s AND config_name = %s
        """, self.db, params=[business_id, config_name])
        
        if not result.empty:
            return result.iloc[0]['config_value']
        else:
            return self.get_default_config(config_name)
    
    def update_business_config(self, business_id: int, config_name: str, config_value: dict, updated_by: str):
        """Update business configuration with audit trail"""
        cursor = self.db.cursor()
        cursor.execute("""
            INSERT INTO business_config (business_id, config_name, config_value, updated_by)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (business_id, config_name)
            DO UPDATE SET 
                config_value = EXCLUDED.config_value,
                updated_at = NOW(),
                updated_by = EXCLUDED.updated_by
        """, [business_id, config_name, json.dumps(config_value), updated_by])
        self.db.commit()
        cursor.close()
    
    def get_all_business_configs(self, business_id: int):
        """Get all configurations for a business"""
        return pd.read_sql("""
            SELECT 
                config_name,
                config_value,
                updated_at,
                updated_by
            FROM business_config 
            WHERE business_id = %s
            ORDER BY config_name
        """, self.db, params=[business_id])
```

### Money Left on Table Service

```python
class HistoricalAnalysisService:
    def __init__(self, db_connection):
        self.db = db_connection
    
    def calculate_money_left_on_table(self, business_ids: List[int], date_range: tuple):
        """Calculate historical reallocation opportunities"""
        return pd.read_sql("""
            WITH campaign_efficiency AS (
                SELECT 
                    c.business_id,
                    c.id as campaign_id,
                    c.name as campaign_name,
                    SUM(dm.spend_micros) as total_spend_micros,
                    SUM(dm.conversions) as total_conversions,
                    CASE 
                        WHEN SUM(dm.conversions) > 0 
                        THEN SUM(dm.spend_micros) / SUM(dm.conversions) 
                        ELSE NULL 
                    END as cpl_micros,
                    ROW_NUMBER() OVER (PARTITION BY c.business_id ORDER BY 
                        CASE WHEN SUM(dm.conversions) > 0 
                        THEN SUM(dm.spend_micros) / SUM(dm.conversions) 
                        ELSE 999999999999 END ASC) as efficiency_rank
                FROM campaigns c
                JOIN daily_metrics dm ON c.id = dm.campaign_id
                LEFT JOIN campaign_exclusions ce ON c.id = ce.campaign_id 
                    AND ce.active = TRUE 
                    AND ce.excluded_from IN ('yield_curves', 'all_analysis')
                WHERE c.business_id = ANY(%s)
                AND dm.date BETWEEN %s AND %s
                AND ce.id IS NULL
                GROUP BY c.business_id, c.id, c.name
                HAVING SUM(dm.conversions) > 0
            ),
            reallocation_opportunity AS (
                SELECT 
                    ce1.business_id,
                    SUM(CASE WHEN ce1.efficiency_rank <= 3 THEN ce1.total_spend_micros ELSE 0 END) as efficient_spend,
                    SUM(CASE WHEN ce1.efficiency_rank > 3 THEN ce1.total_spend_micros ELSE 0 END) as inefficient_spend,
                    AVG(CASE WHEN ce1.efficiency_rank <= 3 THEN ce1.cpl_micros ELSE NULL END) as avg_efficient_cpl,
                    AVG(CASE WHEN ce1.efficiency_rank > 3 THEN ce1.cpl_micros ELSE NULL END) as avg_inefficient_cpl
                FROM campaign_efficiency ce1
                GROUP BY ce1.business_id
            )
            SELECT 
                b.name as business_name,
                ro.inefficient_spend / 1000000.0 as wasted_spend_usd,
                (ro.inefficient_spend / ro.avg_efficient_cpl - ro.inefficient_spend / ro.avg_inefficient_cpl) as missed_conversions,
                ((ro.inefficient_spend / ro.avg_efficient_cpl - ro.inefficient_spend / ro.avg_inefficient_cpl) * 
                 COALESCE((bc.config_value->>'rate')::DECIMAL, 0.10)) as estimated_missed_bookings
            FROM reallocation_opportunity ro
            JOIN businesses b ON ro.business_id = b.id
            LEFT JOIN business_config bc ON b.id = bc.business_id AND bc.config_name = 'booking_conversion_rate'
            ORDER BY wasted_spend_usd DESC
        """, self.db, params=[business_ids, date_range[0], date_range[1]])
```

## Future API Migration Strategy

### When to Build API

- **Team Growth:** Multiple developers need programmatic access
- **External Integrations:** Other systems need data access
- **Real-time Requirements:** Dashboard performance issues with direct DB
- **Security Needs:** Row-level security, API authentication required

### Migration Path

```python
# Current: Direct database access
def get_yield_curves(business_ids, date_range):
    return pd.read_sql(query, db_conn, params=[business_ids, date_range])

# Future: API client wrapper (same interface)
def get_yield_curves(business_ids, date_range):
    return api_client.get('/api/yield-curves', params={
        'business_ids': business_ids,
        'date_range': date_range
    })
```

### FastAPI Endpoint Structure (Future Reference)

```python
# When API becomes necessary
from fastapi import FastAPI, Depends
from .services import YieldCurveDataService

app = FastAPI()

@app.get("/api/businesses/{business_id}/yield-curves")
async def get_business_yield_curves(
    business_id: int,
    date_start: date,
    date_end: date,
    attribution_model: str = "time_decay",
    service: YieldCurveDataService = Depends()
):
    return service.get_business_comparison(
        business_ids=[business_id],
        date_range=(date_start, date_end),
        attribution_model=attribution_model
    )

@app.get("/api/portfolio/reallocation-opportunities")  
async def get_reallocation_opportunities(
    business_ids: List[int] = Query(),
    min_efficiency_gain: float = 0.1,
    service: YieldCurveDataService = Depends()
):
    return service.get_reallocation_recommendations(business_ids, min_efficiency_gain)
```

## Performance Considerations

### Database Connection Management

```python
# Connection pooling for Streamlit
import psycopg2.pool

class DatabaseManager:
    def __init__(self):
        self.connection_pool = psycopg2.pool.ThreadedConnectionPool(
            minconn=1,
            maxconn=10,
            host=os.getenv('DB_HOST'),
            database=os.getenv('DB_NAME'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD')
        )
    
    def get_connection(self):
        return self.connection_pool.getconn()
    
    def return_connection(self, conn):
        self.connection_pool.putconn(conn)
```

### Query Optimization

- **Prepared statements** for repeated queries
- **Connection pooling** for Streamlit multi-user access
- **Query result caching** for dashboard performance
- **Batch processing** for large data operations

### Campaign Exclusion Service

```python
class CampaignExclusionService:
    def __init__(self, db_connection):
        self.db = db_connection
    
    def get_excluded_campaigns(self, business_id: int, exclusion_type: str = 'all'):
        """Get campaigns excluded from analysis"""
        return pd.read_sql("""
            SELECT 
                c.id as campaign_id,
                c.name as campaign_name,
                ce.exclusion_reason,
                ce.excluded_from,
                ce.created_at,
                ce.created_by
            FROM campaign_exclusions ce
            JOIN campaigns c ON ce.campaign_id = c.id
            WHERE c.business_id = %s
            AND (%s = 'all' OR ce.excluded_from = %s)
            AND ce.active = TRUE
            ORDER BY ce.created_at DESC
        """, self.db, params=[business_id, exclusion_type, exclusion_type])
    
    def apply_exclusion_rules(self, business_id: int):
        """Apply business-level exclusion rules automatically"""
        cursor = self.db.cursor()
        
        # Get business exclusion rules
        rules = pd.read_sql("""
            SELECT rule_type, rule_value, exclusion_reason, excluded_from
            FROM exclusion_rules 
            WHERE business_id = %s AND active = TRUE
        """, self.db, params=[business_id])
        
        for _, rule in rules.iterrows():
            if rule.rule_type == 'campaign_name_contains':
                # Find campaigns matching name pattern
                cursor.execute("""
                    INSERT INTO campaign_exclusions (campaign_id, exclusion_reason, excluded_from, created_by)
                    SELECT 
                        c.id, 
                        %s, 
                        %s, 
                        'auto_rule'
                    FROM campaigns c
                    LEFT JOIN campaign_exclusions ce ON c.id = ce.campaign_id 
                        AND ce.exclusion_reason = %s 
                        AND ce.active = TRUE
                    WHERE c.business_id = %s
                    AND LOWER(c.name) LIKE LOWER(%s)
                    AND ce.id IS NULL
                """, [
                    rule.exclusion_reason,
                    rule.excluded_from, 
                    rule.exclusion_reason,
                    business_id,
                    f'%{rule.rule_value}%'
                ])
        
        self.db.commit()
        cursor.close()
    
    def exclude_campaign_manually(self, campaign_id: int, reason: str, excluded_from: str, user: str):
        """Manually exclude a specific campaign"""
        cursor = self.db.cursor()
        cursor.execute("""
            INSERT INTO campaign_exclusions (campaign_id, exclusion_reason, excluded_from, created_by)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (campaign_id, exclusion_reason) 
            DO UPDATE SET active = TRUE, created_by = EXCLUDED.created_by
        """, [campaign_id, reason, excluded_from, user])
        self.db.commit()
        cursor.close()
```

## Streamlit Integration Patterns

### Data Service Integration in Streamlit

```python
# streamlit_app.py
import streamlit as st
from services.yield_curve_service import YieldCurveDataService
from services.attribution_service import AttributionDataService
from services.configuration_service import ConfigurationService

# Initialize services with database connection
@st.cache_resource
def init_services():
    db_manager = DatabaseManager()
    return {
        'yield_curves': YieldCurveDataService(db_manager.get_connection()),
        'attribution': AttributionDataService(db_manager.get_connection()),
        'config': ConfigurationService(db_manager.get_connection())
    }

def main():
    services = init_services()
    
    # Navigation
    st.sidebar.title("Yield Curve Analytics")
    page = st.sidebar.selectbox("Select Page", [
        "📊 System Overview",
        "🎯 Portfolio Overview", 
        "💰 Money Left on Table",
        "🔍 Attribution Analysis",
        "📈 Business Deep Dives"
    ])
    
    if page == "🎯 Portfolio Overview":
        show_portfolio_overview(services)
    elif page == "💰 Money Left on Table":
        show_money_left_on_table(services)
    # ... other pages

def show_portfolio_overview(services):
    st.title("🎯 Portfolio Overview")
    
    # Business selection
    businesses = services['config'].get_all_businesses()
    selected_businesses = st.multiselect(
        "Select Businesses", 
        options=[b.id for b in businesses],
        default=[1, 2, 3],
        format_func=lambda x: next(b.name for b in businesses if b.id == x)
    )
    
    # Date range selection
    date_range = st.date_input(
        "Analysis Period",
        value=(datetime.now() - timedelta(days=365), datetime.now()),
        help="Default: Last 12 months"
    )
    
    if selected_businesses and date_range:
        # Get yield curve comparison data
        comparison_data = services['yield_curves'].get_business_comparison(
            date_range, 'time_decay'
        )
        
        # Filter for selected businesses
        filtered_data = comparison_data[
            comparison_data['business_id'].isin(selected_businesses)
        ]
        
        # Create visualization
        fig = create_yield_curve_comparison_chart(filtered_data)
        st.plotly_chart(fig, use_container_width=True)
        
        # Show reallocation recommendations
        st.subheader("Capital Reallocation Opportunities")
        recommendations = services['yield_curves'].get_reallocation_recommendations(
            selected_businesses, min_efficiency_gain=0.1
        )
        
        if not recommendations.empty:
            st.dataframe(
                recommendations[['business_name', 'recommended_action', 'projected_efficiency_gain']],
                use_container_width=True
            )
        else:
            st.info("No reallocation opportunities identified with current thresholds.")
```

### Caching Strategy for Performance

```python
# Cache expensive database queries
@st.cache_data(ttl=3600)  # Cache for 1 hour
def get_cached_yield_curves(business_ids: List[int], start_date: str, end_date: str):
    services = init_services()
    return services['yield_curves'].get_business_comparison(
        (start_date, end_date)
    )

@st.cache_data(ttl=1800)  # Cache for 30 minutes  
def get_cached_attribution_analysis(business_id: int, start_date: str, end_date: str):
    services = init_services()
    return services['attribution'].get_attribution_comparison(
        [business_id], (start_date, end_date)
    )

# Cache configuration data (changes infrequently)
@st.cache_data(ttl=7200)  # Cache for 2 hours
def get_cached_business_config(business_id: int):
    services = init_services()
    return services['config'].get_all_business_configs(business_id)
```

## Data Validation Layer

```python
class DataValidator:
    @staticmethod
    def validate_date_range(date_range: tuple):
        """Validate date range inputs"""
        if len(date_range) != 2:
            raise ValueError("Date range must contain start and end dates")
        if date_range[0] > date_range[1]:
            raise ValueError("Start date must be before end date")
        if date_range[1] > datetime.now().date():
            raise ValueError("End date cannot be in the future")
        if (date_range[1] - date_range[0]).days > 365:
            raise ValueError("Date range cannot exceed 365 days")
        return True
    
    @staticmethod  
    def validate_business_ids(business_ids: List[int], db_connection):
        """Validate business IDs exist and are active"""
        if not business_ids:
            raise ValueError("At least one business ID required")
        
        existing_ids = pd.read_sql("""
            SELECT id FROM businesses WHERE id = ANY(%s) AND active = TRUE
        """, db_connection, params=[business_ids])
        
        if len(existing_ids) != len(business_ids):
            missing_ids = set(business_ids) - set(existing_ids['id'].tolist())
            raise ValueError(f"Invalid business IDs: {missing_ids}")
        return True
    
    @staticmethod
    def validate_attribution_model(model: str):
        """Validate attribution model selection"""
        valid_models = [
            'time_decay', 'position_based', 'linear', 
            'first_touch', 'last_touch', 'custom_mmm_v1'
        ]
        if model not in valid_models:
            raise ValueError(f"Attribution model must be one of: {valid_models}")
        return True
    
    @staticmethod
    def validate_campaign_tags(tag_filters: Dict[str, List[str]], db_connection):
        """Validate campaign tag filters"""
        if not tag_filters:
            return True
        
        # Check tag types exist
        tag_types = list(tag_filters.keys())
        existing_types = pd.read_sql("""
            SELECT DISTINCT tag_type FROM tag_definitions 
            WHERE tag_type = ANY(%s)
        """, db_connection, params=[tag_types])
        
        if len(existing_types) != len(tag_types):
            missing_types = set(tag_types) - set(existing_types['tag_type'].tolist())
            raise ValueError(f"Invalid tag types: {missing_types}")
        
        return True

# Usage in services
class YieldCurveDataService:
    def get_business_comparison(self, date_range: tuple, attribution_model: str = 'time_decay'):
        # Validate inputs
        DataValidator.validate_date_range(date_range)
        DataValidator.validate_attribution_model(attribution_model)
        
        # Proceed with query...
        return pd.read_sql(query, self.db, params=params)
```

## Error Handling Strategy

```python
# Custom exception hierarchy
class YieldCurveException(Exception):
    """Base exception for yield curve system"""
    pass

class InsufficientDataException(YieldCurveException):
    """Raised when campaign lacks minimum data for analysis"""
    pass

class ConfigurationException(YieldCurveException):
    """Raised when business configuration is invalid"""
    pass

class ExternalAPIException(YieldCurveException):
    """Raised when external API calls fail"""
    pass

# Service-level error handling
class YieldCurveDataService:
    def get_business_comparison(self, date_range: tuple, attribution_model: str = 'time_decay'):
        try:
            # Validation
            DataValidator.validate_date_range(date_range)
            DataValidator.validate_attribution_model(attribution_model)
            
            # Database query
            result = pd.read_sql(query, self.db, params=params)
            
            if result.empty:
                raise InsufficientDataException(
                    f"No yield curve data available for date range {date_range}"
                )
            
            return result
            
        except psycopg2.Error as e:
            logger.error(f"Database error in get_business_comparison: {e}")
            raise YieldCurveException(f"Database query failed: {str(e)}")
        except Exception as e:
            logger.error(f"Unexpected error in get_business_comparison: {e}")
            raise

# Streamlit error handling
def show_portfolio_overview(services):
    try:
        comparison_data = services['yield_curves'].get_business_comparison(
            date_range, attribution_model
        )
        # Display data...
        
    except InsufficientDataException as e:
        st.warning(f"Insufficient data: {e}")
        st.info("Try selecting a longer date range or different businesses.")
    except ConfigurationException as e:
        st.error(f"Configuration error: {e}")
        st.info("Please check business configuration settings.")
    except YieldCurveException as e:
        st.error(f"Analysis error: {e}")
        logger.error(f"Portfolio overview error: {e}")
    except Exception as e:
        st.error("An unexpected error occurred. Please try again.")
        logger.error(f"Unexpected portfolio overview error: {e}")
```

## Testing Strategy for Direct Database Access

```python
# Test utilities for database testing
class TestDatabaseManager:
    def __init__(self):
        self.test_db = self._create_test_database()
    
    def _create_test_database(self):
        # Create in-memory SQLite for testing
        conn = sqlite3.connect(':memory:')
        # Load schema
        with open('schema.sql') as f:
            conn.executescript(f.read())
        return conn
    
    def seed_test_data(self):
        # Insert test businesses, campaigns, metrics
        test_data = {
            'businesses': [
                (1, 'Test Wilderness', 'test-account-1'),
                (2, 'Test Jacada', 'test-account-2')
            ],
            'campaigns': [
                (1, 1, 'test-campaign-1', 'Test Campaign 1', 'search'),
                (2, 1, 'test-campaign-2', 'Test Campaign 2', 'display')
            ]
        }
        # Insert test data...

# Unit tests for services
class TestYieldCurveDataService(unittest.TestCase):
    def setUp(self):
        self.test_db = TestDatabaseManager()
        self.test_db.seed_test_data()
        self.service = YieldCurveDataService(self.test_db.test_db)
    
    def test_get_business_comparison_valid_data(self):
        """Test business comparison with valid test data"""
        result = self.service.get_business_comparison(
            date_range=(datetime(2024, 1, 1).date(), datetime(2024, 12, 31).date()),
            attribution_model='time_decay'
        )
        
        self.assertIsInstance(result, pd.DataFrame)
        self.assertGreater(len(result), 0)
        self.assertIn('business_name', result.columns)
        self.assertIn('marginal_cpl_usd', result.columns)
    
    def test_get_business_comparison_insufficient_data(self):
        """Test handling of insufficient data scenarios"""
        with self.assertRaises(InsufficientDataException):
            self.service.get_business_comparison(
                date_range=(datetime(2025, 1, 1).date(), datetime(2025, 1, 2).date()),
                attribution_model='time_decay'
            )
```

This completes the API specifications document. Should I proceed with the next document (code-standards.md) or would you like to review this one first?