---
title: "Code_Standards"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# Code Standards & Development Guidelines

## Overview

Consistent development standards for AI-assisted rapid MVP development while maintaining code quality for future extensibility and team collaboration.

## Python Code Standards

### Naming Conventions

```python
# Variables & Functions: snake_case
campaign_efficiency_score = calculate_marginal_cpl()
business_config_manager = BusinessConfigManager()
attribution_weights = get_attribution_weights()

# Classes: PascalCase  
class YieldCurveCalculator:
class AttributionModelLibrary:
class BusinessConfigManager:

# Constants: UPPER_SNAKE_CASE
DEFAULT_ATTRIBUTION_MODEL = 'time_decay'
MINIMUM_CONVERSIONS_THRESHOLD = 3
MAX_ATTRIBUTION_WINDOW_DAYS = 180

# Business Prefixes for Clarity
wilderness_campaigns = get_campaigns(business_id=1)
jacada_yield_curves = calculate_curves(business_id=2)  
yellowzebra_attribution = process_attribution(business_id=3)

# Database Fields: snake_case matching schema
spend_micros = row['spend_micros']
campaign_id = row['campaign_id']
attribution_model = 'time_decay'
```

### Function Design Standards

```python
# Clear, descriptive function names with type hints
def calculate_campaign_eligibility(campaign_metrics: CampaignMetrics, 
                                  business_config: dict) -> EligibilityResult:
    """
    Determine if campaign has sufficient data for yield curve analysis.
    
    Args:
        campaign_metrics: Historical performance data with spend/conversions
        business_config: Business-specific thresholds and settings
        
    Returns:
        EligibilityResult with eligible flag, thresholds used, and reasons
        
    Raises:
        InsufficientDataError: When campaign lacks minimum required data
        ConfigurationError: When business config is invalid
    """
    if not campaign_metrics.conversions:
        raise InsufficientDataError("Campaign has zero conversions")
    
    min_spend = business_config.get('min_spend_usd', 450)
    min_conversions = business_config.get('min_conversions', 3)
    
    eligible = (
        campaign_metrics.total_spend >= min_spend and 
        campaign_metrics.conversions >= min_conversions
    )
    
    return EligibilityResult(
        eligible=eligible,
        min_spend_needed=min_spend,
        current_spend=campaign_metrics.total_spend,
        thresholds_used=business_config
    )

# Type hints for all public functions
def get_attribution_weights(touchpoints: List[TouchPoint], 
                          model: str = 'time_decay',
                          half_life_days: int = 30) -> List[float]:
    """Calculate attribution weights for conversion touchpoints."""
    pass

# Return structured data, avoid tuples
@dataclass
class YieldCurveResult:
    campaign_id: int
    business_id: int
    spend_buckets: List[SpendBucket] 
    marginal_cpl_usd: List[float]
    efficiency_score: float
    calculation_date: date
    model_config: dict

# Use enums for constrained values
class AttributionModel(Enum):
    TIME_DECAY = 'time_decay'
    POSITION_BASED = 'position_based'
    LINEAR = 'linear'  
    FIRST_TOUCH = 'first_touch'
    LAST_TOUCH = 'last_touch'
    CUSTOM_MMM_V1 = 'custom_mmm_v1'
```

### Error Handling Standards

