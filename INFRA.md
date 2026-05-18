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
| OS | Ubuntu 24.04 LTS (kernel 6.17.0-23-generic) |
| Hostname | guide-server |
| Role | Guide runtime, data pipeline host, cron executor, local LLM inference |
| File access | /srv/guide-build (cloned), /srv/guide-core, /srv/guide-engine, /srv/onedrive (OneDrive — pending) |
| Network | Tailscale live — `guide-server` (100.80.44.14) |
| Status | **Foundation complete 2026-05-18. OpenClaw migration from Mac Mini pending. CHUNK-07 hardening pending.** |

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
| **Mac Mini M2 Pro** | OpenClaw runtime (interim) | macOS | 100.72.42.1 | Live — pending migration to guide-server |
| **guide-server (HP Z8 G4)** | Guide runtime (target) | Ubuntu 24.04 | 100.80.44.14 | Foundation complete — OpenClaw migration pending |
| **Sentinel** | Infrastructure monitoring | TBC | TBC | Planned |

All machines connected via Tailscale. No public internet exposure.

## Service Map (Target State)

| Service | Port | Machine | Status |
|---------|------|---------|--------|
| OpenClaw gateway | 18789 | Mac Mini (interim) | **Live on Mac Mini** — migration to guide-server pending |
| OpenClaw Studio / TUI | — | Mac Mini (interim) | **Live on Mac Mini** — migration to guide-server pending |
| ETL API (Python) | 5010 | guide-server | Not started |
| Docker Engine | — | guide-server | **Live** (Docker 29.5.0) |

All services bind to 127.0.0.1 (loopback only). Remote access via Tailscale.

## Filesystem Architecture (CHUNK-12+)

Production directory structure for Guide. See [[personal-instance-architecture]] for full specification and `Specs/guide-bootstrap.sh` for the one-shot creation script.

| Directory | Purpose | Write access |
|-----------|---------|-------------|
| `/srv/guide-vaults/private/` | Retained from Mac Mini build — do not remove until confirmed safe | guide-data group |
| `/srv/guide-vaults/personal/` | Per-person agent workspaces (nick/, hadley/) | guide-data group |
| `/srv/guide-vaults/shared/` | Cross-agent shared data | guide-data group |
| `/srv/guide-vaults/teams/` | Team vaults — SMB share `guide-teams` | guide-data group; digital/ symlink to OneDrive deferred |
| `/srv/guide-outputs/` | Agent outputs — append-only | SMB share `guide-outputs` |
| `/srv/guide-data/` | Pipeline data — restricted | SMB share `guide-data`, gareth only |
| `/srv/openclaw/workspace/` | OpenClaw workspace root | guide-data group |
| `/srv/openclaw/config/` | OpenClaw config | guide-data group — managed via guide-core |

**Status:** Directories created — foundation complete 2026-05-18. OpenClaw migration to populate workspace/config pending.

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
| `~/.openclaw/` on Mac Mini | `~/guide-core/scripts/openclaw-backup.sh` | Daily 04:00 (crontab on Mac Mini) | `~/openclaw-backups/openclaw-YYYYMMDD-HHMM.tar.gz` | 30 days |
| `/srv/` on guide-server | restic | Not yet configured — CHUNK-07 | TBD (local + Backblaze B2) | 7 daily, 4 weekly, 12 monthly |

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
