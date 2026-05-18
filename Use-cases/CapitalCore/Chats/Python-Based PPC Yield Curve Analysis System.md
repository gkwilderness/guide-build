---
title: "Python-Based PPC Yield Curve Analysis System"
type: project
area: wilderness
project: "Wilderness"
status: active
---
https://claude.ai/chat/31f4e8cc-e984-4849-b577-50526833d9b8

----
# Python-Based PPC Yield Curve Analysis System

Here's how a Python system could automate and enhance PPC yield curve analysis, freeing you from Excel limitations:

## Core System Components

### 1. Data Collection & Processing

python

```python
# Pseudocode for data collection module
def collect_ppc_data():
    # Connect to Google Ads API
    client = GoogleAdsClient.load_from_storage('google-ads.yaml')
    
    # Define date ranges - historical data needed for curve analysis
    date_ranges = generate_date_ranges(days_back=180, interval_days=7)
    
    # Collect spend and conversion data across dimensions
    dimensions = ['Campaign', 'GeoTarget', 'AudienceSegment', 'Device']
    
    # Store structured data in pandas DataFrame
    performance_data = pd.DataFrame()
    
    for date_range in date_ranges:
        for dimension in dimensions:
            # Query API for specific dimension and date range
            query_results = execute_google_ads_query(client, dimension, date_range)
            
            # Process and append to main DataFrame
            processed_results = process_query_results(query_results)
            performance_data = performance_data.append(processed_results)
    
    return performance_data
```

### 2. Yield Curve Generation Engine

python

```python
# Pseudocode for yield curve analysis
def generate_yield_curves(performance_data):
    # Group by desired dimensions
    dimensions = ['Campaign', 'GeoTarget', 'AudienceSegment', 'Device']
    yield_curves = {}
    
    for dimension in dimensions:
        dimension_groups = performance_data.groupby(dimension)
        
        for name, group in dimension_groups:
            # Sort by spend to create the curve
            sorted_data = group.sort_values('Spend')
            
            # Calculate cumulative metrics
            sorted_data['CumulativeSpend'] = sorted_data['Spend'].cumsum()
            sorted_data['CumulativeConversions'] = sorted_data['Conversions'].cumsum()
            
            # Calculate marginal return at each point
            sorted_data['MarginalReturn'] = sorted_data['CumulativeConversions'].diff() / sorted_data['CumulativeSpend'].diff()
            
            # Fit curve to data points
            x = sorted_data['CumulativeSpend']
            y = sorted_data['CumulativeConversions']
            
            # Use scipy for curve fitting
            # Try multiple models to find best fit
            models = {'polynomial': fit_polynomial(x, y),
                     'logarithmic': fit_logarithmic(x, y),
                     'exponential': fit_exponential(x, y)}
            
            best_model = select_best_model(models, x, y)
            
            # Store curve data and model
            yield_curves[f"{dimension}_{name}"] = {
                'raw_data': sorted_data,
                'model': best_model,
                'inflection_point': find_inflection_point(best_model, x)
            }
    
    return yield_curves
```

### 3. Optimization Engine

python

```python
# Pseudocode for optimization based on yield curves
def optimize_budget_allocation(yield_curves, total_budget):
    # Calculate marginal return at current spend for each dimension
    current_returns = {}
    
    for curve_name, curve_data in yield_curves.items():
        model = curve_data['model']
        current_spend = curve_data['raw_data']['CumulativeSpend'].max()
        
        # Calculate derivative at current spend point
        marginal_return = calculate_derivative(model, current_spend)
        current_returns[curve_name] = {
            'current_spend': current_spend,
            'marginal_return': marginal_return,
            'model': model
        }
    
    # Sort dimensions by marginal return
    sorted_returns = sorted(current_returns.items(), 
                           key=lambda x: x[1]['marginal_return'],
                           reverse=True)
    
    # Allocate additional budget to highest marginal return dimensions
    budget_recommendations = {}
    remaining_budget = total_budget
    
    for dimension, data in sorted_returns:
        # Calculate optimal additional spend
        optimal_additional = calculate_optimal_additional_spend(
            data['model'], 
            data['current_spend'],
            data['marginal_return'])
        
        # Cap at remaining budget
        additional_spend = min(optimal_additional, remaining_budget)
        remaining_budget -= additional_spend
        
        budget_recommendations[dimension] = {
            'current_spend': data['current_spend'],
            'recommended_additional': additional_spend,
            'new_total': data['current_spend'] + additional_spend,
            'expected_additional_conversions': predict_additional_conversions(
                data['model'], 
                data['current_spend'], 
                data['current_spend'] + additional_spend)
        }
        
        if remaining_budget <= 0:
            break
    
    return budget_recommendations
```

