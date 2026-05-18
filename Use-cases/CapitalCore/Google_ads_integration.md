---
title: "Google_ads_integration"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# Google Ads Integration Guide

## Overview

Comprehensive integration with Google Ads API v16 for collecting campaign performance data, conversion tracking, and attribution analysis across multiple business accounts.

## API Architecture

### Integration Strategy

**Batch Processing Approach:**

- Nightly data collection via Celery workers
- Rate limit management with exponential backoff
- Delta updates for efficiency (only changed data)
- Error handling with retry mechanisms

**Multi-Account Management:**

- Business-specific Google Ads accounts
- Centralized API credential management
- Account-level data isolation
- Cross-account performance comparison

### API Access Requirements

#### 1. Google Ads API Setup

**Developer Token:**

```bash
# Environment variable
GOOGLE_ADS_DEVELOPER_TOKEN=your_developer_token_here
```

**OAuth2 Credentials:**

```bash
GOOGLE_ADS_CLIENT_ID=your_client_id
GOOGLE_ADS_CLIENT_SECRET=your_client_secret
GOOGLE_ADS_REFRESH_TOKEN=your_refresh_token
```

**Account Access:**

```bash
# Business-specific account IDs
WILDERNESS_GOOGLE_ADS_ACCOUNT_ID=123-456-7890
JACADA_GOOGLE_ADS_ACCOUNT_ID=234-567-8901
YELLOWZEBRA_GOOGLE_ADS_ACCOUNT_ID=345-678-9012
```

#### 2. API Permissions Required

- **Read access** to campaigns, ad groups, keywords
- **Read access** to performance metrics and conversion data
- **Read access** to attribution data and conversion paths
- **NO write access** required (read-only integration)

### Authentication Flow

```python
from google.ads.googleads.client import GoogleAdsClient
from google.oauth2.credentials import Credentials
import os

class GoogleAdsAuthenticator:
    def __init__(self):
        self.developer_token = os.getenv('GOOGLE_ADS_DEVELOPER_TOKEN')
        self.client_id = os.getenv('GOOGLE_ADS_CLIENT_ID')
        self.client_secret = os.getenv('GOOGLE_ADS_CLIENT_SECRET')
        self.refresh_token = os.getenv('GOOGLE_ADS_REFRESH_TOKEN')
    
    def get_client(self, customer_id):
        """Get authenticated Google Ads client for specific account"""
        credentials = Credentials(
            token=None,
            refresh_token=self.refresh_token,
            token_uri="https://oauth2.googleapis.com/token",
            client_id=self.client_id,
            client_secret=self.client_secret
        )
        
        return GoogleAdsClient(
            credentials=credentials,
            developer_token=self.developer_token,
            version="v16"
        )
```

## Data Collection Pipeline

### 1. Campaign Data Collection

#### Campaign Structure

```python
class GoogleAdsCampaignCollector:
    def __init__(self, client, customer_id):
        self.client = client
        self.customer_id = customer_id
        self.service = client.get_service("GoogleAdsService")
    
    def collect_campaigns(self):
        """Collect campaign structure and metadata"""
        query = """
            SELECT 
                campaign.id,
                campaign.name,
                campaign.status,
                campaign.advertising_channel_type,
                campaign.bidding_strategy_type,
                campaign.start_date,
                campaign.end_date,
                campaign.budget.amount_micros,
                campaign.budget.delivery_method
            FROM campaign
            WHERE campaign.status IN ('ENABLED', 'PAUSED')
            ORDER BY campaign.name
        """
        
        response = self.service.search(
            customer_id=self.customer_id,
            query=query
        )
        
        campaigns = []
        for row in response:
            campaigns.append({
                'external_id': str(row.campaign.id),
                'name': row.campaign.name,
                'status': self._map_campaign_status(row.campaign.status),
                'campaign_type': self._map_channel_type(row.campaign.advertising_channel_type),
                'bid_strategy': self._map_bid_strategy(row.campaign.bidding_strategy_type),
                'budget_micros': row.campaign.budget.amount_micros,
                'start_date': row.campaign.start_date,
                'end_date': row.campaign.end_date
            })
        
        return campaigns
    
    def _map_campaign_status(self, status):
        """Map Google Ads status to internal status"""
        mapping = {
            'ENABLED': 'active',
            'PAUSED': 'paused',
            'REMOVED': 'removed'
        }
        return mapping.get(str(status), 'unknown')
    
    def _map_channel_type(self, channel_type):
        """Map advertising channel type to internal campaign type"""
        mapping = {
            'SEARCH': 'search',
            'DISPLAY': 'display',
            'SHOPPING': 'shopping',
            'VIDEO': 'video',
            'MULTI_CHANNEL': 'multi_channel'
        }
        return mapping.get(str(channel_type), 'unknown')
```

#### Campaign Performance Data

```python
class GoogleAdsMetricsCollector:
    def __init__(self, client, customer_id):
        self.client = client
        self.customer_id = customer_id
        self.service = client.get_service("GoogleAdsService")
    
    def collect_daily_metrics(self, start_date, end_date):
        """Collect daily performance metrics for campaigns"""
        query = f"""
            SELECT 
                campaign.id,
                segments.date,
                metrics.cost_micros,
                metrics.conversions,
                metrics.impressions,
                metrics.clicks,
                metrics.average_cpc,
                metrics.ctr,
                metrics.conversion_rate,
                metrics.cost_per_conversion
            FROM campaign
            WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
            AND campaign.status IN ('ENABLED', 'PAUSED')
            ORDER BY campaign.id, segments.date
        """
        
        response = self.service.search(
            customer_id=self.customer_id,
            query=query
        )
        
        metrics = []
        for row in response:
            metrics.append({
                'campaign_external_id': str(row.campaign.id),
                'date': str(row.segments.date),
                'spend_micros': row.metrics.cost_micros,
                'conversions': row.metrics.conversions,
                'impressions': row.metrics.impressions,
                'clicks': row.metrics.clicks,
                'average_cpc_micros': int(row.metrics.average_cpc * 1000000),
                'ctr': row.metrics.ctr,
                'conversion_rate': row.metrics.conversion_rate
            })
        
        return metrics
```

