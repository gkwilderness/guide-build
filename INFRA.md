---
title: "Guide — Infrastructure"
type: infra
area: ai
project: "Guide"
tags: [ai, guide, infra]
status: active
updated: 2026-04-20
---
# Guide — Infrastructure

## Guide Machine

| Property | Value |
|----------|-------|
| Name | Guide |
| Hardware | HP Z8 G4 (2× Xeon Gold 6134 3.20GHz, Nvidia RTX 3090 24GB VRAM) |
| RAM | 128 GB |
| Storage | 1 TB NVMe + 4 TB HDD |
| OS | Ubuntu (Linux) — migrating from macOS week of 2026-05-12 |
| Role | Guide runtime, data pipeline host, cron executor, local LLM inference |
| File access | guide-build vault (synced), OneDrive (Wilderness, read-only), guide-core, guide-engine |
| Network | Tailscale live — `guide.tailfbf66e.ts.net` (100.72.42.1), `tailscale serve` → gateway port 18789 |
| Status | **Migration in progress — Ubuntu setup week of 2026-05-12. CHUNK-07 hardening spec to be re-written for Ubuntu + Docker before executing.** |

### Local LLM Capability

The RTX 3090 (24GB VRAM) enables on-premise inference for sensitive data that cannot go to external APIs.

| Model class | VRAM fit | Use case |
|-------------|----------|----------|
| 34B (Qwen 2.5 32B, Llama 3.3 34B) — Q4 quantized | Fits in VRAM (~20GB) | Primary local inference — HR data, board docs, financial projections |
| 70B — Q4 quantized | Needs CPU offload (~40GB; VRAM + RAM) | Viable but slower — deep analysis on sensitive data |

**Runtime:** Ollama with CUDA backend. Integrated into OpenClaw model routing as a new tier — see model routing table in `00_Guide-Project-Brief.md`.

## Local Vault & Code Access

The Guide machine has full read access to everything the Engineer Claude needs:

| Resource | Path | Purpose |
|----------|------|---------|
| Guide vault | `$GUIDE_VAULT_PATH` | All specs, briefs, CLAUDE.md files, chunks |
| guide-core | `~/guide-core/` | OpenClaw workspace templates, skills, agent framework |
| guide-engine | `~/guide-engine/` | ETL scripts and exporters — code |
| guide-data | `~/guide-data/` | Output directory — markdown written by guide-engine, read by agents |
| OneDrive (Wilderness) | `~/Library/CloudStorage/OneDrive-Wilderness/` | Shared team documents, Guide anchor at `Documents/Wilderness/guide/` |

**Rule:** The Engineer Claude reads these directly. No need to copy specs into sessions.

## Network

| Machine | Role | OS | Tailscale IP | Status |
|---------|------|-----|-------------|--------|
| **Mac** | Gareth's laptop (Architect) | macOS | Active | Live |
| **Guide** | Guide runtime | macOS | 100.72.42.1 | **Live** — `tailscale serve` proxies to gateway |
| **Sentinel** | Infrastructure monitoring | TBC | TBC | Planned |

All machines connected via Tailscale. No public internet exposure.

## Service Map (Target State)

| Service | Port | Machine | Status |
|---------|------|---------|--------|
| OpenClaw gateway | 18789 | Guide | **Live** — `gateway.bind = "lan"` (0.0.0.0 in container), `tailscale serve` proxies `https://guide.tailfbf66e.ts.net` |
| OpenClaw Studio / TUI | — | Guide | **Live** — accessible via `https://guide.tailfbf66e.ts.net` (Tailscale auth required) |
| ETL API (Python) | 5010 | Guide | Not started |
| Docker Desktop | — | Guide | **Live** |

All services bind to 127.0.0.1 (loopback only). Remote access via Tailscale.

## Filesystem Architecture (CHUNK-12+)

Production directory structure for Guide. See [[personal-instance-architecture]] for full specification and `Specs/guide-bootstrap.sh` for the one-shot creation script.

| Directory | Purpose | Write access |
|-----------|---------|-------------|
| `~/guide-vault/` | Agent workspaces — `main/`, `channel/`, `shared/`, `personal/` | Each agent writes only to its own subdirectory |
| `~/guide-teams/` | Team vaults — `digital/` (symlink to OneDrive), `exec/`, `sales/`, `reservations/`, `people/` | Teams via OneDrive; agents read-only |
| `~/guide-shared/` | Supplementary cross-team — `brand/`, `data/`, `kb/` | Pipeline agent or manual; agents read-only |
| `~/guide-outputs/` | Agent outputs — append-only, git-tracked | Shared agents only; personal agents read-only |

**Status:** Not yet created — CHUNK-12 creates these directories and migrates existing workspaces from `~/.openclaw/workspace-*`.

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
| `~/.openclaw/` (excl. logs, cron, delivery-queue, memory, devices) | `~/scripts/openclaw-backup.sh` | Daily 04:00 (crontab) | `~/openclaw-backups/openclaw-YYYYMMDD-HHMM.tar.gz` | 30 days |

Log: `~/openclaw-backups/backup.log`

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

*Updated: 2026-05-01*
