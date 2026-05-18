---
title: "Guide — Project Brief"
type: project-brief
area: ai
project: "Guide"
tags: [ai, guide, wilderness, build]
status: active
updated: 2026-04-05
---

# Guide — Project Brief

## Mission

Guide is the AI cognitive layer for Wilderness Safaris Group — the always-on digital chief of staff for a three-brand luxury travel group (Wilderness, Jacada, Yellow Zebra). It manages commercial intelligence, team operations, and automation.

Guide serves a **team**, not an individual. It operates through Telegram (Gareth & leaders), WhatsApp (executives), and Slack (team), runs on its own dedicated machine, and has access to the Wilderness vault via OneDrive. Its agents surface intelligence, automate diagnostics, generate briefs, and execute data pipelines — so the human operators focus on decisions, not data wrangling.

**One sentence:** Guide is the always-on digital chief of staff for Wilderness Group's digital and growth function.

---

## Design Philosophy

Five principles that make Guide maintainable at 20+ agents:

1. **Abstracted vault structure** — agents don't know where files live, only what they can access. The filesystem is the access control layer.
2. **Composable skills** — build once, scope per agent, update centrally. A skill improvement propagates to every agent that uses it.
3. **Templates** — consistent output format regardless of which agent produces it. Agents pattern-match against concrete templates reliably.
4. **Thorough routing** — Guide Main reads intent and routes to the right specialist. Users never need to know which agent answered.
5. **Intentional mounting** — every agent sees exactly what it needs and nothing more. Structural access control, not trust-based.

Each principle solves a different failure mode. Together they make the system maintainable as it scales.

---

## Open Design Problems

### Trust & Privacy — Team Adoption Risk

The real concern isn't routing or file access — it's: *"Can Gareth read my conversations with Guide?"*

If team members believe their interactions are monitored, adoption won't happen voluntarily. This is a cultural and architectural problem, not just a comms problem.

**What needs solving:**
- Structural isolation: exec and personal agent instances must not write to shared vaults accessible to Gareth. Enforce architecturally, document as policy.
- Transparency: publish a clear, honest statement of what Guide logs and what it doesn't. "Guide logs actions and outputs for audit. It does not log personal conversations." Must be architecturally true before being stated.
- Role separation: Gareth as Guide architect ≠ Gareth as team manager. AI governance policy ownership should sit with team leads (Danny for Performance, etc.) — not just Gareth.
- Early adopters first: Laura, Adam, David, Richard are the trust-builders. Let culture establish proof before broad rollout.

**The exec instances (Nick, Hadley, Keith) are lower risk — they asked for it. The team layer is where trust has to be earned.**

**Architectural solution: per-person bot isolation.**
Each user gets their own Telegram bot (`@GuideHadleyBot`, `@GuideNickBot`, etc.), bound to their own agent instance with their own private workspace. Conversations are isolated by architecture, not just policy — a different bot literally cannot see another user's conversation. This closes the trust question structurally. "Your Guide instance is your bot. Nobody else messages it. Nobody else sees it." Backed by the architecture, not just a promise.

---

## Scope & Boundaries

### In Scope

- Commercial intelligence: capital allocation, media performance, yield analysis
- Data pipelines: GA4, Google Ads, Bing, Meta, Instagram, DV360, HubSpot, BigQuery
- Team-facing briefs and reports via Telegram, WhatsApp, and Slack
- Orchestration of CapitalCore and Apex (intelligence + execution layers)
- Lead quality engineering automation
- Meeting capture, transcription, and task extraction
- Team AI workflow enablement
- SEO, Paid Media, HubSpot, Digital Product, and Analyst team support

### Out of Scope

- Personal or household operations (out of scope — Guide is a work system)
- Direct access to financial systems (read-only data feeds only)
- Public-facing services (Guide is internal only)
- Customer-facing chatbots or support automation (different project)

### Relationship to Existing Work