### 4. Visualization Engine

python

```python
# Pseudocode for visualization module
def create_visualizations(yield_curves, budget_recommendations):
    visualizations = {}
    
    # Create yield curve plots
    for curve_name, curve_data in yield_curves.items():
        fig, ax = plt.subplots(figsize=(12, 8))
        
        # Plot raw data points
        ax.scatter(
            curve_data['raw_data']['CumulativeSpend'],
            curve_data['raw_data']['CumulativeConversions'],
            alpha=0.7,
            label='Actual Data Points'
        )
        
        # Plot fitted curve
        x_range = np.linspace(0, curve_data['raw_data']['CumulativeSpend'].max() * 1.5, 1000)
        y_predicted = predict_using_model(curve_data['model'], x_range)
        
        ax.plot(x_range, y_predicted, 'r-', label='Fitted Curve')
        
        # Mark inflection point
        ax.axvline(x=curve_data['inflection_point'], color='g', linestyle='--',
                  label=f'Inflection Point (£{curve_data["inflection_point"]:.2f})')
        
        # Mark current spend
        current_spend = curve_data['raw_data']['CumulativeSpend'].max()
        ax.axvline(x=current_spend, color='b', linestyle='-',
                  label=f'Current Spend (£{current_spend:.2f})')
        
        # If in budget recommendations, mark recommended spend
        if curve_name in budget_recommendations:
            recommended_spend = budget_recommendations[curve_name]['new_total']
            ax.axvline(x=recommended_spend, color='purple', linestyle='-.',
                      label=f'Recommended Spend (£{recommended_spend:.2f})')
        
        # Calculate derivative curve (marginal return)
        derivative = calculate_derivative_curve(curve_data['model'], x_range)
        
        # Add second y-axis for marginal return
        ax2 = ax.twinx()
        ax2.plot(x_range, derivative, 'g-', alpha=0.5, label='Marginal Return')
        
        # Formatting
        ax.set_title(f'Yield Curve for {curve_name}')
        ax.set_xlabel('Cumulative Spend (£)')
        ax.set_ylabel('Cumulative Conversions')
        ax2.set_ylabel('Marginal Return (Conversions/£)')
        
        fig.tight_layout()
        visualizations[curve_name] = fig
    
    return visualizations
```

### 5. Reporting & Implementation

python

```python
# Pseudocode for reporting and implementation
def generate_report_and_implement(budget_recommendations, visualizations):
    # Create HTML report
    report = create_html_report_template()
    
    # Add executive summary
    total_additional_spend = sum(r['recommended_additional'] for r in budget_recommendations.values())
    total_additional_conversions = sum(r['expected_additional_conversions'] for r in budget_recommendations.values())
    
    report.add_executive_summary(
        total_additional_spend=total_additional_spend,
        total_additional_conversions=total_additional_conversions,
        average_cpa=total_additional_spend / total_additional_conversions if total_additional_conversions > 0 else 0
    )
    
    # Add recommendations table
    report.add_recommendations_table(budget_recommendations)
    
    # Add visualizations
    for name, fig in visualizations.items():
        report.add_visualization(name, fig)
    
    # Save report
    report.save("ppc_yield_curve_analysis_report.html")
    
    # Implementation options
    if AUTO_IMPLEMENT:
        # Connect to Google Ads API for implementation
        client = GoogleAdsClient.load_from_storage('google-ads.yaml')
        
        # Update budgets according to recommendations
        for dimension, recommendation in budget_recommendations.items():
            dimension_type, dimension_value = dimension.split('_', 1)
            
            if dimension_type == 'Campaign':
                update_campaign_budget(client, dimension_value, recommendation['new_total'])
            elif dimension_type == 'GeoTarget':
                # Update bid adjustments for geo targeting
                update_geo_targeting_adjustment(client, dimension_value, recommendation)
            # Handle other dimension types...
    
    # Email report to stakeholders
    email_report("ppc_yield_curve_analysis_report.html", 
                STAKEHOLDER_EMAILS,
                subject="Weekly PPC Yield Curve Analysis Report")
```

