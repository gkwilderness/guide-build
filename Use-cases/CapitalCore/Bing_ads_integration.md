---
title: "Bing_ads_integration"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# Bing Ads Integration Guide

## Overview

Post-MVP integration with Microsoft Advertising (Bing Ads) API to provide complete platform coverage for Wilderness business. This integration complements Google Ads data to enable comprehensive yield curve analysis across all paid search channels.

## Strategic Context

### Why Bing Ads for Wilderness

**Business Justification:**

- Wilderness has established Bing Ads presence with meaningful spend
- Microsoft Advertising captures different audience demographics (higher income, older travelers)
- Portfolio completeness required for accurate capital allocation decisions
- Cross-platform attribution analysis for luxury travel market

**Integration Priority:**

- **Post-MVP feature** - implement after Google Ads integration proven stable
- **Wilderness-specific** initially, expandable to other businesses
- **Same data model** - leverages existing database schema and analytics engine

## Technical Architecture

### Integration Approach

**Parallel Processing Design:**

```
Google Ads API ──┐
                 ├──→ Unified Data Model ──→ Yield Curve Analytics
Bing Ads API ───┘
```

**Shared Infrastructure:**

- Same database tables with platform differentiation
- Same yield curve calculation engine
- Same attribution models and business logic
- Same Streamlit dashboard with platform filters

### API Requirements

#### 1. Microsoft Advertising API Setup

**Developer Account:**

```bash
# Environment variables
BING_ADS_DEVELOPER_TOKEN=your_bing_developer_token
BING_ADS_CLIENT_ID=your_client_id
BING_ADS_CLIENT_SECRET=your_client_secret
BING_ADS_REFRESH_TOKEN=your_refresh_token
BING_ADS_CUSTOMER_ID=your_customer_id
```

**Account Configuration:**

```bash
# Wilderness Bing Ads account
WILDERNESS_BING_ADS_ACCOUNT_ID=12345678
WILDERNESS_BING_ADS_CUSTOMER_ID=87654321
```

#### 2. Authentication Setup

```python
from bingads.service_client import ServiceClient
from bingads.authorization import *
import os

class BingAdsAuthenticator:
    def __init__(self):
        self.developer_token = os.getenv('BING_ADS_DEVELOPER_TOKEN')
        self.client_id = os.getenv('BING_ADS_CLIENT_ID')
        self.client_secret = os.getenv('BING_ADS_CLIENT_SECRET')
        self.refresh_token = os.getenv('BING_ADS_REFRESH_TOKEN')
        self.customer_id = os.getenv('BING_ADS_CUSTOMER_ID')
        
    def get_service_client(self, service_name, version=13):
        """Get authenticated Bing Ads service client"""
        
        # OAuth2 authentication
        authentication = OAuthWebAuthCodeGrant(
            client_id=self.client_id,
            client_secret=self.client_secret,
            redirection_uri=None,  # Not needed for refresh token flow
            tokens=OAuthTokens(refresh_token=self.refresh_token)
        )
        
        # Create service client
        service_client = ServiceClient(
            service=service_name,
            version=version,
            authorization=authentication,
            environment='production'  # or 'sandbox' for testing
        )
        
        # Set customer and developer token
        service_client.set_customer_id(self.customer_id)
        service_client.set_developer_token(self.developer_token)
        
        return service_client
```

## Data Collection Implementation

### 1. Campaign Structure Collection

```python
from bingads.v13.campaign_management import *

class BingAdsCampaignCollector:
    def __init__(self, service_client, account_id):
        self.service_client = service_client
        self.account_id = account_id
        
    def collect_campaigns(self):
        """Collect Bing Ads campaign structure"""
        
        # Set account context
        self.service_client.set_account_id(self.account_id)
        
        # Create campaign management service
        campaign_service = ServiceClient(
            service='CampaignManagementService',
            version=13,
            authorization=self.service_client.authorization,
            environment=self.service_client.environment
        )
        campaign_service.set_customer_id(self.service_client.customer_id)
        campaign_service.set_developer_token(self.service_client.developer_token)
        campaign_service.set_account_id(self.account_id)
        
        # Get campaigns
        request = GetCampaignsByAccountIdRequest(
            AccountId=self.account_id,
            CampaignType=AllCampaignTypes,
            ReturnAdditionalFields=CampaignAdditionalField.BiddingStrategyType
        )
        
        response = campaign_service.GetCampaignsByAccountId(request)
        
        campaigns = []
        if response and response.Campaigns:
            for campaign in response.Campaigns.Campaign:
                campaigns.append({
                    'external_id': str(campaign.Id),
                    'name': campaign.Name,
                    'status': self._map_campaign_status(campaign.Status),
                    'campaign_type': self._map_campaign_type(campaign.CampaignType),
                    'bid_strategy': self._map_bid_strategy(campaign.BiddingStrategyType),
                    'budget_micros': campaign.MonthlyBudget * 1000000 if campaign.MonthlyBudget else None,
                    'start_date': campaign.StartDate,
                    'end_date': campaign.EndDate
                })
        
        return campaigns
    
    def _map_campaign_status(self, status):
        """Map Bing Ads status to internal status"""
        mapping = {
            'Active': 'active',
            'Paused': 'paused',
            'Deleted': 'removed',
            'Suspended': 'suspended'
        }
        return mapping.get(str(status), 'unknown')
    
    def _map_campaign_type(self, campaign_type):
        """Map Bing Ads campaign type to internal type"""
        mapping = {
            'Search': 'search',
            'Shopping': 'shopping',
            'DynamicSearchAds': 'dynamic_search',
            'Audience': 'audience'
        }
        return mapping.get(str(campaign_type), 'unknown')
    
    def _map_bid_strategy(self, bid_strategy):
        """Map Bing Ads bid strategy to internal representation"""
        mapping = {
            'EnhancedCpc': 'enhanced_cpc',
            'MaxClicks': 'maximize_clicks',
            'MaxConversions': 'maximize_conversions',
            'TargetCpa': 'target_cpa',
            'ManualCpc': 'manual_cpc'
        }
        return mapping.get(str(bid_strategy), 'unknown')
```