```python
# Custom exception hierarchy
class YieldCurveException(Exception):
    """Base exception for yield curve system"""
    pass

class InsufficientDataError(YieldCurveException):
    """Raised when campaign lacks minimum data for analysis"""
    pass

class ConfigurationError(YieldCurveException):  
    """Raised when business configuration is invalid or missing"""
    pass

class GoogleAdsAPIError(YieldCurveException):
    """Raised when Google Ads API calls fail"""
    pass

class AttributionCalculationError(YieldCurveException):
    """Raised when attribution model calculations fail"""
    pass

# Structured error handling with context
def calculate_yield_curves(business_id: int, date_range: tuple) -> List[YieldCurveResult]:
    try:
        campaigns = get_eligible_campaigns(business_id)
        results = []
        
        for campaign in campaigns:
            try:
                metrics = get_campaign_metrics(campaign.id, date_range)
                curve = calculate_single_curve(metrics)
                results.append(curve)
            except InsufficientDataError as e:
                logger.warning(f"Campaign {campaign.id} ({campaign.name}) ineligible: {e}")
                continue  # Skip this campaign, continue with others
            except Exception as e:
                logger.error(f"Unexpected error for campaign {campaign.id}: {e}")
                # Don't fail entire batch for one campaign
                continue
                
        if not results:
            raise InsufficientDataError(f"No eligible campaigns found for business {business_id}")
            
        return results
        
    except GoogleAdsAPIError as e:
        logger.error(f"Google Ads API error for business {business_id}: {e}")
        raise  # Re-raise API errors - these need upstream handling
    except Exception as e:
        logger.error(f"Unexpected error calculating yield curves for business {business_id}: {e}")
        raise YieldCurveException(f"Yield curve calculation failed: {str(e)}")

# Graceful degradation with fallbacks
def get_booking_conversion_rate(business_id: int) -> float:
    """Get booking rate with fallback to conservative default"""
    try:
        config = config_manager.get_business_config(business_id, 'booking_conversion_rate')
        rate = config.get('rate')
        
        if rate is None or rate <= 0 or rate > 1:
            logger.warning(f"Invalid booking rate for business {business_id}, using default")
            return 0.08  # Conservative fallback
            
        return rate
    except Exception as e:
        logger.warning(f"Error getting booking rate for business {business_id}: {e}")
        return 0.08  # Always return a usable value
```

## Architecture Patterns

### Repository Pattern for Data Access

```python
# Abstract repository interface
from abc import ABC, abstractmethod

class CampaignRepository(ABC):
    @abstractmethod
    def get_campaigns_by_business(self, business_id: int, include_paused: bool = False) -> List[Campaign]:
        """Get all campaigns for a business"""
        pass
    
    @abstractmethod  
    def get_daily_metrics(self, campaign_id: int, date_range: tuple) -> pd.DataFrame:
        """Get daily performance metrics for campaign"""
        pass
    
    @abstractmethod
    def get_campaigns_by_tags(self, tag_filters: Dict[str, List[str]]) -> List[Campaign]:
        """Get campaigns matching tag criteria"""
        pass

# Concrete PostgreSQL implementation
class PostgresCampaignRepository(CampaignRepository):
    def __init__(self, db_connection):
        self.db = db_connection
    
    def get_campaigns_by_business(self, business_id: int, include_paused: bool = False) -> List[Campaign]:
        status_filter = "c.status = 'active'" if not include_paused else "c.status IN ('active', 'paused')"
        
        df = pd.read_sql(f"""
            SELECT 
                c.id, c.name, c.external_id, c.campaign_type, c.status,
                c.business_id, b.name as business_name
            FROM campaigns c
            JOIN businesses b ON c.business_id = b.id
            WHERE c.business_id = %s AND {status_filter}
            ORDER BY c.name
        """, self.db, params=[business_id])
        
        return [Campaign(**row) for _, row in df.iterrows()]
    
    def get_daily_metrics(self, campaign_id: int, date_range: tuple) -> pd.DataFrame:
        return pd.read_sql("""
            SELECT 
                date,
                spend_micros / 1000000.0 as spend_usd,
                conversions,
                impressions,
                clicks,
                CASE WHEN conversions > 0 
                     THEN spend_micros / conversions / 1000000.0 
                     ELSE NULL END as cpl_usd
            FROM daily_metrics
            WHERE campaign_id = %s 
            AND date BETWEEN %s AND %s
            ORDER BY date
        """, self.db, params=[campaign_id, date_range[0], date_range[1]])
```

### Service Layer for Business Logic

