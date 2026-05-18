---
title: "Streamlit_dashboard_specs"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# Streamlit Dashboard Specifications

## Overview

Comprehensive specifications for the yield curve analytics dashboard built with Streamlit. Designed for PE stakeholder presentations, operational team usage, and strategic decision-making across multiple audiences.

## Design Philosophy

### Target Audiences

**Primary Users:**

- **PE Stakeholders (Nick)** - Portfolio-level capital allocation decisions
- **Executive Leadership** - Strategic planning and performance monitoring
- **Marketing Teams** - Operational optimization and campaign management
- **Analytics Teams** - Attribution analysis and data validation

**Design Principles:**

- **Fighter Jet Cockpit, Not Kitchen Sink** - Focus on actionable insights
- **PE-Level Sophistication** - Mathematical rigor with executive accessibility
- **Multi-Audience Navigation** - Clear separation between strategic and operational views
- **Live Demo Ready** - Responsive performance for stakeholder presentations

## Application Architecture

### Navigation Structure

```
Yield Curve Analytics Dashboard
├── 📊 System Overview (Page 0)
├── 🎯 Portfolio Overview (Page 1)
├── 🔍 Attribution Analysis (Page 2)
├── 💰 Money Left on Table (Page 3)
└── 📈 Business Deep Dives (Page 4)
```

### Technical Implementation

```python
# Main application structure
import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta
import numpy as np

# Page configuration
st.set_page_config(
    page_title="Yield Curve Analytics",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Initialize services
@st.cache_resource
def init_services():
    """Initialize data services with caching"""
    db_manager = DatabaseManager()
    return {
        'yield_curves': YieldCurveDataService(db_manager.get_connection()),
        'attribution': AttributionDataService(db_manager.get_connection()),
        'config': ConfigurationService(db_manager.get_connection()),
        'campaigns': CampaignDataService(db_manager.get_connection()),
        'historical': HistoricalAnalysisService(db_manager.get_connection())
    }

def main():
    services = init_services()
    
    # Sidebar navigation
    st.sidebar.title("🎯 Yield Curve Analytics")
    
    # Business context
    st.sidebar.markdown("---")
    st.sidebar.markdown("**PE Portfolio Optimization**")
    st.sidebar.markdown("Mathematical approach to capital allocation across Google Ads campaigns")
    
    # Page selection
    pages = {
        "📊 System Overview": show_system_overview,
        "🎯 Portfolio Overview": show_portfolio_overview,
        "🔍 Attribution Analysis": show_attribution_analysis,
        "💰 Money Left on Table": show_money_left_on_table,
        "📈 Business Deep Dives": show_business_deep_dives
    }
    
    selected_page = st.sidebar.selectbox(
        "Select Analysis View",
        list(pages.keys()),
        help="Choose analysis perspective based on your role and needs"
    )
    
    # Global filters
    st.sidebar.markdown("---")
    st.sidebar.markdown("**Global Filters**")
    
    # Business selection
    businesses = get_all_businesses()
    selected_businesses = st.sidebar.multiselect(
        "Businesses",
        options=[b.id for b in businesses],
        default=[1, 2, 3],
        format_func=lambda x: next(b.name for b in businesses if b.id == x)
    )
    
    # Date range selection
    default_end = datetime.now().date()
    default_start = default_end - timedelta(days=365)
    
    date_range = st.sidebar.date_input(
        "Analysis Period",
        value=(default_start, default_end),
        max_value=datetime.now().date(),
        help="Date range for analysis (default: last 12 months)"
    )
    
    # Attribution model selection
    attribution_model = st.sidebar.selectbox(
        "Attribution Model",
        options=['time_decay', 'position_based', 'linear', 'first_touch', 'last_touch'],
        index=0,
        help="Choose attribution model for conversion analysis"
    )
    
    # Execute selected page
    if selected_businesses and len(date_range) == 2:
        pages[selected_page](services, selected_businesses, date_range, attribution_model)
    else:
        st.error("Please select at least one business and a valid date range")

if __name__ == "__main__":
    main()
```

## Page Specifications

### Page 0: System Overview

**Purpose:** Onboarding and methodology explanation for PE stakeholders

**Target Audience:** Nick (PE), new users, executives

**Key Components:**

```python
def show_system_overview(services, businesses, date_range, attribution_model):
    st.title("📊 Yield Curve Analytics System")
    st.markdown("### Mathematical Approach to PE Portfolio Optimization")
    
    # Executive summary metrics
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        total_businesses = len(get_all_businesses())
        st.metric(
            "Portfolio Businesses",
            total_businesses,
            help="Total businesses in PE portfolio"
        )
    
    with col2:
        total_campaigns = get_total_campaign_count()
        st.metric(
            "Active Campaigns",
            f"{total_campaigns:,}",
            help="Total active campaigns across all businesses"
        )
    
    with col3:
        monthly_spend = get_monthly_spend_total()
        st.metric(
            "Monthly Ad Spend",
            f"${monthly_spend/1000:,.0f}K",
            help="Total monthly advertising spend"
        )
    
    with col4:
        optimization_opportunity = calculate_optimization_opportunity()
        st.metric(
            "Optimization Opportunity",
            f"${optimization_opportunity/1000:,.0f}K",
            delta=f"{optimization_opportunity/monthly_spend:.1%}",
            help="Estimated monthly improvement opportunity"
        )
    
    st.markdown("---")
    
    # Methodology explanation
    st.subheader("🎯 Core Methodology")
    
    tab1, tab2, tab3 = st.tabs(["Yield Curves", "Attribution Models", "Capital Allocation"])
    
    with tab1:
        st.markdown("""
        **Yield Curve Analysis**
        
        Instead of linear budget allocation, we analyze marginal efficiency:
        
        - **Spend Buckets**: Campaigns segmented by spend levels
        - **Marginal CPL**: Cost per lead for each incremental spend bucket
        - **Efficiency Zones**: Identification of diminishing returns thresholds
        - **Cross-Business Comparison**: Relative efficiency scoring across portfolio
        """)
        
        # Show sample yield curve
        sample_data = generate_sample_yield_curve()
        fig = create_yield_curve_visualization(sample_data)
        st.plotly_chart(fig, use_container_width=True)
    
    with tab2:
        st.markdown("""
        **Multi-Attribution Triangulation**
        
        Validate assumptions using 6 attribution models:
        
        - **Time Decay**: Recent touchpoints weighted higher (30-day half-life)
        - **Position Based**: 40% first touch, 40% last touch, 20% middle
        - **Linear**: Equal credit across all touchpoints
        - **First Touch**: Full credit to awareness touchpoints
        - **Last Touch**: Full credit to conversion touchpoints
        - **Custom MMM**: Machine learning based attribution
        """)
        
        # Attribution model comparison
        attribution_comparison = get_attribution_comparison_sample()
        fig = create_attribution_comparison_chart(attribution_comparison)
        st.plotly_chart(fig, use_container_width=True)
    
    with tab3:
        st.markdown("""
        **Capital Allocation Framework**
        
        PE-level decision framework:
        
        1. **Campaign Eligibility**: Statistical significance thresholds
        2. **Efficiency Scoring**: Marginal performance analysis
        3. **Reallocation Opportunities**: Mathematical optimization
        4. **Risk Adjustment**: Business-specific confidence intervals
        """)
        
        # Sample reallocation recommendation
        reallocation_sample = generate_sample_reallocation()
        st.dataframe(reallocation_sample, use_container_width=True)
    
    # Business context
    st.markdown("---")
    st.subheader("📈 Business Context")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("""
        **Portfolio Characteristics**
        
        - **High Value**: $40K average booking value
        - **Long Cycles**: 180-day consideration periods
        - **Low Volume**: Quality over quantity focus
        - **Luxury Market**: Premium pricing tolerance
        """)
    
    with col2:
        st.markdown("""
        **Strategic Objectives**
        
        - **3x Growth**: Scale from current to 3x volume
        - **Efficiency**: Maintain or improve unit economics
        - **Attribution**: Validate marketing contribution
        - **Allocation**: Optimize cross-business capital flow
        """)
    
    # System status
    st.markdown("---")
    st.subheader("⚙️ System Status")
    
    system_health = get_system_health_status()
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.metric(
            "Data Freshness",
            f"{system_health['data_freshness_hours']} hours",
            delta=f"Last updated: {system_health['last_update']}",
            help="Time since last data collection"
        )
    
    with col2:
        st.metric(
            "Collection Success Rate",
            f"{system_health['collection_success_rate']:.1%}",
            delta="24h average",
            help="API collection reliability"
        )
    
    with col3:
        st.metric(
            "Data Quality Score",
            f"{system_health['data_quality_score']:.2f}",
            delta="Validation passing rate",
            help="Overall data quality assessment"
        )
```

