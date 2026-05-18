---
title: "CapitalCore vs Apex Boundaries"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# CapitalCore vs Apex Boundaries

## Purpose
Define the operating boundaries between CapitalCore (War Room) and Apex (Battlefield) to ensure clarity of scope, architecture, and execution.

---

## CapitalCore (War Room)
**Role:** Guardrails and allocation discipline across businesses.

- Audience: PE stakeholders, C-suite, senior operators  
- Scope: Budget flows, pacing, capital efficiency  
- Core Functions:
  1. **Spend Velocity & Pacing Monitor**  
     - Track daily actual vs plan vs forecast.  
     - Alert on overshoot/undershoot trends.  

  2. **Market Allocation Guardrails**  
     - Monitor US vs Non-US vs Destination allocation.  
     - Enforce caps (e.g., Non-US Generics ≤ 25%).  

  3. **Bid Strategy Drift Detection**  
     - Flag campaigns where tCPA / Max Conv diverges from efficiency thresholds.  
     - Recommend budget reallocation or target reset.  

  4. **Rule/Automation Audit**  
     - Parse change history.  
     - Attribute budget increases to rules vs manual changes.  
     - Quantify automation dependency.  

  5. **Budget-to-Outcome Map**  
     - Tie spend to conversions/lead quality by campaign cluster.  
     - Surface misallocation (spend velocity ≠ booking velocity).  

---

## Apex (Battlefield)
**Role:** Waste-hunting and operator diagnostics in the trenches.

- Audience: PPC managers, performance team  
- Scope: Keywords, queries, intent, landing pages  
- Core Functions:
  - Keyword clustering & intent scoring  
  - Intent-costing → SQR cleaning → negative keyword sets  
  - Landing page match audits  
  - Funnel diagnostics (CVR drops, booking curve overlays)  
  - Geo/market query leakage (Kenya/South Africa terms in Non-US)  

---

## Operating Principle
- **CapitalCore = Protect the firebreak**  
  → Budgets stay disciplined, rules don’t creep, markets don’t drift.  

- **Apex = Hunt the waste**  
  → Bad queries, poor match types, weak landing page relevance, SQRs automated at scale.  

Both systems run across **all three businesses (Wilderness, Jacada, Yellow Zebra)** but at different levels of the stack.