```python
class YieldCurveService:
    def __init__(self, 
                 campaign_repo: CampaignRepository,
                 config_manager: BusinessConfigManager,
                 exclusion_manager: CampaignExclusionManager):
        self.campaign_repo = campaign_repo
        self.config_manager = config_manager  
        self.exclusion_manager = exclusion_manager
        self.calculator = YieldCurveCalculator()
        
    def calculate_business_yield_curves(self, business_id: int, 
                                      date_range: tuple) -> BusinessYieldResult:
        """
        High-level business logic orchestration for yield curve calculation.
        
        Handles: configuration loading, campaign filtering, eligibility checks,
        yield curve calculations, and result aggregation.
        """
        logger.info(f"Calculating yield curves for business {business_id}, date range {date_range}")
        
        # Get business configuration
        config = self.config_manager.get_business_config(business_id, 'yield_curve_thresholds')
        
        # Get campaigns and apply exclusions
        all_campaigns = self.campaign_repo.get_campaigns_by_business(business_id)
        eligible_campaigns = self.exclusion_manager.filter_eligible_campaigns(
            all_campaigns, analysis_type='yield_curves'
        )
        
        logger.info(f"Found {len(eligible_campaigns)} eligible campaigns out of {len(all_campaigns)} total")
        
        # Calculate yield curves for eligible campaigns
        results = []
        insufficient_data_campaigns = []
        
        for campaign in eligible_campaigns:
            try:
                metrics = self.campaign_repo.get_daily_metrics(campaign.id, date_range)
                
                # Check data sufficiency
                eligibility = self._assess_campaign_eligibility(metrics, config)
                if not eligibility.eligible:
                    insufficient_data_campaigns.append((campaign, eligibility.reason))
                    continue
                
                # Calculate yield curve
                yield_curve = self.calculator.calculate_curve(metrics, config)
                yield_curve.campaign_name = campaign.name
                results.append(yield_curve)
                
            except Exception as e:
                logger.error(f"Error calculating curve for campaign {campaign.id} ({campaign.name}): {e}")
                continue
        
        # Generate restructure recommendations for insufficient data campaigns
        restructure_recommendations = self._generate_restructure_recommendations(
            insufficient_data_campaigns, business_id
        )
        
        return BusinessYieldResult(
            business_id=business_id,
            business_name=self.config_manager.get_business_name(business_id),
            date_range=date_range,
            yield_curves=results,
            insufficient_data_campaigns=len(insufficient_data_campaigns),
            restructure_recommendations=restructure_recommendations,
            calculation_timestamp=datetime.now()
        )
    
    def _assess_campaign_eligibility(self, metrics: pd.DataFrame, config: dict) -> EligibilityResult:
        """Private method to assess if campaign has sufficient data"""
        total_spend = metrics['spend_usd'].sum()
        total_conversions = metrics['conversions'].sum()
        days_active = len(metrics[metrics['spend_usd'] > 0])
        
        min_spend = config.get('min_spend_usd', 450)
        min_conversions = config.get('min_conversions', 3)
        min_days = config.get('min_days', 30)
        
        reasons = []
        if total_spend < min_spend:
            reasons.append(f"Spend ${total_spend:.0f} < ${min_spend} minimum")
        if total_conversions < min_conversions:
            reasons.append(f"Conversions {total_conversions} < {min_conversions} minimum")
        if days_active < min_days:
            reasons.append(f"Active days {days_active} < {min_days} minimum")
        
        return EligibilityResult(
            eligible=len(reasons) == 0,
            reason="; ".join(reasons) if reasons else "Sufficient data",
            thresholds_used=config
        )
```

### Data Transfer Objects (DTOs)

```python
@dataclass
class CampaignSummary:
    """Data transfer object for campaign summary information"""
    id: int
    name: str
    business_id: int
    business_name: str
    total_spend_usd: float
    total_conversions: int
    cpl_usd: float
    efficiency_score: float
    days_active: int
    
    @property
    def spend_formatted(self) -> str:
        return f"${self.total_spend_usd:,.0f}"
    
    @property 
    def cpl_formatted(self) -> str:
        return f"${self.cpl_usd:.2f}"

@dataclass  
class AttributionComparison:
    """DTO for attribution model comparison results"""
    campaign_id: int
    campaign_name: str
    business_name: str
    attribution_results: Dict[str, float]  # model_name -> attributed_conversions
    bias_metrics: Dict[str, float]  # bias analysis between models
    confidence_score: float  # consistency across models
    
    @property
    def last_touch_advantage(self) -> float:
        """Calculate last-touch advantage over first-touch"""
        last_touch = self.attribution_results.get('last_touch', 0)
        first_touch = self.attribution_results.get('first_touch', 0)
        if first_touch > 0:
            return ((last_touch / first_touch) - 1) * 100
        return 0.0

@dataclass
class ReallocationOpportunity:
    """DTO for capital reallocation recommendations"""
    source_campaign_id: int
    source_campaign_name: str
    target_campaign_id: int
    target_campaign_name: str
    recommended_amount_usd: float
    projected_efficiency_gain: float
    confidence_level: str  # 'high', 'medium', 'low'
    rationale: str
```