| System          | Location                                                                                                            | Relationship to Guide                                                                                                 |
| --------------- | ------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| **CapitalCore** | [[20-Projects/Wilderness/20-Projects/Group-Automation-GUIDE/CapitalCore/CapitalCore_INDEX\|Wilderness/CapitalCore]] | Guide orchestrates CapitalCore runs and surfaces outputs. Code stays in its own repo. Specs stay in Wilderness vault. |
| **Apex**        | [[20-Projects/Wilderness/20-Projects/Group-Automation-GUIDE/Apex/Apex_INDEX\|Wilderness/Apex]]                      | Guide triggers Apex diagnostics and delivers results. Code stays in its own repo. Specs stay in Wilderness vault.     |
**Rule:** CapitalCore and Apex code/specs stay in the Wilderness folder and their own GitHub repos. Guide references them. Guide does not duplicate them.

---

## Architecture

### Machine: Guide

| Property | Value |
|----------|-------|
| Machine | Guide (HP Z8 G4 — 2× Xeon Gold 6134, Nvidia RTX 3090 24GB) |
| RAM | 128 GB |
| Storage | 1 TB NVMe + 4 TB HDD |
| OS | Ubuntu (Linux) |
| Role | Guide runtime, data pipeline host, cron executor, local LLM inference |
| File access | OneDrive running locally for Wilderness file access |
| Network | Home LAN, Tailscale-connected |

Guide is a dedicated runtime machine — separate from Gareth's laptop, separate concerns, separate failure domains.

### Runtime

| Component | Detail |
|-----------|--------|
| **Runtime** | OpenClaw |
| **LLM** | Multi-tier routing — see model routing table below |
| **Interface** | Telegram (Gareth + leaders), WhatsApp via Baileys/QR link (executives), Slack (team) |
| **File access** | OneDrive on Guide machine + guide-build vault (synced) |
| **Code repos** | `guide-core` (OpenClaw runtime), `guide-engine` (ETL scripts) — both private on GitHub |
| **Data output** | `~/guide-data/` — markdown written by guide-engine, read by agents. Not a repo. |

### Model Routing

| Task type | Model | Where |
|-----------|-------|-------|
| Sensitive data (HR, board, finance, M&A) | Local 34B (Qwen 2.5 32B or Llama 3.3 34B, Q4) | On-premise — Ollama + RTX 3090 |
| Background cron, data checks, formatting | Haiku | Anthropic API |
| Interactive queries, brief generation | Sonnet | Anthropic API |
| Deep reasoning, capital allocation, board synthesis | Opus | Anthropic API |
| Image analysis, audio transcription | GPT-4o Vision / Whisper | OpenAI API (Scribe agent) |

Local model is a gate for rolling Guide out to Finance, HR, and board-level functions. Set up as part of CHUNK-07 (Ubuntu hardening).

### Orchestration Layer — Paperclip (Future)

