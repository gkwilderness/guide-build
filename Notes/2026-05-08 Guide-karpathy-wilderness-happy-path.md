# Karpathy's Auto-Learning PoC: Application to Wilderness Safaris Website Conversion

**Prepared for:** Gareth Knight, MD Digital & Growth  
**Date:** May 2026  
**Classification:** Strategic / Internal

---

## What Karpathy's PoC Actually Is

The concept sits across two related projects Karpathy shipped in late 2025 and early 2026:

**autoresearch** (March 2026, github.com/karpathy/autoresearch) is the core PoC. The premise: give an AI agent a real experimental environment, let it run unsupervised overnight, and wake up to a better result. In the ML context that means: the agent modifies training code, runs a 5-minute experiment, measures whether performance improved, keeps the change if it did, discards it if it didn't, and repeats — targeting ~100 experiments per night on a single GPU. No human in the loop between iterations.

The key structural insight isn't about machine learning specifically. It's the **autonomous loop**:

```
Propose change → implement → run experiment → measure metric → keep/discard → repeat
```

What makes this different from conventional A/B testing or automated ML is that the agent generates the *hypotheses*, not just executes no. You're not programming the experiment — you're programming the experimenter.

**hn-time-capsule** (December 2025, github.com/karpathy/hn-time-capsule) is the second relevant piece. Here Karpathy fed historical Hacker News discussions into an LLM and asked it to synthesise what those human conversations predicted, grade the predictions with hindsight, and surface who was consistently right. The idea: LLMs can scour large volumes of human behaviour data and extract structured insight automatically and cheaply.

The phrase "auto learning" isn't Karpathy's own label — it's a reasonable description of the underlying idea: AI that learns from iterating on a system, or learns from analysing accumulated human behaviour, without manual effort per cycle.

---

## How the Core Idea Applies to Website Conversion / Happy Path Analysis

The autoresearch loop maps cleanly onto conversion rate optimisation:

| autoresearch (ML) | CRO equivalent |
|---|---|
| `train.py` — the thing the agent modifies | Landing pages, UX elements, copy, flows |
| `val_bpb` — the single metric | Enquiry form submission rate |
| 5-minute training run | Live user session / synthetic user test |
| Keep or discard | Ship or revert |
| Overnight loop | Continuous autonomous experimentation |

The hn-time-capsule pattern also applies: rather than *generating* hypotheses for live experiments, feed historical session data and behaviour signals to an LLM and ask it to *retrospectively grade* what patterns led to conversions. You get structured insight without touching live traffic.

Two modes, both valuable:

1. **Retrospective mode** — LLM analyses existing session/behaviour data to surface what the happy path actually looks like (vs. what we assume it looks like)  
2. **Prospective/simulation mode** — LLM personas navigate the site autonomously, flagging friction before real users hit it

---

## Specific Applications for Wilderness

### 1. Happy Path Retrospective — What Converts vs. What Doesn't

Feed 6–12 months of GA4 session data (page sequences, time-on-page, scroll depth, exit pages) alongside enquiry submission events into an LLM. Ask it to: identify the session patterns that precede enquiry submission, grade the funnel steps for drop-off risk, and surface the 3–5 most common journeys for each brand.

This is the hn-time-capsule method applied to your data. Cost: a few API calls. Effort: structured data export from GA4 + a well-crafted prompt. You're not running experiments — you're synthesising what's already happened.

For Wilderness specifically: luxury safari buyers behave differently from typical e-commerce. Sessions are longer, multi-visit, often research-heavy. The LLM can identify whether converters follow a distinct content sequence (e.g. lodge pages → conservation pages → enquiry vs. destination → itinerary → enquiry) that short-circuited browsers don't.

### 2. Synthetic Persona Simulation — Stress-Test the Happy Path Before It Breaks

Build 4–6 buyer personas (first-time Africa, family, honeymooner, repeat WS guest, Jacada luxury, YZ budget-luxury) and prompt an LLM to navigate each site as that persona — making decisions at each page about whether to proceed or bounce, and why. The agent produces: a written session transcript, friction points by page, the moment it would have submitted an enquiry (or abandoned), and recommended fixes.

This is entirely pre-live. No traffic, no split tests. Useful for the YZ site launch specifically — you can run 50 synthetic sessions across persona types before the first real visitor lands.

### 3. Autonomous Copy Experimentation Loop (autoresearch-style)

The full autoresearch pattern applied to copy and CTA testing: an AI agent proposes a headline variant or CTA change, implements it in a staging environment, routes a slice of real traffic, measures enquiry rate, keeps or reverts. The agent runs this loop autonomously, generating hypotheses based on what's already worked.