## System Benefits

1. **Automation**: Run weekly or daily without manual Excel work
2. **Scale**: Analyze hundreds of dimensions simultaneously
3. **Mathematical Precision**: Use calculus to find exact inflection points
4. **Visual Clarity**: Generate interactive visualizations
5. **Implementation**: Directly update budgets through API
6. **Prediction**: Forecast outcomes of budget changes
7. **Flexibility**: Easily add new dimensions or metrics
8. **Historical Tracking**: Store and compare yield curves over time

## Deployment Options

1. **Local Scheduling**:
    - Run on your machine with scheduled tasks
    - Minimal cloud infrastructure needed
2. **Cloud Deployment**:
    - AWS Lambda or Google Cloud Functions
    - Automatic triggering at set intervals
3. **Hybrid Approach**:
    - Data processing in cloud
    - Final review and implementation locally

This system would free you from Excel, provide deeper insights, and automatically identify the optimal allocation of your UHNWI safari marketing budget across all key dimensions.

----

To implement this PPC yield curve analysis system with real code, here's a realistic timeline:

# Implementation Timeline for PPC Yield Curve Analysis System

## Core Development: 3-4 Weeks

### Week 1: Foundation & Data Collection

- Google Ads API authentication setup (1 day)
- Data collection module implementation (2-3 days)
- Data storage and processing foundations (1-2 days)
- Initial testing with real account data (1 day)

### Week 2: Yield Curve Analysis Engine

- Implementation of curve fitting algorithms (2-3 days)
- Marginal return calculation functions (1-2 days)
- Inflection point detection (1 day)
- Testing with historical data (1 day)

### Week 3: Optimization & Visualization

- Budget allocation algorithm (2-3 days)
- Visualization module development (2 days)
- Integration of components (1 day)
- Initial system testing (1 day)

### Week 4: Reporting & Implementation

- HTML/PDF report generation (2 days)
- Budget implementation module (1-2 days)
- Email notification system (1 day)
- Final integration and testing (1-2 days)

## Additional Considerations

### Complexity Factors That May Extend Timeline

- Complex account structures (+1 week)
- Additional dimensions beyond standard ones (+3 days per dimension)
- Custom visualization requirements (+2-3 days)
- Integration with internal systems (+1 week)

### Shorter Timeline Options

- Basic version focusing only on campaign-level analysis (2 weeks)
- Manual implementation instead of API automation (save 3-4 days)
- Using pre-built visualization libraries instead of custom (save 1-2 days)

## Skills Required

- Python development (intermediate to advanced)
- Google Ads API experience
- Data analysis (pandas, numpy)
- Statistical modeling (scipy)
- Data visualization (matplotlib, seaborn, or plotly)

For a single experienced developer familiar with these technologies, the core system could be completed in approximately 3-4 weeks. With a team of 2-3 developers, this could potentially be reduced to 2 weeks.

The system could be developed iteratively, with basic functionality available within 1-2 weeks and more advanced features added over time.

-----

# Simple V1 PPC Yield Curve Analysis System

Here's what a streamlined V1 would look like, focusing just on analysis, visualization, and core reporting for campaigns and keywords:

## V1 Scope

### ✅ Includes:

- Local machine operation
- Data collection from Google Ads
- Yield curve calculation
- Simple visualization
- Campaign & keyword level analysis
- CSV export of findings

### ❌ Excludes:

- Automatic budget allocation
- HTML/PDF report generation
- Implementation via API
- Complex dimension analysis
- Email notifications

## Implementation Timeline: 1-2 Weeks

### Components:

#### 1. Data Collection Script (2-3 days)

python