### 2. Conversion Tracking Integration

#### Conversion Actions Setup

```python
class GoogleAdsConversionCollector:
    def __init__(self, client, customer_id):
        self.client = client
        self.customer_id = customer_id
        self.service = client.get_service("GoogleAdsService")
    
    def get_conversion_actions(self):
        """Get configured conversion actions"""
        query = """
            SELECT 
                conversion_action.id,
                conversion_action.name,
                conversion_action.type,
                conversion_action.status,
                conversion_action.counting_type,
                conversion_action.attribution_model,
                conversion_action.click_through_lookback_window_days,
                conversion_action.view_through_lookback_window_days
            FROM conversion_action
            WHERE conversion_action.status = 'ENABLED'
        """
        
        response = self.service.search(
            customer_id=self.customer_id,
            query=query
        )
        
        conversion_actions = []
        for row in response:
            conversion_actions.append({
                'external_id': str(row.conversion_action.id),
                'name': row.conversion_action.name,
                'type': str(row.conversion_action.type),
                'counting_type': str(row.conversion_action.counting_type),
                'attribution_model': str(row.conversion_action.attribution_model),
                'click_lookback_days': row.conversion_action.click_through_lookback_window_days,
                'view_lookback_days': row.conversion_action.view_through_lookback_window_days
            })
        
        return conversion_actions
    
    def collect_conversions(self, start_date, end_date):
        """Collect conversion data with attribution details"""
        query = f"""
            SELECT 
                segments.conversion_action_name,
                segments.conversion_action,
                segments.date,
                segments.click_type,
                metrics.conversions,
                metrics.conversions_value,
                segments.external_conversion_source
            FROM conversion_action
            WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
            AND metrics.conversions > 0
            ORDER BY segments.date DESC
        """
        
        response = self.service.search(
            customer_id=self.customer_id,
            query=query
        )
        
        conversions = []
        for row in response:
            conversions.append({
                'conversion_action_name': row.segments.conversion_action_name,
                'conversion_action_id': str(row.segments.conversion_action),
                'conversion_date': str(row.segments.date),
                'click_type': str(row.segments.click_type),
                'conversions': row.metrics.conversions,
                'conversion_value_micros': row.metrics.conversions_value,
                'external_source': str(row.segments.external_conversion_source)
            })
        
        return conversions
```

### 3. Attribution Path Collection

#### Click Path Analysis

```python
class GoogleAdsAttributionCollector:
    def __init__(self, client, customer_id):
        self.client = client
        self.customer_id = customer_id
        self.service = client.get_service("GoogleAdsService")
    
    def collect_click_view_paths(self, start_date, end_date):
        """Collect conversion paths for attribution analysis"""
        query = f"""
            SELECT 
                segments.conversion_action_name,
                segments.conversion_lag_bucket,
                segments.path_length_bucket,
                click_view.ad_network_type,
                click_view.area_of_interest.city,
                click_view.area_of_interest.country,
                click_view.click_type,
                metrics.conversions
            FROM click_view
            WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
            AND metrics.conversions > 0
            ORDER BY segments.conversion_action_name, segments.path_length_bucket
        """
        
        response = self.service.search(
            customer_id=self.customer_id,
            query=query
        )
        
        attribution_paths = []
        for row in response:
            attribution_paths.append({
                'conversion_action': row.segments.conversion_action_name,
                'conversion_lag_bucket': str(row.segments.conversion_lag_bucket),
                'path_length_bucket': str(row.segments.path_length_bucket),
                'network_type': str(row.click_view.ad_network_type),
                'city': str(row.click_view.area_of_interest.city) if row.click_view.area_of_interest.city else None,
                'country': str(row.click_view.area_of_interest.country) if row.click_view.area_of_interest.country else None,
                'click_type': str(row.click_view.click_type),
                'conversions': row.metrics.conversions
            })
        
        return attribution_paths
```

## Data Processing Workflow

### Batch Processing Jobs

```python
from celery import Celery
from datetime import datetime, timedelta
import logging

app = Celery('google_ads_integration')
logger = logging.getLogger(__name__)

@app.task(bind=True, max_retries=3)
def collect_google_ads_data(self, business_id, collection_date=None):
    """Main data collection task for Google Ads"""
    try:
        collection_date = collection_date or datetime.now().date()
        
        # Get business configuration
        business = get_business_by_id(business_id)
        authenticator = GoogleAdsAuthenticator()
        client = authenticator.get_client(business.google_ads_account_id)
        
        # Collect campaign structure
        campaign_collector = GoogleAdsCampaignCollector(client, business.google_ads_account_id)
        campaigns = campaign_collector.collect_campaigns()
        logger.info(f"Collected {len(campaigns)} campaigns for business {business_id}")
        
        # Update campaign structure in database
        campaign_service = CampaignService()
        campaign_service.update_campaigns(business_id, campaigns)
        
        # Collect daily metrics (last 7 days to handle delays)
        end_date = collection_date
        start_date = collection_date - timedelta(days=7)
        
        metrics_collector = GoogleAdsMetricsCollector(client, business.google_ads_account_id)
        daily_metrics = metrics_collector.collect_daily_metrics(start_date, end_date)
        logger.info(f"Collected {len(daily_metrics)} daily metric records")
        
        # Update metrics in database
        metrics_service = MetricsService()
        metrics_service.update_daily_metrics(business_id, daily_metrics)
        
        # Collect conversion data
        conversion_collector = GoogleAdsConversionCollector(client, business.google_ads_account_id)
        conversions = conversion_collector.collect_conversions(start_date, end_date)
        logger.info(f"Collected {len(conversions)} conversion records")
        
        # Update conversion data
        conversion_service = ConversionService()
        conversion_service.update_conversions(business_id, conversions)
        
        # Collect attribution paths (weekly basis)
        if collection_date.weekday() == 0:  # Monday
            attribution_collector = GoogleAdsAttributionCollector(client, business.google_ads_account_id)
            attribution_start = collection_date - timedelta(days=180)  # 6 months lookback
            attribution_paths = attribution_collector.collect_click_view_paths(attribution_start, end_date)
            
            attribution_service = AttributionService()
            attribution_service.update_attribution_paths(business_id, attribution_paths)
            logger.info(f"Collected {len(attribution_paths)} attribution path records")
        
        return {
            'success': True,
            'business_id': business_id,
            'collection_date': str(collection_date),
            'campaigns': len(campaigns),
            'metrics': len(daily_metrics),
            'conversions': len(conversions)
        }
        
    except Exception as e:
        logger.error(f"Error collecting Google Ads data for business {business_id}: {e}")
        
        # Retry logic
        if self.request.retries < self.max_retries:
            logger.info(f"Retrying in 300 seconds... (attempt {self.request.retries + 1})")
            raise self.retry(countdown=300, exc=e)
        else:
            # Send alert for failed collection
            send_data_collection_alert(business_id, str(e))
            raise
```