### 2. Performance Metrics Collection

```python
from bingads.v13.reporting import *
from datetime import datetime, timedelta

class BingAdsMetricsCollector:
    def __init__(self, service_client, account_id):
        self.service_client = service_client
        self.account_id = account_id
        
    def collect_daily_metrics(self, start_date, end_date):
        """Collect daily performance metrics"""
        
        # Create reporting service
        reporting_service = ServiceClient(
            service='ReportingService',
            version=13,
            authorization=self.service_client.authorization,
            environment=self.service_client.environment
        )
        reporting_service.set_customer_id(self.service_client.customer_id)
        reporting_service.set_developer_token(self.service_client.developer_token)
        reporting_service.set_account_id(self.account_id)
        
        # Define report request
        report_request = CampaignPerformanceReportRequest(
            Format=ReportFormat.Csv,
            ReportName=f"Campaign_Performance_{datetime.now().strftime('%Y%m%d')}",
            ReturnOnlyCompleteData=False,
            Aggregation=ReportAggregation.Daily,
            Time=ReportTime(
                StartDate=ReportDate(
                    Day=start_date.day,
                    Month=start_date.month,
                    Year=start_date.year
                ),
                EndDate=ReportDate(
                    Day=end_date.day,
                    Month=end_date.month,
                    Year=end_date.year
                )
            ),
            Columns=[
                CampaignPerformanceReportColumn.CampaignId,
                CampaignPerformanceReportColumn.CampaignName,
                CampaignPerformanceReportColumn.TimePeriod,
                CampaignPerformanceReportColumn.Spend,
                CampaignPerformanceReportColumn.Conversions,
                CampaignPerformanceReportColumn.Impressions,
                CampaignPerformanceReportColumn.Clicks,
                CampaignPerformanceReportColumn.AverageCpc,
                CampaignPerformanceReportColumn.Ctr,
                CampaignPerformanceReportColumn.ConversionRate,
                CampaignPerformanceReportColumn.CostPerConversion
            ],
            Filter=CampaignPerformanceReportFilter(
                AccountStatus=AccountStatusReportFilter.Active,
                CampaignStatus=CampaignStatusReportFilter.Active | CampaignStatusReportFilter.Paused
            )
        )
        
        # Submit report request
        submit_response = reporting_service.SubmitGenerateReport(report_request)
        report_request_id = submit_response.ReportRequestId
        
        # Poll for report completion
        report_download_url = self._poll_report_completion(reporting_service, report_request_id)
        
        # Download and parse report
        metrics = self._download_and_parse_report(report_download_url)
        
        return metrics
    
    def _poll_report_completion(self, reporting_service, report_request_id, max_wait_minutes=10):
        """Poll for report completion"""
        
        max_wait_time = datetime.now() + timedelta(minutes=max_wait_minutes)
        
        while datetime.now() < max_wait_time:
            status_response = reporting_service.PollGenerateReport(report_request_id)
            
            if status_response.ReportRequestStatus == ReportRequestStatusType.Success:
                return status_response.ReportDownloadUrl
            elif status_response.ReportRequestStatus == ReportRequestStatusType.Error:
                raise Exception(f"Report generation failed: {status_response}")
            
            time.sleep(30)  # Wait before next poll
        
        raise Exception("Report generation timed out")
    
    def _download_and_parse_report(self, download_url):
        """Download and parse CSV report"""
        import requests
        import csv
        import io
        
        # Download report
        response = requests.get(download_url)
        response.raise_for_status()
        
        # Parse CSV
        csv_reader = csv.DictReader(io.StringIO(response.text))
        
        metrics = []
        for row in csv_reader:
            # Skip summary rows
            if row.get('CampaignId') and row.get('CampaignId').isdigit():
                metrics.append({
                    'campaign_external_id': row['CampaignId'],
                    'date': datetime.strptime(row['TimePeriod'], '%Y-%m-%d').date(),
                    'spend_micros': int(float(row['Spend']) * 1000000),
                    'conversions': int(float(row['Conversions']) if row['Conversions'] else 0),
                    'impressions': int(row['Impressions']) if row['Impressions'] else 0,
                    'clicks': int(row['Clicks']) if row['Clicks'] else 0,
                    'average_cpc_micros': int(float(row['AverageCpc']) * 1000000) if row['AverageCpc'] else 0,
                    'ctr': float(row['Ctr']) / 100 if row['Ctr'] else 0,  # Convert percentage to decimal
                    'conversion_rate': float(row['ConversionRate']) / 100 if row['ConversionRate'] else 0
                })
        
        return metrics
```

### 3. Conversion Tracking Integration