```python
import pandas as pd
from google.ads.googleads.client import GoogleAdsClient
from datetime import datetime, timedelta

# Configure client
client = GoogleAdsClient.load_from_storage('google-ads.yaml')

def collect_campaign_data(client_id, days_back=180):
    """Collect campaign performance data for yield curve analysis"""
    
    # Calculate date range
    end_date = datetime.now().date()
    start_date = end_date - timedelta(days=days_back)
    
    # Create query for campaign data
    query = f"""
    SELECT 
        campaign.id, 
        campaign.name,
        metrics.cost_micros,
        metrics.conversions,
        segments.date
    FROM campaign
    WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
    ORDER BY segments.date
    """
    
    # Execute query
    ga_service = client.get_service("GoogleAdsService")
    response = ga_service.search(customer_id=client_id, query=query)
    
    # Process results
    rows = []
    for row in response:
        campaign = row.campaign
        metrics = row.metrics
        segments = row.segments
        
        rows.append({
            'campaign_id': campaign.id,
            'campaign_name': campaign.name,
            'date': segments.date,
            'spend': metrics.cost_micros / 1000000,  # Convert to actual currency
            'conversions': metrics.conversions
        })
    
    # Create DataFrame
    df = pd.DataFrame(rows)
    return df

def collect_keyword_data(client_id, days_back=180):
    """Collect keyword performance data for yield curve analysis"""
    
    # Calculate date range
    end_date = datetime.now().date()
    start_date = end_date - timedelta(days=days_back)
    
    # Create query for keyword data
    query = f"""
    SELECT 
        ad_group_criterion.keyword.text,
        campaign.id,
        campaign.name,
        metrics.cost_micros,
        metrics.conversions,
        segments.date
    FROM keyword_view
    WHERE segments.date BETWEEN '{start_date}' AND '{end_date}'
    ORDER BY segments.date
    """
    
    # Execute query
    ga_service = client.get_service("GoogleAdsService")
    response = ga_service.search(customer_id=client_id, query=query)
    
    # Process results
    rows = []
    for row in response:
        keyword = row.ad_group_criterion.keyword
        campaign = row.campaign
        metrics = row.metrics
        segments = row.segments
        
        rows.append({
            'keyword': keyword.text,
            'campaign_id': campaign.id,
            'campaign_name': campaign.name,
            'date': segments.date,
            'spend': metrics.cost_micros / 1000000,
            'conversions': metrics.conversions
        })
    
    # Create DataFrame
    df = pd.DataFrame(rows)
    return df

# Main function to collect all required data
def collect_data(client_id):
    campaigns_df = collect_campaign_data(client_id)
    keywords_df = collect_keyword_data(client_id)
    
    return {
        'campaigns': campaigns_df,
        'keywords': keywords_df
    }
```

#### 2. Yield Curve Analysis (2-3 days)

python

```python
import numpy as np
from scipy.optimize import curve_fit
import pandas as pd

# Define curve fitting functions
def log_func(x, a, b, c):
    """Logarithmic function for curve fitting"""
    return a + b * np.log(x + c)

def exp_func(x, a, b, c, d):
    """Exponential function for curve fitting"""
    return a - b * np.exp(-c * x) + d

def analyze_yield_curve(df, entity_column, spend_column='spend', conv_column='conversions'):
    """Generate yield curves for the given dimension"""
    
    results = {}
    
    # Group by the entity (campaign or keyword)
    for entity, group in df.groupby(entity_column):
        # Sort by date to get cumulative data
        sorted_data = group.sort_values('date')
        
        # Calculate cumulative metrics
        sorted_data['cumulative_spend'] = sorted_data[spend_column].cumsum()
        sorted_data['cumulative_conversions'] = sorted_data[conv_column].cumsum()
        
        # Need at least 5 data points for a meaningful curve
        if len(sorted_data) < 5:
            continue
            
        # Get data points for curve fitting
        x = sorted_data['cumulative_spend'].values
        y = sorted_data['cumulative_conversions'].values
        
        try:
            # Try fitting logarithmic curve (common shape for yield curves)
            log_params, log_cov = curve_fit(log_func, x, y, 
                                           bounds=([0, 0, 0], [np.inf, np.inf, np.inf]),
                                           maxfev=5000)
            
            # Try fitting exponential curve as alternative
            exp_params, exp_cov = curve_fit(exp_func, x, y,
                                           bounds=([0, 0, 0, 0], [np.inf, np.inf, np.inf, np.inf]),
                                           maxfev=5000)
            
            # Calculate errors to determine best fit
            log_y_pred = log_func(x, *log_params)
            log_error = np.mean((y - log_y_pred) ** 2)
            
            exp_y_pred = exp_func(x, *exp_params)
            exp_error = np.mean((y - exp_y_pred) ** 2)
            
            # Select best model
            if log_error <= exp_error:
                model_type = 'logarithmic'
                params = log_params
                func = log_func
            else:
                model_type = 'exponential'
                params = exp_params
                func = exp_func
                
            # Generate smooth curve for plotting
            x_smooth = np.linspace(0, x.max() * 1.5, 1000)
            y_smooth = func(x_smooth, *params)
            
            # Calculate marginal return at current spend
            current_spend = x.max()
            
            # Calculate derivative for log function
            if model_type == 'logarithmic':
                # d/dx (a + b*ln(x+c)) = b/(x+c)
                a, b, c = params
                marginal_return = b / (current_spend + c)
            else:
                # d/dx (a - b*exp(-c*x) + d) = b*c*exp(-c*x)
                a, b, c, d = params
                marginal_return = b * c * np.exp(-c * current_spend)
            
            # Store results
            results[entity] = {
                'raw_data': sorted_data,
                'model_type': model_type,
                'params': params,
                'x_smooth': x_smooth,
                'y_smooth': y_smooth,
                'current_spend': current_spend,
                'current_marginal_return': marginal_return,
                'total_conversions': y.max(),
                'total_spend': x.max()
            }
            
        except (RuntimeError, ValueError) as e:
            # Curve fitting failed
            print(f"Curve fitting failed for {entity}: {e}")
            continue
            
    return results
```