### Rate Limit Management

```python
import time
import random
from functools import wraps

class RateLimitManager:
    def __init__(self):
        self.request_count = 0
        self.request_window_start = time.time()
        self.max_requests_per_minute = 2000  # Google Ads API limit
        self.backoff_base = 2
        
    def rate_limit_decorator(self, func):
        """Decorator to handle rate limiting"""
        @wraps(func)
        def wrapper(*args, **kwargs):
            current_time = time.time()
            
            # Reset window if needed
            if current_time - self.request_window_start >= 60:
                self.request_count = 0
                self.request_window_start = current_time
            
            # Check if we're approaching rate limit
            if self.request_count >= self.max_requests_per_minute * 0.8:
                sleep_time = 60 - (current_time - self.request_window_start)
                if sleep_time > 0:
                    logger.info(f"Rate limit approaching, sleeping for {sleep_time:.2f} seconds")
                    time.sleep(sleep_time)
                    self.request_count = 0
                    self.request_window_start = time.time()
            
            try:
                result = func(*args, **kwargs)
                self.request_count += 1
                return result
                
            except Exception as e:
                if 'RATE_LIMIT_EXCEEDED' in str(e):
                    # Exponential backoff with jitter
                    backoff_time = (self.backoff_base ** self.request_count) + random.uniform(0, 1)
                    logger.warning(f"Rate limit exceeded, backing off for {backoff_time:.2f} seconds")
                    time.sleep(backoff_time)
                    return func(*args, **kwargs)  # Retry once
                else:
                    raise
                    
        return wrapper
```

## Data Validation and Quality Assurance

### Validation Framework

```python
class GoogleAdsDataValidator:
    def __init__(self, business_id):
        self.business_id = business_id
        self.validation_rules = self._load_validation_rules()
    
    def validate_campaign_data(self, campaigns):
        """Validate campaign structure data"""
        validation_results = []
        
        for campaign in campaigns:
            issues = []
            
            # Required fields check
            required_fields = ['external_id', 'name', 'status', 'campaign_type']
            for field in required_fields:
                if not campaign.get(field):
                    issues.append(f"Missing required field: {field}")
            
            # Business logic validation
            if campaign.get('budget_micros', 0) <= 0:
                issues.append("Budget must be positive")
            
            if not self._is_valid_campaign_name(campaign.get('name', '')):
                issues.append("Invalid campaign naming convention")
            
            validation_results.append({
                'campaign_id': campaign.get('external_id'),
                'campaign_name': campaign.get('name'),
                'valid': len(issues) == 0,
                'issues': issues
            })
        
        return validation_results
    
    def validate_metrics_data(self, metrics):
        """Validate daily metrics data"""
        validation_results = []
        
        for metric in metrics:
            issues = []
            
            # Data consistency checks
            if metric.get('spend_micros', 0) > 0 and metric.get('clicks', 0) == 0:
                issues.append("Spend without clicks may indicate data issue")
            
            if metric.get('conversions', 0) > metric.get('clicks', 0):
                issues.append("Conversions exceed clicks - data anomaly")
            
            # Business rule validation
            if metric.get('spend_micros', 0) > 50000000000:  # $50k daily spend
                issues.append("Unusually high daily spend - please verify")
            
            validation_results.append({
                'campaign_id': metric.get('campaign_external_id'),
                'date': metric.get('date'),
                'valid': len(issues) == 0,
                'issues': issues
            })
        
        return validation_results
    
    def _is_valid_campaign_name(self, name):
        """Validate campaign naming convention"""
        # Business-specific naming rules
        forbidden_patterns = ['test', 'temp', 'delete']
        return not any(pattern in name.lower() for pattern in forbidden_patterns)
```

### Data Quality Monitoring

