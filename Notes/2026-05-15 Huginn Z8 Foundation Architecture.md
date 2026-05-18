---
title: "Huginn Z8 — Foundation Architecture"
type: note
area: infra
project: Guide
tags: [infra, z8, huginn, ubuntu, docker, filesystem, smb, backup, onedrive]
status: draft — needs Architect decisions before build
created: 2026-05-15
---

# Huginn Z8 — Foundation Architecture

Pre-build system design for the HP Z8 G4 (Huginn). This document must be completed and signed off by Gareth before any Engineer build work begins. Claude Code implements from this spec — gaps discovered mid-build are expensive.

---

## Machine

- Hostname: huginn
- Hardware: HP Z8 G4, 2× Xeon Gold 6134, 128GB RAM, 1TB NVMe, 4TB HDD, RTX 3090 24GB VRAM
- OS: Ubuntu (latest LTS)
- Role: Guide runtime, data pipeline host, local LLM inference, web services, automation

---

## Users

| User | Type | Shell | Purpose | Notes |
|------|------|-------|---------|-------|
| `gareth` | Admin | bash | Daily management, SSH access, sudo (scoped) | Pre-exists on machine |
| `guide` | Service | nologin | Runs OpenClaw, owns /home/guide/ runtime state | Pre-exists — shell must be corrected to nologin and account locked |
| `engineer` | Restricted | bash | Claude Code sessions — scoped to code repos only | Created during foundation build |

**Note (confirmed 2026-05-18):** `guide` already exists on this machine. Do not attempt to recreate it — correct it:
```bash
sudo usermod --shell /usr/sbin/nologin guide
sudo passwd -l guide
```

**Groups:**

| Group | Members | Purpose | Notes |
|-------|---------|---------|-------|
| `guide-data` | guide, gareth | Read/write to /srv/guide/ | Created during foundation build |
| `srv-data` | guide, gareth, engineer | Read/write to /srv/ service directories | Created during foundation build |
| `docker` | gareth, guide | Run docker compose without sudo | Created by Docker installer — add gareth after Step 5, not before |
| `smb-users` | gareth + any future SMB users | Samba access | Created during foundation build |

**sudo policy for gareth:**
Scoped NOPASSWD entries only — not blanket sudo. Covers:
- `systemctl restart/start/stop` for named services
- `ufw` rule changes
- `restic` backup commands
- Nothing else without a password

---

## /srv/ Directory Structure

```
/srv/
/srv/logs/
/srv/guide-build/          ← Architect vault — specs, chunks, agent definitions (git repo, read-only on this machine)
/srv/guide-core/           ← OpenClaw build files — agent factory, workspace templates, skills (git repo)
/srv/guide-engine/         ← Data pipelines — ETL scripts, BQ, HubSpot, GA4, Ads exporters (git repo)
/srv/guide-data/           ← Pipeline data written by guide-engine, read by agents
/srv/guide-outputs/        ← Agent outputs — append-only, git-tracked (SMB share: guide-outputs)
/srv/guide-vaults/         ← All agent vaults
/srv/guide-vaults/private/           ← Retained from Mac Mini build — do not remove until confirmed safe
/srv/guide-vaults/personal/          ← Per-person agent workspaces
/srv/guide-vaults/personal/nick/
/srv/guide-vaults/personal/hadley/
/srv/guide-vaults/shared/            ← Cross-agent shared data
/srv/guide-vaults/teams/             ← Team vaults (SMB share: guide-teams)
/srv/guide-vaults/teams/digital/     ← Symlink to OneDrive — deferred, wire up after services stable
/srv/guide-vaults/teams/exco/
/srv/guide-vaults/teams/sales/
/srv/guide-vaults/teams/reservations/
/srv/guide-vaults/teams/hr/
/srv/openclaw/             ← OpenClaw runtime
/srv/openclaw/workspace/   ← OpenClaw workspace root (replaces ~/.openclaw/workspace)
/srv/openclaw/config/      ← OpenClaw config (replaces ~/.openclaw/openclaw.json)
/srv/hermes/               ← Hermes Agent
/srv/hermes/profiles/      ← One subdirectory per profile (analyst-paid, analyst-seo, etc.)
/srv/hermes/data/          ← Shared data accessible to all profiles
/srv/paperclip/            ← Paperclip orchestration
/srv/paperclip/data/
/srv/huginn/               ← Huginn automation platform
/srv/huginn/data/
/srv/openwebui/            ← Open WebUI
/srv/openwebui/data/
/srv/ollama/               ← Ollama model storage — must live on 4TB HDD, not NVMe
/srv/ollama/models/
/srv/landing-pages/        ← Web properties
/srv/compose/              ← All Docker Compose files, one per service
/srv/db/                   ← All persistent database storage
/srv/db/postgres/          ← Postgres data dir (one instance, multiple DBs inside)
/srv/db/redis/             ← Redis data dir
/srv/db/clickhouse/        ← Analytics DB — deferred, do not create yet
/srv/backup/               ← Backup staging
/srv/backup/dumps/         ← Pre-snapshot DB dumps (Postgres, Redis)
/srv/backup/config/        ← restic config, repo locations, exclusions
/srv/onedrive/             ← OneDrive mount point (abraunegg/onedrive client)
```