#### 3. Visualization (2 days)

python

```python
import matplotlib.pyplot as plt
import seaborn as sns

def plot_yield_curves(yield_curves, top_n=10, output_dir='./plots/'):
    """Create and save yield curve visualizations"""
    
    import os
    os.makedirs(output_dir, exist_ok=True)
    
    # Sort entities by marginal return
    sorted_entities = sorted(
        yield_curves.items(), 
        key=lambda x: x[1]['current_marginal_return'],
        reverse=True
    )
    
    # Plot top N entities
    for entity, data in sorted_entities[:top_n]:
        fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10), gridspec_kw={'height_ratios': [3, 1]})
        
        # Plot actual data points
        ax1.scatter(
            data['raw_data']['cumulative_spend'],
            data['raw_data']['cumulative_conversions'],
            alpha=0.7, 
            label='Actual Data'
        )
        
        # Plot fitted curve
        ax1.plot(
            data['x_smooth'],
            data['y_smooth'],
            'r-',
            label=f"Fitted Curve ({data['model_type']})"
        )
        
        # Mark current spend point
        ax1.axvline(
            x=data['current_spend'],
            color='blue',
            linestyle='--',
            label=f"Current Spend: £{data['current_spend']:.2f}"
        )
        
        # Calculate marginal return curve (derivative)
        if data['model_type'] == 'logarithmic':
            a, b, c = data['params']
            marginal = [b / (x + c) for x in data['x_smooth']]
        else:
            a, b, c, d = data['params']
            marginal = [b * c * np.exp(-c * x) for x in data['x_smooth']]
        
        # Plot marginal return curve
        ax2.plot(data['x_smooth'], marginal, 'g-')
        ax2.axvline(
            x=data['current_spend'],
            color='blue',
            linestyle='--'
        )
        
        # Mark current marginal return
        ax2.axhline(
            y=data['current_marginal_return'],
            color='red',
            linestyle=':',
            label=f"Current Marginal Return: {data['current_marginal_return']:.4f}"
        )
        
        # Set titles and labels
        ax1.set_title(f"Yield Curve for {entity}")
        ax1.set_ylabel("Cumulative Conversions")
        ax1.legend()
        
        ax2.set_title("Marginal Return Curve")
        ax2.set_xlabel("Cumulative Spend (£)")
        ax2.set_ylabel("Marginal Return\n(Conv./£)")
        
        plt.tight_layout()
        plt.savefig(f"{output_dir}/{entity.replace(' ', '_')}_yield_curve.png")
        plt.close()
        
    # Create summary chart of marginal returns
    plt.figure(figsize=(12, 8))
    
    entities = [x[0] for x in sorted_entities[:top_n]]
    marginal_returns = [x[1]['current_marginal_return'] for x in sorted_entities[:top_n]]
    
    colors = sns.color_palette("viridis", len(entities))
    
    bars = plt.barh(entities, marginal_returns, color=colors)
    
    plt.title("Current Marginal Return by Entity")
    plt.xlabel("Marginal Return (Conversions per £)")
    plt.tight_layout()
    
    plt.savefig(f"{output_dir}/marginal_returns_summary.png")
    plt.close()
```