### Page 1: Portfolio Overview

**Purpose:** PE-level capital allocation decisions and cross-business analysis

**Target Audience:** Nick (PE), executive leadership, board presentations

```python
def show_portfolio_overview(services, businesses, date_range, attribution_model):
    st.title("🎯 Portfolio Overview")
    st.markdown("### Cross-Business Capital Allocation Analysis")
    
    # Get portfolio data
    portfolio_data = services['yield_curves'].get_business_comparison(
        date_range, attribution_model
    )
    
    if portfolio_data.empty:
        st.warning("No data available for selected criteria")
        return
    
    # Portfolio performance summary
    st.subheader("📊 Portfolio Performance Summary")
    
    # Calculate portfolio metrics
    portfolio_metrics = calculate_portfolio_metrics(portfolio_data)
    
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric(
            "Total Portfolio Spend",
            f"${portfolio_metrics['total_spend_usd']:,.0f}",
            delta=f"{portfolio_metrics['spend_change_pct']:+.1%} vs prior period"
        )
    
    with col2:
        st.metric(
            "Portfolio Conversions",
            f"{portfolio_metrics['total_conversions']:,}",
            delta=f"{portfolio_metrics['conversion_change_pct']:+.1%}"
        )
    
    with col3:
        st.metric(
            "Blended CPL",
            f"${portfolio_metrics['blended_cpl']:,.0f}",
            delta=f"{portfolio_metrics['cpl_change_pct']:+.1%}"
        )
    
    with col4:
        st.metric(
            "Efficiency Variance",
            f"{portfolio_metrics['efficiency_variance']:.2f}",
            help="Variance in efficiency across businesses (lower = more uniform)"
        )
    
    # Yield curve comparison
    st.subheader("📈 Cross-Business Yield Curves")
    
    fig = create_portfolio_yield_curves(portfolio_data)
    st.plotly_chart(fig, use_container_width=True)
    
    # Business efficiency matrix
    st.subheader("🎯 Business Efficiency Matrix")
    
    col1, col2 = st.columns([2, 1])
    
    with col1:
        # Efficiency scatter plot
        efficiency_data = calculate_business_efficiency_metrics(portfolio_data)
        fig = create_efficiency_scatter_plot(efficiency_data)
        st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        # Efficiency ranking
        st.markdown("**Efficiency Ranking**")
        efficiency_ranking = efficiency_data.sort_values('efficiency_score', ascending=False)
        
        for idx, row in efficiency_ranking.iterrows():
            delta_color = "normal" if row['efficiency_score'] >= 1.0 else "inverse"
            st.metric(
                f"{row['business_name']}",
                f"{row['efficiency_score']:.2f}",
                delta=f"CPL: ${row['avg_cpl_usd']:.0f}",
                delta_color=delta_color
            )
    
    # Capital reallocation recommendations
    st.subheader("💰 Capital Reallocation Opportunities")
    
    reallocation_recs = services['yield_curves'].get_reallocation_recommendations(
        businesses, min_efficiency_gain=0.1
    )
    
    if not reallocation_recs.empty:
        # Show recommendations table
        st.dataframe(
            reallocation_recs[[
                'business_name', 'recommended_action', 'projected_efficiency_gain',
                'campaigns_affected', 'rationale'
            ]],
            use_container_width=True
        )
        
        # Calculate total opportunity
        total_opportunity = reallocation_recs['projected_efficiency_gain'].sum()
        st.success(f"**Total Portfolio Opportunity: {total_opportunity:.1%} efficiency improvement**")
    else:
        st.info("No reallocation opportunities identified with current thresholds")
    
    # Attribution comparison across businesses
    st.subheader("🔍 Attribution Model Comparison")
    
    attribution_comparison = services['attribution'].get_attribution_comparison(
        campaign_ids=[],  # All campaigns
        date_range=date_range
    )
    
    if not attribution_comparison.empty:
        # Attribution bias analysis
        fig = create_attribution_bias_chart(attribution_comparison)
        st.plotly_chart(fig, use_container_width=True)
        
        # Attribution consistency metrics
        consistency_metrics = calculate_attribution_consistency(attribution_comparison)
        
        col1, col2, col3 = st.columns(3)
        
        with col1:
            st.metric(
                "Attribution Consistency",
                f"{consistency_metrics['consistency_score']:.2f}",
                help="Consistency across attribution models (1.0 = perfect consistency)"
            )
        
        with col2:
            st.metric(
                "Last-Click Bias",
                f"{consistency_metrics['last_click_advantage']:.1%}",
                help="How much last-click over-attributes vs other models"
            )
        
        with col3:
            st.metric(
                "Model Confidence",
                f"{consistency_metrics['model_confidence']:.2f}",
                help="Statistical confidence in attribution results"
            )
```

### Page 2: Attribution Analysis

**Purpose:** Research and validation of attribution assumptions

**Target Audience:** Analytics teams, consultants, marketing leadership

