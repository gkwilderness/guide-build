---
title: "Guide — Infrastructure"
type: infra
area: ai
project: "Guide"
tags: [ai, guide, infra]
status: active
updated: 2026-05-21
---
# Guide — Infrastructure

## Guide Machine

| Property | Value |
|----------|-------|
| Name | Guide |
| Hardware | HP Z8 G4 (2× Xeon Gold 6134 3.20GHz, Nvidia RTX 3090 24GB VRAM) |
| RAM | 128 GB |
| Storage | 1 TB NVMe + 4 TB HDD |
| OS | Ubuntu 24.04 LTS (kernel 6.17.0-23-generic) |
| Hostname | guide-server |
| Role | Guide runtime, data pipeline host, cron executor, local LLM inference |
| File access | /srv/guide-build (cloned), /srv/guide-core, /srv/guide-engine, /srv/onedrive (OneDrive — pending) |
| Network | Tailscale live — `guide-server` (100.80.44.14) |
| Status | **Live — CHUNK-07c complete 2026-05-19. OpenClaw running in Docker, all services green. 7-day soak ends ~2026-05-25.** |

### Local LLM Capability

The RTX 3090 (24GB VRAM) enables on-premise inference for sensitive data that cannot go to external APIs.

**Runtime:** Ollama 0.24.0 with CUDA backend — live on guide-server, accessible at `http://guide-server:11434`. Model storage on `/mnt/storage/ollama/models` (3.7 TB xfs disk).

| Model | Size | Tools | Thinking | Use case |
|-------|------|-------|----------|----------|
| `tinyllama:latest` | 637 MB | no | no | Smoke-test / connectivity check |
| `gemma3:27b-it-q4_K_M` | 17 GB | **no** | no | Summarisation only — do not use for agentic/tool-calling jobs |
| `qwen3:14b` | ~9 GB | **yes** | **yes** | Lightweight agentic jobs, validation |
| `qwen3:30b-a3b` | ~17 GB | **yes** | **yes** | Primary agentic model — MoE, fast, fits in 24 GB VRAM |

> **Warning:** Gemma3 does not support tool calling. It was wired into a cron job in May 2026 and failed silently, falling back to Haiku every run. Always verify tool support before registering a model in OpenClaw — see `/srv/ollama/CLAUDE.md`.

> **From inside Docker container:** reach host Ollama at `http://172.17.0.1:11434`, not `localhost`.

## Local Vault & Code Access

The Guide machine has full read access to everything the Engineer Claude needs:

| Resource | Path | Purpose |
|----------|------|---------|
| guide-build | `/srv/guide-build/` | All specs, briefs, CLAUDE.md files, chunks |
| guide-core | `/srv/guide-core/` | OpenClaw workspace templates, skills, agent framework |
| guide-engine | `/srv/guide-engine/` | ETL scripts and exporters — code |
| guide-data | `/srv/guide-data/` | Output directory — markdown written by guide-engine, read by agents |
| OneDrive (Wilderness) | `/srv/onedrive/` | Shared team documents — abraunegg/onedrive client, pending install |

**Rule:** The Engineer Claude reads these directly. No need to copy specs into sessions.

## Network

| Machine | Role | OS | Tailscale IP | Status |
|---------|------|-----|-------------|--------|
| **Mac** | Gareth's laptop (Architect) | macOS | Active | Live |
| **Mac Mini M2 Pro** | Hot rollback (soak period) | macOS | 100.72.42.1 | Standby — decommission after soak ends ~2026-05-25 |
| **guide-server (HP Z8 G4)** | Guide runtime | Ubuntu 24.04 | 100.80.44.14 | **Live** — CHUNK-07c complete 2026-05-19 |
| **Sentinel** | Infrastructure monitoring | TBC | TBC | Planned |

All machines connected via Tailscale. No public internet exposure.

## Service Map (Current State — 2026-05-21)

| Service | Port | Machine | Status |
|---------|------|---------|--------|
| OpenClaw gateway | 18789 (host loopback) | guide-server | **Live** — Docker + systemd (`openclaw.service`), `network_mode: host` |
| Huginn automation | 3000 (internal) / 3001 (Tailscale) | guide-server | **Live** — Docker Compose + systemd (`huginn.service`) |
| Ollama LLM inference | 11434 | guide-server | **Live** — systemd (`ollama.service`), GPU-backed |
| Docker Engine | — | guide-server | **Live** |
| Hermes agent platform | — | guide-server | Directory prepared (`/srv/hermes/`), not running |
| Open WebUI | — | guide-server | Directory prepared (`/srv/openwebui/`), not running |
| Paperclip orchestration | — | guide-server | **Installation in progress** (2026-05-21) |
| PostgreSQL | — | guide-server | `/srv/db/postgres/` prepared, not running as standalone service |
| Redis | — | guide-server | `/srv/db/redis/` prepared, not running as standalone service |
| ETL API (Python) | 5010 | guide-server | Not started |

