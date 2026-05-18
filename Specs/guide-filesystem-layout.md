# Filesystem Layout — Z8 / Ubuntu

**Status:** APPROVED — 2026-05-18. Canonical reference for the Guide filesystem on `guide-server` (HP Z8 G4, Ubuntu 24.04).
**Supersedes:** the macOS `~/.openclaw/` + `~/guide-vault/` layout that applied during the Mac Mini interim.

OpenClaw runs in a Docker container under `openclaw.service` (systemd). The container bind-mounts `/srv/` paths from the host passthrough — so paths inside the container equal paths on the host. There is no `~/.openclaw/` indirection; `openclaw.json` carries `/srv/...` strings directly.

```
/srv/openclaw/                            ← OpenClaw runtime root
├── openclaw.json                         (lives at /srv/openclaw/config/openclaw.json — see config/)
├── config/
│   ├── openclaw.json                     ← path-rewritten from Mac Mini at migration (CHUNK-07c)
│   └── credentials/                      ← anthropic, slack-*, telegram-*, pairing.json (mode 600)
├── workspaces/
│   ├── main/                             ← Main agent (system files)
│   ├── data/
│   ├── martech/
│   ├── seo/
│   ├── product/
│   ├── hubspot/
│   ├── safari/
│   ├── personal-nick/                    ← Nick agent (system files)
│   ├── personal-hadley/                  ← pending CHUNK-16
│   ├── personal-keith/                   ← pending CHUNK-15
│   ├── personal-francis/                 ← future
│   ├── personal-dean/                    ← future
│   └── personal-caro/                    ← future
├── agents/                               ← agent registrations (per-agent agent.json, auth-profiles.json)
├── credentials/                          ← shared OpenClaw credential store (anthropic API key, etc.)
├── cron/
│   ├── jobs.json                         ← OpenClaw-internal cron jobs
│   └── runs/                             ← per-run logs
└── logs/                                 ← gateway.log, gateway.err.log

/srv/guide-vaults/                        ← User content (Obsidian-shaped vaults)
├── personal/                             ← Personal vaults (read-write per person)
│   ├── nick/
│   ├── hadley/
│   ├── keith/
│   ├── scott/
│   ├── caro/
│   ├── frances/
│   ├── simon/
│   └── dean/
├── teams/                                ← Team vaults (read-write per folder)
│   ├── digital/                          ← symlink → /srv/onedrive/Wilderness-Guide/ (when OneDrive client is up)
│   ├── exco/
│   ├── sales/
│   ├── reservations/
│   └── hr/
├── shared/                               ← Shared data (read-write for agents)
│   ├── business/
│   ├── brand/
│   ├── data/
│   ├── impact/
│   ├── camps/
│   ├── sales/
│   ├── countries/
│   ├── regions/
│   └── kb/
└── private/                              ← retained from Mac Mini era — review/migrate

/srv/guide-outputs/                       ← Agent outputs (append-only)
├── reports/
├── briefs/
└── alerts/

/srv/guide-data/                          ← Pipeline outputs from guide-engine — fed into agents
                                            (markdown exports; not a git repo)
/srv/guide-core/                          ← OpenClaw workspace templates, agent factory, scripts
/srv/guide-engine/                        ← ETL scripts and exporters
/srv/guide-build/                         ← Architect vault — specs, chunks, agent definitions

/srv/compose/                             ← One Docker Compose file per service
├── openclaw.yml
├── openclaw/Dockerfile
└── (huginn.yml, hermes.yml, etc. — future chunks)

/srv/backup/dumps/                        ← Tarballs (Mac Mini final state, restic backups)
/srv/logs/                                ← Host-level logs (non-OpenClaw)
```

## What an agent sees (e.g. Nick's personal instance)

Nick's agent reads from:
- `/srv/guide-vaults/personal/nick/` — his personal vault (read-write)
- `/srv/guide-vaults/teams/exco/` — exec team vault (read-write)
- `/srv/guide-vaults/shared/*/` — shared data (read-write)
- `/srv/guide-outputs/*/` — outputs (append-only)

Nick's agent **NEVER** surfaces files from `/srv/openclaw/workspaces/personal-nick/` — that directory contains the agent's system files (IDENTITY, SOUL, AGENTS, TOOLS, BOOT, USER, MEMORY, memory/*) and is not user content.

## Ownership and modes

| Path | Owner | Group | Mode |
|------|-------|-------|------|
| `/srv/openclaw/` | guide | guide-data | 775 |
| `/srv/openclaw/config/openclaw.json` | guide | guide-data | 640 |
| `/srv/openclaw/config/credentials/*` | guide | guide-data | 600 |
| `/srv/guide-vaults/` | guide | guide-data | 775 |
| `/srv/guide-core/__CONFIG/keys/*` | gareth | srv-data | 600 |
| `/srv/guide-build/`, `/srv/guide-core/`, `/srv/guide-engine/` | gareth | srv-data | 775 |
| Workspace identity files (SOUL.md, AGENTS.md, TOOLS.md, IDENTITY.md, BOOT.md, USER.md) | guide | guide-data | 440 |
| `/srv/compose/` | gareth | srv-data | 775 |