```python
class DataQualityMonitor:
    def __init__(self, business_id):
        self.business_id = business_id
    
    def run_quality_checks(self, collection_date):
        """Run comprehensive data quality checks"""
        checks = [
            self._check_data_completeness(collection_date),
            self._check_data_consistency(collection_date),
            self._check_historical_variance(collection_date),
            self._check_attribution_data_quality(collection_date)
        ]
        
        return DataQualityReport(
            business_id=self.business_id,
            collection_date=collection_date,
            checks=checks,
            overall_status=self._determine_overall_status(checks)
        )
    
    def _check_data_completeness(self, collection_date):
        """Check if all expected data was collected"""
        expected_campaigns = self._get_expected_campaign_count()
        actual_campaigns = self._get_actual_campaign_count(collection_date)
        
        completeness_ratio = actual_campaigns / expected_campaigns if expected_campaigns > 0 else 0
        
        return QualityCheck(
            name="data_completeness",
            passed=completeness_ratio >= 0.95,
            score=completeness_ratio,
            message=f"Collected {actual_campaigns}/{expected_campaigns} campaigns"
        )
    
    def _check_data_consistency(self, collection_date):
        """Check for data consistency issues"""
        inconsistencies = []
        
        # Check for campaigns with metrics but no campaign record
        orphaned_metrics = self._get_orphaned_metrics(collection_date)
        if orphaned_metrics > 0:
            inconsistencies.append(f"{orphaned_metrics} orphaned metric records")
        
        # Check for missing conversion tracking
        campaigns_without_conversions = self._get_campaigns_without_conversion_tracking()
        if campaigns_without_conversions > 0:
            inconsistencies.append(f"{campaigns_without_conversions} campaigns without conversion tracking")
        
        return QualityCheck(
            name="data_consistency",
            passed=len(inconsistencies) == 0,
            issues=inconsistencies,
            message=f"Found {len(inconsistencies)} consistency issues"
        )
```

## Error Handling and Recovery

### Error Categories

```python
class GoogleAdsAPIError(Exception):
    """Base exception for Google Ads API errors"""
    pass

class AuthenticationError(GoogleAdsAPIError):
    """Authentication or authorization errors"""
    pass

class RateLimitError(GoogleAdsAPIError):
    """Rate limit exceeded errors"""
    pass

class DataCollectionError(GoogleAdsAPIError):
    """Data collection specific errors"""
    pass

class ValidationError(GoogleAdsAPIError):
    """Data validation errors"""
    pass
```

### Recovery Strategies

```python
class ErrorRecoveryManager:
    def __init__(self):
        self.recovery_strategies = {
            'authentication_error': self._handle_authentication_error,
            'rate_limit_error': self._handle_rate_limit_error,
            'data_collection_error': self._handle_data_collection_error,
            'validation_error': self._handle_validation_error
        }
    
    def handle_error(self, error_type, error_details, context):
        """Handle errors with appropriate recovery strategy"""
        strategy = self.recovery_strategies.get(error_type)
        if strategy:
            return strategy(error_details, context)
        else:
            return self._default_error_handling(error_details, context)
    
    def _handle_authentication_error(self, error_details, context):
        """Handle authentication errors"""
        # Attempt token refresh
        try:
            self._refresh_oauth_token(context['business_id'])
            return RecoveryResult(success=True, action="token_refreshed", retry_possible=True)
        except Exception as e:
            return RecoveryResult(
                success=False, 
                action="token_refresh_failed", 
                retry_possible=False,
                alert_required=True,
                message=f"Manual intervention required: {str(e)}"
            )
    
    def _handle_rate_limit_error(self, error_details, context):
        """Handle rate limit errors"""
        backoff_time = self._calculate_backoff_time(context.get('retry_count', 0))
        return RecoveryResult(
            success=True,
            action="exponential_backoff",
            retry_possible=True,
            delay_seconds=backoff_time
        )
    
    def _handle_data_collection_error(self, error_details, context):
        """Handle data collection errors"""
        # Try alternative data collection method
        if context.get('use_fallback_method', False):
            return RecoveryResult(
                success=True,
                action="fallback_method",
                retry_possible=True,
                message="Using CSV import fallback"
            )
        else:
            return RecoveryResult(
                success=False,
                action="collection_failed",
                retry_possible=True,
                alert_required=True
            )
```

## Performance Optimization

### Query Optimization

```python
class OptimizedGoogleAdsCollector:
    def __init__(self, client, customer_id):
        self.client = client
        self.customer_id = customer_id
        self.batch_size = 1000
        
    def collect_metrics_in_batches(self, start_date, end_date, campaign_ids=None):
        """Collect metrics in optimized batches"""
        all_metrics = []
        
        # Split date range into weekly batches for large collections
        date_ranges = self._split_date_range(start_date, end_date, days=7)
        
        for date_start, date_end in date_ranges:
            batch_metrics = self._collect_metrics_batch(date_start, date_end, campaign_ids)
            all_metrics.extend(batch_metrics)
            
            # Small delay to be respectful to API
            time.sleep(0.1)
        
        return all_metrics
    
    def _collect_metrics_batch(self, start_date, end_date, campaign_ids=None):
        """Collect metrics for a specific date range batch"""
        campaign_filter = ""
        if campaign_ids:
            campaign_list = "','".join(campaign_ids)
            campaign_filter = f"AND campaign.id IN ('{campaign_list}')"
        
        query = f"""
            SELECT 
                campaign.id,
                segments.date,
                metrics.cost_micros,
                metrics.conversions,
                metrics.impressions,
                metrics.clicks
            FROM campaign
            WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
            {campaign_filter}
            AND campaign.status IN ('ENABLED', 'PAUSED')
            ORDER BY campaign.id, segments.date
        """
        
        return self._execute_query_with_pagination(query)
    
    def _execute_query_with_pagination(self, query):
        """Execute query with proper pagination handling"""
        results = []
        page_token = None
        
        while True:
            request = {
                'customer_id': self.customer_id,
                'query': query,
                'page_size': self.batch_size
            }
            
            if page_token:
                request['page_token'] = page_token
            
            response = self.service.search(**request)
            
            for row in response:
                results.append(self._format_metrics_row(row))
            
            page_token = response.next_page_token
            if not page_token:
                break
        
        return results
```

### Caching Strategy