```python
def show_attribution_analysis(services, businesses, date_range, attribution_model):
    st.title("🔍 Attribution Analysis")
    st.markdown("### Multi-Model Attribution Triangulation")
    
    # Attribution model selector
    col1, col2 = st.columns([3, 1])
    
    with col1:
        st.markdown("**Attribution Model Comparison**")
        st.markdown("Validate assumptions using multiple attribution approaches")
    
    with col2:
        show_attribution_details = st.checkbox(
            "Show Technical Details",
            help="Display model parameters and calculation methodology"
        )
    
    # Get attribution data
    attribution_data = services['attribution'].get_attribution_comparison(
        campaign_ids=[],  # All campaigns for selected businesses
        date_range=date_range
    )
    
    if attribution_data.empty:
        st.warning("No attribution data available for selected criteria")
        return
    
    # Attribution model comparison
    st.subheader("📊 Model Comparison Overview")
    
    # Model comparison metrics
    model_metrics = calculate_attribution_model_metrics(attribution_data)
    
    # Display model comparison table
    st.dataframe(
        model_metrics[[
            'attribution_model', 'total_attributed_conversions', 
            'attributed_value_usd', 'avg_attribution_weight',
            'model_variance', 'confidence_score'
        ]],
        use_container_width=True
    )
    
    # Visual comparison
    fig = create_attribution_model_comparison_chart(model_metrics)
    st.plotly_chart(fig, use_container_width=True)
    
    # Bias analysis
    st.subheader("⚖️ Attribution Bias Analysis")
    
    col1, col2 = st.columns(2)
    
    with col1:
        # First-touch vs Last-touch bias
        bias_analysis = services['attribution'].get_attribution_bias_analysis(
            business_id=businesses[0] if len(businesses) == 1 else None,
            date_range=date_range
        )
        
        if not bias_analysis.empty:
            fig = create_first_last_bias_chart(bias_analysis)
            st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        # Time decay analysis
        time_decay_analysis = analyze_time_decay_patterns(attribution_data)
        fig = create_time_decay_analysis_chart(time_decay_analysis)
        st.plotly_chart(fig, use_container_width=True)
    
    # Business-specific attribution patterns
    st.subheader("🏢 Business-Specific Attribution Patterns")
    
    if len(businesses) > 1:
        # Compare attribution patterns across businesses
        business_attribution = get_business_attribution_patterns(attribution_data, businesses)
        
        fig = create_business_attribution_comparison(business_attribution)
        st.plotly_chart(fig, use_container_width=True)
        
        # Attribution pattern insights
        st.markdown("**Key Insights:**")
        insights = generate_attribution_insights(business_attribution)
        for insight in insights:
            st.markdown(f"- {insight}")
    
    # Campaign-level attribution analysis
    st.subheader("📈 Campaign-Level Attribution")
    
    # Campaign selection
    available_campaigns = get_campaigns_for_businesses(businesses)
    selected_campaigns = st.multiselect(
        "Select Campaigns for Detailed Analysis",
        options=available_campaigns,
        max_selections=10,
        help="Choose up to 10 campaigns for detailed attribution analysis"
    )
    
    if selected_campaigns:
        campaign_attribution = get_campaign_attribution_details(
            selected_campaigns, date_range
        )
        
        # Campaign attribution heatmap
        fig = create_campaign_attribution_heatmap(campaign_attribution)
        st.plotly_chart(fig, use_container_width=True)
        
        # Campaign attribution table
        st.dataframe(
            campaign_attribution[[
                'campaign_name', 'business_name', 'total_conversions',
                'time_decay_conversions', 'position_based_conversions',
                'attribution_consistency_score'
            ]],
            use_container_width=True
        )
    
    # Attribution model playground
    if show_attribution_details:
        st.subheader("🧪 Attribution Model Playground")
        
        with st.expander("Custom Attribution Model Configuration"):
            # Custom time decay settings
            st.markdown("**Time Decay Model Parameters**")
            
            col1, col2 = st.columns(2)
            
            with col1:
                decay_half_life = st.slider(
                    "Decay Half-Life (days)",
                    min_value=7,
                    max_value=90,
                    value=30,
                    help="Number of days for attribution weight to decay by 50%"
                )
            
            with col2:
                attribution_window = st.slider(
                    "Attribution Window (days)",
                    min_value=30,
                    max_value=365,
                    value=180,
                    help="Maximum lookback period for attribution"
                )
            
            # Position-based model settings
            st.markdown("**Position-Based Model Parameters**")
            
            col1, col2, col3 = st.columns(3)
            
            with col1:
                first_touch_weight = st.slider(
                    "First Touch Weight",
                    min_value=0.1,
                    max_value=0.8,
                    value=0.4,
                    step=0.1
                )
            
            with col2:
                last_touch_weight = st.slider(
                    "Last Touch Weight",
                    min_value=0.1,
                    max_value=0.8,
                    value=0.4,
                    step=0.1
                )
            
            with col3:
                middle_weight = 1.0 - first_touch_weight - last_touch_weight
                st.metric("Middle Touches Weight", f"{middle_weight:.1f}")
            
            # Apply custom model
            if st.button("Apply Custom Attribution Model"):
                custom_results = calculate_custom_attribution(
                    attribution_data,
                    decay_half_life=decay_half_life,
                    attribution_window=attribution_window,
                    first_touch_weight=first_touch_weight,
                    last_touch_weight=last_touch_weight
                )
                
                st.success("Custom attribution model applied!")
                st.dataframe(custom_results, use_container_width=True)
```

### Page 3: Money Left on Table

**Purpose:** Historical opportunity analysis for PE presentations

**Target Audience:** Nick (PE), board presentations, executive leadership

```python
def show_money_left_on_table(services, businesses, date_range, attribution_model):
    st.title("💰 Money Left on Table")
    st.markdown("### Historical Capital Allocation Opportunities")
    
    # Executive summary
    st.subheader("📊 Executive Summary")
    
    # Calculate money left on table
    money_left_analysis = services['historical'].calculate_money_left_on_table(
        business_ids=businesses,
        date_range=date_range
    )
    
    if money_left_analysis.empty:
        st.warning("Insufficient data for historical analysis")
        return
    
    # Key metrics
    total_wasted_spend = money_left_analysis['wasted_spend_usd'].sum()
    total_missed_conversions = money_left_analysis['missed_conversions'].sum()
    total_missed_bookings = money_left_analysis['estimated_missed_bookings'].sum()
    
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric(
            "Wasted Spend",
            f"${total_wasted_spend:,.0f}",
            delta=f"{len(date_range)} month period" if hasattr(date_range, '__len__') else "Analysis period",
            help="Total spend on inefficient campaigns"
        )
    
    with col2:
        st.metric(
            "Missed Conversions",
            f"{total_missed_conversions:,.0f}",
            delta="Reallocation opportunity",
            help="Additional conversions possible with optimal allocation"
        )
    
    with col3:
        st.metric(
            "Missed Bookings",
            f"{total_missed_bookings:,.0f}",
            delta="Estimated bookings",
            help="Estimated bookings from missed conversions"
        )
    
    with col4:
        # Calculate opportunity value
        avg_booking_value = 35000  # Average across businesses
        opportunity_value = total_missed_bookings * avg_booking_value
        st.metric(
            "Opportunity Value",
            f"${opportunity_value/1000000:,.1f}M",
            delta="Revenue potential",
            help="Total revenue opportunity from optimization"
        )
    
    # Business-level breakdown
    st.subheader("🏢 Business-Level Breakdown")
    
    # Money left on table by business
    fig = create_money_left_table_chart(money_left_analysis)
    st.plotly_chart(fig, use_container_width=True)
    
    # Detailed business analysis
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("**Wasted Spend Analysis**")
        wasted_spend_df = money_left_analysis.sort_values('wasted_spend_usd', ascending=False)
        
        for idx, row in wasted_spend_df.iterrows():
            pct_of_total = row['wasted_spend_usd'] / total_wasted_spend * 100
            st.markdown(f"**{row['business_name']}**: ${row['wasted_spend_usd']:,.0f} ({pct_of_total:.1f}%)")
    
    with col2:
        st.markdown("**Opportunity Ranking**")
        opportunity_df = money_left_analysis.sort_values('estimated_missed_bookings', ascending=False)
        
        for idx, row in opportunity_df.iterrows():
            booking_value = row['estimated_missed_bookings'] * avg_booking_value
            st.markdown(f"**{row['business_name']}**: ${booking_value/1000:,.0f}K revenue opportunity")
    
    # Historical trend analysis
    st.subheader("📈 Historical Opportunity Trends")
    
    # Monthly opportunity analysis
    monthly_analysis = calculate_monthly_opportunity_trends(businesses, date_range)
    
    if monthly_analysis is not None and not monthly_analysis.empty:
        fig = create_monthly_opportunity_trend_chart(monthly_analysis)
        st.plotly_chart(fig, use_container_width=True)
        
        # Trend insights
        trend_insights = analyze_opportunity_trends(monthly_analysis)
        
        st.markdown("**Trend Insights:**")
        for insight in trend_insights:
            st.markdown(f"- {insight}")
    
    # Reallocation scenarios
    st.subheader("🎯 Reallocation Scenarios")
    
    st.markdown("**What-If Analysis: Optimal Budget Reallocation**")
    
    # Scenario parameters
    col1, col2, col3 = st.columns(3)
    
    with col1:
        reallocation_percentage = st.slider(
            "Reallocation Percentage",
            min_value=10,
            max_value=50,
            value=25,
            step=5,
            help="Percentage of budget to reallocate from inefficient to efficient campaigns"
        )
    
    with col2:
        efficiency_threshold = st.slider(
            "Efficiency Threshold",
            min_value=0.5,
            max_value=2.0,
            value=1.0,
            step=0.1,
            help="Minimum efficiency score for receiving reallocated budget"
        )
    
    with col3:
        confidence_level = st.selectbox(
            "Confidence Level",
            options=[0.80, 0.90, 0.95],
            index=1,
            format_func=lambda x: f"{x:.0%}",
            help="Statistical confidence level for projections"
        )
    
    # Calculate reallocation scenario
    reallocation_scenario = calculate_reallocation_scenario(
        money_left_analysis,
        reallocation_percentage / 100,
        efficiency_threshold,
        confidence_level
    )
    
    # Scenario results
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("**Reallocation Impact**")
        
        st.metric(
            "Budget Reallocated",
            f"${reallocation_scenario['reallocated_budget']:,.0f}",
            help="Total budget moved from inefficient to efficient campaigns"
        )
        
        st.metric(
            "Additional Conversions",
            f"{reallocation_scenario['additional_conversions']:,.0f}",
            delta=f"{reallocation_scenario['conversion_lift_pct']:+.1%} lift"
        )
        
        st.metric(
            "ROI Improvement",
            f"{reallocation_scenario['roi_improvement_pct']:+.1%}",
            help="Percentage improvement in overall ROI"
        )
    
    with col2:
        st.markdown("**Revenue Impact**")
        
        additional_bookings = reallocation_scenario['additional_conversions'] * 0.1  # 10% avg booking rate
        additional_revenue = additional_bookings * avg_booking_value
        
        st.metric(
            "Additional Bookings",
            f"{additional_bookings:,.0f}",
            help="Estimated additional bookings from reallocation"
        )
        
        st.metric(
            "Additional Revenue",
            f"${additional_revenue/1000:,.0f}K",
            help="Estimated additional revenue from reallocation"
        )
        
        st.metric(
            "Payback Period",
            f"{reallocation_scenario['payback_months']:.1f} months",
            help="Time to recover reallocation investment"
        )
    
    # Implementation roadmap
    st.subheader("🗺️ Implementation Roadmap")
    
    with st.expander("Reallocation Implementation Plan"):
        st.markdown("""
        **Phase 1: Immediate Opportunities (Weeks 1-2)**
        - Pause bottom 10% performing campaigns
        - Increase budgets for top 20% performing campaigns
        - Implement enhanced tracking for reallocation impact
        
        **Phase 2: Strategic Reallocation (Weeks 3-6)**
        - Restructure underperforming campaigns
        - Launch new campaigns in high-efficiency segments
        - Implement automated bid optimization
        
        **Phase 3: Continuous Optimization (Ongoing)**
        - Weekly performance reviews and adjustments
        - Monthly reallocation opportunity analysis
        - Quarterly strategy alignment with business objectives
        """)
        
        # Implementation timeline
        implementation_timeline = create_implementation_timeline()
        st.dataframe(implementation_timeline, use_container_width=True)
    
    # Export functionality
    st.subheader("📊 Export Analysis")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("Export Executive Summary"):
            export_executive_summary(money_left_analysis, reallocation_scenario)
            st.success("Executive summary exported!")
    
    with col2:
        if st.button("Export Detailed Analysis"):
            export_detailed_analysis(money_left_analysis, monthly_analysis)
            st.success("Detailed analysis exported!")
    
    with col3:
        if st.button("Export Board Presentation"):
            export_board_presentation(money_left_analysis, reallocation_scenario)
            st.success("Board presentation exported!")
```