Requires: a CMS that supports programmatic edits, a traffic router (Cloudflare Workers or similar), and a defined metric (enquiry form start, not just page view). Highest effort, highest ceiling. This is the 6-month build — not the first move.

### 4. Drop-Off Diagnosis — Why People Leave Before Enquiring

Take Hotjar/Clarity session recordings for sessions that exit on the enquiry page without submitting, and feed transcripts or interaction sequences to an LLM. Ask it to generate ranked hypotheses for abandonment. Common findings in luxury travel: form friction (too many fields, too early), price anxiety (no anchoring), trust gaps (not enough social proof at decision moment).

The LLM doesn't need to be right every time — it needs to generate better hypotheses faster than a CRO analyst working manually. Then test the top 3.

### 5. Cross-Brand Signal Aggregation

All three brands (WS, JC, YZ) run separate funnels but share a buyer pool. An LLM can be prompted to compare session patterns across brands — where do the same content types convert on JC but not WS? What does YZ do in the funnel that WS doesn't? This is pattern recognition across datasets that a human analyst would take weeks to do manually.

---

## What Would Be Needed to Implement

**Data (start here):**
- GA4 session-level export with event sequences (not just aggregate metrics)
- Enquiry submission events tagged and linked to session IDs
- Hotjar or Microsoft Clarity session recordings and heatmaps
- CRM data: which lead sources actually close (to back-calibrate what "good" looks like)

**Tools:**
- LLM API access (Claude or GPT — you have this via Guide)
- Structured data pipeline from GA4 → flat file → LLM prompt (André's handover territory)
- For the full autonomous loop: a CMS with API access and a traffic experimentation layer

**Effort by mode:**

| Mode | Effort | Time to first output |
|---|---|---|
| Retrospective analysis (mode 1, 4) | Low — 1–2 days to structure the data | 1 week |
| Synthetic persona simulation (mode 2) | Low-medium — prompt engineering + site crawl | 2 weeks |
| Cross-brand aggregation (mode 5) | Medium — data normalisation across 3 GA4 properties | 3–4 weeks |
| Autonomous CRO loop (mode 3) | High — requires engineering | 3–6 months |

---

## Risks and Limitations

**The single-metric trap.** autoresearch works because val_bpb is a clean signal. Enquiry form submission is cleaner than most CRO metrics, but it's not the end of the funnel — a surge in low-quality leads can look like a win. Tie any optimisation metric to lead quality signals from HubSpot, not just volume.

**Luxury buyer psychology isn't fully captured by session data.** High-consideration safari buyers do significant off-site research (travel agent, word of mouth, editorial). The website is often the *confirmation* step, not the discovery step. The LLM can only see what happens on-site — it will miss the pre-session context that shaped the visit intent.

**Synthetic personas have a distribution problem.** An LLM persona navigating a luxury travel site will behave more rationally and less emotionally than a real HNW buyer. It will notice confusing navigation that a real buyer might forgive; it will miss the aspirational pull that keeps a real buyer engaged through friction. Use synthetic sessions for structural / functional diagnosis, not emotional resonance testing.

**Autonomous experimentation needs guardrails in luxury.** A wrong test on an e-commerce site costs you a fraction of a percent conversion rate. A wrong test on a £15,000 safari enquiry page can undermine brand trust. Any autonomous loop needs human review before shipping live changes.

**Data quality dependency.** GA4 data quality on all three sites needs to be verified before feeding it to an LLM for analysis. If the event tracking is patchy or the session stitching is broken, the LLM will confidently surface nonsense. Ashleigh's first audit on joining should include a data quality check specifically for this use case.

---

## Recommended First Step

**Run the retrospective analysis on one brand within 30 days.**

Pick Jacada (clearest buyer persona, longest-running GA4 data). Export 12 months of session-level data for sessions that include an enquiry form view. Split into two groups: submitted and abandoned. Feed both sets to Claude with the following prompt structure:

> "You are a senior CRO analyst reviewing luxury travel website sessions. Here are [N] sessions from users who submitted an enquiry. Here are [N] sessions from users who viewed the enquiry page but did not submit. Identify: (1) the 5 most common page sequences before submission in the converting group; (2) the 5 most common exit patterns in the abandonment group; (3) your top 3 hypotheses for why the abandonment group left; (4) which changes you would test first."

This costs under $10 in API calls. It produces structured, testable output. It requires no new tooling, no engineering, and no live traffic risk. If the output is useful — and it will be — it proves the method and builds the case for the more ambitious implementations.

That's the wedge. Everything else follows.

---

*Brief compiled by Guide · May 2026 · Based on research across Karpathy's GitHub (autoresearch, hn-time-capsule, jobs), published writeups, and field assessment of applicability to Wilderness Group's commercial context.*