```python
from functools import lru_cache
import redis

class GoogleAdsDataCache:
    def __init__(self):
        self.redis_client = redis.Redis(host='localhost', port=6379, db=0)
        self.cache_ttl = 3600  # 1 hour
    
    @lru_cache(maxsize=100)
    def get_cached_campaigns(self, business_id, cache_key):
        """Get cached campaign data"""
        cached_data = self.redis_client.get(f"campaigns:{business_id}:{cache_key}")
        if cached_data:
            return json.loads(cached_data)
        return None
    
    def cache_campaigns(self, business_id, cache_key, campaigns):
        """Cache campaign data"""
        self.redis_client.setex(
            f"campaigns:{business_id}:{cache_key}",
            self.cache_ttl,
            json.dumps(campaigns)
        )
    
    def invalidate_cache(self, business_id):
        """Invalidate all cached data for a business"""
        pattern = f"campaigns:{business_id}:*"
        keys = self.redis_client.keys(pattern)
        if keys:
            self.redis_client.delete(*keys)
```

## Monitoring and Alerting

### Collection Monitoring

```python
class GoogleAdsMonitor:
    def __init__(self):
        self.alert_thresholds = {
            'collection_failure_rate': 0.05,  # 5% failure rate
            'data_delay_hours': 4,
            'validation_failure_rate': 0.10
        }
    
    def monitor_collection_health(self, business_id):
        """Monitor overall collection health"""
        health_metrics = {
            'last_successful_collection': self._get_last_collection_time(business_id),
            'failure_rate_24h': self._get_failure_rate(business_id, hours=24),
            'average_collection_time': self._get_average_collection_time(business_id),
            'data_freshness': self._get_data_freshness(business_id)
        }
        
        alerts = self._check_alert_conditions(business_id, health_metrics)
        
        return CollectionHealthReport(
            business_id=business_id,
            metrics=health_metrics,
            alerts=alerts,
            status=self._determine_health_status(health_metrics, alerts)
        )
    
    def _check_alert_conditions(self, business_id, metrics):
        """Check if any alert conditions are met"""
        alerts = []
        
        if metrics['failure_rate_24h'] > self.alert_thresholds['collection_failure_rate']:
            alerts.append({
                'type': 'high_failure_rate',
                'severity': 'high',
                'message': f"Collection failure rate {metrics['failure_rate_24h']:.2%} exceeds threshold"
            })
        
        if metrics['data_freshness'] > self.alert_thresholds['data_delay_hours']:
            alerts.append({
                'type': 'stale_data',
                'severity': 'medium',
                'message': f"Data is {metrics['data_freshness']} hours old"
            })
        
        return alerts
```

## Testing and Validation

### Integration Testing

````python
import unittest
from unittest.mock import Mock, patch

class TestGoogleAdsIntegration(unittest.TestCase):
    def setUp(self):
        self.business_id = 1
        self.customer_id = "123-456-7890"
        self.mock_client = Mock()
        
    @patch('google_ads_integration.GoogleAdsAuthenticator')
    def test_campaign_collection(self, mock_auth):
        """Test campaign data collection"""
        mock_auth.return_value.get_client.return_value = self.mock_client
        
        # Mock API response
        mock_response = [
            Mock(campaign=Mock(
                id=12345,
                name="Test Campaign",
                status='ENABLED',
                advertising_channel_type='SEARCH'
            ))
        ]
        self.mock_client.get_service.return_value.search.return_value = mock_response
        
        collector = GoogleAdsCampaignCollector(self.mock_client, self.customer_id)
        campaigns = collector.collect_campaigns()
        
        self.assertEqual(len(campaigns), 1)
        self.assertEqual(campaigns[0]['name'], "Test Campaign")
        self.assertEqual(campaigns[0]['status'], 'active')
    
    def test_data_validation(self):
        """Test data validation logic"""
        validator = GoogleAdsDataValidator(self.business_id)
        
        # Test valid campaign data
        valid_campaign = {
            'external_id': '12345',
            'name': 'Valid Campaign',
            'status': 'active',
            'campaign_type': 'search',
            'budget_micros': 1000000
        }
        
        result = validator.validate_campaign_data([valid_campaign])
        self.assertTrue(result[0]['valid'])
        
        # Test invalid campaign data
        invalid_campaign = {
            'external_id': '12346',
            'name': 'Test Campaign',  # Contains forbidden pattern
            'status': 'active',
            'campaign_type': 'search',
            'budget_micros': -1000  # Invalid negative budget
        }
        
        result = validator.validate_campaign_data([invalid_campaign])
        self.assertFalse(result[0]['valid'])
        self.assertGreater(len(result[0]['issues']), 0)

## Deployment and Configuration

### Environment Setup

#### Production Environment Variables

