---
title: "Guide — Integrations"
type: integrations
area: ai
project: "Guide"
tags: [ai, guide, integrations]
status: active
updated: 2026-04-05
---
# Guide — Integrations

## Communication Channels

| Channel | Method | Use | Agent(s) | Phase | Status |
|---------|--------|-----|----------|-------|--------|
| **Telegram** | Bot API (webhook) | Gareth DM + operator DMs + team group | Guide, all agents | 0 | **Live** |
| **WhatsApp** | Baileys (QR link, dedicated SIM) | Executive outputs (Hadley, Keith, Nick) | Briefing, Guide | 0 | Deferred — SIM this weekend |
| **Slack** | Bolt + Socket Mode (bi-directional) | Team channels — DMs, @mentions, briefs, inbound | All agents | 0 | **Live** (partial — 4 channels + 1 inbound) |

### Slack Detail

OpenClaw uses **Slack Bolt** with **Socket Mode** (persistent WebSocket — no public URL required). Fully bi-directional: users can DM the bot, @mention it in channels, react to messages. Bot can post, stream text, upload files, add reactions.

**Required:** Bot token (`xoxb-`), App token (`xapp-` with `connections:write`). No signing secret needed for Socket Mode.

## Data Sources — Priority 1 (Foundation)

| Source | Use Case | Agent(s) | Phase | Status |
|--------|----------|----------|-------|--------|
| **OneDrive** | File access, shared documents, team PARA structures | Guide, all agents | 0 | Planned |
| **GA4** | Conversion funnels, traffic quality, engagement metrics | Pipeline, Analyst | 4 | Planned |
| **BigQuery** | Data warehouse, cross-source analysis | Pipeline, Analyst | 4 | Planned |

## Data Sources — Priority 2 (Media & CRM)

| Source | Use Case | Agent(s) | Phase | Status |
|--------|----------|----------|-------|--------|
| **Google Ads** | CPA/CPL tracking, yield curves, budget pacing (×3 brands) | Pipeline, Paid, CapitalCore | 4 | Planned |
| **HubSpot** | Lead scoring, pipeline velocity, booking attribution (×3 brands) | Pipeline, HubSpot, CapitalCore | 4 | Planned |

## Data Sources — Priority 3 (Extended Media)

| Source | Use Case | Agent(s) | Phase | Status |
|--------|----------|----------|-------|--------|
| **Meta** | Social paid performance, audience insights (×3 brands) | Pipeline, Paid | 4 | Planned |
| **Instagram** | Social organic + paid performance (×3 brands) | Pipeline, Paid | 4 | Planned |
| **Bing** | PPC diagnostics for Bing campaigns | Pipeline, Paid | 4 | Planned |
| **DV360** | Display/programmatic performance | Pipeline, Paid | 4 | Planned |

## Data Sources — Priority 4 (Operational)

| Source | Use Case | Agent(s) | Phase | Status |
|--------|----------|----------|-------|--------|
| **Booking system** | Camp bookings, lead times, cancellations, booking window trends | Pipeline, CapitalCore, Finance | 5 | Source identified. Excel file available for schema analysis — scope before writing integration chunk. |
| **Camp occupancy data** | Occupancy by camp by season by brand | Pipeline, CapitalCore, Finance | 5 | Source identified alongside booking system. Structure TBC. |

## Internal Systems

| System | Use Case | Agent(s) | Phase | Status |
|--------|----------|----------|-------|--------|
| **OpenClaw** | Agent runtime + gateway | All | 0 | **Live** |
| **Claude API** | LLM backbone (Sonnet/Haiku/Opus) | All | 0 | **Live** |
| **Obsidian vault** (`Wilderness-Guide`) | Guide operational vault — read/write day to day | Guide | 0 | **Live** |
| **OneDrive** | Shared team documents (read-only mount) | Guide | 0 | **Live** (mounted, not yet used) |
| **Tailscale** | Remote access to Guide machine | — | 0 | **Live** — `guide.tailfbf66e.ts.net` via `tailscale serve` |
| **Brave Search** | Web search capability | Guide | 0 | Planned |

## Multi-Brand Coverage

Each data integration must handle three brands:

| Brand | Google Ads | HubSpot | GA4 | Meta | Bing | DV360 |
|-------|-----------|---------|-----|------|------|-------|
| **Wilderness** | Yes | Yes | Yes | Yes | Yes | Yes |
| **Jacada** | Yes | Yes | Yes | Yes | TBC | TBC |
| **Yellow Zebra** | Yes | Yes | Yes | Yes | TBC | TBC |

---

*Updated: 2026-04-16*