All services bind to 127.0.0.1 (loopback only). Remote access via Tailscale.

## Filesystem Architecture

Production directory structure for Guide on guide-server. All paths are under `/srv/`.

| Directory | Purpose | Status |
|-----------|---------|--------|
| `/srv/openclaw/` | OpenClaw state root — config, workspaces, skills, credentials | **Live** |
| `/srv/openclaw/workspaces/` | All agent workspaces (main + 12 agents) | **Live** |
| `/srv/openclaw/skills/` | Skills directory — 19 skills on disk | **Live** |
| `/srv/openclaw/openclaw.json` | Live OpenClaw config (guide:guide-data 640) | **Live** |
| `/srv/guide-core/` | OpenClaw workspace templates, scripts, agent factory | **Live** |
| `/srv/guide-engine/` | ETL scripts and exporters | **Live** |
| `/srv/guide-build/` | Specs, chunks, CLAUDE.md files (this vault) | **Live** (read-only mount in container) |
| `/srv/guide-vaults/personal/` | Per-person agent vaults (nick, keith, hadley, caro, dean, julian) | **Live** |
| `/srv/guide-vaults/shared/` | Cross-agent shared data — brand, camps, countries, KB, sales | **Live — populated** |
| `/srv/guide-vaults/teams/digital/` | Digital team vault — live via Obsidian Sync | **Live** (2026-05-19) |
| `/srv/guide-vaults/teams/exco/` | Exco team vault | **Live — has content** |
| `/srv/guide-vaults/teams/hr/` | HR team vault | Directory only — empty |
| `/srv/guide-vaults/teams/reservations/` | Reservations team vault | Directory only — empty |
| `/srv/guide-vaults/teams/sales/` | Sales team vault | Directory only — empty |
| `/srv/guide-outputs/` | Agent outputs — append-only | **Live** |
| `/srv/guide-data/` | Pipeline data — restricted to gareth | **Live** (empty pending pipelines) |
| `/srv/guide-staging/` | Skills/scripts staging scratchpad | **Live** |
| `/srv/huginn/` | Huginn config, docker-compose.yml, data | **Live** |
| `/srv/ollama/` | Ollama docs; models on `/mnt/storage/ollama/models` | **Live** |
| `/srv/hermes/` | Hermes data + profiles | Prepared — not running |
| `/srv/openwebui/` | Open WebUI data | Prepared — not running |
| `/srv/paperclip/` | Paperclip data | Installing (2026-05-21) |
| `/srv/db/` | Database volumes (postgres, redis) | Prepared — not running as standalone |
| `/srv/compose/` | Docker Compose files (openclaw.yml, Dockerfiles) | **Live** |
| `/srv/backup/` | Backup dumps (openclaw-backup.sh output) | **Live** |
| `/srv/landing-pages/` | Landing pages | Exists — purpose TBD |
| `/srv/onedrive/` | OneDrive mount point | Empty — pending OneDrive setup |

**Status:** All core directories live — CHUNK-07c complete 2026-05-19.

## Access Model

| Level | Who | Channel | Sees What |
|-------|-----|---------|-----------|
| **Architect** | Gareth | Telegram + shell | Everything |
| **Personal** | Nick, Hadley, Keith, Scott, Caro, Frances, Simon, Dean | Telegram (per-person bot) | Own private Guide instance with scoped team vault access |
| **Operator** | Team leads (Danny, Richard, Laura, Matt; Ashleigh joins 2026-05-11) | Telegram | Agent outputs, can trigger team-scoped agents |
| **Consumer** | Wider team | Slack | Read-only channels, briefs and reports |

## Slack Channels

| Channel | ID | Mode | Notes |
|---------|----|------|-------|
| #guide-briefs | C0ATG3V2EDN | Bidirectional | Guide posts briefs |
| #guide-ops | C0ASJDN5KGV | Bidirectional | Ops comms |
| #guide-alerts | C0ASJDP022H | Bidirectional | Alert escalation |
| #wilderness-digital-team | C0987SGJ9NJ | Bidirectional | Digital team channel (upgraded from post-only 2026-04-20) |
| #guide-data-backlog | C0ASP8ZD495 | Bidirectional | PIE process — routes to Data CLAUDE.md |
| #guide-martech-backlog | C0AT56RRUEP | Bidirectional | Routes to MarTech CLAUDE.md |
| #alerts | C0AFFV58ZCY | Bidirectional | Monitor + escalate urgent items to Gareth via Telegram |
| #guide-logs | C0ATGQ167SN | Bidirectional | Nightly digest cron at 21:00 Europe/London |
| #guide-seo (SEO channel) | C0ATXQ8MDS5 | Bidirectional | SEO channel |
| #digital-product-external-triage-list | C0AUT4WSPBJ | Bidirectional | Laura's triage channel (added 2026-04-20) |