```bash
# Google Ads API Configuration
GOOGLE_ADS_DEVELOPER_TOKEN=your_production_developer_token
GOOGLE_ADS_CLIENT_ID=your_production_client_id
GOOGLE_ADS_CLIENT_SECRET=your_production_client_secret
GOOGLE_ADS_REFRESH_TOKEN=your_production_refresh_token

# Business Account Mapping
WILDERNESS_GOOGLE_ADS_ACCOUNT_ID=123-456-7890
JACADA_GOOGLE_ADS_ACCOUNT_ID=234-567-8901
YELLOWZEBRA_GOOGLE_ADS_ACCOUNT_ID=345-678-9012

# API Configuration
GOOGLE_ADS_API_VERSION=v16
GOOGLE_ADS_LOGIN_CUSTOMER_ID=your_manager_account_id

# Rate Limiting
GOOGLE_ADS_MAX_REQUESTS_PER_MINUTE=2000
GOOGLE_ADS_BACKOFF_MULTIPLIER=2
GOOGLE_ADS_MAX_RETRY_ATTEMPTS=3

# Data Collection
GOOGLE_ADS_DEFAULT_LOOKBACK_DAYS=7
GOOGLE_ADS_ATTRIBUTION_WINDOW_DAYS=180
GOOGLE_ADS_BATCH_SIZE=1000
````

#### Configuration Validation

```python
class GoogleAdsConfigValidator:
    def __init__(self):
        self.required_env_vars = [
            'GOOGLE_ADS_DEVELOPER_TOKEN',
            'GOOGLE_ADS_CLIENT_ID',
            'GOOGLE_ADS_CLIENT_SECRET',
            'GOOGLE_ADS_REFRESH_TOKEN'
        ]
    
    def validate_configuration(self):
        """Validate Google Ads API configuration"""
        validation_results = []
        
        # Check required environment variables
        for var in self.required_env_vars:
            value = os.getenv(var)
            validation_results.append({
                'variable': var,
                'present': value is not None,
                'valid': self._validate_env_var(var, value)
            })
        
        # Test API connectivity
        connectivity_test = self._test_api_connectivity()
        validation_results.append(connectivity_test)
        
        return ConfigurationValidationReport(
            results=validation_results,
            overall_valid=all(r['valid'] for r in validation_results)
        )
    
    def _validate_env_var(self, var_name, value):
        """Validate specific environment variable"""
        if not value:
            return False
        
        if var_name == 'GOOGLE_ADS_DEVELOPER_TOKEN':
            return len(value) >= 20 and not value.startswith('INSERT_')
        elif var_name in ['GOOGLE_ADS_CLIENT_ID', 'GOOGLE_ADS_CLIENT_SECRET']:
            return '.googleusercontent.com' in value or len(value) >= 20
        elif var_name == 'GOOGLE_ADS_REFRESH_TOKEN':
            return len(value) >= 40
        
        return True
    
    def _test_api_connectivity(self):
        """Test actual API connectivity"""
        try:
            authenticator = GoogleAdsAuthenticator()
            client = authenticator.get_client('123-456-7890')  # Use any valid customer ID
            
            # Simple test query
            service = client.get_service("CustomerService")
            customer = service.get_customer(customer_id='123-456-7890')
            
            return {
                'test': 'api_connectivity',
                'present': True,
                'valid': True,
                'message': 'API connectivity successful'
            }
        except Exception as e:
            return {
                'test': 'api_connectivity',
                'present': True,
                'valid': False,
                'message': f'API connectivity failed: {str(e)}'
            }
```

### Deployment Scripts

#### Initial Setup Script

```bash
#!/bin/bash
# scripts/setup_google_ads_integration.sh

set -e

echo "🔧 Setting up Google Ads integration..."

# Check prerequisites
command -v python3 >/dev/null 2>&1 || { echo "❌ Python 3 is required"; exit 1; }
command -v pip >/dev/null 2>&1 || { echo "❌ pip is required"; exit 1; }

# Install Google Ads API dependencies
echo "📦 Installing Google Ads API library..."
pip install google-ads==22.1.0
pip install google-auth==2.23.0
pip install google-auth-oauthlib==1.0.0

# Create configuration directory
mkdir -p config/google_ads

# Create configuration template
cat > config/google_ads/google-ads.yaml << EOF
# Google Ads API Configuration
# DO NOT commit this file with real credentials

developer_token: "INSERT_YOUR_DEVELOPER_TOKEN_HERE"
client_id: "INSERT_YOUR_CLIENT_ID_HERE"
client_secret: "INSERT_YOUR_CLIENT_SECRET_HERE"
refresh_token: "INSERT_YOUR_REFRESH_TOKEN_HERE"
login_customer_id: "INSERT_YOUR_MANAGER_ACCOUNT_ID_HERE"

# Optional: Use service account instead of OAuth
# use_proto_plus: True
# json_key_file_path: "path/to/service-account-key.json"
EOF

echo "✅ Google Ads integration setup complete!"
echo "📝 Please edit config/google_ads/google-ads.yaml with your credentials"
echo "🔐 Run: python scripts/test_google_ads_connection.py to verify setup"
```

#### Connection Test Script

```python
#!/usr/bin/env python3
# scripts/test_google_ads_connection.py

import os
import sys
from google.ads.googleads.client import GoogleAdsClient
from google.oauth2.credentials import Credentials

def test_google_ads_connection():
    """Test Google Ads API connection for all businesses"""
    print("🔍 Testing Google Ads API connections...")
    
    # Load credentials from environment
    try:
        credentials = Credentials(
            token=None,
            refresh_token=os.getenv('GOOGLE_ADS_REFRESH_TOKEN'),
            token_uri="https://oauth2.googleapis.com/token",
            client_id=os.getenv('GOOGLE_ADS_CLIENT_ID'),
            client_secret=os.getenv('GOOGLE_ADS_CLIENT_SECRET')
        )
        
        client = GoogleAdsClient(
            credentials=credentials,
            developer_token=os.getenv('GOOGLE_ADS_DEVELOPER_TOKEN'),
            version="v16"
        )
        
        print("✅ Google Ads client initialized successfully")
        
    except Exception as e:
        print(f"❌ Failed to initialize Google Ads client: {e}")
        sys.exit(1)
    
    # Test each business account
    businesses = [
        ('Wilderness', os.getenv('WILDERNESS_GOOGLE_ADS_ACCOUNT_ID')),
        ('Jacada', os.getenv('JACADA_GOOGLE_ADS_ACCOUNT_ID')),
        ('Yellow Zebra', os.getenv('YELLOWZEBRA_GOOGLE_ADS_ACCOUNT_ID'))
    ]
    
    for business_name, account_id in businesses:
        if not account_id:
            print(f"⚠️  {business_name}: Account ID not configured")
            continue
        
        try:
            # Test basic account access
            customer_service = client.get_service("CustomerService")
            customer = customer_service.get_customer(customer_id=account_id)
            
            print(f"✅ {business_name}: Connected successfully")
            print(f"   Account: {customer.descriptive_name}")
            print(f"   Currency: {customer.currency_code}")
            print(f"   Time Zone: {customer.time_zone}")
            
            # Test campaign access
            google_ads_service = client.get_service("GoogleAdsService")
            query = """
                SELECT campaign.id, campaign.name, campaign.status
                FROM campaign
                WHERE campaign.status IN ('ENABLED', 'PAUSED')
                LIMIT 5
            """
            
            response = google_ads_service.search(customer_id=account_id, query=query)
            campaigns = list(response)
            
            print(f"   Campaigns accessible: {len(campaigns)}")
            
            if campaigns:
                print("   Sample campaigns:")
                for i, row in enumerate(campaigns[:3]):
                    print(f"     - {row.campaign.name} ({row.campaign.status})")
            
        except Exception as e:
            print(f"❌ {business_name}: Connection failed - {e}")
    
    print("\n🎯 Connection test completed!")