```python
class BingAdsConversionCollector:
    def __init__(self, service_client, account_id):
        self.service_client = service_client
        self.account_id = account_id
    
    def get_conversion_goals(self):
        """Get configured conversion goals"""
        
        campaign_service = ServiceClient(
            service='CampaignManagementService',
            version=13,
            authorization=self.service_client.authorization,
            environment=self.service_client.environment
        )
        campaign_service.set_customer_id(self.service_client.customer_id)
        campaign_service.set_developer_token(self.service_client.developer_token)
        campaign_service.set_account_id(self.account_id)
        
        # Get conversion goals
        request = GetConversionGoalsByAccountIdRequest(
            AccountId=self.account_id,
            ConversionGoalTypes=AllConversionGoalTypes
        )
        
        response = campaign_service.GetConversionGoalsByAccountId(request)
        
        conversion_goals = []
        if response and response.ConversionGoals:
            for goal in response.ConversionGoals.ConversionGoal:
                conversion_goals.append({
                    'external_id': str(goal.Id),
                    'name': goal.Name,
                    'type': str(goal.Type),
                    'status': str(goal.Status),
                    'conversion_window_days': goal.ConversionWindowInMinutes // (24 * 60) if goal.ConversionWindowInMinutes else 30
                })
        
        return conversion_goals
    
    def collect_conversions(self, start_date, end_date):
        """Collect conversion data"""
        
        reporting_service = ServiceClient(
            service='ReportingService',
            version=13,
            authorization=self.service_client.authorization,
            environment=self.service_client.environment
        )
        reporting_service.set_customer_id(self.service_client.customer_id)
        reporting_service.set_developer_token(self.service_client.developer_token)
        reporting_service.set_account_id(self.account_id)
        
        # Create conversion report request
        report_request = ConversionPerformanceReportRequest(
            Format=ReportFormat.Csv,
            ReportName=f"Conversion_Performance_{datetime.now().strftime('%Y%m%d')}",
            ReturnOnlyCompleteData=False,
            Aggregation=ReportAggregation.Daily,
            Time=ReportTime(
                StartDate=ReportDate(
                    Day=start_date.day,
                    Month=start_date.month,
                    Year=start_date.year
                ),
                EndDate=ReportDate(
                    Day=end_date.day,
                    Month=end_date.month,
                    Year=end_date.year
                )
            ),
            Columns=[
                ConversionPerformanceReportColumn.ConversionGoalId,
                ConversionPerformanceReportColumn.GoalName,
                ConversionPerformanceReportColumn.TimePeriod,
                ConversionPerformanceReportColumn.Conversions,
                ConversionPerformanceReportColumn.Revenue,
                ConversionPerformanceReportColumn.ConversionRate
            ]
        )
        
        # Submit and process report (similar to metrics collection)
        submit_response = reporting_service.SubmitGenerateReport(report_request)
        report_request_id = submit_response.ReportRequestId
        
        report_download_url = self._poll_report_completion(reporting_service, report_request_id)
        conversions = self._download_and_parse_conversion_report(report_download_url)
        
        return conversions
    
    def _download_and_parse_conversion_report(self, download_url):
        """Download and parse conversion CSV report"""
        import requests
        import csv
        import io
        
        response = requests.get(download_url)
        response.raise_for_status()
        
        csv_reader = csv.DictReader(io.StringIO(response.text))
        
        conversions = []
        for row in csv_reader:
            if row.get('ConversionGoalId') and row.get('ConversionGoalId').isdigit():
                conversions.append({
                    'conversion_goal_id': row['ConversionGoalId'],
                    'goal_name': row['GoalName'],
                    'conversion_date': datetime.strptime(row['TimePeriod'], '%Y-%m-%d').date(),
                    'conversions': float(row['Conversions']) if row['Conversions'] else 0,
                    'revenue_micros': int(float(row['Revenue']) * 1000000) if row['Revenue'] else 0,
                    'conversion_rate': float(row['ConversionRate']) / 100 if row['ConversionRate'] else 0
                })
        
        return conversions
```

## Database Integration

### Platform-Agnostic Data Model

```sql
-- Extend existing tables to support multiple platforms

-- Add platform tracking to ad_platforms table
ALTER TABLE ad_platforms ADD COLUMN platform_type VARCHAR(20) DEFAULT 'google_ads';

-- Insert Bing Ads platform configuration
INSERT INTO ad_platforms (name, business_id, platform_type, account_id, api_credentials_env_key, active)
VALUES 
('bing_ads', 1, 'bing_ads', '12345678', 'BING_ADS_CONFIG', TRUE);

-- Campaigns table already supports external_id, so no changes needed
-- daily_metrics table links to campaigns, so automatically supports both platforms

-- Add platform-specific configuration
INSERT INTO business_config (business_id, config_name, config_value, updated_by)
VALUES 
(1, 'bing_ads_settings', '{
    "account_id": "12345678",
    "customer_id": "87654321",
    "attribution_window_days": 180,
    "conversion_goals": ["leads", "bookings"],
    "bid_strategy_preferences": ["enhanced_cpc", "target_cpa"]
}', 'system');
```

### Data Processing Service

```python
class MultiPlatformDataService:
    def __init__(self, db_manager):
        self.db_manager = db_manager
        self.google_ads_collector = None
        self.bing_ads_collector = None
    
    def collect_all_platform_data(self, business_id, collection_date=None):
        """Collect data from all configured platforms for a business"""
        
        collection_date = collection_date or datetime.now().date()
        results = {}
        
        # Get configured platforms for business
        platforms = self._get_business_platforms(business_id)
        
        for platform in platforms:
            try:
                if platform.platform_type == 'google_ads':
                    results['google_ads'] = self._collect_google_ads_data(
                        business_id, platform, collection_date
                    )
                elif platform.platform_type == 'bing_ads':
                    results['bing_ads'] = self._collect_bing_ads_data(
                        business_id, platform, collection_date
                    )
                    
            except Exception as e:
                logger.error(f"Error collecting {platform.platform_type} data for business {business_id}: {e}")
                results[platform.platform_type] = {'error': str(e)}
        
        # Consolidate and validate cross-platform data
        validation_results = self._validate_cross_platform_data(business_id, results)
        
        return {
            'collection_results': results,
            'validation': validation_results,
            'collection_date': collection_date
        }
    
    def _collect_bing_ads_data(self, business_id, platform, collection_date):
        """Collect Bing Ads data for business"""
        
        # Initialize Bing Ads collector
        authenticator = BingAdsAuthenticator()
        service_client = authenticator.get_service_client('CampaignManagementService')
        
        campaign_collector = BingAdsCampaignCollector(service_client, platform.account_id)
        metrics_collector = BingAdsMetricsCollector(service_client, platform.account_id)
        conversion_collector = BingAdsConversionCollector(service_client, platform.account_id)
        
        # Collect data
        campaigns = campaign_collector.collect_campaigns()
        
        # Get date range for metrics
        end_date = collection_date
        start_date = collection_date - timedelta(days=7)
        
        daily_metrics = metrics_collector.collect_daily_metrics(start_date, end_date)
        conversions = conversion_collector.collect_conversions(start_date, end_date)
        
        # Update database
        self._update_platform_campaigns(business_id, platform.id, campaigns)
        self._update_platform_metrics(business_id, platform.id, daily_metrics)
        self._update_platform_conversions(business_id, platform.id, conversions)
        
        return {
            'campaigns': len(campaigns),
            'metrics': len(daily_metrics),
            'conversions': len(conversions),
            'platform': 'bing_ads'
        }
    
    def _validate_cross_platform_data(self, business_id, results):
        """Validate data consistency across platforms"""
        validation_issues = []
        
        # Check for significant spend discrepancies
        if 'google_ads' in results and 'bing_ads' in results:
            google_spend = self._get_total_spend_by_platform(business_id, 'google_ads')
            bing_spend = self._get_total_spend_by_platform(business_id, 'bing_ads')
            
            total_spend = google_spend + bing_spend
            if total_spend > 0:
                google_percentage = google_spend / total_spend
                bing_percentage = bing_spend / total_spend
                
                # Log platform distribution for analysis
                logger.info(f"Business {business_id} spend distribution: "
                           f"Google Ads {google_percentage:.1%}, Bing Ads {bing_percentage:.1%}")
        
        # Check for conversion tracking consistency
        google_conversions = self._get_conversion_count_by_platform(business_id, 'google_ads')
        bing_conversions = self._get_conversion_count_by_platform(business_id, 'bing_ads')
        
        if google_conversions == 0 and bing_conversions == 0:
            validation_issues.append("No conversions tracked on any platform")
        
        return {
            'issues': validation_issues,
            'platform_distribution': {
                'google_ads_spend': google_spend if 'google_ads' in results else 0,
                'bing_ads_spend': bing_spend if 'bing_ads' in results else 0
            }
        }
```