[Paperclip](https://paperclip.ing/) ([GitHub](https://github.com/paperclipai/paperclip)) is a multi-agent orchestration platform — not an agent framework but a "company" that coordinates multiple agents ("employees"). OpenClaw is a first-class supported agent type within Paperclip.

| Capability | Relevance to Guide |
|------------|-------------------|
| Org-chart delegation | Maps to Guide's 4-tier access model — agents report up/down |
| Multi-company isolation | Perfect for WS / Jacada / YZ brand separation |
| Per-agent budgets | Token cost control across 12+ agents |
| Ticket-based work | Audit trail for every agent action |
| Governance gates | Human-in-the-loop for executive-facing outputs |

**Decision:** Not yet. Paperclip is 5 weeks old (launched March 2026) with a bus factor of ~1 core contributor. High momentum (47K+ stars) but volatile.

- **Phase 0–2:** Build on OpenClaw directly
- **Phase 3+:** Evaluate Paperclip as the orchestration layer when spinning up team agents at scale
- **Trigger:** Revisit when agent count exceeds 4 and cost/coordination overhead becomes real

### Automation Layer — Huginn (Phase 3)

[Huginn](https://github.com/huginn/huginn) is a self-hosted event-driven automation platform — open-source Zapier/IFTTT with no per-action cost. Agents watch for events, transform data, and trigger actions through a directed graph of workflows.

| Capability | Relevance to Guide |
|------------|-------------------|
| Webhook send/receive | Route HubSpot/GA4/ad platform webhooks to Guide pipelines |
| Web monitoring | Watch competitor pricing, camp availability, content changes |
| Scheduled triggers | Data source polling, health checks that don't need LLM |
| Event chaining | Data arrives → validate → transform → store → notify Guide |
| 30+ integrations | Slack, Telegram, JIRA, RSS, SMTP, Twilio, custom APIs |

**Why Huginn, not custom Python:** `guide-engine/` was designed to hold custom automation code. Huginn replaces much of that with a visual workflow builder — faster to build, easier to maintain, no custom code for standard integration patterns. LLM agents handle intelligence; Huginn handles plumbing.

**Decision:** Phase 3 (alongside data layer). Install on the Guide machine once personal instances are stable and data integrations are starting. Self-hosted Ruby on Rails app — runs alongside OpenClaw, no dependency conflict.

### Two-Claude Architecture

| Role | Machine | Function |
|------|---------|----------|
| **Architect** | Mac (Gareth's laptop) | Writes specs, designs agents, authors chunks. Claude Code in guide-build vault. |
| **Engineer** | Guide (HP Z8 G4, Ubuntu) | Executes chunks, runs code, operates Guide runtime. Claude Code on bare metal. |

Gareth writes specs on the Mac. The Engineer executes them on Guide.

The Guide machine has the **guide-build vault synced** and all repos locally. The Engineer Claude reads all specs, agent definitions, and CLAUDE.md files directly — no copying into sessions.

The Two-Claude separation is about **role**, not **access**. The Architect designs; the Engineer builds. Both can read everything.

### Data Architecture

Guide uses an atomic data process:

```
Python scripts pull raw data from sources (GA4, Google Ads, etc.)
    ↓
Scripts create a markdown summary of the data
    ↓
Guide (LLM) interprets the markdown and creates a report
    ↓
Guide sends the report to the relevant person via Telegram/WhatsApp/Slack
```

This separation ensures:
- Python handles API calls, authentication, and data transformation (deterministic)
- Guide handles interpretation, narrative, and delivery (intelligence)
- Markdown is the interchange format between data and intelligence layers

### Access Model

Guide serves a team of 15+ across three brands. This requires a multi-tier access model, not a simple per-user allow-list.

| Access Level  | Who                                          | Channel          | Sees What                                                     |
| ------------- | -------------------------------------------- | ---------------- | ------------------------------------------------------------- |
| **Architect** | Gareth                                       | Telegram + shell | Everything — full vault, all agents, all data, direct access  |
| **Personal** | Nick, Hadley, Keith, Scott, Caro, Frances, Simon, Dean | Telegram (per-person bot) | Own private Guide instance with scoped team vault access |
| **Operator**  | Team leads (Danny, Richard, Laura, Ashleigh) | Telegram         | Agent outputs, can trigger team-scoped agents                 |
| **Consumer**  | Wider team                                   | Slack            | Read-only channels, briefs and reports, cannot trigger agents |

**Personal instances (ADR-018, 2026-04-29):** Each person gets their own Guide agent with a dedicated Telegram bot (`@GuideNickBot`, `@GuideHadleyBot`, etc.). Conversations are isolated by architecture — separate bot tokens, separate workspaces, separate context windows. Each instance mounts team vaults relevant to the person's role (read-only). See [[personal-instance-architecture]] for the full specification.

---

## Macro Phases

The build follows four macro phases. Each maps to detailed build phases below.

### 1. MVP
Guide is up and running on the Mac Mini. OneDrive provides file access. Claude LLMs are operational. First brief sent. Machine is production-hardened.

### 2. Briefing Works
Teams are running their own PARA structures and can communicate with Guide. Briefing and Scribe agents are operational. Team enablement is underway.

### 3. Data Works
Data is being ingested and processed. The atomic ETL pattern is operational:
- Python scripts pull data and create markdown summaries
- Guide interprets the data and creates reports
- Guide sends reports to the relevant person

### 4. Agents
Once data works, we build the team agents (SEO, Paid, HubSpot, Product, Analyst). Apex and CapitalCore come last as agents/components — they sit above the team comms layer.

---

## Multi-Brand Architecture

Guide serves three brands: **Wilderness**, **Jacada**, and **Yellow Zebra (YZ)**. The architecture must handle brand-specific data, teams, and reporting without tripling agent count or cost.

### Decision: Hybrid Model (Option C)

| Layer | Strategy | Rationale |
|-------|----------|-----------|
| **Shared agents** | Guide, Pipeline, Briefing, Scribe, Analyst | Infrastructure agents serve all brands — one pipeline, one orchestrator, one briefing engine |
| **Brand-specific agents** | SEO, Paid, HubSpot, Product | These teams already work in brand silos; data is brand-scoped; reports go to brand leads |
| **Cross-brand agents** | Apex, CapitalCore | Portfolio-level intelligence by definition — they compare across brands |

This gives us ~16 agents (4 shared + 4×3 brand-specific + 2 cross-brand) instead of 36 (12×3). Brand-specific agents share templates but have separate workspaces, data scopes, and delivery channels.

### Brand Configuration Model

Each brand-specific agent inherits from a base template and receives a brand overlay:

```
Base template (e.g., SEO Agent)
  + Brand overlay (Wilderness / Jacada / YZ)
    = Brand-scoped agent (SEO-WS, SEO-JC, SEO-YZ)
```

Overlay contains: data source credentials, Telegram/Slack channel IDs, team lead contacts, brand-specific KPIs and thresholds.

**When Paperclip is adopted (Phase 3+):** Each brand becomes a "company" in Paperclip's multi-company isolation model. Shared agents operate at the parent level.

---

## Agent Factory

16+ hand-crafted agents is a maintenance nightmare. The agent factory automates agent creation from templates.

### How It Works

The factory supports two agent types — channel agents and personal instances:

```
agent-factory/
  templates/
    channel/                 ← Channel agent templates (9 identity files)
    personal/                ← Personal instance templates (9 identity files)
  roles/                     ← Channel agent configs (data.env, seo.env, etc.)
  roster.json                ← Master roster (from vault Specs/guide-roster.json — all persons, vaults, gates)
  generate.sh                ← ./generate.sh channel data | ./generate.sh personal nick
```

**Channel agent:** `./generate.sh channel data`
**Output:** Workspace at `~/guide-vault/channel/data/` — bound to a Slack channel, reads from a team vault.

**Personal instance:** `./generate.sh personal nick`
**Output:** Workspace at `~/guide-vault/personal/nick/` — bound to a Telegram bot, reads from team vaults relevant to that person.

**Rule:** New agent spin-up is a 5–10 minute config task, not a multi-day build. The factory is built in Phase 1 (CHUNK-09 for channels, CHUNK-13 for personal instances).

---

## Agent Roster

### Shared Agents (All Brands)

| Agent | Role | Priority | Phase |
|-------|------|----------|-------|
| **Guide** | Chief of staff — orchestrates all sub-agents, handles ad hoc requests | P0 | 0 |
| **Briefing** | Team briefs — morning digests, weekly summaries, board-ready packs | P0 | 1 |
| **Scribe** | Meeting capture — transcription, note extraction, task routing | P1 | 2 |
| **Pipeline** | Data pipeline — manages ETL runs, data freshness, pipeline health | P2 | 2 |
| **Analyst** | Cross-domain analysis, ad hoc investigation, data storytelling | P3 | 3 |
| **Finance** | Finance team — lead volume, sales pipeline, media spend (cross-brand) | P2 | 2 |

### Brand-Specific Agents (×3: WS, Jacada, YZ)

| Agent Template | Role | Priority | Phase |
|----------------|------|----------|-------|
| **SEO** | Rankings, technical audits, content gap analysis | P3 | 3 |
| **Paid** | PPC/Social/Programmatic performance | P3 | 3 |
| **HubSpot** | Lead/deal pipeline, CRM health, conversion tracking | P3 | 3 |
| **Product** | Site performance, UX metrics, A/B test analysis | P3 | 3 |

*Each template produces 3 agents (e.g., SEO-WS, SEO-JC, SEO-YZ) via the agent factory.*

### Cross-Brand Agents (Portfolio Level)

| Agent | Role | Priority | Phase |
|-------|------|----------|-------|
| **Apex** | Competition hunter — PPC diagnostics, anomaly detection, opportunity | P4 | 4 |
| **CapitalCore** | Capital allocation — yield curves, budget pacing, portfolio efficiency | P4 | 5 |

### Future

| Agent | Role | Priority | Phase |
|-------|------|----------|-------|
| **Dev Team (×5)** | Full dev team — built once rest is running | P5 | Future |

**Total agent count:** 6 shared + 12 brand-specific (4 templates × 3 brands) + 2 cross-brand = **20 agents** (+ 5 future dev team)

### Personal Instances (ADR-018)

In addition to the shared/brand/cross-brand agents above, Guide supports **personal instances** — one agent per person, serving that individual through a dedicated Telegram bot. Personal instances mount team vaults (read-only) relevant to the person's role.

| Person | Agent ID | Team Vault(s) | Tier |
|--------|----------|---------------|------|
| Nick | `personal-nick` | exec | Exec |
| Hadley | `personal-hadley` | exec, digital | Exec |
| Keith | `personal-keith` | exec | Exec |
| Scott | `personal-scott` | sales (future) | Domain |
| Caro | `personal-caro` | reservations (future) | Domain |
| Frances | `personal-frances` | digital | Domain |
| Simon | `personal-simon` | sales (future) | Domain |
| Dean | `personal-dean` | people (future) | Domain |

See [[personal-instance-architecture]] for the full specification.

### Team Vaults (ADR-019)

Team vaults are shared operational context for functional teams. They live in `guide-teams/` on the Guide machine, synced via OneDrive. Agents mount them read-only.

| Team Vault | Status | First Team Vault? |
|------------|--------|-------------------|
| `digital` | Live — Wilderness-Guide vault | Yes (reference implementation) |
| `exec` | To create | — |
| `sales` | Future | — |
| `reservations` | Future | — |
| `people` | Future | — |

See [[team-vault-conventions]] for the structure and conventions.

### Agent Scope Isolation

Each agent has a restricted workspace — scope isolation is an architectural principle:

- **Guide** sees everything. Orchestrates.
- **Briefing** reads outputs from all agents. Cannot execute pipelines or modify data.
- **Scribe** has write access to Wilderness notes sections only.
- **Pipeline** has shell access for ETL execution. Tightly scoped to data directories.
- **Team agents** (SEO, Paid, HubSpot, Product, Analyst) read their domain data only. Cannot cross-access other agent data.
- **Apex** reads Paid agent outputs + raw Google Ads data. Cannot access CRM.
- **CapitalCore** reads all financial/media data. Read-only. Cannot modify pipelines.

---

## Data Integrations

### Priority 1 — Foundation

| Source | Use Case | Agent(s) |
|--------|----------|----------|
| **OneDrive** | File access, shared documents, team PARA structures | Guide, all agents |
| **GA4** | Conversion funnels, traffic quality, engagement metrics | Pipeline, Analyst |
| **BigQuery** | Data warehouse, cross-source analysis | Pipeline, Analyst |

### Priority 2 — Media & CRM

| Source | Use Case | Agent(s) |
|--------|----------|----------|
| **Google Ads** | CPA/CPL tracking, yield curves, budget pacing | Pipeline, Paid, CapitalCore |
| **HubSpot** | Lead scoring, pipeline velocity, booking attribution | Pipeline, HubSpot, CapitalCore |

### Priority 3 — Extended Media

| Source | Use Case | Agent(s) |
|--------|----------|----------|
| **Meta** | Social paid performance, audience insights | Pipeline, Paid |
| **Instagram** | Social organic + paid performance | Pipeline, Paid |
| **Bing** | PPC diagnostics for Bing campaigns | Pipeline, Paid |
| **DV360** | Display/programmatic performance | Pipeline, Paid |

---

## Proven Patterns

These design decisions are established and must be followed — they reflect hard-won learning from operating OpenClaw at scale.

| Pattern | Applied to Guide |
|---------|-----------------|
| OpenClaw runtime + gateway | macOS (launchd, bare metal) |
| 9-file workspace framework (SOUL → BOOTSTRAP) | Extended with brand overlays |
| Chunk-based build system | Guide-specific paths — see `_CONVENTIONS.md` |
| Agent scope isolation | Extended to 4-tier access model |
| Cron strategy (Haiku background, Sonnet interactive) | Same model routing |
| Token cost management (session resets, prompt caching) | Same patterns from day 1 |
| `openclaw-templates` shared includes | Extended into agent factory with brand overlays |
| Telegram bot + webhook binding | Extended to Slack |

### Hard-Won Lessons

1. **Heartbeat burn** — Disable default heartbeat. Use explicit cron jobs with isolated sessions.
2. **Retry loops** — Set strict retry limits in SOUL.md. Agents must not burn tokens retrying failed calls.
3. **Over-verbose models** — Set output token caps in model config. Haiku for all background work.
4. **Context bloat** — Automatic session resets. Isolated cron sessions. Prompt caching enabled.
5. **bootstrapMaxChars** — OpenClaw silently truncates at 20K chars. Keep each identity file under 2K chars. Heavy content in `workspace/docs/`.
6. **Don't over-plan** — Install from the README and stabilise. Then add structure. Don't plan 15 chunks before touching the machine.

---

## Build Phases

Chunk-based build. Chunk conventions documented in `BUILD/DEV-CHUNKS/_CONVENTIONS.md`.

### Phase 0 — Foundation

**Goal:** Guide machine is production-ready. First brief delivered. Security hardened.

| Chunk | Title | Key Deliverables |
|-------|-------|------------------|
| CHUNK-00 | Machine Setup | macOS config, SSH key auth, Tailscale, OneDrive, base packages |
| CHUNK-01 | Docker | Docker Desktop, container strategy, compose files |
| CHUNK-02 | OpenClaw Install | OpenClaw on Guide, gateway running, vault access confirmed |
| CHUNK-03 | LLM Configuration | Claude API, model routing (Sonnet/Haiku/Opus), cost controls |
| CHUNK-04 | Telegram Integration | Telegram bot, webhook delivery, Gareth can message Guide |
| CHUNK-05 | Guide Agent | Guide identity (SOUL.md, IDENTITY.md, USER.md), first brief sent |
| CHUNK-06 | Access Control | 4-tier access model, Telegram/WhatsApp/Slack channel structure |
| CHUNK-07 | Security & Hardening | Firewall, credential management, audit logging, production lockdown |
| CHUNK-08 | Cron & Ops | Cron schedule (7 jobs), health checks, monitoring, folder structure |

### Phase 1 — Team Ops

**Goal:** Team can communicate with Guide. Agent factory operational. Briefing and meeting capture working.

| Chunk | Title | Key Deliverables |
|-------|-------|------------------|
| CHUNK-09 | Agent Factory | Base templates, brand overlays, `generate.sh`, automated workspace creation |
| CHUNK-10 | Channel Agents | 5 channel agents (data, martech, seo, product, hubspot) wired to Slack |
| CHUNK-11 | Paperclip POC | Paperclip governance layer for Keith & Nick demo |
| CHUNK-12 | Team Vault Architecture | `guide-vault/`, `guide-teams/`, `guide-shared/`, `guide-outputs/` filesystem + workspace migration |
| CHUNK-13 | Personal Instance Factory | Factory extension: personal templates, persons/ configs, generate.sh update |
| CHUNK-14 | Nick Instance | First personal instance end-to-end: workspace, Telegram bot, registration, testing |

### Phase 2 — Data Layer

**Goal:** Data flowing through the atomic ETL pattern. Pipeline agent watching health.

| Chunk | Title | Key Deliverables |
|-------|-------|------------------|
| CHUNK-13 | Pipeline Agent | ETL orchestration, data freshness monitoring, self-healing restarts |
| CHUNK-14 | Data Quality | Validation rules, anomaly detection on ingested data, alerting |
| CHUNK-15 | MVP ETL Process | End-to-end: Python pulls → markdown summary → Guide interprets → report → person |

### Phase 3 — Team Scale

**Goal:** Every team has their agent. Brand-specific agents created via agent factory. Each template produces 3 brand instances.

| Chunk | Title | Key Deliverables |
|-------|-------|------------------|
| CHUNK-16 | SEO Agents (×3) | Rankings, technical audits, content gap analysis — WS, JC, YZ via factory |
| CHUNK-17 | Paid Agents (×3) | PPC/Social/Programmatic performance — WS, JC, YZ via factory |
| CHUNK-18 | HubSpot Agents (×3) | Lead/deal pipeline, CRM health, conversion tracking — WS, JC, YZ via factory |
| CHUNK-19 | Product Agents (×3) | Site performance, UX metrics, A/B test analysis — WS, JC, YZ via factory |
| CHUNK-20 | Analyst Agent | Cross-domain analysis, ad hoc investigation, data storytelling (shared) |
| CHUNK-21 | Finance Agent | Lead volume, sales pipeline, media spend (shared, cross-brand) |

### Phase 4 — Data Integrations

**Goal:** All data sources connected. Full data coverage across paid, organic, CRM.

| Chunk | Title | Key Deliverables |
|-------|-------|------------------|
| CHUNK-22 | HubSpot Integration | HubSpot API — contacts, deals, pipeline stages, booking attribution (×3 brands) |
| CHUNK-23 | Google Ads Integration | Google Ads API — all 3 brands, campaign/keyword/ad group data |
| CHUNK-24 | GA4 + BigQuery | GA4 via BigQuery export — conversion funnels, traffic quality |
| CHUNK-25 | Meta + Instagram | Meta Marketing API — social paid + organic across brands |
| CHUNK-26 | Bing + DV360 | Bing Ads API + DV360 API — complete paid media coverage |

### Phase 5 — Productisation

**Goal:** CapitalCore and Apex operational as Guide agents. Paperclip evaluation. Sitting above the team comms layer.

| Chunk | Title | Key Deliverables |
|-------|-------|------------------|
| CHUNK-27 | Apex Agent | PPC diagnostics, anomaly detection, competition hunting — cross-brand |
| CHUNK-28 | CapitalCore Agent | Yield curves, budget pacing, capital allocation reports — cross-brand |
| CHUNK-29 | Paperclip Evaluation | Evaluate Paperclip for orchestration — if viable, migrate agent coordination |
| CHUNK-30 | Template Export | Guide architecture as a deployable template (replicable pattern) |
| CHUNK-31 | Documentation | Full system docs, operator runbook, architecture decision records |

### Future — Dev Team

Full dev team (5 agents: @growth, @dev, @qa, @db, @creative). Built once the rest of Guide is running and monitored.

---

## Cron Schedule (Target State)

| Time | Days | Job | Channel | Agent |
|------|------|-----|---------|-------|
| 07:30 | Mon-Fri | Performance morning brief | Telegram (leaders) | Briefing |
| 08:00 | Mon-Fri | Gareth strategic brief | Telegram (Gareth DM) | Guide |
| 09:00 | Mon-Fri | Pipeline health check | Slack #guide-ops (silent if healthy) | Pipeline |
| 12:00 | Mon-Fri | Midday anomaly scan | Telegram (leaders, silent if clean) | Paid |
| 17:00 | Fri | Weekly performance summary | WhatsApp (executives) | Briefing |
| 09:00 | 1st of month | Monthly board digest | WhatsApp (executives) | Briefing |
| 06:00 | Daily | ETL refresh (all sources) | Silent | Pipeline |

---

## File Structure

All files below live at `20-Projects/Guide/`.

```
Guide/
  00_Guide-Project-Brief.md    ← THIS FILE
  BUILD.md                     ← Build roadmap (phases + chunk index)
  CLAUDE.md                    ← Claude Code instructions for working with Guide
  FEATURES.md                  ← Current and planned feature list + agent roster
  INTEGRATIONS.md              ← Data integrations index (status, priority)
  INFRA.md                     ← Infrastructure docs (Guide machine, network, access)
  BACKLOG.md                   ← Non-chunk work items (pull-based)
  DOCUMENTATION.md             ← Canonical reference index + knowledge gaps
  Guide_INDEX.md               ← Obsidian vault navigation (EXISTS — update)
  __CONFIG/                    ← OpenClaw config, LLM settings, comms config
    GUIDE.md                   ← Canonical system config reference
    Telegram/                  ← Bot config, chat IDs
    Slack/                     ← Slack app config, webhook URLs, channel map
    WhatsApp/                  ← WhatsApp Business API config
    LLMs/                      ← Model configuration
    __CONFIG_INDEX.md
  Agents/                      ← Agent specifications
    Guide-Main.md              ← Chief of staff agent spec
    Briefing.md                ← Team briefing agent spec
    Scribe.md                  ← Meeting capture agent spec
    Pipeline.md                ← Data pipeline agent spec
    SEO.md                     ← SEO team agent spec
    Paid.md                    ← Paid media agent spec
    HubSpot.md                 ← CRM agent spec
    Product.md                 ← Digital product agent spec
    Analyst.md                 ← Analysis agent spec
    Apex.md                    ← Competition diagnostic agent spec
    CapitalCore.md             ← Capital allocation agent spec
    Agents_INDEX.md
  BUILD/                       ← Build chunks
    DEV-CHUNKS/                ← CHUNK-00 through CHUNK-28
      _CONVENTIONS.md          ← Paths, ports, naming rules
      DECISIONS.md             ← Architectural decisions log
      DEV-CHUNKS_INDEX.md
    BUILD_INDEX.md
  Logs/                        ← Session logs and system specs
    Logs_INDEX.md
  Notes/                       ← Working notes and research
    Notes_INDEX.md
  Prompts/                     ← Reusable prompt templates
    PROMPT_Claude-Guide-Build.md  ← Handoff prompt for Guide Claude (Engineer)
    Prompts_INDEX.md
```

---

## Design Characteristics

| Dimension | Guide |
|-----------|-------|
| **Audience** | Team of 15+ across 3 brands |
| **Interface** | Telegram (leaders) + WhatsApp (execs) + Slack (team) |
| **Machine** | Guide (Mac Mini M4, macOS) |
| **File access** | OneDrive on local machine |
| **Data sources** | GA4, Google Ads, Bing, Meta, Instagram, DV360, HubSpot, BigQuery |
| **Data architecture** | Atomic: Python → markdown → Guide → report → person |
| **Agent count (target)** | 20 (Phase 5) — 6 shared + 12 brand-specific + 2 cross-brand |
| **Agent creation** | Agent factory: template + brand overlay → workspace |
| **Multi-brand** | Hybrid: shared infra agents + brand-specific team agents |
| **Access control** | 4-tier (Architect/Operator/Consumer/Executive) |
| **Orchestration** | OpenClaw (Phase 0–2), Paperclip evaluation (Phase 5) |
| **Code repos** | `guide-core` (runtime) + `guide-engine` (pipelines) |

---

## Immediate Next Actions

1. ~~**Create remaining project files**~~ — CLAUDE.md, BUILD.md, FEATURES.md, INTEGRATIONS.md, INFRA.md, BACKLOG.md, DOCUMENTATION.md ✅
2. ~~**Create `BUILD/DEV-CHUNKS/_CONVENTIONS.md`**~~ ✅
3. **Write `CHUNK-00-machine-setup.md`** — First executable chunk
4. **Order/configure Guide machine** if not already done
5. **Create `guide-core` GitHub repo** — Private. README + .gitignore
6. **Create `guide-engine` GitHub repo** — Private. ETL scripts + exporters
7. **Design agent factory templates** — Base identity files + brand overlay schema

---

## Strategic Notes

- Guide is not a demo. It is an operational system that a PE-backed travel group will rely on for capital allocation decisions. Build accordingly.
- The CapitalCore + Apex stack already exists in partial form. Guide's job is to orchestrate and deliver, not rebuild. They come last because they sit above the team comms layer.
- Nick (PE stakeholder) responds to capital allocation framing. Every Guide output to executive channels should speak that language.
- This is a replicable pattern. If Guide works, it becomes the template for "AI chief of staff for a team." The agent factory and template export (Phase 5) make this explicit.
- Teams run their own PARA structures. Guide plugs into those structures — it doesn't impose a new one.
- The atomic data architecture (Python → markdown → Guide → report) keeps the LLM out of the data plumbing. Python is deterministic. Guide is intelligence.
- **Build on proven patterns.** Guide's architecture is established. The job is to extend and execute, not rediscover.
- **Multi-brand is a feature, not a complication.** The hybrid model (shared infra + brand-specific team agents) keeps cost linear while serving three brands. The agent factory makes brand-specific agents cheap to create and maintain.
- **Paperclip is a bet on the future.** If it matures, it becomes the orchestration layer that ties Guide's 20 agents into a coherent organisation. If it doesn't, OpenClaw's native multi-agent support is sufficient.

---

*Created: 2026-04-03 | Updated: 2026-04-05*