if __name__ == "__main__":
    test_google_ads_connection()
```

## Best Practices and Guidelines

### Data Collection Best Practices

#### 1. Efficient Query Design

```python
# ✅ Good: Specific fields, reasonable date ranges
def collect_campaign_metrics_efficiently(client, customer_id, start_date, end_date):
    query = f"""
        SELECT 
            campaign.id,
            campaign.name,
            segments.date,
            metrics.cost_micros,
            metrics.conversions,
            metrics.clicks
        FROM campaign
        WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
        AND campaign.status IN ('ENABLED', 'PAUSED')
        AND metrics.cost_micros > 0
        ORDER BY campaign.id, segments.date
    """
    return execute_query_with_pagination(client, customer_id, query)

# ❌ Bad: SELECT *, no filters, excessive date range
def collect_campaign_metrics_inefficiently(client, customer_id):
    query = """
        SELECT *
        FROM campaign
        WHERE segments.date >= '2020-01-01'
    """
    return client.get_service("GoogleAdsService").search(customer_id=customer_id, query=query)
```

#### 2. Error Handling Patterns

```python
# ✅ Good: Specific error handling with recovery
def robust_data_collection(client, customer_id, query):
    max_retries = 3
    retry_count = 0
    
    while retry_count < max_retries:
        try:
            service = client.get_service("GoogleAdsService")
            response = service.search(customer_id=customer_id, query=query)
            return list(response)
            
        except GoogleAdsException as ex:
            for error in ex.failure.errors:
                if error.error_code.authentication_error:
                    logger.error("Authentication error - check credentials")
                    raise AuthenticationError("Invalid credentials")
                elif error.error_code.rate_exceeded_error:
                    wait_time = 2 ** retry_count
                    logger.warning(f"Rate limit exceeded, waiting {wait_time}s")
                    time.sleep(wait_time)
                    retry_count += 1
                else:
                    logger.error(f"API error: {error.message}")
                    raise DataCollectionError(f"API error: {error.message}")
        
        except Exception as e:
            logger.error(f"Unexpected error: {e}")
            retry_count += 1
            if retry_count >= max_retries:
                raise
```

#### 3. Data Consistency Checks

```python
def validate_collected_data(campaigns, metrics, conversions):
    """Ensure data consistency across collections"""
    validation_issues = []
    
    # Check campaign-metrics consistency
    campaign_ids = {c['external_id'] for c in campaigns}
    metric_campaign_ids = {m['campaign_external_id'] for m in metrics}
    
    orphaned_metrics = metric_campaign_ids - campaign_ids
    if orphaned_metrics:
        validation_issues.append(f"Metrics for non-existent campaigns: {orphaned_metrics}")
    
    # Check metrics-conversions consistency
    dates_with_spend = {(m['campaign_external_id'], m['date']) 
                       for m in metrics if m['spend_micros'] > 0}
    dates_with_conversions = {(c['campaign_id'], c['conversion_date']) 
                             for c in conversions}
    
    conversions_without_spend = dates_with_conversions - dates_with_spend
    if len(conversions_without_spend) > len(dates_with_conversions) * 0.1:
        validation_issues.append("High rate of conversions without corresponding spend")
    
    return validation_issues
```

### Performance Optimization Guidelines

#### 1. Batch Processing Strategy

```python
class OptimizedCollectionStrategy:
    def __init__(self, client, customer_id):
        self.client = client
        self.customer_id = customer_id
        self.optimal_batch_size = 1000
        self.max_date_range_days = 30
    
    def collect_with_optimal_batching(self, start_date, end_date, data_type='metrics'):
        """Collect data using optimal batching strategy"""
        
        # Split large date ranges
        date_chunks = self._split_date_range(start_date, end_date, self.max_date_range_days)
        
        all_results = []
        for chunk_start, chunk_end in date_chunks:
            
            if data_type == 'metrics':
                chunk_results = self._collect_metrics_chunk(chunk_start, chunk_end)
            elif data_type == 'conversions':
                chunk_results = self._collect_conversions_chunk(chunk_start, chunk_end)
            else:
                raise ValueError(f"Unknown data type: {data_type}")
            
            all_results.extend(chunk_results)
            
            # Rate limiting pause
            time.sleep(0.1)
        
        return all_results
    
    def _split_date_range(self, start_date, end_date, max_days):
        """Split date range into optimal chunks"""
        chunks = []
        current_start = start_date
        
        while current_start <= end_date:
            current_end = min(current_start + timedelta(days=max_days), end_date)
            chunks.append((current_start, current_end))
            current_start = current_end + timedelta(days=1)
        
        return chunks