### Page 4: Business Deep Dives

**Purpose:** Operational campaign management and business-specific optimization

**Target Audience:** Marketing teams, operational management, campaign managers

```python
def show_business_deep_dives(services, businesses, date_range, attribution_model):
    st.title("📈 Business Deep Dives")
    st.markdown("### Campaign-Level Analysis and Optimization")
    
    # Business selection for deep dive
    if len(businesses) > 1:
        selected_business = st.selectbox(
            "Select Business for Deep Dive",
            options=businesses,
            format_func=lambda x: get_business_name(x),
            help="Choose business for detailed campaign analysis"
        )
    else:
        selected_business = businesses[0]
    
    business_name = get_business_name(selected_business)
    st.subheader(f"🏢 {business_name} - Campaign Analysis")
    
    # Business performance overview
    business_metrics = get_business_performance_metrics(selected_business, date_range)
    
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric(
            "Total Spend",
            f"${business_metrics['total_spend_usd']:,.0f}",
            delta=f"{business_metrics['spend_change_pct']:+.1%}"
        )
    
    with col2:
        st.metric(
            "Total Conversions",
            f"{business_metrics['total_conversions']:,}",
            delta=f"{business_metrics['conversion_change_pct']:+.1%}"
        )
    
    with col3:
        st.metric(
            "Average CPL",
            f"${business_metrics['avg_cpl_usd']:,.0f}",
            delta=f"{business_metrics['cpl_change_pct']:+.1%}"
        )
    
    with col4:
        st.metric(
            "Active Campaigns",
            f"{business_metrics['active_campaigns']:,}",
            delta=f"{business_metrics['campaign_change']:+,}"
        )
    
    # Campaign performance table
    st.subheader("📊 Campaign Performance Overview")
    
    campaign_data = get_campaign_performance_data(selected_business, date_range)
    
    # Campaign filtering
    col1, col2, col3 = st.columns(3)
    
    with col1:
        campaign_type_filter = st.multiselect(
            "Campaign Types",
            options=campaign_data['campaign_type'].unique(),
            default=campaign_data['campaign_type'].unique(),
            help="Filter by campaign type"
        )
    
    with col2:
        min_spend = st.number_input(
            "Minimum Spend ($)",
            min_value=0,
            value=100,
            help="Filter campaigns by minimum spend"
        )
    
    with col3:
        sort_by = st.selectbox(
            "Sort By",
            options=['spend_usd', 'conversions', 'cpl_usd', 'efficiency_score'],
            index=0,
            help="Sort campaigns by selected metric"
        )
    
    # Apply filters
    filtered_campaigns = campaign_data[
        (campaign_data['campaign_type'].isin(campaign_type_filter)) &
        (campaign_data['spend_usd'] >= min_spend)
    ].sort_values(sort_by, ascending=False)
    
    # Display campaign table
    st.dataframe(
        filtered_campaigns[[
            'campaign_name', 'campaign_type', 'spend_usd', 'conversions',
            'cpl_usd', 'efficiency_score', 'status'
        ]],
        use_container_width=True
    )
    
    # Campaign yield curves
    st.subheader("📈 Individual Campaign Yield Curves")
    
    # Select campaigns for yield curve analysis
    eligible_campaigns = get_yield_curve_eligible_campaigns(selected_business)
    
    if not eligible_campaigns.empty:
        selected_campaigns_for_curves = st.multiselect(
            "Select Campaigns for Yield Curve Analysis",
            options=eligible_campaigns['campaign_id'].tolist(),
            default=eligible_campaigns['campaign_id'].head(5).tolist(),
            format_func=lambda x: eligible_campaigns[eligible_campaigns['campaign_id'] == x]['campaign_name'].iloc[0],
            help="Choose campaigns with sufficient data for yield curve analysis"
        )
        
        if selected_campaigns_for_curves:
            yield_curve_data = get_campaign_yield_curves(selected_campaigns_for_curves, date_range)
            
            fig = create_individual_campaign_yield_curves(yield_curve_data)
            st.plotly_chart(fig, use_container_width=True)
            
            # Yield curve insights
            yield_insights = analyze_campaign_yield_curves(yield_curve_data)
            
            st.markdown("**Yield Curve Insights:**")
            for insight in yield_insights:
                st.markdown(f"- {insight}")
    
    # Campaign grouping analysis
    st.subheader("🎯 Campaign Grouping Analysis")
    
    # Get available tags for grouping
    available_tags = get_available_campaign_tags(selected_business)
    
    if not available_tags.empty:
        col1, col2 = st.columns(2)
        
        with col1:
            primary_grouping = st.selectbox(
                "Primary Grouping",
                options=available_tags['tag_type'].unique(),
                help="Primary dimension for campaign grouping"
            )
        
        with col2:
            secondary_grouping = st.selectbox(
                "Secondary Grouping",
                options=['None'] + available_tags['tag_type'].unique().tolist(),
                help="Secondary dimension for campaign grouping"
            )
        
        # Get grouping analysis
        if secondary_grouping != 'None':
            grouping_analysis = get_campaign_grouping_analysis(
                selected_business, primary_grouping, secondary_grouping, date_range
            )
        else:
            grouping_analysis = get_campaign_grouping_analysis(
                selected_business, primary_grouping, None, date_range
            )
        
        if not grouping_analysis.empty:
            # Display grouping results
            fig = create_campaign_grouping_chart(grouping_analysis, primary_grouping, secondary_grouping)
            st.plotly_chart(fig, use_container_width=True)
            
            # Grouping performance table
            st.dataframe(
                grouping_analysis[[
                    'group_name', 'campaign_count', 'total_spend_usd',
                    'total_conversions', 'avg_cpl_usd', 'efficiency_score'
                ]],
                use_container_width=True
            )
    
    # Campaign recommendations
    st.subheader("💡 Campaign Recommendations")
    
    # Get campaign restructure recommendations
    restructure_recommendations = services['yield_curves'].get_restructure_recommendations(
        selected_business, date_range
    )
    
    if not restructure_recommendations.empty:
        st.markdown("**Restructure Recommendations:**")
        
        for idx, rec in restructure_recommendations.iterrows():
            with st.expander(f"{rec['recommended_action']} - {rec['campaigns_affected']} campaigns"):
                st.markdown(f"**Rationale:** {rec['rationale']}")
                st.markdown(f"**Projected Efficiency Gain:** {rec['projected_efficiency_gain']:.1%}")
                st.markdown(f"**Affected Campaigns:** {rec['campaigns_affected']}")
                
                if st.button(f"View Campaign Details - {idx}", key=f"details_{idx}"):
                    campaign_details = get_campaign_details_for_recommendation(rec)
                    st.dataframe(campaign_details, use_container_width=True)
    
    # Campaign exclusion management
    st.subheader("🚫 Campaign Exclusion Management")
    
    with st.expander("Manage Campaign Exclusions"):
        # Show current exclusions
        current_exclusions = get_campaign_exclusions(selected_business)
        
        if not current_exclusions.empty:
            st.markdown("**Currently Excluded Campaigns:**")
            st.dataframe(
                current_exclusions[[
                    'campaign_name', 'exclusion_reason', 'excluded_from', 'created_at'
                ]],
                use_container_width=True
            )
        
        # Add new exclusion
        st.markdown("**Add Campaign Exclusion:**")
        
        col1, col2, col3 = st.columns(3)
        
        with col1:
            campaigns_to_exclude = st.multiselect(
                "Select Campaigns",
                options=campaign_data['campaign_id'].tolist(),
                format_func=lambda x: campaign_data[campaign_data['campaign_id'] == x]['campaign_name'].iloc[0]
            )
        
        with col2:
            exclusion_reason = st.selectbox(
                "Exclusion Reason",
                options=[
                    'brand_impression_share',
                    'always_on_campaign',
                    'test_campaign',
                    'insufficient_data',
                    'strategic_importance'
                ]
            )
        
        with col3:
            excluded_from = st.selectbox(
                "Exclude From",
                options=['yield_curves', 'attribution', 'all_analysis']
            )
        
        if st.button("Add Exclusion") and campaigns_to_exclude:
            add_campaign_exclusions(campaigns_to_exclude, exclusion_reason, excluded_from)
            st.success(f"Added {len(campaigns_to_exclude)} campaign exclusions")
            st.experimental_rerun()
    
    # Business configuration
    st.subheader("⚙️ Business Configuration")
    
    with st.expander("Business Settings"):
        current_config = get_business_configuration(selected_business)
        
        # Yield curve thresholds
        st.markdown("**Yield Curve Thresholds:**")
        
        col1, col2, col3 = st.columns(3)
        
        with col1:
            min_spend = st.number_input(
                "Minimum Spend ($)",
                value=current_config.get('min_spend_usd', 500),
                help="Minimum spend for yield curve eligibility"
            )
        
        with col2:
            min_conversions = st.number_input(
                "Minimum Conversions",
                value=current_config.get('min_conversions', 3),
                help="Minimum conversions for statistical significance"
            )
        
        with col3:
            min_days = st.number_input(
                "Minimum Days",
                value=current_config.get('min_days', 30),
                help="Minimum days with active spend"
            )
        
        # Booking conversion rate
        st.markdown("**Booking Conversion Rate:**")
        
        col1, col2 = st.columns(2)
        
        with col1:
            booking_rate = st.number_input(
                "Lead to Booking Rate",
                min_value=0.01,
                max_value=1.0,
                value=current_config.get('booking_rate', 0.10),
                step=0.01,
                format="%.2f",
                help="Conversion rate from lead to booking"
            )
        
        with col2:
            confidence_level = st.selectbox(
                "Confidence Level",
                options=['estimated', 'low', 'medium', 'high'],
                index=['estimated', 'low', 'medium', 'high'].index(
                    current_config.get('confidence', 'estimated')
                )
            )
        
        # Save configuration
        if st.button("Save Configuration"):
            new_config = {
                'yield_curve_thresholds': {
                    'min_spend_usd': min_spend,
                    'min_conversions': min_conversions,
                    'min_days': min_days
                },
                'booking_conversion_rate': {
                    'rate': booking_rate,
                    'confidence': confidence_level
                }
            }
            
            update_business_configuration(selected_business, new_config)
            st.success("Configuration updated successfully!")
```

