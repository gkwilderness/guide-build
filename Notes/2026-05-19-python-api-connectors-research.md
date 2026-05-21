# Python API Connectors — Research & Recommendations

**Date:** 2026-05-19
**Author:** Guide
**Status:** Unprocessed — for review
**Tags:** #research #connectors #skills #python #api

---

## Context

On 2026-05-19, Guide demonstrated the HubSpot connector pattern live in Slack: a Python script authenticates against the HubSpot API, pulls structured data, and returns deterministic JSON. The LLM reads the output. The script is the boundary — it controls exactly what gets fetched.

This research documents the equivalent Python libraries and SDKs for six platforms, so the same pattern can be replicated as Guide skills across the team's data stack.

**The pattern:**
```
Python script → authenticates → queries API → returns structured JSON
LLM reads the JSON → reasons over it
```

Not: give the LLM direct API access. Python fetches. LLM reads.

---

## Findings by Platform

---

### Google Search Console

**Library:** `google-searchconsole` (joshcarty)
**URL:** https://github.com/joshcarty/google-searchconsole
**Stars:** 247 | **Updated:** Nov 2025 | **Language:** Python

**What it pulls:** Search analytics — queries, pages, countries, devices. Metrics: clicks, impressions, CTR, position. Date range filtering, up to 25,000 rows per request.

**Auth:** OAuth 2.0 via service account JSON or interactive credentials file.

**Output:** List of dicts or pandas DataFrame.

```python
account = searchconsole.authenticate(client_config='client_secrets.json', credentials='creds.json')
wp = account['https://www.wildernessdestinations.com/']
df = wp.query.range('today', days=-30).dimension('query', 'page').get().to_dataframe()
```

**Output shape:**
```json
[
  {"keys": ["safari lodges", "/kenya/"], "clicks": 142, "impressions": 3400, "ctr": 0.0418, "position": 4.2}
]
```

**Also useful:** `google-api-python-client` (official Google, 8,800 stars) — lower-level but includes URL Inspection (index status, crawl state, rich results, mobile usability).

---

### Ahrefs

**Library:** `ahrefs/ahrefs-python` (Official Ahrefs SDK)
**URL:** https://github.com/ahrefs/ahrefs-python
**Status:** Official, maintained by Ahrefs engineering | MIT | Python 3.11+

**What it pulls:** Organic keywords, backlinks, domain rating, traffic history, competitor analysis, content gaps, rank tracker, site audit issues, Brand Radar / AI visibility (share of voice).

**Auth:** API key — `AHREFS_API_KEY` env var.

**Output:** Typed dataclass objects — trivially serialisable to JSON via `dataclasses.asdict()`. Async client available (`AsyncAhrefsClient`). Auto-retries on 429.

```python
from ahrefs_python import AhrefsClient
client = AhrefsClient(api_key=AHREFS_API_KEY)
keywords = client.site_explorer_organic_keywords(target="wildernessdestinations.com", date="2026-05-01")
```

**Output shape:**
```json
[
  {"keyword": "luxury safari kenya", "volume": 1900, "best_position": 3, "difficulty": 28, "traffic": 312}
]
```

---

### SEMrush

**Library:** No official Python SDK exists.
**Approach:** Raw `requests` wrapper — the API is plain REST over HTTP GET.

**What it pulls:** Domain organic keywords, paid keywords, backlinks, competitor analysis, keyword research, PAA questions, SERP results.

**Auth:** API key as query param.

**Output:** JSON or CSV (pipe-delimited) — you control exactly which fields come back.

```python
import requests

def semrush_domain_organic(domain, api_key, database="uk", limit=100):
    params = {
        "type": "domain_organic",
        "key": api_key,
        "domain": domain,
        "database": database,
        "display_limit": limit,
        "export_format": "json",
        "export_columns": "Ph,Po,Nq,Cp,Co,Tr,Tc,Nr,Td"
    }
    r = requests.get("https://api.semrush.com/", params=params)
    r.raise_for_status()
    return r.json()
```

**Output shape:**
```json
[
  {"Ph": "luxury safari", "Po": "3", "Nq": "1900", "Cp": "4.23", "Tr": "15.23"}
]
```

**Note:** This is a ~20-line wrapper. Build it. Nothing worth adopting exists.

---

### Google Ads

**Two layers — use both:**

#### Layer 1: `google-ads` (Official)
**URL:** https://github.com/googleads/google-ads-python
**Stars:** Official Google repo | **Version:** 31.0.0, May 2026 | **Language:** Python