## Dashboard Integration

### Multi-Platform Yield Curves

```python
# Update Streamlit dashboard to support platform filtering

def show_portfolio_overview_with_platforms(services):
    st.title("🎯 Portfolio Overview - Multi-Platform")
    
    # Platform selection
    available_platforms = get_available_platforms()
    selected_platforms = st.multiselect(
        "Select Advertising Platforms",
        options=available_platforms,
        default=available_platforms,
        help="Choose which platforms to include in analysis"
    )
    
    # Business selection
    businesses = services['config'].get_all_businesses()
    selected_businesses = st.multiselect(
        "Select Businesses", 
        options=[b.id for b in businesses],
        default=[1],  # Wilderness (has both platforms)
        format_func=lambda x: next(b.name for b in businesses if b.id == x)
    )
    
    if selected_businesses and selected_platforms:
        # Get multi-platform yield curve data
        comparison_data = services['yield_curves'].get_multi_platform_comparison(
            business_ids=selected_businesses,
            platforms=selected_platforms,
            date_range=date_range
        )
        
        # Create platform comparison visualization
        fig = create_multi_platform_yield_curves(comparison_data)
        st.plotly_chart(fig, use_container_width=True)
        
        # Platform spend distribution
        col1, col2 = st.columns(2)
        
        with col1:
            st.subheader("Platform Distribution")
            platform_dist = calculate_platform_distribution(comparison_data)
            fig_dist = create_platform_distribution_chart(platform_dist)
            st.plotly_chart(fig_dist, use_container_width=True)
        
        with col2:
            st.subheader("Cross-Platform Efficiency")
            efficiency_comparison = calculate_cross_platform_efficiency(comparison_data)
            st.dataframe(efficiency_comparison, use_container_width=True)
```

### Platform-Specific Analytics

```python
def create_platform_comparison_service():
    """Service for cross-platform analytics"""
    
    class PlatformComparisonService:
        def __init__(self, db_manager):
            self.db_manager = db_manager
        
        def get_platform_performance_comparison(self, business_id, date_range):
            """Compare performance across platforms"""
            
            query = """
                SELECT 
                    p.platform_type,
                    p.name as platform_name,
                    COUNT(DISTINCT c.id) as campaign_count,
                    SUM(dm.spend_micros) / 1000000.0 as total_spend_usd,
                    SUM(dm.conversions) as total_conversions,
                    AVG(dm.spend_micros / NULLIF(dm.conversions, 0)) / 1000000.0 as avg_cpl_usd,
                    SUM(dm.clicks) as total_clicks,
                    SUM(dm.impressions) as total_impressions
                FROM ad_platforms p
                JOIN campaigns c ON p.id = c.platform_id
                JOIN daily_metrics dm ON c.id = dm.campaign_id
                WHERE c.business_id = %s
                AND dm.date BETWEEN %s AND %s
                GROUP BY p.platform_type, p.name
                ORDER BY total_spend_usd DESC
            """
            
            return pd.read_sql(query, self.db_manager.get_connection(), 
                             params=[business_id, date_range[0], date_range[1]])
        
        def get_cross_platform_attribution_analysis(self, business_id, date_range):
            """Analyze attribution patterns across platforms"""
            
            # This would require enhanced attribution tracking
            # that considers cross-platform customer journeys
            
            query = """
                SELECT 
                    p.platform_type,
                    ar.attribution_model,
                    SUM(ar.attributed_value_micros) / 1000000.0 as attributed_value_usd,
                    COUNT(*) as attribution_events
                FROM attribution_results ar
                JOIN campaigns c ON ar.campaign_id = c.id
                JOIN ad_platforms p ON c.platform_id = p.id
                WHERE c.business_id = %s
                AND ar.calculation_date BETWEEN %s AND %s
                GROUP BY p.platform_type, ar.attribution_model
                ORDER BY p.platform_type, attributed_value_usd DESC
            """
            
            return pd.read_sql(query, self.db_manager.get_connection(), 
                             params=[business_id, date_range[0], date_range[1]])
    
    return PlatformComparisonService
```

## Batch Processing Integration

### Enhanced Celery Tasks