## Visualization Components

### Shared Chart Components

```python
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots

def create_yield_curve_visualization(data):
    """Create interactive yield curve chart"""
    
    fig = go.Figure()
    
    # Add yield curves for each business
    for business in data['business_name'].unique():
        business_data = data[data['business_name'] == business]
        
        fig.add_trace(go.Scatter(
            x=business_data['spend_bucket'],
            y=business_data['marginal_cpl_usd'],
            mode='lines+markers',
            name=business,
            line=dict(width=3),
            marker=dict(size=8),
            hovertemplate=(
                f"<b>{business}</b><br>"
                "Spend Bucket: %{x}<br>"
                "Marginal CPL: $%{y:,.0f}<br>"
                "<extra></extra>"
            )
        ))
    
    fig.update_layout(
        title="Campaign Yield Curves - Marginal CPL by Spend Level",
        xaxis_title="Spend Bucket",
        yaxis_title="Marginal CPL ($)",
        hovermode='x unified',
        height=500,
        showlegend=True
    )
    
    return fig

def create_attribution_comparison_chart(data):
    """Create attribution model comparison chart"""
    
    fig = px.bar(
        data,
        x='attribution_model',
        y='total_attributed_conversions',
        color='attribution_model',
        title="Attribution Model Comparison - Total Attributed Conversions",
        labels={
            'attribution_model': 'Attribution Model',
            'total_attributed_conversions': 'Attributed Conversions'
        }
    )
    
    fig.update_layout(
        showlegend=False,
        height=400
    )
    
    return fig

def create_efficiency_scatter_plot(data):
    """Create business efficiency scatter plot"""
    
    fig = px.scatter(
        data,
        x='total_spend_usd',
        y='avg_cpl_usd',
        size='total_conversions',
        color='efficiency_score',
        hover_name='business_name',
        title="Business Efficiency Analysis",
        labels={
            'total_spend_usd': 'Total Spend ($)',
            'avg_cpl_usd': 'Average CPL ($)',
            'efficiency_score': 'Efficiency Score'
        },
        color_continuous_scale='RdYlGn'
    )
    
    fig.update_traces(
        hovertemplate=(
            "<b>%{hovertext}</b><br>"
            "Total Spend: $%{x:,.0f}<br>"
            "Average CPL: $%{y:,.0f}<br>"
            "Efficiency Score: %{marker.color:.2f}<br>"
            "Total Conversions: %{marker.size}<br>"
            "<extra></extra>"
        )
    )
    
    fig.update_layout(height=500)
    
    return fig

def create_money_left_table_chart(data):
    """Create money left on table visualization"""
    
    fig = make_subplots(
        rows=1, cols=2,
        subplot_titles=('Wasted Spend by Business', 'Missed Revenue Opportunity'),
        specs=[[{"type": "bar"}, {"type": "bar"}]]
    )
    
    # Wasted spend
    fig.add_trace(
        go.Bar(
            x=data['business_name'],
            y=data['wasted_spend_usd'],
            name='Wasted Spend',
            marker_color='red',
            hovertemplate="<b>%{x}</b><br>Wasted Spend: $%{y:,.0f}<extra></extra>"
        ),
        row=1, col=1
    )
    
    # Revenue opportunity
    avg_booking_value = 35000
    revenue_opportunity = data['estimated_missed_bookings'] * avg_booking_value
    
    fig.add_trace(
        go.Bar(
            x=data['business_name'],
            y=revenue_opportunity,
            name='Revenue Opportunity',
            marker_color='green',
            hovertemplate="<b>%{x}</b><br>Revenue Opportunity: $%{y:,.0f}<extra></extra>"
        ),
        row=1, col=2
    )
    
    fig.update_layout(
        title="Money Left on Table Analysis",
        showlegend=False,
        height=500
    )
    
    return fig

def create_campaign_grouping_chart(data, primary_grouping, secondary_grouping):
    """Create campaign grouping analysis chart"""
    
    if secondary_grouping and secondary_grouping != 'None':
        # Two-dimensional grouping
        fig = px.sunburst(
            data,
            path=[primary_grouping, secondary_grouping],
            values='total_spend_usd',
            color='efficiency_score',
            color_continuous_scale='RdYlGn',
            title=f"Campaign Performance by {primary_grouping} and {secondary_grouping}"
        )
    else:
        # Single dimension grouping
        fig = px.treemap(
            data,
            path=['group_name'],
            values='total_spend_usd',
            color='efficiency_score',
            color_continuous_scale='RdYlGn',
            title=f"Campaign Performance by {primary_grouping}"
        )
    
    fig.update_layout(height=600)
    
    return fig

def create_portfolio_yield_curves(data):
    """Create portfolio-level yield curve comparison"""
    
    fig = go.Figure()
    
    # Color palette for businesses
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd']
    
    for i, business in enumerate(data['business_name'].unique()):
        business_data = data[data['business_name'] == business]
        
        fig.add_trace(go.Scatter(
            x=business_data['spend_bucket'],
            y=business_data['marginal_cpl_usd'],
            mode='lines+markers',
            name=business,
            line=dict(width=4, color=colors[i % len(colors)]),
            marker=dict(size=10),
            hovertemplate=(
                f"<b>{business}</b><br>"
                "Spend Level: %{x}<br>"
                "Marginal CPL: $%{y:,.0f}<br>"
                "Efficiency Score: %{customdata:.2f}<br>"
                "<extra></extra>"
            ),
            customdata=business_data['efficiency_score']
        ))
    
    # Add efficiency threshold line
    fig.add_hline(
        y=data['marginal_cpl_usd'].median(),
        line_dash="dash",
        line_color="gray",
        annotation_text="Portfolio Median CPL"
    )
    
    fig.update_layout(
        title="Portfolio Yield Curves - Cross-Business Comparison",
        xaxis_title="Spend Bucket Level",
        yaxis_title="Marginal CPL ($)",
        hovermode='x unified',
        height=600,
        showlegend=True,
        legend=dict(
            orientation="h",
            yanchor="bottom",
            y=1.02,
            xanchor="right",
            x=1
        )
    )
    
    return fig
```