## Backup

| What | Script | Schedule | Destination | Retention |
|------|--------|----------|-------------|-----------|
| `/srv/openclaw/` on guide-server | `/srv/guide-core/scripts/openclaw-backup.sh` | Daily 04:00 (gareth crontab) | `/srv/backup/openclaw-YYYYMMDD-HHMM.tar.gz` | 30 days |
| `/srv/` on guide-server | restic | Not yet configured | TBD (local + Backblaze B2) | 7 daily, 4 weekly, 12 monthly |

## Slack DM Policy

Controlled by `dmPolicy` and `allowFrom` in `openclaw.json`.

**Current config:** `dmPolicy: "pairing"` — Guide only holds two-way conversations with users in `allowFrom`. Users outside the list can receive messages from Guide but their replies are ignored.

**Current `allowFrom`:** Gareth (`U07NDN5T57A`), Laura (`U08UX404HDK`), Danny (`U0AAW754GEA`), Richard (`U08HDPM75FD`).

**Note:** `dmOutboundAllowlist` and `dmPoliteList` do not exist in the OpenClaw schema — do not add these keys. Outbound DM control is an open gap; see CHUNK-07 security notes.

### Slack DM Tier Model (live — ADR-015)

| DM Mode | Who | Slack IDs | Guide sends | They reply | Guide responds | Vault access |
|---------|-----|-----------|------------|------------|----------------|--------------|
| **Full** | Gareth, Laura, Danny, Richard | U07NDN5T57A, U08UX404HDK, U0AAW754GEA, U08HDPM75FD | ✅ | ✅ | ✅ full | ✅ |
| **Polite** | Maria, Fay, David, Jack, Tenneil, Adam, Claire, Frances, Yoann | U068JTPF1UL, U095N3ADT6W, U0A7YBTBS03, U08HDPKFK43, U098FB39ANR, U0A1KJUT4LQ, U09D2LYUJ1J, U096ND9S0UD, U0982MRSBM5 | ✅ reminders/nudges | ✅ | ✅ limited — acknowledge, redirect to #guide-ops | ❌ |
| **None** | Everyone else | — | ❌ | — | — | — |

**Still missing Slack IDs:** Matt Wylie, Rafael Aquino (add when collected).
**Joining soon (add when onboarded):** Michael (2026-05-05), Ashleigh (2026-05-11), Elise (2026-05-18), Kieron (2026-06-15), Andrea (2026-06-22).

## OS Conventions

Guide runs Ubuntu Linux. Chunks account for Linux-specific setup:

| Dimension | Value |
|-----------|-------|
| OS | Ubuntu (Linux) |
| Service mgmt | systemd |
| Packages | apt |
| Docker | Docker Engine (Linux native — not Docker Desktop) |
| Runtime | OpenClaw (Docker Compose) |
| GPU | Nvidia RTX 3090 — CUDA drivers + nvidia-container-toolkit required |

---

## Session Retention (openclaw.json)

Applied 2026-04-20:
- `session.maintenance.mode: "enforce"`, `pruneDays: 7`, `resetArchiveRetention: "7d"`
- `cron.sessionRetention: "7d"` (was `"24h"`)

## Message & Streaming Defaults (openclaw.json)

Applied 2026-05-01:

| Setting | Value | Scope | Why |
|---------|-------|-------|-----|
| `messages.suppressToolErrors` | `true` | Top-level | Tool error payloads (e.g. "⚠️ Edit failed") are visible to the user by default. The agent already sees the error and retries — no reason to surface in chat. |
| `channels.telegram.streaming.preview.toolProgress` | `false` | Global Telegram default | Live tool progress messages (e.g. "🔧 running...") render during partial streaming. Users should see final output only. |
| `channels.telegram.accounts.<name>.streaming.preview.toolProgress` | `false` | Per-account | Must be set on every Telegram account — the global default alone may not override account-level settings. |

**Every new Telegram account** added to `channels.telegram.accounts` needs `streaming.preview.toolProgress: false`. Add to the pre-flight checklist.

**Slack/Discord equivalent:** Check whether `channels.slack.streaming.preview.toolProgress` exists in the schema. If it does, apply the same setting. Slack socket mode may handle streaming differently — verify before adding.

**Action item:** When the Engineer next has a session, run `openclaw config schema` and check whether `channels.slack.streaming.preview.toolProgress` exists. If it does, apply the same `false` setting. Slack socket mode may handle streaming differently — it's less likely to leak progress messages since Slack doesn't do live streaming the same way Telegram does, but verify.

*Updated: 2026-05-21 — service map, filesystem, and LLM docs updated to reflect live state*
