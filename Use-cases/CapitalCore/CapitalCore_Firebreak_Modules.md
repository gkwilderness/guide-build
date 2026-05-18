---
title: "CapitalCore_Firebreak_Modules"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# CapitalCore Firebreak Modules

## Objective
Architect the high-leverage operator guardrails needed to stop budget creep, enforce market allocation, and neutralise automation bloat before it compounds.

---

## Module 1: Spend Velocity & Pacing Monitor
- Daily actual vs forecast vs plan.  
- Outputs:
  - "At current run-rate, account overspends by $X → cut campaigns Y by Z%."  
- Runs across all businesses.

---

## Module 2: Market Allocation Guardrails
- Split budgets into US / Non-US / Destination buckets.  
- Enforce target caps (e.g., Non-US ≤ 25%).  
- Outputs:
  - "Non-US Generics = 62% of budget vs 25% target → restrict."

---

## Module 3: Bid Strategy Drift Detector
- Watch tCPA / Max Conv campaigns.  
- Detect when CPA > threshold or conversion rate dips.  
- Outputs:
  - "WS_UK_SEA_Generic running 38% above blended CPA → recommend target reset or budget cut."

---

## Module 4: Rule & Automation Audit
- Parse change history logs daily.  
- Attribute budget changes to **rules vs operator.**  
- Outputs:
  - "83% of yesterday’s budget increases were automated."

---

## Module 5: Budget-to-Outcome Map
- Tie budget allocations to conversion velocity.  
- Map lead quality & booking progression.  
- Outputs:
  - "Botswana Generics consuming $65k/month with weak funnel progression → reallocate."

---

## Positioning
- These 5 modules = **the firebreak.**  
- They live in CapitalCore, not Apex.  
- They ensure budget & velocity stay on-rails before Apex starts keyword/intent optimisation.