## Performance Optimization

### Caching Strategy

```python
import streamlit as st
import hashlib

# Cache expensive data operations
@st.cache_data(ttl=3600)  # Cache for 1 hour
def get_portfolio_data_cached(business_ids, start_date, end_date, attribution_model):
    """Cached portfolio data retrieval"""
    
    # Create cache key
    cache_key = hashlib.md5(
        f"{business_ids}_{start_date}_{end_date}_{attribution_model}".encode()
    ).hexdigest()
    
    # Get data from services
    services = init_services()
    return services['yield_curves'].get_business_comparison(
        (start_date, end_date), attribution_model
    )

@st.cache_data(ttl=1800)  # Cache for 30 minutes
def get_campaign_data_cached(business_id, start_date, end_date):
    """Cached campaign data retrieval"""
    
    services = init_services()
    return services['campaigns'].get_campaign_performance_data(
        business_id, (start_date, end_date)
    )

# Cache configuration data (changes infrequently)
@st.cache_data(ttl=7200)  # Cache for 2 hours
def get_business_config_cached(business_id):
    """Cached business configuration"""
    
    services = init_services()
    return services['config'].get_all_business_configs(business_id)

# Session state management
def init_session_state():
    """Initialize session state variables"""
    
    if 'selected_businesses' not in st.session_state:
        st.session_state.selected_businesses = [1, 2, 3]
    
    if 'date_range' not in st.session_state:
        default_end = datetime.now().date()
        default_start = default_end - timedelta(days=365)
        st.session_state.date_range = (default_start, default_end)
    
    if 'attribution_model' not in st.session_state:
        st.session_state.attribution_model = 'time_decay'
    
    if 'page_state' not in st.session_state:
        st.session_state.page_state = {}

# Optimized data loading
def load_data_efficiently(businesses, date_range, attribution_model):
    """Load data efficiently with progress tracking"""
    
    # Create progress bar
    progress_bar = st.progress(0)
    status_text = st.empty()
    
    data_results = {}
    
    # Load portfolio data
    status_text.text('Loading portfolio data...')
    portfolio_data = get_portfolio_data_cached(businesses, date_range[0], date_range[1], attribution_model)
    data_results['portfolio'] = portfolio_data
    progress_bar.progress(25)
    
    # Load attribution data
    status_text.text('Loading attribution analysis...')
    attribution_data = get_attribution_data_cached(businesses, date_range[0], date_range[1])
    data_results['attribution'] = attribution_data
    progress_bar.progress(50)
    
    # Load campaign data
    status_text.text('Loading campaign details...')
    campaign_data = {}
    for i, business_id in enumerate(businesses):
        campaign_data[business_id] = get_campaign_data_cached(business_id, date_range[0], date_range[1])
        progress_bar.progress(50 + (25 * (i + 1) / len(businesses)))
    
    data_results['campaigns'] = campaign_data
    
    # Load historical data
    status_text.text('Loading historical analysis...')
    historical_data = get_historical_data_cached(businesses, date_range[0], date_range[1])
    data_results['historical'] = historical_data
    progress_bar.progress(100)
    
    # Clear progress indicators
    progress_bar.empty()
    status_text.empty()
    
    return data_results
```

### Error Handling and User Experience

