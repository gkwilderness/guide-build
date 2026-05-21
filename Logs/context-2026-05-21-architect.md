---
title: "context-2026-05-21-architect"
type: log
area: infra
project: Guide
tags: [infra, guide, docs, architect, session-log]
date: 2026-05-21
---

# Session Handover — 2026-05-21 (Architect)

Architect session on guide-server. Focus: full documentation sync — all spec docs updated to match live Z8 state.

---

## What Was Done This Session

### Documentation audit against live machine state

Ran a comprehensive live audit of guide-server (what's actually running, what's installed, what workspaces exist) and compared against all spec docs. Found significant drift across six files. Updated all of them.

### Files updated

| File | What changed |
|------|-------------|
| `INFRA.md` | Replaced placeholder LLM model table with actual installed models; expanded service map to include Huginn, Ollama, Hermes/OpenWebUI/Paperclip; replaced filesystem table with complete `/srv/` directory inventory |
| `FEATURES.md` | Added 15 new live features (Z8, agents, vaults, Huginn, Ollama, skills, host cron); updated Phase 0/1 planned feature status; updated local LLM infrastructure section |
| `00_Guide-Project-Brief.md` | Added Safari agent to shared agent roster; added Status column to all agent tables; added Julian to personal instances; updated team vault table (exco now live); corrected model routing table; updated Huginn + Paperclip decision sections |
| `BACKLOG.md` | Removed duplicate cron item (edit error, fixed); moved Z8 foundation spec from FIRE→YELLOW; fixed model reference (gemma4:26b → qwen3:30b-a3b); added Safari TOOLS.md stale paths as Engineer item; added Slack channel table audit as WHITE item |
| `BUILD.md` | Paperclip → installing 2026-05-21; Huginn → deployed ahead of schedule; CHUNK-15/16 → built, awaiting tokens; Phase 2 Ubuntu note → updated to reflect Z8 live |
| `CLAUDE.md` | Build status section updated with Huginn, Ollama, Paperclip, Safari agent, exec bot status, cron state |
| `DOCUMENTATION.md` | Engineer context paths corrected to `/srv/`; vault sync knowledge gap marked resolved |

---

## Key Facts Discovered During Audit

### Services live on guide-server (as of 2026-05-21)

| Service | Status |
|---------|--------|
| OpenClaw | Live — Docker, systemd, healthy |
| Huginn + MySQL | Live — Docker, systemd, Tailscale port 3001 |
| Ollama | Live — systemd, RTX 3090 CUDA |
| Hermes | Directory prepared (`/srv/hermes/data`, `profiles/`) — not running |
| Open WebUI | Directory prepared (`/srv/openwebui/data/`) — not running |
| Paperclip | Gareth installing (2026-05-21) — `/srv/paperclip/data/` prepared |

### Ollama models (actual, not what docs said)

| Model | Tools | Purpose |
|-------|-------|---------|
| `tinyllama:latest` | no | Smoke test |
| `gemma3:27b-it-q4_K_M` | **no** | Summarisation only — **do not use for agentic/tool jobs** |
| `qwen3:14b` | yes | Lightweight agentic |
| `qwen3:30b-a3b` | yes | Primary agentic model |

Docs previously referenced `gemma4:26b` — that model does not exist. Corrected everywhere.

### Registered agents in openclaw.json

main, data, martech, seo, product, hubspot, safari, personal-nick, personal-keith, personal-hadley, personal-caro, personal-dean, personal-julian

### Safari agent

- Workspace: `/srv/openclaw/workspaces/safari/`
- Channel: `#guide-sales` (Slack ID: `C0B1Z2ETB26`)
- Purpose: Safari knowledge layer for Travel Designers — camps, regions, seasons, itinerary building, battlecards
- KB: `/srv/guide-vaults/shared/kb/safari/`
- Added to agent roster in `00_Guide-Project-Brief.md`
- TOOLS.md still has stale Mac Mini paths — Engineer fix logged in BACKLOG

### Vault state (actual)

| Vault | Status |
|-------|--------|
| `teams/digital` | Live — Obsidian Sync |
| `teams/exco` | Live — has content (PRIORITIES.md, hubspot-sales-data, travel policy) |
| `teams/hr`, `teams/reservations`, `teams/sales` | Directory only — empty |
| `shared/` | Populated (brand, camps, countries, kb, sales, etc.) |
| `personal/nick` | PRIORITIES.md is a stub. `performance/` has cpl-tracker.md + vs-plan.md (likely stubs too) |
| `personal/keith`, `hadley`, `caro`, `dean`, `julian` | Vault dirs exist |

### Skills (19 on disk, registration status unclear)

Skills in `/srv/openclaw/skills/`: caveman, claude-context-generator, clickup-connector, diagnose, grill-me, grill-with-docs, handoff, hubspot-connector, learn-a-skill, meta-questions, ppc-questions, programmatic-questions, prompt-builder, prompt-rewriter, seo-questions, skill-improver, wilderness-seo, write-a-skill, zoom-out.

The `skills` section in `openclaw.json` only has `install.nodeManager: npm` — no skills list. Whether OpenClaw auto-detects from the directory or registration is genuinely outstanding is unconfirmed. BACKLOG FIRE item still stands.

### Cron state

OpenClaw cron in `openclaw.json`: **zero jobs configured** — only config (maxConcurrentRuns, sessionRetention, retry). All active cron is host-level (gareth crontab):
- `0 4 * * *` — `openclaw-backup.sh`
- `0 8 * * *` — `google-ads-api-utils/run_all.sh`
- `0 5 * * *` — `llm-checker/run_all.sh`
- PAUSED: pulse + LLM report generators (awaiting OneDrive)

The BACKLOG FIRE item "Fix nightly flush cron" implies there should be OpenClaw cron jobs — but none exist in `openclaw.json`. Either they were removed or never migrated from the Mac Mini.

### Undocumented `/srv/` directories

| Directory | Notes |
|-----------|-------|
| `/srv/db/postgres`, `/srv/db/redis` | Database volumes prepared, not running standalone |
| `/srv/landing-pages/` | Exists, purpose unknown — not documented |
| `/srv/guide-staging/` | Skills/scripts staging area — already in use |

---

## Open Items for Next Session

All in BACKLOG. Key ones to be aware of:

- **FIRE**: Register/wire 9 new skills + refresh 8 in openclaw.json (or confirm auto-detection)
- **FIRE**: Fix nightly flush cron path in openclaw.json
- **FIRE**: Wire `#guide-help` in openclaw.json
- **HIGH/Engineer**: Safari TOOLS.md stale paths
- **YELLOW**: Z8 foundation architecture spec (idempotent chunk — not blocking but not done)
- **Soak ends ~2026-05-25**: Mac Mini decommission + workspace file lockdown

---

## Operational Notes

- Paperclip installing as of this session — check `/srv/paperclip/` after next restart
- `/srv/landing-pages/` purpose unknown — ask Gareth if relevant before next build session
- Skills registration: run `openclaw skills list` in container to confirm whether skills are auto-detected or need openclaw.json wiring
