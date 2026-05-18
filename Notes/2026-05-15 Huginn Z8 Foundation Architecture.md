---
title: "Guide Z8 — Foundation Architecture"
type: note
area: infra
project: Guide
tags: [infra, z8, guide, ubuntu, docker, filesystem, smb, backup, onedrive]
status: approved — ready for Engineer
created: 2026-05-15
updated: 2026-05-18
---

# Guide Z8 — Foundation Architecture

Pre-build system design for the HP Z8 G4 (Guide machine). This document is the Architect's signed-off spec — the Engineer (Claude Code on the Guide machine) implements from this directly. Do not start the build without reading it in full.

---

## Machine

- Hostname: guide
- Hardware: HP Z8 G4, 2× Xeon Gold 6134, 128GB RAM, 1TB NVMe, 4TB HDD, RTX 3090 24GB VRAM
- OS: Ubuntu (latest LTS)
- Role: Guide runtime, data pipeline host, local LLM inference, web services, automation

---

## Users

| User | Type | Shell | Purpose | Notes |
|------|------|-------|---------|-------|
| `gareth` | Admin | bash | Daily management, SSH access, sudo (scoped) | Pre-exists on machine |
| `guide` | Service | nologin | Runs OpenClaw, owns /srv/openclaw/ runtime state | Pre-exists — shell must be corrected to nologin and account locked |
| `engineer` | Restricted | bash | Claude Code sessions — scoped to code repos only | Created during foundation build |

**Note (confirmed 2026-05-18):** `guide` already exists on this machine. Do not attempt to recreate it — correct it:
```bash
sudo usermod --shell /usr/sbin/nologin guide
sudo passwd -l guide
```

**Groups:**

| Group | Members | Purpose | Notes |
|-------|---------|---------|-------|
| `guide-data` | guide, gareth | Read/write to /srv/guide-vaults/, /srv/openclaw/ | Created during foundation build |
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

**As implemented (2026-05-18):** Two broad shares scoped to working surfaces.

| Share name | Path | Access | Notes |
|------------|------|--------|-------|
| `srv` | /srv | gareth (admin users) | Full read/write to all service directories |
| `home` | /home | gareth (admin users) | Access to /home/gareth and /home/engineer |

Mac mounts: `smb://guide-server/srv` and `smb://guide-server/home`

**Not exposed via SMB:** /etc, /root, /var, /boot, /usr, /opt, /tmp, /proc, /sys, /dev — system-level edits go through SSH + sudo.

Samba authenticates via smbpasswd (standalone, no AD). Gareth's SMB password set separately from system password.

---

## Databases

One Postgres container, multiple databases inside it:

| Database | Used by | Notes |
|----------|---------|-------|
| `huginn` | Huginn automation platform | Required by Huginn |
| `openwebui` | Open WebUI | Optional — defaults to SQLite, Postgres for production |
| `paperclip` | Paperclip | Requires PostgreSQL |
| `guide_pipeline` | guide-engine | Pipeline data, HubSpot exports, GA4 |

Redis: single instance, used by Huginn (required) and any other services that need queuing/caching.

**Analytics DB:** Deferred — DuckDB vs ClickHouse decision TBD after foundation is stable.

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

- Client: abraunegg/onedrive
- Mount: /srv/onedrive/
- Runs as: systemd service under gareth
- Syncs: Wilderness Safaris shared drives → /srv/onedrive/
- Sync mode: two-way
- Symlink: /srv/guide-vaults/teams/digital/ → relevant OneDrive path — deferred, wire up after services are stable

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
  - Offsite: Backblaze B2 — deferred, set up after foundation is stable
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

1. Engineer reads this note and the bootstrap prompt in full before starting
2. Bootstrap prompt creates directory structure, users, groups, permissions, Tailscale, SMB config, runtimes — all idempotent
3. Claude Code runs as `engineer` system user (not devcontainer — revisit later)
4. Engineer never touches /srv/openclaw/config/ directly — config is managed via guide-core
5. Security hardening (CHUNK-07-ubuntu) runs after foundation is stable
6. Services deploy on top in sequence via Docker Compose

**Claude Code scoping:**
- Read/write: /srv/compose/, /srv/guide-vaults/, /srv/guide-core/, /srv/guide-engine/
- Read-only: /srv/guide-build/ (Architect vault — pull only, never push from this machine)
- No access: /srv/openclaw/config/, /srv/db/, /srv/backup/

---

## guide-build Vault — Sync Strategy (decided 2026-05-18)

The guide-build vault (specs, prompts, chunks, architecture docs) is an Obsidian vault on Gareth's Mac. Obsidian Sync requires the desktop app running — it cannot run headlessly on a Linux server.

**Decision:** guide-build is a Git repository, not an Obsidian Sync vault.

- **Location:** `/srv/guide-build/` — cloned directly to its permanent location during foundation build
- Synced via: Git (private GitHub repo — `github.com/gkwilderness/guide-build`)
- Source of truth: Gareth's Mac (push from Mac after edits)
- To get updates on the server: `git -C /srv/guide-build pull`
- Obsidian on the Mac continues to read/write the vault normally
- Agents and Claude Code on the server read from /srv/guide-build/; no Obsidian app needed server-side

**Prerequisite before Linux build starts:** guide-build GitHub repo must exist and be initialised. ✓ Done 2026-05-18.

---

## Decisions Log

All foundation decisions resolved 2026-05-18:

| Decision | Outcome |
|----------|---------|
| Machine hostname | `guide` |
| Analytics DB | Deferred — DuckDB vs ClickHouse TBD after foundation stable |
| OneDrive sync mode | Two-way (abraunegg/onedrive) |
| SMB users at launch | Gareth only |
| Engineer: user vs container | System user (`engineer`) for now — revisit for devcontainer later |
| Monitoring | Deferred — htop only until services are stable |
| Backblaze B2 offsite backup | Deferred — set up after foundation stable |
| Huginn | Both: machine was previously called Huginn (now renamed Guide), and Huginn the automation software is a service running on it |
| Paperclip requirements | PostgreSQL, Node 20+, git worktrees |
| Landing pages | Deferred |

---

## Related Files

- `Prompts/PROMPT_Engineer-guide-foundation-bootstrap.md` — executable bootstrap prompt for the Engineer
- `Notes/2026-05-15 Z8 Security Best Practice.md` — security hardening reference, read alongside CHUNK-07
- `BUILD/DEV-CHUNKS/CHUNK-07-security-hardening.md` — macOS version, preserve and rewrite for Ubuntu
- `INFRA.md` — infrastructure reference (update after foundation build)

---

## Known Issues — Flag for CHUNK-07

- **`guide` user has unexpected sudo group membership** — verification gate shows `guide: groups=guide,adm,cdrom,sudo,...`. The spec requires the guide service user to have no sudo access. This was pre-existing on the machine and was not corrected during the foundation build. Must be addressed in CHUNK-07 hardening.

---

## Status

**Foundation complete 2026-05-18.** Next: OpenClaw migration chunk, then CHUNK-07 security hardening.