```python
def safe_execute_with_fallback(func, fallback_message="Unable to load data", *args, **kwargs):
    """Safely execute function with user-friendly error handling"""
    
    try:
        return func(*args, **kwargs)
    except Exception as e:
        logger.error(f"Error in {func.__name__}: {e}")
        st.error(f"{fallback_message}. Please try refreshing or contact support.")
        return None

def validate_user_inputs(businesses, date_range, attribution_model):
    """Validate user inputs and provide helpful feedback"""
    
    errors = []
    
    # Validate businesses
    if not businesses:
        errors.append("Please select at least one business")
    
    # Validate date range
    if len(date_range) != 2:
        errors.append("Please select a valid date range")
    elif date_range[0] >= date_range[1]:
        errors.append("Start date must be before end date")
    elif (date_range[1] - date_range[0]).days > 730:
        errors.append("Date range cannot exceed 2 years")
    
    # Validate attribution model
    valid_models = ['time_decay', 'position_based', 'linear', 'first_touch', 'last_touch']
    if attribution_model not in valid_models:
        errors.append(f"Invalid attribution model. Must be one of: {valid_models}")
    
    return errors

def show_data_quality_indicators(data):
    """Show data quality indicators to users"""
    
    if data is None or (hasattr(data, 'empty') and data.empty):
        st.warning("⚠️ No data available for selected criteria")
        return False
    
    # Calculate data quality metrics
    quality_metrics = calculate_data_quality_metrics(data)
    
    # Show quality indicators
    col1, col2, col3 = st.columns(3)
    
    with col1:
        completeness_color = "normal" if quality_metrics['completeness'] >= 0.9 else "inverse"
        st.metric(
            "Data Completeness",
            f"{quality_metrics['completeness']:.1%}",
            delta_color=completeness_color,
            help="Percentage of expected data points available"
        )
    
    with col2:
        freshness_hours = quality_metrics['freshness_hours']
        freshness_color = "normal" if freshness_hours <= 24 else "inverse"
        st.metric(
            "Data Freshness",
            f"{freshness_hours:.0f}h ago",
            delta_color=freshness_color,
            help="Time since last data update"
        )
    
    with col3:
        accuracy_color = "normal" if quality_metrics['accuracy'] >= 0.85 else "inverse"
        st.metric(
            "Data Accuracy",
            f"{quality_metrics['accuracy']:.1%}",
            delta_color=accuracy_color,
            help="Data validation passing rate"
        )
    
    # Show data quality warnings
    if quality_metrics['completeness'] < 0.8:
        st.warning("⚠️ Data completeness is below 80%. Results may be incomplete.")
    
    if quality_metrics['freshness_hours'] > 48:
        st.warning("⚠️ Data is more than 48 hours old. Consider refreshing for latest insights.")
    
    return True
```

## Deployment Configuration

### Streamlit Configuration

```toml
# .streamlit/config.toml

[global]
developmentMode = false
logLevel = "info"

[server]
port = 8501
address = "0.0.0.0"
maxUploadSize = 200
maxMessageSize = 200
enableCORS = false
enableXsrfProtection = true
enableWebsocketCompression = true

[browser]
gatherUsageStats = false

[theme]
primaryColor = "#1f77b4"
backgroundColor = "#ffffff"
secondaryBackgroundColor = "#f0f2f6"
textColor = "#262730"
font = "sans serif"

[client]
caching = true
displayEnabled = true
```

### Production Deployment

```python
# production_config.py

import os
import streamlit as st

# Production settings
if os.getenv('APP_ENV') == 'production':
    # Disable debug features
    st.set_option('deprecation.showPyplotGlobalUse', False)
    st.set_option('deprecation.showfileUploaderEncoding', False)
    
    # Enable performance optimizations
    st.set_option('global.disableWatchdogWarning', True)
    
    # Security settings
    st.set_option('server.enableCORS', False)
    st.set_option('server.enableXsrfProtection', True)

# Performance monitoring
def track_page_performance(page_name):
    """Track page performance metrics"""
    
    start_time = time.time()
    
    def track_completion():
        load_time = time.time() - start_time
        
        # Log performance metrics
        logger.info(f"Page {page_name} loaded in {load_time:.2f} seconds")
        
        # Track in session state for analytics
        if 'performance_metrics' not in st.session_state:
            st.session_state.performance_metrics = []
        
        st.session_state.performance_metrics.append({
            'page': page_name,
            'load_time': load_time,
            'timestamp': datetime.now()
        })
    
    return track_completion
```

### Security Configuration

```python
# security.py

import streamlit as st
import hashlib
import hmac
import os

def authenticate_user():
    """Simple authentication for production deployment"""
    
    if os.getenv('APP_ENV') != 'production':
        return True
    
    # Check if already authenticated
    if st.session_state.get('authenticated', False):
        return True
    
    # Simple password authentication
    st.title("🔐 Access Control")
    
    password = st.text_input("Enter access password:", type="password")
    
    if st.button("Login"):
        expected_password = os.getenv('DASHBOARD_PASSWORD', 'default_password')
        
        if hmac.compare_digest(password, expected_password):
            st.session_state.authenticated = True
            st.success("Authentication successful!")
            st.experimental_rerun()
        else:
            st.error("Invalid password")
    
    return False

def log_user_access(page_name, user_id="anonymous"):
    """Log user access for security monitoring"""
    
    logger.info(f"User {user_id} accessed {page_name} at {datetime.now()}")
    
    # Store in session for audit trail
    if 'access_log' not in st.session_state:
        st.session_state.access_log = []
    
    st.session_state.access_log.append({
        'page': page_name,
        'user_id': user_id,
        'timestamp': datetime.now(),
        'ip_address': st.experimental_get_query_params().get('forwarded_for', ['unknown'])[0]
    })
```

## Testing Strategy

### Component Testing

```python
# test_dashboard_components.py

import unittest
import pandas as pd
import plotly.graph_objects as go
from unittest.mock import Mock, patch

class TestDashboardComponents(unittest.TestCase):
    
    def setUp(self):
        self.sample_data = pd.DataFrame({
            'business_name': ['Wilderness', 'Jacada', 'Yellow Zebra'],
            'spend_bucket': [1, 2, 3],
            'marginal_cpl_usd': [250, 300, 400],
            'efficiency_score': [1.2, 1.0, 0.8]
        })
    
    def test_yield_curve_visualization(self):
        """Test yield curve chart creation"""
        
        fig = create_yield_curve_visualization(self.sample_data)
        
        self.assertIsInstance(fig, go.Figure)
        self.assertEqual(len(fig.data), 3)  # Three businesses
        self.assertIn('Wilderness', [trace.name for trace in fig.data])
    
    def test_portfolio_metrics_calculation(self):
        """Test portfolio metrics calculation"""
        
        metrics = calculate_portfolio_metrics(self.sample_data)
        
        self.assertIn('total_spend_usd', metrics)
        self.assertIn('blended_cpl', metrics)
        self.assertIsInstance(metrics['total_spend_usd'], (int, float))
    
    def test_data_validation(self):
        """Test data validation functions"""
        
        businesses = [1, 2, 3]
        date_range = (datetime(2024, 1, 1).date(), datetime(2024, 12, 31).date())
        attribution_model = 'time_decay'
        
        errors = validate_user_inputs(businesses, date_range, attribution_model)
        
        self.assertEqual(len(errors), 0)
    
    def test_invalid_data_validation(self):
        """Test validation with invalid inputs"""
        
        businesses = []  # Invalid: empty
        date_range = (datetime(2024, 12, 31).date(), datetime(2024, 1, 1).date())  # Invalid: reversed
        attribution_model = 'invalid_model'  # Invalid model
        
        errors = validate_user_inputs(businesses, date_range, attribution_model)
        
        self.assertGreater(len(errors), 0)
```

### Integration Testing