```python
@app.task(bind=True, max_retries=3)
def collect_multi_platform_data(self, business_id, collection_date=None):
    """Enhanced task to collect data from all platforms"""
    
    try:
        collection_date = collection_date or datetime.now().date()
        
        # Get business platforms
        business = get_business_by_id(business_id)
        platforms = get_business_platforms(business_id)
        
        results = {}
        
        for platform in platforms:
            try:
                if platform.platform_type == 'google_ads':
                    results['google_ads'] = collect_google_ads_data.delay(
                        business_id, collection_date
                    ).get()
                    
                elif platform.platform_type == 'bing_ads':
                    results['bing_ads'] = collect_bing_ads_data.delay(
                        business_id, collection_date
                    ).get()
                    
            except Exception as e:
                logger.error(f"Platform {platform.platform_type} collection failed: {e}")
                results[platform.platform_type] = {'error': str(e)}
        
        # Cross-platform data validation
        validation_results = validate_cross_platform_data(business_id, results)
        
        # Update yield curves with multi-platform data
        calculate_multi_platform_yield_curves.delay(business_id, collection_date)
        
        return {
            'success': True,
            'business_id': business_id,
            'collection_date': str(collection_date),
            'platform_results': results,
            'validation': validation_results
        }
        
    except Exception as e:
        logger.error(f"Multi-platform collection failed for business {business_id}: {e}")
        
        if self.request.retries < self.max_retries:
            raise self.retry(countdown=600, exc=e)  # 10 minute delay
        else:
            send_collection_failure_alert(business_id, str(e))
            raise

@app.task
def collect_bing_ads_data(business_id, collection_date):
    """Dedicated task for Bing Ads data collection"""
    
    try:
        platform = get_platform_by_business_and_type(business_id, 'bing_ads')
        if not platform:
            raise ValueError(f"No Bing Ads platform configured for business {business_id}")
        
        # Initialize collectors
        authenticator = BingAdsAuthenticator()
        service_client = authenticator.get_service_client('CampaignManagementService')
        
        campaign_collector = BingAdsCampaignCollector(service_client, platform.account_id)
        metrics_collector = BingAdsMetricsCollector(service_client, platform.account_id)
        
        # Collect campaigns
        campaigns = campaign_collector.collect_campaigns()
        logger.info(f"Collected {len(campaigns)} Bing Ads campaigns for business {business_id}")
        
        # Update campaigns in database
        campaign_service = CampaignService()
        campaign_service.update_campaigns(business_id, campaigns, platform_id=platform.id)
        
        # Collect metrics
        end_date = collection_date
        start_date = collection_date - timedelta(days=7)
        
        daily_metrics = metrics_collector.collect_daily_metrics(start_date, end_date)
        logger.info(f"Collected {len(daily_metrics)} Bing Ads metric records")
        
        # Update metrics
        metrics_service = MetricsService()
        metrics_service.update_daily_metrics(business_id, daily_metrics, platform_id=platform.id)
        
        return {
            'success': True,
            'platform': 'bing_ads',
            'campaigns': len(campaigns),
            'metrics': len(daily_metrics)
        }
        
    except Exception as e:
        logger.error(f"Bing Ads collection failed for business {business_id}: {e}")
        raise
```

## Testing and Validation

### Bing Ads Integration Tests

```python
import unittest
from unittest.mock import Mock, patch

class TestBingAdsIntegration(unittest.TestCase):
    def setUp(self):
        self.business_id = 1
        self.account_id = "12345678"
        self.mock_service_client = Mock()
        
    @patch('bing_ads_integration.BingAdsAuthenticator')
    def test_campaign_collection(self, mock_auth):
        """Test Bing Ads campaign collection"""
        
        mock_auth.return_value.get_service_client.return_value = self.mock_service_client
        
        # Mock campaign response
        mock_campaign = Mock()
        mock_campaign.Id = 12345
        mock_campaign.Name = "Test Bing Campaign"
        mock_campaign.Status = "Active"
        mock_campaign.CampaignType = "Search"
        mock_campaign.MonthlyBudget = 1000
        
        mock_response = Mock()
        mock_response.Campaigns = Mock()
        mock_response.Campaigns.Campaign = [mock_campaign]
        
        self.mock_service_client.GetCampaignsByAccountId.return_value = mock_response
        
        collector = BingAdsCampaignCollector(self.mock_service_client, self.account_id)
        campaigns = collector.collect_campaigns()
        
        self.assertEqual(len(campaigns), 1)
        self.assertEqual(campaigns[0]['name'], "Test Bing Campaign")
        self.assertEqual(campaigns[0]['status'], 'active')
        self.assertEqual(campaigns[0]['campaign_type'], 'search')
    
    def test_cross_platform_validation(self):
        """Test cross-platform data validation"""
        
        results = {
            'google_ads': {'campaigns': 10, 'metrics': 70, 'conversions': 15},
            'bing_ads': {'campaigns': 5, 'metrics': 35, 'conversions': 8}
        }
        
        service = MultiPlatformDataService(Mock())
        validation = service._validate_cross_platform_data(self.business_id, results)
        
        self.assertIsInstance(validation, dict)
        self.assertIn('platform_distribution', validation)
    
    @patch('bing_ads_integration.requests')
    def test_report_download(self, mock_requests):
        """Test Bing Ads report download and parsing"""
        
        # Mock CSV response
        csv_content = """CampaignId,CampaignName,TimePeriod,Spend,Conversions,Clicks
12345,Test Campaign,2024-01-01,100.50,5,50
12346,Another Campaign,2024-01-01,200.25,3,75"""
        
        mock_response = Mock()
        mock_response.text = csv_content
        mock_response.raise_for_status.return_value = None
        mock_requests.get.return_value = mock_response
        
        collector = BingAdsMetricsCollector(self.mock_service_client, self.account_id)
        metrics = collector._download_and_parse_report("http://fake-url.com")
        
        self.assertEqual(len(metrics), 2)
        self.assertEqual(metrics[0]['campaign_external_id'], '12345')
        self.assertEqual(metrics[0]['spend_micros'], 100500000)  # $100.50 in micros
        self.assertEqual(metrics[0]['conversions'], 5)
```

## Deployment and Configuration

### Environment Setup

```bash
# Additional environment variables for Bing Ads
export BING_ADS_DEVELOPER_TOKEN="your_bing_developer_token"
export BING_ADS_CLIENT_ID="your_bing_client_id"
export BING_ADS_CLIENT_SECRET="your_bing_client_secret"
export BING_ADS_REFRESH_TOKEN="your_bing_refresh_token"
export BING_ADS_CUSTOMER_ID="your_bing_customer_id"

# Wilderness Bing Ads configuration
export WILDERNESS_BING_ADS_ACCOUNT_ID="12345678"
export WILDERNESS_BING_ADS_CUSTOMER_ID="87654321"
```