```

#### 2. Memory Management

```python
class MemoryEfficientCollector:
    def __init__(self, client, customer_id):
        self.client = client
        self.customer_id = customer_id
    
    def collect_large_dataset(self, query, processor_func):
        """Collect and process large datasets without memory issues"""
        
        service = self.client.get_service("GoogleAdsService")
        page_token = None
        processed_count = 0
        
        while True:
            # Request with pagination
            request = {
                'customer_id': self.customer_id,
                'query': query,
                'page_size': 1000
            }
            
            if page_token:
                request['page_token'] = page_token
            
            response = service.search(**request)
            
            # Process results immediately, don't store in memory
            batch_results = []
            for row in response:
                result = self._format_row(row)
                batch_results.append(result)
                processed_count += 1
                
                # Process in smaller batches to manage memory
                if len(batch_results) >= 100:
                    processor_func(batch_results)
                    batch_results = []
            
            # Process remaining results
            if batch_results:
                processor_func(batch_results)
            
            # Check for next page
            page_token = response.next_page_token
            if not page_token:
                break
        
        return processed_count
```

### Security Considerations

#### 1. Credential Management

```python
class SecureCredentialManager:
    def __init__(self):
        self.required_permissions = [
            'https://www.googleapis.com/auth/adwords'
        ]
    
    def validate_credentials(self, credentials):
        """Validate credentials have required permissions"""
        try:
            client = GoogleAdsClient(
                credentials=credentials,
                developer_token=os.getenv('GOOGLE_ADS_DEVELOPER_TOKEN'),
                version="v16"
            )
            
            # Test minimal access
            service = client.get_service("CustomerService")
            customer = service.get_customer(customer_id='123-456-7890')
            
            return CredentialValidationResult(
                valid=True,
                permissions=self.required_permissions,
                message="Credentials validated successfully"
            )
            
        except Exception as e:
            return CredentialValidationResult(
                valid=False,
                error=str(e),
                message="Credential validation failed"
            )
    
    def rotate_refresh_token(self, business_id):
        """Rotate refresh token for security"""
        # Implementation would depend on your OAuth flow
        # This is a placeholder for the security process
        pass
```

#### 2. Access Logging

```python
class GoogleAdsAccessLogger:
    def __init__(self):
        self.logger = logging.getLogger('google_ads_access')
        
    def log_api_access(self, customer_id, query_type, user_context=None):
        """Log API access for security auditing"""
        self.logger.info({
            'event': 'google_ads_api_access',
            'customer_id': customer_id,
            'query_type': query_type,
            'timestamp': datetime.utcnow().isoformat(),
            'user_context': user_context,
            'source_ip': self._get_source_ip()
        })
    
    def log_data_export(self, customer_id, data_type, record_count, user_context=None):
        """Log data export events"""
        self.logger.warning({
            'event': 'data_export',
            'customer_id': customer_id,
            'data_type': data_type,
            'record_count': record_count,
            'timestamp': datetime.utcnow().isoformat(),
            'user_context': user_context
        })
```

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. Authentication Errors

**Problem:** "Invalid credentials" or "Authentication failed"

**Solutions:**

```bash
# Check environment variables
echo $GOOGLE_ADS_DEVELOPER_TOKEN
echo $GOOGLE_ADS_CLIENT_ID
echo $GOOGLE_ADS_CLIENT_SECRET
echo $GOOGLE_ADS_REFRESH_TOKEN

# Test credential validity
python scripts/test_google_ads_connection.py

# Refresh OAuth token
python scripts/refresh_oauth_token.py
```

#### 2. Rate Limit Issues

**Problem:** "Rate limit exceeded" errors

**Solutions:**

```python
# Implement exponential backoff
def handle_rate_limit_error(retry_count):
    backoff_time = min(300, (2 ** retry_count) + random.uniform(0, 1))
    time.sleep(backoff_time)
    return backoff_time

# Monitor request rate
def monitor_api_usage():
    requests_per_minute = get_current_request_rate()
    if requests_per_minute > 1800:  # 90% of limit
        time.sleep(60)  # Wait for rate limit reset
```

#### 3. Data Quality Issues

**Problem:** Missing or inconsistent data

**Diagnostic Steps:**

```python
def diagnose_data_issues(business_id, collection_date):
    """Comprehensive data quality diagnosis"""
    
    # Check campaign count
    expected_campaigns = get_expected_campaign_count(business_id)
    actual_campaigns = get_actual_campaign_count(business_id, collection_date)
    
    print(f"Campaigns: {actual_campaigns}/{expected_campaigns}")
    
    # Check data freshness
    latest_data_date = get_latest_data_date(business_id)
    days_behind = (datetime.now().date() - latest_data_date).days
    
    print(f"Data freshness: {days_behind} days behind")
    
    # Check for gaps in metrics
    date_gaps = find_metric_date_gaps(business_id, collection_date - timedelta(days=30), collection_date)
    
    if date_gaps:
        print(f"Date gaps found: {date_gaps}")
    
    # Check conversion tracking
    campaigns_with_conversions = get_campaigns_with_conversions(business_id)
    print(f"Campaigns with conversion tracking: {len(campaigns_with_conversions)}")
```

### Support and Maintenance

#### Health Check Dashboard

```python
def generate_integration_health_report():
    """Generate comprehensive health report"""
    
    businesses = get_all_businesses()
    health_report = {}
    
    for business in businesses:
        health_metrics = {
            'last_successful_collection': get_last_collection_time(business.id),
            'collection_success_rate_7d': get_collection_success_rate(business.id, days=7),
            'data_freshness_hours': get_data_freshness(business.id),
            'api_error_rate_24h': get_api_error_rate(business.id, hours=24),
            'data_quality_score': calculate_data_quality_score(business.id)
        }
        
        health_status = determine_health_status(health_metrics)
        
        health_report[business.name] = {
            'status': health_status,
            'metrics': health_metrics,
            'alerts': get_active_alerts(business.id)
        }
    
    return IntegrationHealthReport(
        generated_at=datetime.utcnow(),
        overall_status=determine_overall_status(health_report),
        business_reports=health_report
    )
```

This completes the comprehensive Google Ads Integration Guide. Shall I proceed with the remaining documentation files?