## Database Standards

### Connection Management

```python
import psycopg2
from psycopg2 import pool
from contextlib import contextmanager
import os

class DatabaseManager:
    """Centralized database connection management with pooling"""
    
    def __init__(self):
        self.connection_pool = None
        self._initialize_pool()
    
    def _initialize_pool(self):
        """Initialize connection pool with environment-based configuration"""
        try:
            self.connection_pool = psycopg2.pool.ThreadedConnectionPool(
                minconn=2,
                maxconn=10,
                host=os.getenv('DB_HOST', 'localhost'),
                port=os.getenv('DB_PORT', 5432),
                database=os.getenv('DB_NAME', 'yield_curves'),
                user=os.getenv('DB_USER', 'postgres'),
                password=os.getenv('DB_PASSWORD'),
                options='-c default_transaction_isolation=read_committed'
            )
            logger.info("Database connection pool initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize database connection pool: {e}")
            raise
    
    @contextmanager
    def get_connection(self):
        """Context manager for database connections"""
        if not self.connection_pool:
            raise RuntimeError("Database connection pool not initialized")
            
        conn = None
        try:
            conn = self.connection_pool.getconn()
            yield conn
        except Exception as e:
            if conn:
                conn.rollback()
            logger.error(f"Database operation error: {e}")
            raise
        finally:
            if conn:
                self.connection_pool.putconn(conn)
    
    def close_all_connections(self):
        """Close all connections in pool (for cleanup)"""
        if self.connection_pool:
            self.connection_pool.closeall()

# Usage pattern in services
class BaseService:
    def __init__(self, db_manager: DatabaseManager):
        self.db_manager = db_manager
    
    def _execute_query(self, query: str, params: list = None) -> pd.DataFrame:
        """Execute SELECT query and return DataFrame"""
        with self.db_manager.get_connection() as conn:
            return pd.read_sql(query, conn, params=params)
    
    def _execute_command(self, command: str, params: list = None) -> int:
        """Execute INSERT/UPDATE/DELETE and return affected rows"""
        with self.db_manager.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(command, params)
            affected_rows = cursor.rowcount
            conn.commit()
            cursor.close()
            return affected_rows
```

### Query Construction Standards

```python
class SafeQueryBuilder:
    """Utility class for building dynamic queries safely"""
    
    @staticmethod
    def build_tag_filter_query(tag_filters: Dict[str, List[str]]) -> tuple:
        """
        Build WHERE clause for campaign tag filtering.
        Returns (where_clause, parameters)
        """
        if not tag_filters:
            return "1=1", []
        
        tag_conditions = []
        params = []
        
        for tag_type, tag_values in tag_filters.items():
            if not tag_values:
                continue
                
            placeholders = ','.join(['%s'] * len(tag_values))
            tag_conditions.append(f"(ct.tag_type = %s AND ct.tag_value IN ({placeholders}))")
            params.extend([tag_type] + tag_values)
        
        where_clause = ' OR '.join(tag_conditions) if tag_conditions else "1=1"
        return where_clause, params
    
    @staticmethod
    def build_date_filter(date_column: str, date_range: tuple) -> tuple:
        """Build date range filter clause"""
        return f"{date_column} BETWEEN %s AND %s", [date_range[0], date_range[1]]
    
    @staticmethod
    def build_business_filter(business_ids: List[int]) -> tuple:
        """Build business ID filter clause"""
        if not business_ids:
            return "1=1", []
        
        placeholders = ','.join(['%s'] * len(business_ids))
        return f"business_id IN ({placeholders})", business_ids

# Usage example
def get_filtered_campaigns(self, business_ids: List[int], 
                          tag_filters: Dict[str, List[str]], 
                          date_range: tuple) -> pd.DataFrame:
    """Get campaigns with complex filtering"""
    
    # Build filter clauses
    business_clause, business_params = SafeQueryBuilder.build_business_filter(business_ids)
    tag_clause, tag_params = SafeQueryBuilder.build_tag_filter_query(tag_filters)
    date_clause, date_params = SafeQueryBuilder.build_date_filter('dm.date', date_range)
    
    # Combine parameters
    all_params = business_params + tag_params + date_params
    
    # Build final query
    query = f"""
        SELECT DISTINCT 
            c.id, c.name, c.business_id,
            SUM(dm.spend_micros) / 1000000.0 as total_spend_usd,
            SUM(dm.conversions) as total_conversions
        FROM campaigns c
        JOIN campaign_tags ct ON c.id = ct.campaign_id
        JOIN daily_metrics dm ON c.id = dm.campaign_id
        WHERE {business_clause}
        AND ({tag_clause})
        AND {date_clause}
        GROUP BY c.id, c.name, c.business_id
        ORDER BY total_spend_usd DESC
    """
    
    return self._execute_query(query, all_params)
```

