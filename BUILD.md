---
title: "Guide — Build Roadmap"
type: build
area: ai
project: "Guide"
tags: [ai, guide, build]
status: active
updated: 2026-04-20
---
# Guide — Build Roadmap

## Starting Point

Guide follows a structured chunk-based build. Every chunk is a self-contained, verifiable unit. Execute in order.

---

## Adoption Sequence

The order in which people come online and Guide becomes part of their daily routine. Machine is the current gate.

| Step | What | Gate |
|------|------|------|
| 1 | Ubuntu migration + hardening (CHUNK-07 re-spec'd) | Machine arrives |
| 2 | Keith instance (CHUNK-15) | Ubuntu stable |
| 3 | Hadley instance (CHUNK-16) | Keith instance working |
| 4a | Daily Pulse → production (code exists — deploy to HP Z8, wire cron) | Ubuntu stable |
| 4b | LLM Checker → production (code exists — deploy to HP Z8, wire cron) | Ubuntu stable |
| 4c | HubSpot data → production (code exists — deploy to HP Z8, wire cron) | Ubuntu stable |
| 4d | Team adoption — training, embedding in daily workflow | 4a–4c live |
| 5 | Paperclip (CHUNK-11) | Exec instances stable + data flowing |
| 6 | Hermes pilot (CHUNK-18) | Paperclip stable |
| 7 | Next personal instances (Caro, Scott, Frances, Simon, Dean) | Pulled — not pushed |
| 8 | Brand agents ×3 (Phase 4) | Team leads ask for it |


---

## Phase Map

| Phase | Name | Status | Chunks | Key Agents |
|-------|------|--------|--------|------------|
| 0 | Foundation | **Mostly complete — hardening outstanding** | CHUNK-00 to CHUNK-08 | **Guide** (main) |
| 1 | Context Fix + Personal Instances | **Mostly complete — Paperclip + Keith outstanding** | CHUNK-09 to CHUNK-14 | Agent Factory, Channel Agents, **Paperclip**, Team Vault Architecture, Personal Instance Factory, **Nick Instance** |
| 2 | Post-Demo Team Ops | Not started | CHUNK-15 to CHUNK-18 | **Scribe**, Team Enablement, **Hermes Analyst**, Personal Instance Rollouts (Keith → Hadley → Scott → ...) |
| 3 | Data Layer | Not started | CHUNK-16 to CHUNK-18 | **Pipeline** |
| 4 | Brand Scale | Not started | CHUNK-19 to CHUNK-24 | SEO×3, Paid×3, HubSpot×3, Product×3, **Analyst**, **Finance** |
| 5 | Data Integrations | Not started | CHUNK-25 to CHUNK-29 | Pipeline enhanced |
| 6 | Intelligence Layer | Not started | CHUNK-30 to CHUNK-31 | **Apex**, **CapitalCore** |
| 7 | Productisation | Not started | CHUNK-32 to CHUNK-33 | Template export, docs |

---

## Phase 0 — Foundation

**Goal:** Guide machine is production-ready. First brief delivered. Security hardened.

| Chunk | Title | Status | Key Deliverables |
|-------|-------|--------|------------------|
| CHUNK-00 | Machine Setup | ✅ Complete | macOS config, SSH key auth, Tailscale, OneDrive, base packages |
| CHUNK-01 | Docker | ✅ Complete | Docker Desktop, container strategy, compose files |
| CHUNK-02 | OpenClaw Install | ✅ Complete | OpenClaw on Guide, gateway running, vault access confirmed |
| CHUNK-03 | LLM Configuration | ✅ Complete | Claude API, model routing (Sonnet/Haiku/Opus), cost controls |
| CHUNK-04 | Telegram Integration | ✅ Complete | @WildernessGuideBot live, Gareth DM working |
| CHUNK-05 | Guide Agent | ✅ Complete | Guide identity files (SOUL, AGENTS, USER, TOOLS), workspace committed to git |
| CHUNK-06 | Access Control | ✅ Complete | 4-tier access live. Telegram: Gareth + 4 operators (Danny, Richard, Laura, Matt) + group. Slack: socket mode, bi-directional (4 channels + `#guide-data-inbox` inbound). Laura added to operator DMs. WhatsApp deferred (SIM this weekend). Ashleigh joins 2026-05-11. |
| CHUNK-07 | Security & Hardening (macOS) | **Superseded by CHUNK-07c** for Z8 deployment | macOS-era spec — preserved for reference. Ubuntu hardening (UFW, fail2ban, SSH key-only, workspace perms) folded into CHUNK-07c. |
| CHUNK-07a | Google Integration | **Spec written — not yet executed** | `gog` CLI, OAuth for work Google account, Calendar + Gmail access, TOOLS.md updated. Needs `~/guide-core/` → `/srv/guide-core/` path adaptation. |
| CHUNK-07b | Bare Metal Migration (macOS) | ✅ Complete — **direction reversed for Z8** | OpenClaw migrated from Docker to native macOS launchd on Mac Mini. Z8 reverses this back to Docker (Linux native, no VM layer) — see ADR-023 and CHUNK-07c. |
| CHUNK-07c | Mac Mini → Z8 Ubuntu Migration | **Pending — current focus** | OpenClaw to Docker on Ubuntu + systemd. `/srv/` canonical paths. Channel-disabled cutover (ADR-024). Migration + Ubuntu hardening combined. |
| CHUNK-08 | Cron & Ops | Partial — paths need `/srv/` rewrite for Z8 | Several cron jobs running on Mac Mini. Host crontab migration to Z8 with `/srv/` paths is handled inside CHUNK-07c Task E5. Full spec re-execution deferred to post-migration revisit. |

---

## Phase 1 — Context Fix + Demo

**Goal:** Solve the shared context window problem. Each team channel has its own agent. Paperclip wired as control plane with at least Data + SEO agents live. Demo-ready for Keith & Nick in 3 weeks.

**Why this order:** The team is actively using Guide and all Slack sessions share the main agent's context window. Memory and context are being lost. Channel agents fix this immediately. Paperclip is pulled forward from Phase 6 (was CHUNK-29) because it is the centrepiece of the Keith & Nick demo — showing the governance layer, org chart, and heartbeat model.

| Chunk | Title | Status | Key Deliverables |
|-------|-------|--------|------------------|
| CHUNK-09 | Agent Factory | ✅ Complete | Base templates, `generate.sh`, workspace scaffold. Channel + personal instance types supported. |
| CHUNK-10 | Channel Agents | ✅ Complete | 5 agents live: Data, MarTech, SEO, Digital Product, HubSpot. All wired to Slack channels, tested. Wilderness-only. |
| CHUNK-11 | Paperclip | **Not started — deferred to post-Ubuntu** | Pulled forward for demo but not executed. Will build on Ubuntu machine once stable. |
| CHUNK-12 | Team Vault Architecture | ✅ Complete | `guide-vault/`, `guide-teams/`, `guide-shared/`, `guide-outputs/` created. Digital vault symlinked. |
| CHUNK-13 | Personal Instance Factory | ✅ Complete | Factory extended with personal instance support. `templates/personal/`, `generate.sh personal {name}`. |
| CHUNK-14 | Nick Instance | ✅ Complete (Nick only) | Nick instance live on @WildernessGuideNickBot. Keith deferred — moves to Phase 2 as CHUNK-15. |

**Sequence note:** CHUNK-14 shipped Nick only. Keith is now CHUNK-15 (Phase 2). Paperclip deferred to post-Ubuntu migration.

**Architecture references:** [[personal-instance-architecture]], [[team-vault-conventions]]

---

## Phase 2 — Post-Demo Team Ops + Personal Instance Rollouts

**Goal:** Remaining team ops agents. Hermes Analyst pilot. Personal instances rolled out one by one.

| Chunk | Title | Key Deliverables |
|-------|-------|------------------|
| CHUNK-15 | Keith Instance | CEO instance — broadest exec scope. Deferred from CHUNK-14. |
| CHUNK-16 | Hadley Instance | CCO instance — exec + digital team vault access |
| CHUNK-17 | Scribe Agent | Meeting transcription, note extraction, task routing to vault |
| CHUNK-18 | Hermes Analyst | Hermes installed (separate Docker container). Analyst Agent configured. Parallel pilot alongside OpenClaw for 6 weeks. |

**Personal instance rollouts continue:** Scott, Caro, Frances, Simon, Dean — one per chunk, following rollout order in [[personal-instance-architecture]]. Each is lightweight once the factory works.

**Note:** All Phase 2 work begins after the Ubuntu machine is set up and hardened (CHUNK-07 re-spec'd for Ubuntu + Docker).

**Note on Hermes:** Chunk spec to be written now (Architect) so it is ready to execute post-demo. Not demo-critical — do not let it distract from Phase 1.

---

## Phase 3 — Data Layer + Automation Plumbing

**Goal:** Data flowing through the atomic ETL pattern. Pipeline agent watching health. Huginn handling event-driven automation that doesn't need LLM intelligence.

| Chunk | Title | Key Deliverables |
|-------|-------|------------------|
| CHUNK-16 | Pipeline Agent | ETL orchestration, data freshness monitoring, self-healing restarts |
| CHUNK-17 | Data Quality | Validation rules, anomaly detection on ingested data, alerting |
| CHUNK-18 | MVP ETL Process | End-to-end: Python pulls → markdown summary → Guide interprets → report → person |
| CHUNK-19 | Huginn | Self-hosted event automation ([huginn/huginn](https://github.com/huginn/huginn)). Webhook routing, data source monitoring, scheduled triggers, non-LLM pipeline orchestration. Replaces custom Python glue in `guide-engine/`. |

**Huginn rationale:** Guide's LLM agents handle intelligence — interpretation, briefs, recommendations. Huginn handles the plumbing — watching for events, transforming data, routing webhooks, triggering pipelines. Self-hosted Zapier with no per-action cost, full control, and 30+ integrations (Slack, Telegram, JIRA, RSS, webhooks, SMTP, etc.). See [[00_Guide-Project-Brief#Huginn]] for detail.

---

## Phase 4 — Brand Scale

**Goal:** Jacada and Yellow Zebra added. Full ×3 agent coverage via factory. WS channel agents from Phase 1 expanded to JC + YZ variants.

**Factory note:** WS variants for SEO, HubSpot, and Product already exist from CHUNK-10. Phase 4 adds JC + YZ role configs and generates those workspaces — each chunk is a thin factory run, not a ground-up build. Paid agents are all-new in Phase 4 (not in Phase 1 scope).

| Chunk | Title | Key Deliverables |
|-------|-------|------------------|
| CHUNK-19 | SEO Agents — JC + YZ | Add `seo-jc.env` + `seo-yz.env` role configs, generate workspaces, wire to JC + YZ Slack channels. (WS SEO agent already live from CHUNK-10) |
| CHUNK-20 | Paid Agents ×3 | New agents — PPC/Social/Programmatic. Add `paid-ws.env`, `paid-jc.env`, `paid-yz.env`, generate, wire. All three are new (Paid not in Phase 1 scope) |
| CHUNK-21 | HubSpot Agents — JC + YZ | Add `hubspot-jc.env` + `hubspot-yz.env`, generate, wire. (WS HubSpot agent already live from CHUNK-10) |
| CHUNK-22 | Product Agents — JC + YZ | Add `product-jc.env` + `product-yz.env`, generate, wire. (WS Product agent already live from CHUNK-10) |
| CHUNK-23 | Analyst Agent | Cross-domain analysis, ad hoc investigation (shared). Hermes decision gate: if Hermes pilot compelling, implement as Hermes agent. |
| CHUNK-24 | Finance Agent | Lead volume, sales pipeline, media spend (shared, cross-brand) |

---

## Phase 5 — Data Integrations

**Goal:** All data sources connected. Full data coverage across paid, organic, CRM.

| Chunk | Title | Key Deliverables |
|-------|-------|------------------|
| CHUNK-25 | HubSpot Integration | HubSpot API — contacts, deals, pipeline stages, booking attribution (×3 brands) |
| CHUNK-26 | Google Ads Integration | Google Ads API — all 3 brands, campaign/keyword/ad group data |
| CHUNK-27 | GA4 + BigQuery | GA4 via BigQuery export — conversion funnels, traffic quality |
| CHUNK-28 | Meta + Instagram | Meta Marketing API — social paid + organic across brands |
| CHUNK-29 | Bing + DV360 | Bing Ads API + DV360 API — complete paid media coverage |

---

## Phase 6 — Intelligence Layer

**Goal:** Apex and CapitalCore operational across all brands. Both require live data from Phase 5 to function.

| Chunk | Title | Key Deliverables |
|-------|-------|------------------|
| CHUNK-30 | Apex Agent | PPC diagnostics, anomaly detection, competition hunting — cross-brand |
| CHUNK-31 | CapitalCore Agent | Yield curves, budget pacing, capital allocation reports — cross-brand |

---

## Phase 7 — Productisation

**Goal:** Architecture documented and exportable.

| Chunk | Title | Key Deliverables |
|-------|-------|------------------|
| CHUNK-32 | Template Export | Guide architecture as a deployable template (replicable pattern) |
| CHUNK-33 | Documentation | Full system docs, operator runbook, architecture decision records |

---

## Future — Dev Team

Full dev team (5 agents: @growth, @dev, @qa, @db, @creative). Built once Guide is running and monitored.

---

## Conventions

All chunks follow `BUILD/DEV-CHUNKS/_CONVENTIONS.md`.

## Build Principles

1. **Numbering starts at 00** — Guide is greenfield
2. **Agent factory before channel agents** — CHUNK-09 must exist before CHUNK-10 can spin up agents
3. **Single-brand first** — Channel agents (Phase 1) are Wilderness-only. Jacada + YZ added in Phase 4 via factory
4. **Paperclip pulled forward** — Was Phase 5/CHUNK-29. Now Phase 1/CHUNK-11. Demo driver for Keith & Nick
5. **Hermes as parallel pilot** — Not a migration. Analyst Agent runs alongside OpenClaw for 6 weeks. Decision gate at CHUNK-23
6. **Data integrations late** — Channel agents and governance layer deliver value before any API is connected
7. **Intelligence layer last** — Apex and CapitalCore need live data (Phase 5) to function. Don't build the engine before the fuel line
8. **Ubuntu + Docker target** — new machine arriving week of 2026-05-12 runs Ubuntu with Docker. CHUNK-07 hardening spec must be re-written for this environment (ufw not macOS firewall, systemd/Docker Compose not launchd, Docker bind mounts with :ro for vault isolation). macOS bare metal is temporary.

---

*Updated: 2026-05-12 — Reflected actual build state. Phase 0 mostly complete (hardening deferred). Phase 1 mostly complete (Paperclip + Keith deferred). Keith moved to CHUNK-15 (Phase 2). Ubuntu machine arriving — pausing dev until machine is stable. Hardening spec to be re-written for Ubuntu + Docker.*
