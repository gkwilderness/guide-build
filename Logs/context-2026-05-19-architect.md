---
title: "context-2026-05-19-architect"
type: log
area: infra
project: Guide
tags: [infra, guide, paths, obsidian, architect, session-log]
date: 2026-05-19
---

# Session Handover — 2026-05-19 (Architect)

Architect session on guide-server. Focus: path cleanup after Z8 migration + Obsidian vault setup.

---

## What Was Done This Session

### 1. Path cleanup — all spec docs updated to Z8 canonical paths

Every doc that still referenced Mac Mini / `~/` / `~/.openclaw/` / macOS paths has been updated. Files touched:

| File | What changed |
|------|-------------|
| `CLAUDE.md` | Runtime row, Vault row, Build Status section, roster path, signals path, date |
| `INFRA.md` | Machine status, network table (Mac Mini row), service map, backup paths, filesystem table, date |
| `BUILD.md` | CHUNK-07c status → ✅ Complete, CHUNK-07a/08 notes updated, build principle 8 |
| `BUILD/DEV-CHUNKS/_CONVENTIONS.md` | ⚠️ banner removed, System Assumptions rewritten for Z8, full Canonical Paths table replaced, agent factory paths, macOS→Ubuntu conventions section, cron path (jobs.json → openclaw.json key) |
| `BUILD/DEV-CHUNKS/CHUNK-07a-google-integration.md` | All `~/` paths to `/srv/`, brew→Linux note for gog, docker .env → systemd override, TOOLS/BOOTSTRAP paths |
| `BUILD/DEV-CHUNKS/CHUNK-08-cron-ops.md` | Status banner updated, pre-chunk backup path, all `~/guide-core/` and `~/.openclaw/workspace/` paths replaced |

**Key path mappings applied throughout:**
- `~/.openclaw/` → `/srv/openclaw/`
- `~/.openclaw/workspace/` → `/srv/openclaw/workspaces/main/`
- `~/.openclaw/workspace-{role}/` → `/srv/openclaw/workspaces/{role}/`
- `~/.openclaw/workspace-personal-{name}/` → `/srv/openclaw/workspaces/personal-{name}/`
- `~/guide-core/` → `/srv/guide-core/`
- `~/guide-vault/` → `/srv/guide-vaults/`
- `~/Obsidian/Wilderness-Guide/` → `/srv/guide-vaults/teams/digital/`
- Cron: no separate `jobs.json` — cron config lives in `/srv/openclaw/openclaw.json` under `cron` key
- Workspace logs: `/srv/openclaw/logs/gateway.log` (no `/tmp/openclaw/`)
- Signals: `/srv/openclaw/workspaces/main/signals/`

### 2. Obsidian digital team vault — live

- Deleted empty `/srv/guide-vaults/teams/digital/` stub to let Obsidian create its own folder name
- Gareth opened Obsidian in remote desktop session, pointed at `/srv/guide-vaults/teams/digital/` — vault synced via Obsidian Sync
- Vault is fully populated with Wilderness Digital team content (00-Compass, 10-Areas, 10-Infra, 20-Projects, 25-Channels, 30-People, 40-Meetings, 50-Reports, 70-Reports, __INBOX, __Logs, __DASHBOARD, CLAUDE.md, INDEX.md)
- Permissions: `gareth:guide-data 775` — gareth owns (Obsidian writes), guide-data group write (Guide writes)
- Container has `/srv/guide-vaults` mounted at same path — Guide can read/write

### 3. Live workspace files patched — all agents

Guide and all channel agents had `~/Obsidian/Wilderness-Guide/` and `~/guide-vault/` paths in workspace identity files. These caused boot failures ("vault not on Z8").

**Main agent** (`/srv/openclaw/workspaces/main/`):
- `SOUL.md` — vault write rule path
- `AGENTS.md` — boot sequence vault load, vault access rules, strategic context path
- `BOOT.md` — added Team Vault section, removed "OneDrive pending" blocker, updated pending list
- `TOOLS.md` — added digital team vault row, fixed cron path, fixed container user (gareth→guide uid=1002)
- `MEMORY.md` — Nick's personal vault path

**Channel agents** (bulk sed across data, martech, seo, hubspot, product, safari workspaces):
- `BOOT.md`, `AGENTS.md`, `TOOLS.md` in each — all `~/Obsidian/Wilderness-Guide/` → `/srv/guide-vaults/teams/digital/`
- `~/guide-vault/shared/` → `/srv/guide-vaults/shared/`
- `~/guide-vault/personal/` → `/srv/guide-vaults/personal/`

**personal-nick** workspace (`SOUL.md`, `AGENTS.md`, `USER.md`, `BOOTSTRAP.md`):
- All `~/guide-vault/personal/nick/` → `/srv/guide-vaults/personal/nick/`
- All `~/guide-vault/teams/` → `/srv/guide-vaults/teams/`
- All `~/guide-vault/shared/` → `/srv/guide-vaults/shared/`

Historical session memory files (`memory/*.md`) still contain old paths — these are conversation records, not instructions. Left as-is intentionally.

### 4. Workspace file permissions — loosened for setup phase

Identity files are temporarily `gareth:guide-data 664` (writable) for active setup work. This is intentional. Lockdown reminder written to `→gareth.md` signal with exact commands to run before team comes online.

**To lock down when ready:**
```bash
sudo chown guide:guide-data /srv/openclaw/workspaces/main/SOUL.md AGENTS.md BOOT.md TOOLS.md MEMORY.md HEARTBEAT.md USER.md
sudo chmod 440 /srv/openclaw/workspaces/main/SOUL.md AGENTS.md BOOT.md TOOLS.md MEMORY.md HEARTBEAT.md USER.md
sudo systemctl restart openclaw.service
```

---

## Current State

- Guide main: boots clean — "All loaded. Gateway clean."
- Digital team vault: live and accessible
- All channel agents: vault paths corrected — should boot clean (verify in Slack)
- Workspace files: temporarily open for editing (gareth owns, 664)
- Mac Mini: still on tailnet as hot rollback, soak ends ~2026-05-25

---

## Known Gaps (not touched this session)

- `/srv/guide-vaults/shared/` — still empty (no OneDrive, no pipeline data yet)
- `/srv/guide-vaults/personal/nick/` stub files still need content (PRIORITIES.md, vs-plan.md, etc.) — see `→gareth.md` signal from 2026-05-04
- CHUNK-07a (Google integration) — paths updated, but gog Linux support unconfirmed. Check releases before executing.
- CHUNK-07d — `allowedOrigins` in openclaw.json still has old Mac Mini Tailscale URL. Small cleanup.
- CHUNK-08 — remaining tasks (cron health checks, prompt files) not yet executed.
- `→gareth.md` has several other open signals (Scott Vincent KB ingest, #digital-product-requests channel, signals git repo)

---

## Immediate Next Actions

1. Watch Slack for channel agent boot messages — confirm data/martech/seo/hubspot/product all come up clean
2. Test Guide can actually read from the digital vault (ask it something vault-dependent)
3. When team is about to come online: run the lockdown commands above
4. Mac Mini decommission after soak (~2026-05-25)

---

## Operational Notes

- **sudo needed for:** systemctl restart, chown/chmod on guide-owned files, anything in `/etc/systemd/`
- **No sudo needed for:** editing workspace .md files (now gareth-owned), reading `/srv/` dirs (gareth in guide-data group)
- **openclaw.json edits:** hot-reload on file change — no restart needed for config changes; restart needed after workspace identity file changes
- **`openclaw agents bind` CLI is broken for Slack** — edit openclaw.json directly