### Installation Script

```bash
#!/bin/bash
# scripts/setup_bing_ads_integration.sh

echo "🔧 Setting up Bing Ads integration..."

# Install Bing Ads SDK
pip install bingads==13.0.13

# Create Bing Ads configuration directory
mkdir -p config/bing_ads

# Test connection
python scripts/test_bing_ads_connection.py

echo "✅ Bing Ads integration setup complete!"
```

### Connection Test Script

```python
#!/usr/bin/env python3
# scripts/test_bing_ads_connection.py

import os
from bingads.service_client import ServiceClient
from bingads.authorization import *

def test_bing_ads_connection():
    """Test Bing Ads API connection"""
    
    print("🔍 Testing Bing Ads API connection...")
    
    try:
        # Initialize authentication
        authentication = OAuthWebAuthCodeGrant(
            client_id=os.getenv('BING_ADS_CLIENT_ID'),
            client_secret=os.getenv('BING_ADS_CLIENT_SECRET'),
            redirection_uri=None,
            tokens=OAuthTokens(refresh_token=os.getenv('BING_ADS_REFRESH_TOKEN'))
        )
        
        # Test customer service
        customer_service = ServiceClient(
            service='CustomerManagementService',
            version=13,
            authorization=authentication,
            environment='production'
        )
        
        customer_service.set_customer_id(os.getenv('BING_ADS_CUSTOMER_ID'))
        customer_service.set_developer_token(os.getenv('BING_ADS_DEVELOPER_TOKEN'))
        
        # Test account access
        account_id = os.getenv('WILDERNESS_BING_ADS_ACCOUNT_ID')
        
        # Get account info
        get_accounts_info = GetAccountsInfoRequest(
            CustomerId=os.getenv('BING_ADS_CUSTOMER_ID')
        )
        
        accounts_info = customer_service.GetAccountsInfo(get_accounts_info)
        
        if accounts_info and accounts_info.AccountsInfo:
            print("✅ Bing Ads connection successful!")
            
            for account_info in accounts_info.AccountsInfo.AccountInfo:
                if str(account_info.Id) == account_id:
                    print(f"   Account: {account_info.Name}")
                    print(f"   Currency: {account_info.CurrencyCode}")
                    print(f"   Time Zone: {account_info.TimeZone}")
                    
                    # Test campaign access
                    test_campaign_access(account_info.Id)
                    break
        else:
            print("❌ No accounts found")
            
    except Exception as e:
        print(f"❌ Bing Ads connection failed: {e}")

def test_campaign_access(account_id):
    """Test campaign access for specific account"""
    
    try:
        authentication = OAuthWebAuthCodeGrant(
            client_id=os.getenv('BING_ADS_CLIENT_ID'),
            client_secret=os.getenv('BING_ADS_CLIENT_SECRET'),
            redirection_uri=None,
            tokens=OAuthTokens(refresh_token=os.getenv('BING_ADS_REFRESH_TOKEN'))
        )
        
        campaign_service = ServiceClient(
            service='CampaignManagementService',
            version=13,
            authorization=authentication,
            environment='production'
        )
        
        campaign_service.set_customer_id(os.getenv('BING_ADS_CUSTOMER_ID'))
        campaign_service.set_developer_token(os.getenv('BING_ADS_DEVELOPER_TOKEN'))
        campaign_service.set_account_id(account_id)
        
        # Get campaigns
        get_campaigns_request = GetCampaignsByAccountIdRequest(
            AccountId=account_id,
            CampaignType=AllCampaignTypes
        )
        
        campaigns_response = campaign_service.GetCampaignsByAccountId(get_campaigns_request)
        
        if campaigns_response and campaigns_response.Campaigns:
            campaign_count = len(campaigns_response.Campaigns.Campaign)
            print(f"   Campaigns accessible: {campaign_count}")
            
            if campaign_count > 0:
                print("   Sample campaigns:")
                for i, campaign in enumerate(campaigns_response.Campaigns.Campaign[:3]):
                    print(f"     - {campaign.Name} ({campaign.Status})")
        else:
            print("   No campaigns found")
            
    except Exception as e:
        print(f"   Campaign access test failed: {e}")

if __name__ == "__main__":
    test_bing_ads_connection()
```

## Performance Considerations

### Rate Limiting and Throttling

```python
class BingAdsRateLimitManager:
    def __init__(self):
        self.api_requests_per_hour = 100000  # Bing Ads limit
        self.report_requests_per_day = 2000   # Report request limit
        self.current_hour_requests = 0
        self.current_day_reports = 0
        self.hour_start = datetime.now().replace(minute=0, second=0, microsecond=0)
        self.day_start = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    
    def check_rate_limit(self, request_type='api'):
        """Check if request is within rate limits"""
        
        current_time = datetime.now()
        
        # Reset counters if needed
        if current_time.hour != self.hour_start.hour:
            self.current_hour_requests = 0
            self.hour_start = current_time.replace(minute=0, second=0, microsecond=0)
        
        if current_time.date() != self.day_start.date():
            self.current_day_reports = 0
            self.day_start = current_time.replace(hour=0, minute=0, second=0, microsecond=0)
        
        # Check limits
        if request_type == 'api' and self.current_hour_requests >= self.api_requests_per_hour * 0.9:
            return False, "API hourly limit approaching"
        
        if request_type == 'report' and self.current_day_reports >= self.report_requests_per_day * 0.9:
            return False, "Report daily limit approaching"
        
        return True, "Within limits"
    
    def record_request(self, request_type='api'):
        """Record a request for rate limiting"""
        if request_type == 'api':
            self.current_hour_requests += 1
        elif request_type == 'report':
            self.current_day_reports += 1
```

### Optimized Data Collection

