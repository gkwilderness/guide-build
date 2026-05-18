# Personal Vault Separation — Directory Layout

**Status:** APPROVED — 2026-05-01. Canonical reference for Guide filesystem layout.

~/.openclaw/                              ← OpenClaw's home (don't touch)
├── openclaw.json
├── workspace/                            ← Main agent (system files)
├── workspace-personal-nick/              ← Nick agent (system files)
├── workspace-personal-hadley/            ← Hadley agent (system files)
├── workspace-personal-keith/             ← Keith agent (system files)
├── workspace-personal-francis/           ← Francis agent (system files)
├── workspace-personal-dean/              ← Dean agent (system files)
├── workspace-personal-caro/              ← Caro agent (system files)
├── agents/
├── credentials/
├── logs/
└── ...

~/guide-vault/personal/                   ← Personal vaults (user content)
├── nick/                                 ← Nick's files (read-write)
│   ├── INDEX.md
│   ├── PRIORITIES.md
│   ├── WATCHLIST.md
│   └── ...
├── hadley/
├── keith/
├── scott/
├── caro/
├── frances/
├── simon/
└── dean/

~/guide-vault/teams/                      ← Team vaults (read-write per folder)
├── digital/                              ← symlink → ~/Obsidian/Wilderness-Guide/
├── exco/
├── sales/
├── reservations/
└── hr/

~/guide-vault/shared/                     ← Shared data (read-write for agents)
├── business/
├── brand/
├── data/
├── impact/
├── camps/
├── sales/
├── countries/
├── regions/
└── kb/

~/guide-outputs/                          ← Agent outputs (append-only)
├── reports/
├── briefs/
└── alerts/

## What the agent sees

Nick's agent reads from:
- `~/guide-vault/personal/nick/` — his personal vault (read-write)
- `~/guide-vault/teams/exco/` — exec team vault (read-write)
- `~/guide-vault/shared/*/` — shared data (read-write)
- `~/guide-outputs/*/` — outputs (append-only)

Nick's agent NEVER surfaces files from `~/.openclaw/workspace-personal-nick/`.