**Storage allocation:**
- NVMe (1TB): OS, all of /srv/ except Ollama models, databases, Docker images
- HDD (4TB): /srv/ollama/models/, long-term backup staging, archive data

---

## SMB Shares

| Share name | Path | Access | Notes |
|------------|------|--------|-------|
| `guide-teams` | /srv/guide-vaults/teams/ | gareth only (at launch) | Team vaults — read/write |
| `guide-outputs` | /srv/guide-outputs/ | gareth only (at launch) | Agent outputs — read-only for non-admin |
| `guide-data` | /srv/guide-data/ | gareth only | Pipeline data — restricted |

**Not shared via SMB:**
- /srv/openclaw/ — service runtime, never exposed
- /home/gareth/ — admin home, never exposed
- /srv/db/ — databases, never exposed
- /srv/backup/ — backup staging, never exposed

Samba authenticates via smbpasswd (standalone, no AD). Gareth's SMB password set separately from system password.

---

## Databases

One Postgres container, multiple databases inside it:

| Database | Used by | Notes |
|----------|---------|-------|
| `huginn` | Huginn | Required by Huginn |
| `openwebui` | Open WebUI | Optional — defaults to SQLite, Postgres for production |
| `paperclip` | Paperclip | TBC — depends on Paperclip requirements |
| `guide_pipeline` | guide-engine | Pipeline data, HubSpot exports, GA4 |

Redis: single instance, used by Huginn (required) and any other services that need queuing/caching.

**Analytics DB — decision needed:**
- DuckDB: simpler, file-based, no server, good for ad-hoc analysis. Limitation: single writer.
- ClickHouse: server-based, columnar, scales well, better for high-volume pipeline data.
- Recommendation: DuckDB to start (low ops overhead), migrate to ClickHouse if volume demands it.

**SQLite stays per-service** for Hermes and OpenClaw lightweight state — don't migrate unnecessarily.

---

## Ollama / Local Models

- Storage: /srv/ollama/models/ → must be on 4TB HDD (models are 20GB+ each)
- Runtime: GPU-accelerated via RTX 3090 + nvidia-container-toolkit
- Primary model: Qwen 2.5 32B or Llama 3.3 34B Q4 (fits entirely in 24GB VRAM)
- 70B Q4: viable with CPU offload (VRAM + RAM), slower — for deep analysis only
- Hermes models (Nous Research): natural fit for Hermes Agent — model and runtime from same lab
- Open WebUI connects to Ollama directly as a model source

---

## OneDrive

- Client: abraunegg/onedrive (most maintained Linux client — confirm before locking in)
- Mount: /srv/onedrive/
- Runs as: systemd service under gareth or a dedicated onedrive user
- Syncs: Wilderness Safaris shared drives → /srv/onedrive/
- Symlink: /srv/guide/teams/digital/ → relevant OneDrive path for Obsidian vault access
- Decision needed: sync (two-way) or download-only (safer for production server)