#### 4. CSV Export (1 day)

python

```python
def export_results(yield_curves, output_file='yield_curve_results.csv'):
    """Export yield curve analysis results to CSV"""
    
    rows = []
    
    for entity, data in yield_curves.items():
        rows.append({
            'Entity': entity,
            'Total_Spend': data['total_spend'],
            'Total_Conversions': data['total_conversions'],
            'Current_Marginal_Return': data['current_marginal_return'],
            'Model_Type': data['model_type'],
            'Avg_CPA': data['total_spend'] / data['total_conversions'] if data['total_conversions'] > 0 else None
        })
    
    # Create DataFrame
    results_df = pd.DataFrame(rows)
    
    # Sort by marginal return
    results_df = results_df.sort_values('Current_Marginal_Return', ascending=False)
    
    # Export to CSV
    results_df.to_csv(output_file, index=False)
    
    return results_df
```

#### 5. Main Script (1 day)

python

```python
def main():
    # Load config
    import json
    with open('config.json', 'r') as f:
        config = json.load(f)
    
    # Set up Google Ads client
    client_id = config['client_id']
    
    print("Collecting data from Google Ads...")
    data = collect_data(client_id)
    
    # Analyze campaigns
    print("Analyzing campaign yield curves...")
    campaign_curves = analyze_yield_curve(
        data['campaigns'], 
        entity_column='campaign_name'
    )
    
    # Analyze keywords (only top spenders for simplicity)
    print("Analyzing keyword yield curves...")
    # Get top keywords by spend
    top_keywords = data['keywords'].groupby('keyword').agg(
        {'spend': 'sum'}
    ).sort_values('spend', ascending=False).head(100)
    
    # Filter for just these keywords
    keywords_to_analyze = data['keywords'][
        data['keywords']['keyword'].isin(top_keywords.index)
    ]
    
    keyword_curves = analyze_yield_curve(
        keywords_to_analyze,
        entity_column='keyword'
    )
    
    # Create visualizations
    print("Creating visualizations...")
    plot_yield_curves(campaign_curves, top_n=10, output_dir='./plots/campaigns/')
    plot_yield_curves(keyword_curves, top_n=20, output_dir='./plots/keywords/')
    
    # Export results
    print("Exporting results...")
    campaign_results = export_results(campaign_curves, 'campaign_yield_results.csv')
    keyword_results = export_results(keyword_curves, 'keyword_yield_results.csv')
    
    print("Analysis complete!")
    print(f"Campaign results saved to campaign_yield_results.csv")
    print(f"Keyword results saved to keyword_yield_results.csv")
    print(f"Visualizations saved to ./plots/ directory")

if __name__ == "__main__":
    main()
```

### Integration with Metabase (Optional: 1-2 days)

If you want to use Metabase for visualization:

1. Export results to a SQLite database instead of CSV
2. Configure Metabase to connect to this database
3. Create dashboards in Metabase showing:
    - Yield curves for top campaigns
    - Marginal return comparison chart
    - Historical trend of marginal returns

## Total Implementation: 6-9 Days

This V1 system provides the core analysis capabilities while keeping the scope manageable. It runs locally, provides useful visualizations, and focuses on campaigns and keywords without the complexity of automated budget allocation or report generation.

The output would be:

1. CSV files with yield curve analysis results
2. Visualization images saved to disk
3. (Optional) Metabase dashboard


-----

I'd be happy to help you build this system! You're absolutely right about the campaign-to-keyword relationship - we need to account for the same keywords appearing across multiple campaigns.

Let's start by outlining our approach and then I can help guide you through the implementation:

## Implementation Plan for Campaign-Keyword Yield Curve Analysis

### Step 1: Project Setup

Let's create a proper project structure and make sure we have all dependencies:

```
ppc-yield-curve/
├── config.json             # Configuration file
├── requirements.txt        # Dependencies
├── src/
│   ├── __init__.py
│   ├── data_collection.py  # Google Ads data collection
│   ├── analysis.py         # Yield curve analysis 
│   ├── visualization.py    # Plotting functions
│   └── export.py           # CSV/database export
└── main.py                 # Main script
```