**What it pulls:** Campaigns, ad groups, keywords, search terms, quality scores, PMax assets, change history, conversion actions, geographic performance, demographic performance. Anything reachable via GAQL (Google Ads Query Language — SQL-like).

**Auth:** `google-ads.yaml` with developer token + OAuth refresh token.

**Output:** Protobuf objects — convert with a dict comprehension. Costs in micros (÷ 1,000,000).

```python
query = """
    SELECT campaign.name, metrics.impressions, metrics.clicks, metrics.cost_micros
    FROM campaign
    WHERE segments.date DURING LAST_7_DAYS
    ORDER BY metrics.cost_micros DESC
"""
stream = ga_service.search_stream(customer_id="1234567890", query=query)
results = [{"name": r.campaign.name, "cost": r.metrics.cost_micros / 1e6} for batch in stream for r in batch.results]
```

#### Layer 2: `gaarf` (Google open source)
**URL:** https://github.com/google/ads-api-report-fetcher
**Install:** `pip install google-ads-api-report-fetcher`

Wraps the official library. GAQL file in → JSON/CSV/DataFrame/BigQuery out. CLI and Python library. This is the cleanest fit for the skill pattern — write a GAQL file per query type, script calls gaarf, outputs JSON.

```bash
gaarf campaigns.sql --account=1234567890 --output=json
```

---

### Google Analytics 4

**Library:** `google-analytics-data` (Google LLC)
**URL:** https://pypi.org/project/google-analytics-data/
**Version:** 0.22.0, May 2026 | **Maintained by:** Google | **Apache 2.0**

**What it pulls:** Standard reports (any dimension/metric combination), realtime, pivot, funnel, batch, audience exports. ~50 dimensions, ~50 metrics available.

**Auth:** Service account JSON via `GOOGLE_APPLICATION_CREDENTIALS` env var. Read-only by design.

**Output:** Typed Python objects — convert to JSON with a standard helper.

```python
def ga4_report(property_id, start_date, end_date, dimensions, metrics):
    client = BetaAnalyticsDataClient()
    request = RunReportRequest(
        property=f"properties/{property_id}",
        dimensions=[Dimension(name=d) for d in dimensions],
        metrics=[Metric(name=m) for m in metrics],
        date_ranges=[DateRange(start_date=start_date, end_date=end_date)],
    )
    response = client.run_report(request)
    rows = []
    for row in response.rows:
        rows.append(dict(zip(
            [h.name for h in response.dimension_headers] + [h.name for h in response.metric_headers],
            [d.value for d in row.dimension_values] + [m.value for m in row.metric_values]
        )))
    return rows
```

**Note:** All values return as strings — cast metrics to int/float after extraction.

---

### Google BigQuery

**Library:** `google-cloud-bigquery` (Google LLC)
**URL:** https://pypi.org/project/google-cloud-bigquery/
**Version:** 3.41.0, March 2026 | **Maintained by:** Google | **Apache 2.0**

**What it does:** Execute any SQL, return rows as dicts, DataFrame, or Arrow table. Parameterised queries. Dry-run support (estimate bytes before executing). Schema introspection.

**Auth:** ADC or service account JSON.

**Output:**
```python
rows = client.query(query).result()
result = [dict(row) for row in rows]
print(json.dumps(result, indent=2, default=str))
```

**Note:** Already on the machine. Foundation for everything data-related. Parameterised queries are the right pattern — prevents drift, keeps queries deterministic.

---

### Meta Ads

**Two options — raw `requests` is cleaner for read-only:**

#### Option A: Raw Graph API (recommended for read-only)
```python
def get_campaign_insights(account_id, access_token, date_preset='last_30d'):
    url = f'https://graph.facebook.com/v21.0/{account_id}/insights'
    params = {
        'fields': 'campaign_id,campaign_name,impressions,clicks,spend,ctr,cpc,actions',
        'date_preset': date_preset,
        'level': 'campaign',
        'time_increment': 1,
        'access_token': access_token,
        'limit': 500,
    }
    # Handle cursor pagination
    rows = []
    while True:
        r = requests.get(url, params=params)
        data = r.json()
        rows.extend(data.get('data', []))
        if 'next' not in data.get('paging', {}).get('cursors', {}):
            break
        params['after'] = data['paging']['cursors']['after']
    return rows
```

#### Option B: `facebook-business` SDK (Meta official)
**URL:** https://github.com/facebook/facebook-python-business-sdk
**Version:** 25.0.1, March 2026 | ~2.8k stars | Full read+write