---

## Backups

- Tool: restic (encrypted, deduplicated, incremental)
- Scope: entire /srv/ tree
- Pre-snapshot: DB dumps written to /srv/backup/dumps/ before restic runs
  - pg_dump for all Postgres databases
  - redis-cli BGSAVE for Redis
- Schedule: systemd timer (not cron) — daily at 02:00
- Destinations:
  - Local: secondary internal or USB drive (fast recovery)
  - Offsite: Backblaze B2 (decision needed — B2 account required)
- Retention: 7 daily, 4 weekly, 12 monthly
- Monitoring: backup failure → alert to Gareth via Telegram

---

## Docker Compose Organisation

One file per service in /srv/compose/. Services brought up independently.
All services start on boot via systemd → `docker compose -f /srv/compose/<service>.yml up -d`

gareth in docker group — no sudo needed for docker compose commands.

---

## Claude Code / Engineer Implementation

Claude Code (Engineer) implements this from the spec. For this to go fast:

1. Architect writes the complete foundation chunk from this note
2. Chunk creates directory structure, users, groups, permissions, SMB config, Compose scaffolding — all idempotent
3. Claude Code runs as `engineer` user or inside a Docker devcontainer scoped to /srv/ and code repos
4. Engineer never touches /home/guide/ or .openclaw/ config directly
5. Security hardening (CHUNK-07-ubuntu) runs after foundation is stable
6. Services deploy on top in sequence

**Claude Code scoping:**
- Read/write: /srv/compose/, /srv/guide/vaults/, code repos (guide-core, guide-engine)
- Read-only: /srv/guide/teams/, /srv/guide/outputs/
- No access: /home/guide/.openclaw/, /srv/db/ (databases managed separately), /srv/backup/

---

## guide-build Vault — Sync Strategy (decided 2026-05-18)

The guide-build vault (specs, prompts, chunks, architecture docs) is an Obsidian vault on Gareth's Mac. Obsidian Sync requires the desktop app running — it cannot run headlessly on a Linux server.

**Decision:** guide-build is a Git repository, not an Obsidian Sync vault.

- **Location:** `/srv/guide-build/` — cloned directly to its permanent location during foundation build
- Synced via: Git (private GitHub repo)
- Source of truth: Gareth's Mac (push from Mac after edits)
- To get updates on the server: `git pull` in the current location
- Obsidian on the Mac continues to read/write the vault normally — it just also happens to be a git repo
- Agents and Claude Code on the server read from whichever location is current; no Obsidian app needed server-side

**Prerequisite before Linux build starts:** guide-build GitHub repo must exist and be initialised. ✓ Done 2026-05-18.

---

## Open Questions — Architect Decisions Needed

Before this spec is handed to the Engineer, the following must be decided:

1. **Analytics DB**: DuckDB or ClickHouse?
2. **OneDrive client**: abraunegg/onedrive confirmed? Sync mode: two-way or download-only?
3. **Backup offsite**: Backblaze B2 account — set up before or after foundation build?
4. **SMB users**: Anyone other than Gareth getting SMB access at launch?
5. **Engineer user vs container**: Is `engineer` a system user, or does Claude Code run inside a Docker devcontainer?
6. **Landing pages**: Static (nginx) or dynamic (needs a runtime — Node, Python)?
7. **Huginn**: Is this Huginn the automation software (requires Postgres + Redis), or just the machine name?
8. **Paperclip**: What does Paperclip need from the filesystem? Does it have a database requirement?
9. **Monitoring**: Grafana + Prometheus, or something lighter? Decide before build so monitoring is included in foundation.

---

## Related Files

- `Notes/2026-05-15 Z8 Security Best Practice.md` — security hardening reference, read alongside CHUNK-07
- `BUILD/DEV-CHUNKS/CHUNK-07-security-hardening.md` — macOS version, preserve and rewrite for Ubuntu
- `INFRA.md` — infrastructure reference (update after foundation build)

---

## Status

Draft. Architect to review, answer open questions, and produce foundation chunk before Engineer session begins.
