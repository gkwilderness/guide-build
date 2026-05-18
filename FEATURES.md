---
title: "Guide — Features"
type: features
area: ai
project: "Guide"
tags: [ai, guide, features]
status: active
updated: 2026-04-14
---
# Guide — Features

## Live Features

| Feature | Agent | Live Since |
|---------|-------|------------|
| OpenClaw runtime on Guide machine | Guide | 2026-04-13 |
| Claude API (Sonnet/Haiku/Opus routing) | Guide | 2026-04-13 |
| Telegram bot — Gareth DM + team lead DMs | Guide | 2026-04-13 |
| Telegram group (team leads) | Guide | 2026-04-14 |
| Slack — socket mode, bi-directional (DM + channel post + inbound) | Guide | 2026-04-14 |
| Slack inbound — `#guide-data-inbox` channel observation | Guide | 2026-04-16 |
| Guide identity (SOUL/IDENTITY/USER/AGENTS/TOOLS) | Guide | 2026-04-13 |
| 4-tier access control | Guide | 2026-04-14 |
| Operator DM access (Telegram) — Danny, Richard, Laura, Matt | Guide | 2026-04-14 |
| Operator DM access (Slack) — Gareth, Laura, Danny, Richard | Guide | 2026-04-16 |
| Polite DM access (Slack) — 9 digital team members | Guide | 2026-04-16 |
| Tailscale remote access — `guide.tailfbf66e.ts.net` → gateway | Guide | 2026-04-15 |
| Strategic context loading (CEO Commitments file) | Guide | 2026-04-16 |
| Autonomy by context rules (diagnose→discuss→execute in group chats) | Guide | 2026-04-16 |

---

## Planned Features

### Phase 0 — Foundation (in progress)

| Feature | Agent | Status |
|---------|-------|--------|
| Slack inbound — SEO channel (`#seo-guide`) | Guide | Channel ID confirmed `C0ATXQ8MDS5` — wire in CHUNK-10 |
| Slack inbound — remaining team channels | Guide | All IDs confirmed 2026-04-20 — wire in CHUNK-10 |
| Production security hardening | Guide | CHUNK-07 — spec written, not yet executed |
| Cron schedule (7 jobs) | Guide | CHUNK-08 — deferred until data layer ready |
| WhatsApp Executive tier | Guide | Deferred — SIM purchase this weekend |

### Phase 1 — Context Fix + Demo + Personal Instances

| Feature | Agent | Status |
|---------|-------|--------|
| Agent factory (template + role config → workspace) | — | CHUNK-09 complete |
| Channel agents (5 agents, isolated context windows) | Data, MarTech, SEO, Product, HubSpot | CHUNK-10 in progress |
| Paperclip governance POC | — | CHUNK-11 planned |
| Team vault architecture (`guide-vault/`, `guide-teams/`, `guide-shared/`, `guide-outputs/`) | — | CHUNK-12 planned |
| Personal instance factory (roster.json → generate.sh → workspace) | — | CHUNK-13 planned |
| Personal instances — per-person Guide with dedicated Telegram bot | personal-nick (first) | CHUNK-14 planned |
| Personal instances — exec tier (Nick, Hadley, Keith) | personal-hadley, personal-keith | CHUNK-15-16 planned |
| Personal instances — domain tier (Scott, Caro, Frances, Simon, Dean) | 5 instances | Planned after exec tier |

### Phase 2 — Data Layer

| Feature | Agent | Status |
|---------|-------|--------|
| ETL orchestration + data freshness monitoring | Pipeline | Planned |
| Data quality validation + anomaly alerting | Pipeline | Planned |
| MVP atomic ETL: Python → markdown → Guide → report | Pipeline | Planned |

### Phase 3 — Team Scale

| Feature | Agent | Status |
|---------|-------|--------|
| SEO intelligence (×3 brands) | SEO-WS/JC/YZ | Planned |
| Paid media intelligence (×3 brands) | Paid-WS/JC/YZ | Planned |
| CRM/HubSpot intelligence (×3 brands) | HubSpot-WS/JC/YZ | Planned |
| Digital product intelligence (×3 brands) | Product-WS/JC/YZ | Planned |
| Cross-domain analysis | Analyst | Planned |
| Financial reporting | Finance | Planned |

### Phase 4 — Data Integrations

| Feature | Agent | Status |
|---------|-------|--------|
| HubSpot API (×3 brands) | Pipeline | Planned |
| Google Ads API (×3 brands) | Pipeline | Planned |
| GA4 via BigQuery | Pipeline | Planned |
| Meta Marketing API | Pipeline | Planned |
| Bing Ads + DV360 API | Pipeline | Planned |

### Phase 5 — Productisation

| Feature | Agent | Status |
|---------|-------|--------|
| PPC diagnostics + competition hunting | Apex | Planned |
| Capital allocation + yield curves | CapitalCore | Planned |
| Paperclip orchestration evaluation | — | Planned |
| Template export (replicable pattern) | — | Planned |

### Infrastructure — Local LLM (Phase 3, alongside Ubuntu hardening)

| Feature | Agent | Status |
|---------|-------|--------|
| Ollama + CUDA backend on HP Z8 (RTX 3090) | Infrastructure | Planned — CHUNK-07 or new CHUNK-07c |
| Local model: Qwen 2.5 32B or Llama 3.3 34B Q4 | Infrastructure | Planned — 34B fits entirely in 24GB VRAM |
| Model routing: local tier for sensitive data | All agents | Planned |

---

## Agent Roster

See [[00_Guide-Project-Brief#Agent Roster]] for the full agent roster with priority and phase assignments.

**Summary:** 6 shared + 12 brand-specific (4 templates × 3 brands) + 2 cross-brand + 8 personal instances = **28 agents**.

**Master roster:** `Specs/guide-roster.json` — single source of truth for all persons, team vaults, channel agents, API keys, and deployment gates.

---

*Updated: 2026-04-29*
