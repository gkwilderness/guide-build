---
title: "README"
type: reference
area: wilderness
project: "Wilderness"
status: active
---
# 📘 Apex: The Wilderness Marketing Intelligence System

## What is Apex?

GUIDE is an internal diagnostic engine built for Wilderness, designed to automatically analyze paid media performance, detect growth opportunities, and surface actionable insights — starting with Botswana PPC.

It acts as a trusted, tireless operator that runs dozens of diagnostics every night, translates data into strategy, and scales Gareth's thinking across the business.

---

## Why It Exists

Most performance marketing teams rely on dashboards and gut instinct. GUIDE replaces that with memory, reasoning, and velocity. It was built to:
- Remove Gareth as the bottleneck
- Codify expert-level PPC strategy into code
- Surface hidden revenue levers in real time
- Provide leverage across brands without headcount
- Impress executive stakeholders with clarity and control

---

## Current Scope

### ✅ Phase 0: Botswana PPC Opportunity Radar
- 12 diagnostic modules run on Botswana search data
- Outputs plain-English summary and opportunity table
- Demo-ready and fully local
- Proves value before permission is required

---

## Example Diagnostic Questions GUIDE Can Answer

- “Which clusters in Botswana have low impression share despite strong conversion rates?”
- “What search terms are triggering our ads but aren’t yet covered in keywords?”
- “Where are we wasting spend on poor-quality leads?”
- “Which landing pages are hurting performance and why?”
- “How does current spend align with the historical booking curve?”

---

## Output Files

- `/output/diagnostics_summary.md` → Narrative performance breakdown
- `/output/opportunity_matrix.csv` → Quantified recommendations by cluster
- `/notebook/jarvis_demo.ipynb` → Interactive diagnostic exploration

---

## How to Run It

1. Drop updated keyword/ads/booking data into `/data/`
2. Run `jarvis_runner.py` or load the notebook
3. Review generated markdown + CSV outputs
4. Use for meetings, planning, or daily strategy

---

## Who Should Use It

- Gareth (Digital Director) for strategic control
- Performance team for opportunity surfacing
- Execs (Keith, Hadley) for understanding scale & leverage
- Future: Jacada, Yellow Zebra as it expands

---

## What Comes Next

- Auto-daily refresh pipeline
- Streamlit UI for broader access
- Rollout to other countries and brands
- Full "Guide OS" with social, CRM, booking curve overlays