150+ insight metrics available. Use `ads_read` permission only for read-only access. Async jobs for date ranges >7 days.

**Note:** All metric values return as strings — cast to float on ingest.

---

### Microsoft Advertising (Bing Ads)

**Library:** `bingads` / `msads` (Official Microsoft SDK)
**URL:** https://github.com/BingAds/BingAds-Python-SDK
**Version:** v13.0.28, May 2026 | 127 stars | MIT

**What it pulls:** Campaign performance, search query reports, keyword performance, conversion reports, geo reports, change history. Via `ReportingService`.

**Auth:** OAuth 2.0 + Microsoft developer token. Config via env vars.

**Output:** Async pattern — submit report → poll → download TSV → parse to DataFrame. More friction than the others but functional.

**Note:** The async polling (submit → wait → download) means the script takes 30–60 seconds to return data. Design the skill around this — don't expect synchronous output.

---

### Bing Webmaster Tools

**Library:** `bing-webmaster-tools` (merj)
**URL:** https://github.com/merj/bing-webmaster-tools
**Version:** v1.2.0, April 2025 | 20 stars | Python 3.9+, async, Pydantic v2

**What it pulls:** Crawl stats, keyword stats, query/page data, URL links, crawl issues, blocked pages, sitemaps.

**Auth:** API key only — generate from Bing Webmaster dashboard.

**Output:** Pydantic models → `model_dump()` → JSON. Clean.

```python
async with BingWebmasterClient(Settings.from_env()) as client:
    stats = await client.crawling.get_crawl_stats("https://wildernessdestinations.com")
    print(json.dumps([s.model_dump() for s in stats], default=str))
```

---

## Recommendations

### Build priority

| Platform | Library | Effort | Notes |
|----------|---------|--------|-------|
| Google Search Console | `google-searchconsole` | Low | Same auth pattern as GA4 |
| GA4 | `google-analytics-data` | Low | ADC already configured |
| Google Ads | `gaarf` + `google-ads` | Medium | GAQL files = deterministic queries |
| Ahrefs | `ahrefs/ahrefs-python` | Low | Official SDK, typed output |
| Meta Ads | Raw `requests` → Graph API | Low | Simpler than SDK for read-only |
| BigQuery | `google-cloud-bigquery` | Low | Already on machine |
| SEMrush | Custom `requests` wrapper | Low | 20 lines, full control |
| Microsoft Ads | `bingads` SDK | Medium | Async polling is friction |
| Bing Webmaster | `bing-webmaster-tools` | Low | Only option, decent quality |

### Design principles for each skill

1. **Read-only by default** — use minimum permission scopes (e.g. `ads_read` not `ads_management`)
2. **Parameterised inputs** — date range, brand, account ID passed in, not hardcoded
3. **Structured JSON output** — one consistent output contract the LLM can always parse
4. **Bounded queries** — script defines exactly what fields come back; no open-ended pulls
5. **Token stored in vault or env** — not hardcoded in the script
6. **Cache output as .md report** — every run writes a timestamped report to the vault (→ `70-Reports/`)

### Auth pattern to standardise

Each skill should resolve its token the same way the HubSpot connector does: read from a known vault path or environment variable. The Architect has a signal to define the canonical token storage pattern before these skills are built.

---

---

## The Skill Factory

*Added 2026-05-19 19:49*

This document is not just research — it's the input to a repeatable build process.

The pattern that emerged today:

1. **Live demo** — HubSpot connector built in a single Slack session, live in front of the team
2. **Skill** — write-a-skill wrapped it into a reusable, deployable asset
3. **Research** — six parallel agents documented the equivalent libraries across every platform
4. **Document** — this note defines the output contract, auth patterns, and build order

The next step is this document becoming the input to the build queue:
- **Architect** reviews, confirms the token storage pattern (signal filed), sequences the skills
- **Engineer** builds them in order — one skill per platform, consistent pattern throughout
- **Guide** deploys each skill — immediately available to every agent in the system

The marginal cost of each additional skill is close to zero once the factory is running. Same auth pattern. Same JSON output contract. Same vault caching. Ten platforms, ten skills — the team gets deterministic data access without ever touching an API directly.

**The factory isn't the skills. The factory is the process that produces them.**

This is the recursive loop: ask the AI to think about how to use AI to build something with AI. One full cycle completed today. The output is this document.

---

*Filed by Guide 🦁 | 2026-05-19 | Source: parallel research session across 6 agents*