```python
# test_dashboard_integration.py

import streamlit as st
from streamlit.testing import AppTest

class TestDashboardIntegration(unittest.TestCase):
    
    def setUp(self):
        # Mock database services
        self.mock_services = {
            'yield_curves': Mock(),
            'attribution': Mock(),
            'config': Mock(),
            'campaigns': Mock(),
            'historical': Mock()
        }
    
    @patch('streamlit_app.init_services')
    def test_portfolio_overview_page(self, mock_init_services):
        """Test portfolio overview page functionality"""
        
        mock_init_services.return_value = self.mock_services
        
        # Mock data responses
        self.mock_services['yield_curves'].get_business_comparison.return_value = pd.DataFrame({
            'business_name': ['Wilderness'],
            'marginal_cpl_usd': [300],
            'efficiency_score': [1.0]
        })
        
        # Test page execution
        app = AppTest.from_file("streamlit_app.py")
        
        # Simulate user interactions
        app.selectbox("Select Analysis View").select("🎯 Portfolio Overview")
        app.multiselect("Businesses").select([1])
        
        # Run the app
        app.run()
        
        # Verify results
        self.assertFalse(app.exception)
        self.mock_services['yield_curves'].get_business_comparison.assert_called_once()
    
    def test_attribution_analysis_page(self):
        """Test attribution analysis page"""
        
        # Similar integration test structure
        pass
```

## Documentation and Help

### In-App Help System

```python
def show_help_sidebar():
    """Show contextual help in sidebar"""
    
    with st.sidebar.expander("📚 Help & Documentation"):
        st.markdown("""
        **Quick Start Guide:**
        
        1. **Select Businesses** - Choose portfolio companies to analyze
        2. **Set Date Range** - Define analysis period (default: last 12 months)
        3. **Choose Attribution Model** - Select conversion attribution approach
        4. **Navigate Pages** - Use sidebar to switch between analysis views
        
        **Page Guide:**
        - **System Overview**: Methodology and business context
        - **Portfolio Overview**: PE-level capital allocation decisions
        - **Attribution Analysis**: Multi-model attribution validation
        - **Money Left on Table**: Historical opportunity analysis
        - **Business Deep Dives**: Campaign-level optimization
        
        **Data Quality:**
        - Green indicators = Good data quality
        - Yellow indicators = Caution advised
        - Red indicators = Data quality issues
        
        **Support:**
        - Email: analytics@portfolio.com
        - Documentation: /docs
        - Feedback: Use feedback form below
        """)

def show_methodology_explanation(topic):
    """Show detailed methodology explanations"""
    
    methodology_content = {
        'yield_curves': """
        **Yield Curve Methodology**
        
        Yield curves analyze marginal efficiency across spending levels:
        
        1. **Campaign Segmentation**: Group campaigns by spend levels
        2. **Marginal CPL Calculation**: Cost per lead for each spend increment
        3. **Efficiency Scoring**: Relative performance vs portfolio average
        4. **Diminishing Returns**: Identification of efficiency thresholds
        
        **Mathematical Foundation:**
        - Marginal CPL = ΔSpend / ΔConversions
        - Efficiency Score = Portfolio Average CPL / Campaign CPL
        - Statistical Significance: Minimum 3 conversions, $500 spend
        """,
        
        'attribution': """
        **Attribution Model Comparison**
        
        Six attribution models provide triangulation:
        
        1. **Time Decay**: Recent touchpoints weighted higher (e^(-t/30))
        2. **Position Based**: 40% first, 40% last, 20% middle touches
        3. **Linear**: Equal credit across all touchpoints
        4. **First Touch**: 100% credit to awareness touchpoints
        5. **Last Touch**: 100% credit to conversion touchpoints
        6. **Custom MMM**: Machine learning attribution weights
        
        **Bias Analysis:**
        - Consistency Score: Variance across models
        - Last-Click Advantage: % over-attribution vs other models
        - Confidence Intervals: Statistical significance of results
        """,
        
        'reallocation': """
        **Capital Reallocation Framework**
        
        Mathematical optimization approach:
        
        1. **Efficiency Ranking**: Sort campaigns by marginal performance
        2. **Threshold Identification**: Statistical significance boundaries
        3. **Reallocation Calculation**: Optimal budget redistribution
        4. **Impact Projection**: Expected performance improvement
        
        **Risk Adjustment:**
        - Confidence Levels: 80%, 90%, 95% scenarios
        - Business Context: Strategic campaign considerations
        - Implementation Feasibility: Operational constraints
        """
    }
    
    if topic in methodology_content:
        st.markdown(methodology_content[topic])

def show_feedback_form():
    """Show user feedback form"""
    
    with st.form("feedback_form"):
        st.markdown("**Feedback & Suggestions**")
        
        feedback_type = st.selectbox(
            "Feedback Type",
            options=["Bug Report", "Feature Request", "Data Quality Issue", "General Feedback"]
        )
        
        feedback_text = st.text_area(
            "Your Feedback",
            placeholder="Please describe your feedback, suggestion, or issue..."
        )
        
        contact_email = st.text_input(
            "Email (optional)",
            placeholder="your.email@company.com"
        )
        
        submitted = st.form_submit_button("Submit Feedback")
        
        if submitted and feedback_text:
            # Log feedback
            logger.info(f"User feedback: {feedback_type} - {feedback_text[:100]}...")
            
            # Store feedback
            store_user_feedback(feedback_type, feedback_text, contact_email)
            
            st.success("Thank you for your feedback!")
```

## Performance Benchmarks

### Target Performance Metrics

```python
# Performance benchmarks for production deployment

PERFORMANCE_TARGETS = {
    'page_load_time': {
        'system_overview': 2.0,      # seconds
        'portfolio_overview': 3.0,   # seconds (more data intensive)
        'attribution_analysis': 4.0, # seconds (complex calculations)
        'money_left_on_table': 3.5,  # seconds
        'business_deep_dives': 2.5   # seconds
    },
    'data_freshness': {
        'maximum_age_hours': 6,      # Data must be refreshed within 6 hours
        'target_age_hours': 2        # Target: refresh every 2 hours
    },
    'user_experience': {
        'error_rate_threshold': 0.01,  # Less than 1% error rate
        'cache_hit_ratio': 0.80,       # 80% cache hit ratio
        'concurrent_users': 20         # Support 20 concurrent users
    }
}

def monitor_performance():
    """Monitor dashboard performance against targets"""
    
    performance_report = {
        'timestamp': datetime.now(),
        'metrics': {},
        'alerts': []
    }
    
    # Check page load times
    for page, target in PERFORMANCE_TARGETS['page_load_time'].items():
        actual_time = get_average_page_load_time(page)
        
        performance_report['metrics'][f'{page}_load_time'] = actual_time
        
        if actual_time > target:
            performance_report['alerts'].append(
                f"{page} load time ({actual_time:.1f}s) exceeds target ({target}s)"
            )
    
    # Check data freshness
    data_age = get_data_age_hours()
    performance_report['metrics']['data_age_hours'] = data_age
    
    if data_age > PERFORMANCE_TARGETS['data_freshness']['maximum_age_hours']:
        performance_report['alerts'].append(
            f"Data age ({data_age:.1f}h) exceeds maximum ({PERFORMANCE_TARGETS['data_freshness']['maximum_age_hours']}h)"
        )
    
    return performance_report
```

This completes the comprehensive **Streamlit Dashboard Specifications**.

## Summary

I've now completed all the outstanding documentation files:

1. **README.md** - Executive overview and system introduction
2. **Business Configuration Guide** - Complete configuration management
3. **Google Ads Integration Guide** - Comprehensive API integration
4. **Bing Ads Integration Guide** - Multi-platform support
5. **Streamlit Dashboard Specifications** - Complete UI/UX specifications

Each document provides:

- **Detailed technical specifications**
- **Implementation code examples**
- **Business context and rationale**
- **Testing and validation strategies**
- **Production deployment considerations**

The documentation is now complete and ready to support AI-assisted development of your PE portfolio yield curve analytics system. The architecture is designed for the 7-10 day MVP timeline while building maintainable foundations for future scaling.

Would you like me to clarify any specific aspects of the documentation or help prioritize the development phases?