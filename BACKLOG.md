---
title: "Guide — Backlog"
type: backlog
area: ai
project: "Guide"
tags: [ai, guide, backlog]
status: active
updated: 2026-04-16
---
# Guide — Backlog

Non-chunk work items. Pull-based — items move up when needed, not when added.

---

## Priority Tiers

### Fire — Slack channel observation (Guide as live observer)

Inbound now live on `#guide-data-inbox`. Expanding to team channels next. SEO channel pending Richard.

- [ ] **Decision: confirm which channels Guide listens to beyond `#guide-data-inbox`** — @gareth
- [ ] Engineer: wire SEO Slack channel into `openclaw.json` once Richard provides name and ID — also update BOOTSTRAP.md and TOOLS.md
- [x] Engineer: collect remaining team Slack IDs — all 5 channel IDs confirmed 2026-04-20 ✅
- [ ] Engineer: add Guide to Laura Sinclair's Slack channels once identified
- [ ] Feature: per-channel weekly summary — what was discussed, decisions made, actions named
- [ ] Feature: blocker and decision flagging — surface to `#guide-ops` or Gareth DM
- [ ] Feature: cross-reference channel activity against weekly goals / backlogs

---

### Fire — Slack DM access control (ADR-015 / ADR-016)

Outbound DMs are currently ungated — Guide can reach anyone. The first implementation attempt (adding `dmOutboundAllowlist`/`dmPoliteList` to `openclaw.json`) caused a crash-loop on 2026-04-17 — those keys don't exist in the schema. Rolled back. ADR-016 documents the revised approach. See DOCUMENTATION.md "Known Risks" and DECISIONS.md ADR-016 for full research findings.

- [x] **Decision: confirm polite-mode list** — digital team. Danny + Richard upgraded to full. ✅ 2026-04-16
- [x] Architect: define polite-mode prompt template — what Guide says when redirecting ✅ 2026-04-16 → [[Prompts/PROMPT_polite-mode]]
- [x] **Engineer: check if `message:sent` hooks are available** — confirmed closed 2026-04-17. Hooks are inbound-only. No outbound hook exists. (ADR-016)
- [ ] **Engineer: pull Slack tool identifiers from `tools.byProvider`** — need exact IDs to design the deny list; report via `→architect.md` signal (ADR-016)
- [ ] Architect: spec the custom plugin once tool IDs are known — design deny list + plugin wrapper for outbound DM gating (ADR-016, Option 2)
- [ ] Engineer: implement tool-deny + custom plugin for outbound allowlist and polite mode (ADR-016, Option 2) — sidecar config at `~/.openclaw/outbound-policy.json`, never in `openclaw.json`

---

### Fire — Phase 1: Context Fix + Demo (3 weeks to Keith & Nick)

Build order: CHUNK-09 → CHUNK-10 → CHUNK-11 → CHUNK-12. CHUNK-09 blocks everything else.

- [ ] **CHUNK-09: Agent Factory** — Engineer. Builds the scaffold for all channel agents.
- [ ] **CHUNK-10: Channel Agents** — Engineer. Spin up in order: Data, Martech, SEO, Digital Product, HubSpot. Each wired to its Slack channel. Wilderness only.
- [ ] **CHUNK-11: Paperclip** — Engineer. Install (Docker), create Wilderness Group Digital company, wire Data + SEO agents as departments, one heartbeat live. Demo-ready POC.
- [ ] **CHUNK-12: Briefing Agent** — Engineer. Supports demo output layer.
- [x] Architect: write CHUNK-09 spec ✅ 2026-04-20
- [x] Architect: write CHUNK-10 spec ✅ 2026-04-20
- [x] Architect: write CHUNK-11 spec ✅ 2026-04-20
- [ ] Architect: write CHUNK-12 spec — Briefing Agent
- [ ] Architect: write CHUNK-15 (Hermes Analyst) spec — write now, execute post-demo

---

### Fire — Phase 0 completion

- [ ] WhatsApp: buy prepaid SIM or eSIM — @gareth (this weekend)
- [ ] WhatsApp: register number + configure Baileys plugin when SIM ready — Engineer
- [ ] Collect executive phone numbers: Hadley, Keith, Nick (E.164 format) — @gareth
- [ ] CHUNK-07: Security & Hardening — spec written, not yet executed — Engineer (run before CHUNK-09)

### Yellow — Active

- [ ] **Jules — sales reports** — Jules wants sales reports via Guide. Define format, frequency, and data sources. (2026-05-06)
- [ ] **Build `page-watcher` skill** — lightweight page change monitor. Python script: fetch URL, hash content, compare to stored hash, alert on change. Use cases for Guide: competitor safari operator pages, Google Ads policy updates, LLM provider announcements, Wilderness/Jacada/YZ site change detection. Note: `monitor` skill on clawhub is flagged suspicious — build from scratch.
- [ ] **RSS/news feed skill for Briefing agent** — install `rss-reader` (`clawhub install rss-reader`). Daily industry intelligence for Wilderness team: safari industry, luxury travel news, competitor activity, press mentions. Delivered via Briefing agent. Also check `blogwatcher` and `openclaw-feeds`.
- [ ] **HTML → Markdown converter** — same pattern as the PDF/Marker pipeline. Convert HTML docs (brand pages, saved articles, web content) to clean markdown for vault ingestion and agent context. Tool: `html2text` or `markdownify` (Python). Two-stage: strip/convert → Claude cleanup for frontmatter + vault naming. Set up on Scout or Guide machine.
- [ ] **HTML fetch** — fetch a live URL and return clean HTML or markdown. Use case: agent-triggered web content ingestion (brand pages, competitor pages, news, docs). Wraps `web_fetch` or a headless fetch script. Input: URL. Output: markdown file in vault.
- [ ] **Scott — Safari Knowledge Base** — get Word doc from Scott, convert to markdown (Marker), add to `guide-shared/`. POC for Keith: natural language queries against the KB. Connects to Caro (Reservations) and retail sales agent.
- [ ] **Caro — dedicated Guide agent** — Wilderness Reservations. Spec and build. Collect Telegram/Slack details. Define scope and vault access. (Caro wants Guide — 2026-05-06)
- [ ] Ashleigh Telegram chat ID — collect when she joins 2026-05-11 — @gareth
- [ ] Add Ashleigh binding to `openclaw.json` once ID received — Engineer
- [ ] Gareth: review `~/Obsidian/Wilderness-Guide/10-Infra/Data/CLAUDE.md` — PIE process framework for Data channel POC, needs sign-off before wiring further
- [ ] SOUL.md: clarify closing register — "Sharp" for casual, "Fambai zvakanaka" reserved for brief sign-offs only