## Logging Standards

```python
import logging
import sys
from datetime import datetime

def setup_logging(level: str = 'INFO', log_file: str = None):
    """Configure application logging"""
    
    # Create formatter
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(funcName)s:%(lineno)d - %(message)s'
    )
    
    # Configure root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(getattr(logging, level.upper()))
    
    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    root_logger.addHandler(console_handler)
    
    # File handler (optional)
    if log_file:
        file_handler = logging.FileHandler(log_file)
        file_handler.setFormatter(formatter)
        root_logger.addHandler(file_handler)
    
    # Set specific logger levels
    logging.getLogger('psycopg2').setLevel(logging.WARNING)
    logging.getLogger('urllib3').setLevel(logging.WARNING)

# Usage in modules
logger = logging.getLogger(__name__)

class YieldCurveCalculator:
    def calculate_curve(self, metrics: pd.DataFrame) -> YieldCurveResult:
        logger.info(f"Calculating yield curve for {len(metrics)} data points")
        
        try:
            # Calculation logic
            result = self._perform_calculation(metrics)
            logger.info(f"Yield curve calculated successfully, efficiency score: {result.efficiency_score:.3f}")
            return result
            
        except Exception as e:
            logger.error(f"Yield curve calculation failed: {e}", exc_info=True)
            raise
```

## Testing Standards

```python
import unittest
import pandas as pd
from unittest.mock import Mock, patch
from datetime import date, datetime

class TestYieldCurveService(unittest.TestCase):
    """Test suite for YieldCurveService business logic"""
    
    def setUp(self):
        """Set up test fixtures"""
        self.mock_campaign_repo = Mock(spec=CampaignRepository)
        self.mock_config_manager = Mock(spec=BusinessConfigManager)
        self.mock_exclusion_manager = Mock(spec=CampaignExclusionManager)
        
        self.service = YieldCurveService(
            self.mock_campaign_repo,
            self.mock_config_manager,
            self.mock_exclusion_manager
        )
        
        # Test data
        self.test_business_id = 1
        self.test_date_range = (date(2024, 1, 1), date(2024, 12, 31))
        
    def test_calculate_business_yield_curves_success(self):
        """Test successful yield curve calculation"""
        # Mock repository responses
        test_campaigns = [
            Campaign(id=1, name='Test Campaign 1', business_id=1),
            Campaign(id=2, name='Test Campaign 2', business_id=1)
        ]
        self.mock_campaign_repo.get_campaigns_by_business.return_value = test_campaigns
        self.mock_exclusion_manager.filter_eligible_campaigns.return_value = test_campaigns
        
        # Mock configuration
        test_config = {'min_spend_usd': 500, 'min_conversions': 3, 'min_days': 30}
        self.mock_config_manager.get_business_config.return_value = test_config
        
        # Mock metrics data
        test_metrics = pd.DataFrame({
            'date': pd.date_range('2024-01-01', periods=100),
            'spend_usd': [10.0] * 100,
            'conversions': [1] * 100
        })
        self.mock_campaign_repo.get_daily_metrics.return_value = test_metrics
        
        # Execute
        result = self.service.calculate_business_yield_curves(
            self.test_business_id, self.test_date_range
        )
        
        # Assertions
        self.assertIsInstance(result, BusinessYieldResult)
        self.assertEqual(result.business_id, self.test_business_id)
        self.assertGreater(len(result.yield_curves), 0)
        
    def test_insufficient_data_handling(self):
        """Test handling of campaigns with insufficient data"""
        # Mock campaigns with insufficient data
        test_campaigns = [Campaign(id=1, name='Low Volume Campaign', business_id=1)]
        self.mock_campaign_repo.get_campaigns_by_business.return_value = test_campaigns
        self.mock_exclusion_manager.filter_eligible_campaigns.return_value = test_campaigns
        
        # Mock insufficient metrics
        insufficient_metrics = pd.DataFrame({
            'date': pd.date_range('2024-01-01', periods=5),
            'spend_usd': [1.0] * 5,  # Below threshold
            'conversions': [0] * 5   # No conversions
        })
        self.mock_campaign_repo.get_daily_metrics.return_value = insufficient_metrics
        
        # Execute
        result = self.service.calculate_business_yield_curves(
            self.test_business_id, self.test_date_range
        )
        
        # Should handle gracefully
        self.assertEqual(len(result.yield_curves), 0)
        self.assertGreater(result.insufficient_data_campaigns, 0)

# Integration test utilities
class TestDatabaseManager:
    """Test database manager for integration tests"""
    
    def __init__(self):
        self.test_db_connection = self._create_test_database()
    
    def _create_test_database(self):
        """Create in-memory test database with schema"""
        import sqlite3
        conn = sqlite3.connect(':memory:')
        
        # Load and execute schema
        schema_path = os.path.join(os.path.dirname(__file__), 'test_schema.sql')
        with open(schema_path, 'r') as f:
            conn.executescript(f.read())
        
        return conn
    
    def seed_test_data(self):
        """Insert test data for integration tests"""
        cursor = self.test_db_connection.cursor()
        
        # Insert test businesses
        cursor.execute("INSERT INTO businesses (id, name) VALUES (1, 'Test Wilderness')")
        cursor.execute("INSERT INTO businesses (id, name) VALUES (2, 'Test Jacada')")
        
        # Insert test campaigns
        cursor.execute("""
            INSERT INTO campaigns (id, business_id, name, external_id, campaign_type, status)
            VALUES (1, 1, 'Test Campaign 1', 'ext-1', 'search', 'active')
        """)
        
        # Insert test metrics
        for i in range(30):
            cursor.execute("""
                INSERT INTO daily_metrics (date, campaign_id, spend_micros, conversions, impressions, clicks)
                VALUES (date('2024-01-01', '+{} days'), 1, 50000000, 2, 1000, 100)
            """.format(i))
        
        self.test_db_connection.commit()
```