### Step 2: Requirements

Let's define what we need in `requirements.txt`:

```
google-ads==19.0.0
pandas==2.0.3
numpy==1.24.3
scipy==1.10.1
matplotlib==3.7.2
seaborn==0.12.2
```

### Step 3: Let's start coding the system together

I'd be happy to provide you with the code for each component, adapted to include the campaign-to-keyword relationship. Would you like me to:

1. Provide the complete code for each file in sequence?
2. Start with a specific component you want to focus on first?
3. Share any particular implementation details you'd like to ensure are included?

Also, to make sure this meets your needs:

1. Do you already have Google Ads API credentials set up?
2. Is there a particular account structure or quirk we should account for?
3. Would you prefer SQLite integration for Metabase or just CSV output for now?


----


## Adapting for Your Data Reality

### 1. 30% Unknown Tracking

This means 30% of your conversions aren't properly attributed to their source, which introduces substantial uncertainty into yield curve analysis.

**Modifications needed:**

- **Adjustment Factor**: Apply a tracking correction factor to account for under-reporting
- **Confidence Intervals**: Include error bands on yield curves to show the range of possible true performance
- **Sensitivity Analysis**: Show how yield curves shift under different attribution assumptions

### 2. First-Click Attribution Model

First-click attribution gives all credit to the initial touchpoint, which may significantly undervalue PPC's contribution later in the customer journey.

**Modifications needed:**

- **Model Comparison**: Create parallel yield curves using estimated multi-touch attribution values
- **Journey Analysis**: Incorporate indicators for when PPC appears in journey but doesn't get attribution
- **Conversion Delay Analysis**: Account for lag between first click and conversion

### 3. PPC = 30% of Conversions

This indicates other channels contribute significantly, making cross-channel effects crucial to consider.

**Modifications needed:**

- **Channel Interaction**: Analyze how PPC interacts with other channels
- **Incremental Analysis**: Focus on incremental impact rather than directly attributed conversions
- **Assisted Conversion Value**: Include metrics for PPC-assisted conversions

## Revised Implementation Approach

Here's how we should modify the system:

python

```python
# In analysis.py - add attribution adjustment
def analyze_yield_curve(df, entity_column, spend_column='spend', conv_column='conversions', 
                       unknown_rate=0.3, attribution_model='first_click'):
    """
    Generate yield curves with adjustments for tracking limitations
    
    Parameters:
    - unknown_rate: Percentage of conversions not properly tracked
    - attribution_model: Current attribution model in use
    """
    
    results = {}
    
    # Calculate adjustment factor for unattributed conversions
    # Simple approach: distribute unknown conversions proportionally
    attribution_adjustment = 1 / (1 - unknown_rate)
    
    # Adjustment for first-click when PPC is often in the middle/end
    # This is an estimated factor - would ideally be based on path analysis
    if attribution_model == 'first_click':
        # Estimate that first-click undercounts PPC contribution by ~40%
        attribution_model_adjustment = 1.4
    else:
        attribution_model_adjustment = 1.0
    
    # Combined adjustment factor
    combined_adjustment = attribution_adjustment * attribution_model_adjustment
    
    # Group by the entity (campaign or keyword)
    for entity, group in df.groupby(entity_column):
        # Sort by date to get cumulative data
        sorted_data = group.sort_values('date')
        
        # Calculate cumulative metrics
        sorted_data['cumulative_spend'] = sorted_data[spend_column].cumsum()
        
        # Apply conversion adjustment
        sorted_data['adjusted_conversions'] = sorted_data[conv_column] * combined_adjustment
        sorted_data['cumulative_conversions'] = sorted_data['adjusted_conversions'].cumsum()
        
        # Create lower and upper bounds for confidence interval
        sorted_data['cumulative_conversions_lower'] = sorted_data[conv_column].cumsum()  # Original unadjusted
        sorted_data['cumulative_conversions_upper'] = sorted_data[conv_column].cumsum() * (combined_adjustment * 1.2)  # Upper estimate
        
        # Need at least 5 data points for a meaningful curve
        if len(sorted_data) < 5:
            continue
            
        # Get data points for curve fitting
        x = sorted_data['cumulative_spend'].values
        y = sorted_data['cumulative_conversions'].values
        y_lower = sorted_data['cumulative_conversions_lower'].values
        y_upper = sorted_data['cumulative_conversions_upper'].values
        
        # Continue with curve fitting as before but now fit 3 curves
        # (main adjusted curve, lower bound, upper bound)
        # ...
```