```python
class OptimizedBingAdsCollector:
    def __init__(self, service_client, account_id):
        self.service_client = service_client
        self.account_id = account_id
        self.rate_limiter = BingAdsRateLimitManager()
        
    def collect_data_efficiently(self, start_date, end_date, data_types=['campaigns', 'metrics']):
        """Efficiently collect multiple data types in single session"""
        
        results = {}
        
        # Collect campaigns (quick API call)
        if 'campaigns' in data_types:
            can_proceed, message = self.rate_limiter.check_rate_limit('api')
            if can_proceed:
                results['campaigns'] = self._collect_campaigns_optimized()
                self.rate_limiter.record_request('api')
            else:
                logger.warning(f"Skipping campaign collection: {message}")
        
        # Collect metrics (report-based, slower)
        if 'metrics' in data_types:
            can_proceed, message = self.rate_limiter.check_rate_limit('report')
            if can_proceed:
                results['metrics'] = self._collect_metrics_batched(start_date, end_date)
                self.rate_limiter.record_request('report')
            else:
                logger.warning(f"Skipping metrics collection: {message}")
        
        return results
    
    def _collect_campaigns_optimized(self):
        """Collect campaigns with minimal API calls"""
        
        # Single call to get all campaign data
        campaign_service = ServiceClient(
            service='CampaignManagementService',
            version=13,
            authorization=self.service_client.authorization,
            environment=self.service_client.environment
        )
        campaign_service.set_customer_id(self.service_client.customer_id)
        campaign_service.set_developer_token(self.service_client.developer_token)
        campaign_service.set_account_id(self.account_id)
        
        request = GetCampaignsByAccountIdRequest(
            AccountId=self.account_id,
            CampaignType=AllCampaignTypes,
            ReturnAdditionalFields=[
                CampaignAdditionalField.BiddingStrategyType,
                CampaignAdditionalField.BidStrategyId
            ]
        )
        
        response = campaign_service.GetCampaignsByAccountId(request)
        
        campaigns = []
        if response and response.Campaigns:
            for campaign in response.Campaigns.Campaign:
                campaigns.append(self._format_campaign(campaign))
        
        return campaigns
    
    def _collect_metrics_batched(self, start_date, end_date, batch_days=30):
        """Collect metrics in optimized date batches"""
        
        # Split date range into smaller batches to avoid timeout
        date_ranges = self._split_date_range_optimally(start_date, end_date, batch_days)
        
        all_metrics = []
        
        for batch_start, batch_end in date_ranges:
            try:
                batch_metrics = self._collect_single_metrics_batch(batch_start, batch_end)
                all_metrics.extend(batch_metrics)
                
                # Small delay between batches
                time.sleep(1)
                
            except Exception as e:
                logger.error(f"Failed to collect metrics batch {batch_start} to {batch_end}: {e}")
                continue
        
        return all_metrics
    
    def _split_date_range_optimally(self, start_date, end_date, max_days):
        """Split date range for optimal performance"""
        
        ranges = []
        current_start = start_date
        
        while current_start <= end_date:
            current_end = min(current_start + timedelta(days=max_days), end_date)
            ranges.append((current_start, current_end))
            current_start = current_end + timedelta(days=1)
        
        return ranges
```

## Monitoring and Maintenance

### Multi-Platform Health Monitoring

```python
class MultiPlatformHealthMonitor:
    def __init__(self):
        self.platforms = ['google_ads', 'bing_ads']
        self.health_thresholds = {
            'collection_success_rate': 0.95,
            'data_freshness_hours': 6,
            'cross_platform_variance': 0.3
        }
    
    def check_multi_platform_health(self, business_id):
        """Check health across all platforms for a business"""
        
        health_report = {}
        
        for platform in self.platforms:
            platform_health = self._check_platform_health(business_id, platform)
            health_report[platform] = platform_health
        
        # Cross-platform consistency checks
        consistency_check = self._check_cross_platform_consistency(business_id, health_report)
        
        return MultiPlatformHealthReport(
            business_id=business_id,
            platform_health=health_report,
            consistency_check=consistency_check,
            overall_status=self._determine_overall_health(health_report, consistency_check),
            checked_at=datetime.utcnow()
        )
    
    def _check_platform_health(self, business_id, platform):
        """Check health metrics for specific platform"""
        
        return {
            'last_collection': self._get_last_collection_time(business_id, platform),
            'collection_success_rate_24h': self._get_collection_success_rate(business_id, platform, 24),
            'data_quality_score': self._calculate_data_quality_score(business_id, platform),
            'api_error_rate': self._get_api_error_rate(business_id, platform),
            'active_campaigns': self._get_active_campaign_count(business_id, platform)
        }
    
    def _check_cross_platform_consistency(self, business_id, platform_health):
        """Check consistency between platforms"""
        
        issues = []
        
        # Check if both platforms have recent data
        google_last = platform_health.get('google_ads', {}).get('last_collection')
        bing_last = platform_health.get('bing_ads', {}).get('last_collection')
        
        if google_last and bing_last:
            time_diff = abs((google_last - bing_last).total_seconds() / 3600)
            if time_diff > 6:  # More than 6 hours difference
                issues.append(f"Collection time difference: {time_diff:.1f} hours")
        
        # Check data quality consistency
        google_quality = platform_health.get('google_ads', {}).get('data_quality_score', 0)
        bing_quality = platform_health.get('bing_ads', {}).get('data_quality_score', 0)
        
        if abs(google_quality - bing_quality) > 0.2:
            issues.append(f"Data quality variance: Google {google_quality:.2f}, Bing {bing_quality:.2f}")
        
        return {
            'consistent': len(issues) == 0,
            'issues': issues,
            'variance_score': self._calculate_platform_variance(business_id)
        }
```

### Automated Alerts

