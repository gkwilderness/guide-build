# yellow zebra website migration – SEO & delivery summary

## overall status
- **behind but recoverable**
- confidence: **~6/10**
- key constraint: SEO validation cycles (crawl + analysis) take 2–3 days, creating pressure during final QA — compounded by upcoming resource gap

## executive summary
- the agency (Kitty) is **not fundamentally the issue**
- delivery risk is being driven by:
  - **lack of clear ownership**
  - **fragmented communication**
  - **insufficient senior SEO direction**
- result: work is **reactive, inconsistent, and requires constant re-checking**

## what’s working well
- dev team is **responsive and capable when given clear direction**
- agency engages well when **brought into direct, structured conversations**
- good pushback on **non-critical pre-launch items**
- some stakeholders are:
  - documenting actions
  - trying to balance UX and SEO constraints

## critical risks (SEO + performance)

### 1. crawlability & indexation (high risk)
- page sizes exceeding **2MB**
- **risk of Google not crawling pages fully or at all**
- **unknown where Google truncates rendering/crawling on page**
- impacts **~4,400 pages (majority of the site)**
- **this is a critical launch blocker and must be resolved**

### 2. site speed & performance
- staging performance is **significantly worse than expected**
- potential mitigation via:
  - Cloudflare
  - WP Engine
- requires **proper production-like testing**

### 3. international SEO (critical)
- implementation is **poor and inconsistent**
- agreed approach not correctly executed
- current state **no better than production**

### 4. technical SEO foundations
- inconsistent:
  - canonicals / indexing signals
  - internal linking
- heavy reliance on JavaScript
- no consideration for LLM crawling
- schema:
  - no clear strategy
  - no visibility
  - inconsistent execution

### 5. redirects & migration readiness
- redirects strategy: **~5/10**
- partially de-risked via Cloudflare testing
- requires full validation pre-launch

### 6. content quality
- content **not materially improved**
- issues:
  - spelling errors
  - broken links
  - missing content blocks
- not optimised for launch

## delivery & process issues

### lack of ownership
- no clear owner for SEO or content quality

### fragmented communication
- spread across Slack, Google Docs, email
- causing duplication and delays

### over-reliance on devs
- CMS not used effectively
- unnecessary dev dependency for basic fixes

### reactive SEO integration
- SEO brought in late
- implementation inconsistent
- requires constant checking

## priority actions

1. resolve crawlability issue (page size)
2. fix international SEO
3. improve content quality
4. define schema strategy

## overall assessment
- agency is capable
- main issue is lack of direction and coordination

## final take
- project is recoverable
- primary risk is execution clarity, not capability