python

```python
# In visualization.py - add confidence intervals and model comparisons
def plot_yield_curves(yield_curves, top_n=10, output_dir='./plots/'):
    # ... existing code ...
    
    # Add confidence interval to the plot
    ax1.fill_between(
        data['x_smooth'],
        data['y_smooth_lower'],
        data['y_smooth_upper'],
        alpha=0.2,
        color='gray',
        label='Confidence Interval (Attribution Uncertainty)'
    )
    
    # Add note about attribution model
    plt.figtext(
        0.5, 0.01, 
        "Note: Curves adjusted for 30% unknown attribution and first-click model limitations.",
        ha='center', fontsize=9, style='italic'
    )
    
    # ... rest of plotting code ...
```

python

```python
# In export.py - add attribution model details to output
def export_results(yield_curves, output_file='yield_curve_results.csv', 
                  unknown_rate=0.3, attribution_model='first_click'):
    # ... existing code ...
    
    # Add attribution information
    for entity, data in yield_curves.items():
        rows.append({
            # ... existing fields ...
            'Attribution_Model': attribution_model,
            'Unknown_Rate': unknown_rate,
            'Adjustment_Factor': data['adjustment_factor'],
            'Adjusted_Conversions': data['total_adjusted_conversions'],
            'Raw_Conversions': data['total_raw_conversions'],
            'Conversion_Range_Low': data['total_conversions_lower'],
            'Conversion_Range_High': data['total_conversions_upper'],
            # ... additional fields ...
        })
```

## Addressing Campaign-Keyword Relationships

We also need to handle the same keywords appearing across multiple campaigns:

python

```python
# In data_collection.py
def collect_campaign_keyword_data(client_id, days_back=180):
    """Collect keyword performance data with campaign context"""
    
    # ... API query code similar to before ...
    
    # Process results
    rows = []
    for row in response:
        keyword = row.ad_group_criterion.keyword
        campaign = row.campaign
        ad_group = row.ad_group
        metrics = row.metrics
        segments = row.segments
        
        rows.append({
            'keyword': keyword.text,
            'campaign_id': campaign.id,
            'campaign_name': campaign.name,
            'ad_group_id': ad_group.id,
            'ad_group_name': ad_group.name,
            'date': segments.date,
            'spend': metrics.cost_micros / 1000000,
            'conversions': metrics.conversions,
            'campaign_keyword_pair': f"{campaign.name}|{keyword.text}"  # Unique identifier
        })
    
    # Create DataFrame
    df = pd.DataFrame(rows)
    return df
```

python

```python
# In main.py - analyze keywords within campaign context
def main():
    # ... existing setup code ...
    
    # Analyze campaign-specific keywords
    print("Analyzing campaign-keyword pairs...")
    campaign_keyword_df = data['campaign_keywords']
    
    # Create unique identifier for campaign-keyword combination
    campaign_keyword_df['campaign_keyword_pair'] = (
        campaign_keyword_df['campaign_name'] + '|' + campaign_keyword_df['keyword']
    )
    
    campaign_keyword_curves = analyze_yield_curve(
        campaign_keyword_df,
        entity_column='campaign_keyword_pair',
        unknown_rate=0.3,
        attribution_model='first_click'
    )
    
    # Also analyze keywords across all campaigns (aggregate view)
    print("Analyzing keywords across all campaigns...")
    keyword_aggregate = data['campaign_keywords'].groupby(['keyword', 'date']).agg({
        'spend': 'sum',
        'conversions': 'sum'
    }).reset_index()
    
    keyword_curves = analyze_yield_curve(
        keyword_aggregate,
        entity_column='keyword',
        unknown_rate=0.3,
        attribution_model='first_click'
    )
    
    # ... visualization and export code ...
```

## Implications for Interpretation

Given these data limitations, we should make clear in our outputs that:

1. **The yield curves represent estimates** affected by attribution limitations
2. **The actual ROI is likely higher** than directly reported
3. **Campaign/keyword rankings** may change under different attribution models
4. **Budget recommendations** should be treated as directional rather than precise

------