## Code Review Checklist

### Before Committing Code

- [ ] **Type hints** added to all public functions
- [ ] **Docstrings** with Args, Returns, Raises sections
- [ ] **Error handling** with appropriate custom exceptions
- [ ] **Logging** at appropriate levels (info for major operations, error for failures)
- [ ] **Input validation** for public methods
- [ ] **Business logic** separated from data access logic
- [ ] **Constants** extracted and properly named
- [ ] **Database queries** use parameterized statements
- [ ] **Resource cleanup** (connections, cursors) handled properly

### AI Development Integration

- [ ] **Function signatures** clear enough for AI code completion
- [ ] **Complex algorithms** broken into smaller, testable functions
- [ ] **Configuration** externalized, not hardcoded
- [ ] **Test scenarios** documented for AI-assisted test generation
- [ ] **Error messages** descriptive enough for AI debugging assistance

## Performance Standards

### Database Query Optimization

```python
# Good: Specific columns, proper indexing
def get_campaign_summary(self, business_id: int, date_range: tuple) -> pd.DataFrame:
    return self._execute_query("""
        SELECT 
            c.id,
            c.name,
            SUM(dm.spend_micros) / 1000000.0 as total_spend_usd,
            SUM(dm.conversions) as total_conversions
        FROM campaigns c
        JOIN daily_metrics dm ON c.id = dm.campaign_id
        WHERE c.business_id = %s 
        AND dm.date BETWEEN %s AND %s
        GROUP BY c.id, c.name
        ORDER BY total_spend_usd DESC
        LIMIT 50
    """, [business_id, date_range[0], date_range[1]])

# Avoid: SELECT *, no LIMIT, inefficient JOINs
```

### Memory Management

```python
# Process large datasets in chunks
def process_large_attribution_dataset(self, conversion_data: pd.DataFrame):
    chunk_size = 1000
    results = []
    
    for i in range(0, len(conversion_data), chunk_size):
        chunk = conversion_data.iloc[i:i+chunk_size]
        chunk_results = self._process_attribution_chunk(chunk)
        results.extend(chunk_results)
        
        # Clear intermediate results
        del chunk_results
        
    return results
```

This completes the **code-standards.md** document. Ready for **deployment-guide.md** next?