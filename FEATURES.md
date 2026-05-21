---
title: "Guide — Features"
type: features
area: ai
project: "Guide"
tags: [ai, guide, features]
status: active
updated: 2026-05-21
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
| Z8 Ubuntu migration — OpenClaw in Docker, systemd-managed | Infrastructure | 2026-05-19 |
| Agent factory — channel + personal instance types (`generate.sh`) | — | 2026-04-30 |
| Channel agents ×5 (data, martech, seo, product, hubspot) — isolated context per Slack channel | Data/MarTech/SEO/Product/HubSpot | 2026-04-30 |
| Safari knowledge agent — Travel Designers via `#guide-sales` | Safari | 2026-05 |
| Team vault architecture — `/srv/guide-vaults/` (personal/, shared/, teams/) | Infrastructure | 2026-04-30 |
| Digital team vault — live via Obsidian Sync | — | 2026-05-19 |
| Exco team vault — live with content | — | 2026-05 |
| Shared vault — populated (brand, camps, countries, KB, sales data) | — | 2026-05 |
| Personal instance factory (roster.json → generate.sh → workspace) | — | 2026-04-30 |
| Personal instance: Nick (`@WildernessGuideNickBot`) | personal-nick | 2026-04-30 |
| Personal instances: exec tier built — Keith, Hadley, Caro, Dean, Julian (awaiting bot tokens) | personal-* | 2026-05-20 |
| Cross-agent session send (`tools.sessions.visibility: "all"`) | Infrastructure | 2026-05-14 |
| HubSpot connector skill + `hs_query.py` | hubspot | 2026-05-19 |
| 19 skills on disk (`/srv/openclaw/skills/`) | — | 2026-05-20 |
| Huginn automation platform — Docker, systemd, Tailscale port 3001 | Infrastructure | 2026-05-19 |
| Ollama local LLM inference — RTX 3090, 4 models (qwen3:30b-a3b primary) | Infrastructure | 2026-05-21 |
| Host-level cron — backup (04:00), Google Ads API (08:00), LLM checker (05:00) | Infrastructure | 2026-05 |

---

## Planned Features

### Phase 0 — Foundation (complete)

| Feature | Agent | Status |
|---------|-------|--------|
| Slack inbound — all team channels | Guide | ✅ Live — 20 channels configured in openclaw.json |
| Production security hardening (Ubuntu/Z8) | Guide | ✅ CHUNK-07c complete 2026-05-19 |
| Google integration (Calendar + Gmail) | Guide | CHUNK-07a — spec written, not yet executed |
| Cron schedule | Guide | CHUNK-08 partial — host cron has backup/ads/LLM jobs; OpenClaw cron jobs not yet configured |
| WhatsApp Executive tier | Guide | Deferred — SIM purchase pending |

### Phase 1 — Context Fix + Demo + Personal Instances (mostly complete)

| Feature | Agent | Status |
|---------|-------|--------|
| Agent factory (template + role config → workspace) | — | ✅ CHUNK-09 complete |
| Channel agents ×5 (isolated context windows) | Data, MarTech, SEO, Product, HubSpot | ✅ CHUNK-10 complete |
| Safari knowledge agent | Safari | ✅ Live — `#guide-sales` |
| Paperclip governance POC | — | ⚙️ CHUNK-11 — installation in progress 2026-05-21 |
| Team vault architecture | — | ✅ CHUNK-12 complete — digital + exco live, shared populated |
| Personal instance factory | — | ✅ CHUNK-13 complete |
| Personal instance: Nick | personal-nick | ✅ CHUNK-14 complete |
| Personal instances: Keith | personal-keith | CHUNK-15 — built, awaiting bot token |
| Personal instances: Hadley, Caro, Dean, Julian | personal-* | Built, awaiting bot tokens |
| Personal instances — domain tier (Scott, Frances, Simon) | — | Planned |

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

### Infrastructure — Local LLM

| Feature | Agent | Status |
|---------|-------|--------|
| Ollama + CUDA backend on HP Z8 (RTX 3090) | Infrastructure | ✅ Live — `ollama.service`, CUDA confirmed |
| `tinyllama:latest` — smoke test model | Infrastructure | ✅ Installed |
| `gemma3:27b-it-q4_K_M` — summarisation (no tool calling) | Infrastructure | ✅ Installed |
| `qwen3:14b` — lightweight agentic (tools + thinking) | Infrastructure | ✅ Installed |
| `qwen3:30b-a3b` — primary agentic model (tools + thinking) | Infrastructure | ✅ Installed |
| Model routing: local tier for sensitive data | All agents | Planned — requires OpenClaw model config |
| Huginn automation platform | Infrastructure | ✅ Live — Docker, systemd, Tailscale port 3001 |
| Hermes agent platform | Infrastructure | Prepared — not yet running |
| Open WebUI | Infrastructure | Prepared — not yet running |
| Paperclip orchestration | Infrastructure | ⚙️ Installing (2026-05-21) |

---

## Agent Roster

See [[00_Guide-Project-Brief#Agent Roster]] for the full agent roster with priority and phase assignments.

**Summary:** 6 shared + 12 brand-specific (4 templates × 3 brands) + 2 cross-brand + 8 personal instances = **28 agents**.

**Master roster:** `Specs/guide-roster.json` — single source of truth for all persons, team vaults, channel agents, API keys, and deployment gates.

---

*Updated: 2026-04-29*