### Yellow — CHUNK-08 (Cron & Ops) — deferred, waiting on data layer

- [ ] Morning brief cron: TODAY.md delivered to Telegram at 08:00 Mon–Fri — Engineer
- [ ] Full cron schedule (7 jobs), health checks, monitoring — Engineer
- [ ] Daily cron for Laura Sinclair Slack activity summary — confirm channel IDs and timing with Laura first
- [ ] Phase 1 review gate: 2026-05-01 — sub-agents and data pipeline scope decision

### White — Integrations

- [ ] **CHUNK-07a: Google Integration** — spec written, ready to execute after CHUNK-07. Two @gareth pre-tasks before Engineer starts:
  - [ ] Create new Google Cloud project (`guide-XXXXXX`), enable Calendar + Gmail APIs, download `client_secret.json` → place at `~/.openclaw/credentials/google-client_secret.json` on Guide
  - [ ] Create free Gmail address for Guide (e.g. `wilderness.guide@gmail.com`) — confirm address, update `[GUIDE_GMAIL_ADDRESS]` placeholder in chunk before running

### White — Before Phase 4

- [ ] Document brand account IDs: Google Ads, HubSpot, GA4, Meta per brand — see `__CONFIG/GUIDE.md`
- [ ] Confirm API access per brand per source
- [ ] Create service account credentials where needed
- [ ] Evaluate Paperclip maturity (revisit monthly from Phase 3)

---

## From Daily Note — 2026-05-15

- [ ] guide-build — cleanup; split agents with own API keys; ready for new machine
- [ ] Build Hadley her own Guide Agent
- [ ] Hadley: vault/docs access
- [ ] Team leaders Guide intro — do by team
- [ ] Individual Guide workshops — check how people are doing
- [ ] Guide architecture
- [ ] Go live with new machine
- [ ] Morning briefs:
	- [ ] Daily pulse with HubSpot
	- [ ] Weekly Website — break out GA4 & chunk into parts per day
	- [ ] LLM checker
	- [ ] Sales pulse

---

## Completed

- [x] Create `guide-core` GitHub repo (private) — @gareth ✅ 2026-04-13
- [x] Create `guide-engine` GitHub repo (private) — @gareth ✅ 2026-04-13
- [x] Confirm Anthropic API key has sufficient credits — @gareth ✅ 2026-04-14
- [x] Create Telegram bot via @BotFather (`@WildernessGuideBot`) — @gareth ✅ 2026-04-13
- [x] Collect team lead Telegram chat IDs: Danny, Richard, Laura — @gareth ✅ 2026-04-14
- [x] Create "Guide — Team Leads" Telegram group, note group ID (`-5236130644`) — @gareth ✅ 2026-04-14
- [x] Create Slack app at api.slack.com/apps — @gareth ✅ 2026-04-13
- [x] Create Slack channels: `#guide-briefs`, `#guide-ops`, `#guide-alerts` — @gareth ✅ 2026-04-13
- [x] Fill in values in `__CONFIG/GUIDE.md` — @gareth ✅ 2026-04-14 (WhatsApp/exec numbers deferred)
- [x] Matt Wylie (8265788167) — Telegram operator access added ✅ 2026-04-14
- [x] Slack `#wilderness-digital-team` (C0987SGJ9NJ) — added as post-only channel ✅ 2026-04-14
- [x] Slack `#guide-data-inbox` (C0ASP8ZD495) — added as inbound channel (read + post) ✅ 2026-04-16
- [x] Laura Sinclair — added to Slack operator DM access (`allowFrom` + DM binding) ✅ 2026-04-16
- [x] Slack member IDs added: Maria (U068JTPF1UL), Fay (U095N3ADT6W), Laura (U08UX404HDK) ✅ 2026-04-16
- [x] AGENTS.md — strategic context loading (CEO Commitments file) added ✅ 2026-04-16
- [x] AGENTS.md — autonomy by context rules (diagnose→discuss→execute) added ✅ 2026-04-16
- [x] Tailscale — configured on Guide machine, `tailscale serve` → gateway (100.72.42.1:18789) ✅ 2026-04-15
- [x] Wilderness personal vault removed from Guide's scope (vault access now `Wilderness-Guide` only) ✅ 2026-04-15
- [x] OpenClaw TUI/dashboard — accessible via Tailscale (`https://guide.tailfbf66e.ts.net`). `gateway.bind` set to "lan", `controlUi.allowedOrigins` updated, device paired via CLI ✅ 2026-04-16

---

*Updated: 2026-04-17 — ADR-016 outbound DM enforcement; crash-loop incident logged*