```python
class MultiPlatformAlertManager:
    def __init__(self):
        self.alert_channels = ['email', 'slack']
        
    def process_health_report(self, health_report):
        """Process health report and trigger alerts"""
        
        alerts = []
        
        # Platform-specific alerts
        for platform, health in health_report.platform_health.items():
            platform_alerts = self._check_platform_alerts(platform, health)
            alerts.extend(platform_alerts)
        
        # Cross-platform alerts
        consistency_alerts = self._check_consistency_alerts(health_report.consistency_check)
        alerts.extend(consistency_alerts)
        
        # Send alerts if any found
        if alerts:
            self._send_alerts(health_report.business_id, alerts)
        
        return alerts
    
    def _check_platform_alerts(self, platform, health):
        """Check for platform-specific alert conditions"""
        
        alerts = []
        
        # Collection failure alert
        if health['collection_success_rate_24h'] < 0.9:
            alerts.append({
                'type': 'collection_failure',
                'platform': platform,
                'severity': 'high',
                'message': f"{platform} collection success rate: {health['collection_success_rate_24h']:.1%}"
            })
        
        # Data quality alert
        if health['data_quality_score'] < 0.7:
            alerts.append({
                'type': 'data_quality',
                'platform': platform,
                'severity': 'medium',
                'message': f"{platform} data quality score: {health['data_quality_score']:.2f}"
            })
        
        # API error rate alert
        if health['api_error_rate'] > 0.1:
            alerts.append({
                'type': 'api_errors',
                'platform': platform,
                'severity': 'medium',
                'message': f"{platform} API error rate: {health['api_error_rate']:.1%}"
            })
        
        return alerts
    
    def _send_alerts(self, business_id, alerts):
        """Send alerts through configured channels"""
        
        business_name = get_business_name(business_id)
        
        alert_message = self._format_alert_message(business_name, alerts)
        
        # Send email alert
        if 'email' in self.alert_channels:
            send_email_alert(
                to=get_business_alert_emails(business_id),
                subject=f"Multi-Platform Integration Alert: {business_name}",
                body=alert_message
            )
        
        # Send Slack alert
        if 'slack' in self.alert_channels:
            send_slack_alert(
                channel=get_business_slack_channel(business_id),
                message=alert_message
            )
```

## Best Practices Summary

### Development Guidelines

1. **Platform Abstraction**
    
    - Use common interfaces for both Google Ads and Bing Ads
    - Implement platform-specific logic in separate modules
    - Maintain consistent data models across platforms
2. **Error Handling**
    
    - Implement platform-specific error handling
    - Use circuit breaker pattern for API failures
    - Provide fallback mechanisms for single-platform failures
3. **Performance Optimization**
    
    - Batch requests where possible
    - Implement intelligent rate limiting
    - Use async processing for independent platform calls
4. **Data Quality**
    
    - Validate data consistency between platforms
    - Monitor for platform-specific anomalies
    - Implement cross-platform validation rules

### Operational Guidelines

1. **Monitoring**
    
    - Monitor each platform independently
    - Track cross-platform consistency metrics
    - Set up automated health checks
2. **Maintenance**
    
    - Regular credential rotation
    - API version upgrade planning
    - Platform-specific configuration management
3. **Scaling**
    
    - Design for additional platform integration
    - Plan for increased data volumes
    - Consider regional API requirements

### Security Considerations

1. **Credential Management**
    
    - Separate credentials for each platform
    - Encrypted storage of sensitive data
    - Regular access audit and rotation
2. **Data Privacy**
    
    - Platform-specific data retention policies
    - Compliance with platform terms of service
    - Secure cross-platform data correlation

## Future Enhancements

### Advanced Attribution

```python
class CrossPlatformAttributionEngine:
    """Advanced attribution across Google Ads and Bing Ads"""
    
    def __init__(self):
        self.attribution_models = {
            'cross_platform_time_decay': self._cross_platform_time_decay,
            'platform_weighted': self._platform_weighted_attribution,
            'unified_customer_journey': self._unified_journey_attribution
        }
    
    def calculate_unified_attribution(self, business_id, conversion_date, lookback_days=180):
        """Calculate attribution considering all platforms"""
        
        # Get touchpoints from all platforms
        touchpoints = self._get_cross_platform_touchpoints(
            business_id, conversion_date, lookback_days
        )
        
        # Apply cross-platform attribution models
        attribution_results = {}
        
        for model_name, model_func in self.attribution_models.items():
            attribution_results[model_name] = model_func(touchpoints)
        
        return attribution_results
    
    def _cross_platform_time_decay(self, touchpoints):
        """Time decay attribution across platforms"""
        
        # Weight touchpoints by recency regardless of platform
        total_weight = 0
        attributed_touchpoints = []
        
        for touchpoint in touchpoints:
            days_ago = (touchpoint.conversion_date - touchpoint.touchpoint_date).days
            weight = 0.5 ** (days_ago / 30)  # 30-day half-life
            
            attributed_touchpoints.append({
                'touchpoint_id': touchpoint.id,
                'platform': touchpoint.platform,
                'campaign_id': touchpoint.campaign_id,
                'weight': weight,
                'attributed_value': touchpoint.conversion_value * weight
            })
            
            total_weight += weight
        
        # Normalize weights
        for touchpoint in attributed_touchpoints:
            touchpoint['normalized_weight'] = touchpoint['weight'] / total_weight
            touchpoint['normalized_attributed_value'] = (
                touchpoint['attributed_value'] / total_weight
            )
        
        return attributed_touchpoints
```

### Predictive Analytics

```python
class MultiPlatformPredictiveEngine:
    """Predictive analytics across platforms"""
    
    def predict_optimal_budget_allocation(self, business_id, total_budget, prediction_horizon_days=30):
        """Predict optimal budget allocation between platforms"""
        
        # Get historical performance data
        historical_data = self._get_historical_performance(business_id, days=90)
        
        # Build prediction models for each platform
        models = {}
        for platform in ['google_ads', 'bing_ads']:
            platform_data = historical_data[historical_data['platform'] == platform]
            models[platform] = self._build_performance_model(platform_data)
        
        # Optimize budget allocation
        optimization_result = self._optimize_cross_platform_allocation(
            models, total_budget, prediction_horizon_days
        )
        
        return {
            'recommended_allocation': optimization_result['allocation'],
            'predicted_performance': optimization_result['performance'],
            'confidence_score': optimization_result['confidence'],
            'optimization_method': 'multi_platform_yield_optimization'
        }
```

This completes the comprehensive **Bing Ads Integration Guide**. Now let me create the final document - **Streamlit Dashboard Specifications**: