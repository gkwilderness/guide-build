---
title: "Guide Filesystem Architecture"
type: architecture-spec
area: wilderness
project: Guide
tags: [guide, architecture, filesystem, vault, docker, git]
created: 2026-04-24
status: superseded
superseded_by: "Specs/personal-instance-architecture.md"
---

# Guide Filesystem Architecture

> **Note (2026-04-29):** This document is superseded by [[personal-instance-architecture]]. The filesystem design has been revised to include `guide-teams/` (team vaults as first-class), a restructured `guide-vault/` with `personal/`, `channel/`, and `shared/` subdirectories, and a supplementary-only `guide-shared/`. The original design below remains as historical context.

*Derived from 2026-04-24 architecture sessions. Companion to [[2026-04-24 Guide Architecture — Vault Scoping & Agent Comms]].*

---

## Machine Layout

```
/home/guide/
├── guide-core/          ← OpenClaw runtime, agent configs, docker-compose
├── guide-data/          ← ETL scripts, pipeline code
├── guide-engine/        ← Code that runs all Guide grunt work
├── guide-vault/         ← Agent workspaces (private, git-tracked)
├── guide-shared/        ← Shared read layer (mounted read-only by agents)
└── guide-outputs/       ← Agent outputs, append-only logs (git-tracked)
```

---

## guide-vault/ (private agent workspaces)

Each agent gets its own directory. Write access scoped to that directory only. Nobody else writes here.

Each workspace contains the standard 9-file identity stack (SOUL.md, AGENTS.md, TOOLS.md, IDENTITY.md, USER.md, MEMORY.md, HEARTBEAT.md, BOOTSTRAP.md, KEYS.md) + agent memory and daily logs.

```
guide-vault/
├── main/                ← Guide Main (orchestrator — broad access)
├── briefing/
├── scribe/
├── pipeline/
├── analyst/
├── finance/
├── capitalcore/
├── apex/
├── paid-ws/
├── paid-jc/
├── paid-yz/
├── seo-ws/
├── seo-jc/
├── seo-yz/
├── hubspot-ws/
├── hubspot-jc/
├── hubspot-yz/
├── product-ws/
├── product-jc/
├── product-yz/
└── exec/
    ├── nick/
    ├── hadley/
    └── keith/
```

---

## guide-shared/ (read-only knowledge commons)

Mounted read-only into agent containers via Docker bind mounts. Agents can read, never write. Access control is structural — cannot be prompt-injected.

Agents can mount multiple shared directories simultaneously. No technical limit. Practical constraint is access policy.

```
guide-shared/
├── wilderness-vault/    ← Obsidian Wilderness vault (OneDrive sync → here)
├── brand/
│   ├── wilderness/      ← WS brand docs, guidelines, strategy
│   ├── jacada/          ← JC brand docs
│   └── yellow-zebra/    ← YZ brand docs
├── data/
│   ├── paid/            ← Google Ads, Bing, Meta markdown outputs
│   ├── seo/             ← Rankings, technical audit outputs
│   ├── hubspot/         ← CRM pipeline markdown outputs
│   ├── analytics/       ← GA4, BigQuery outputs
│   └── finance/         ← Yield curves, budget pacing outputs
└── exec/                ← Curated exec-only context (board docs, capital reports)
```

### Tiered access model

| Vault | Who mounts it |
|-------|--------------|
| `exec/` | Nick, Hadley, Keith instances + Guide Main only |
| `data/` (all) | CapitalCore, Apex, Analyst, Finance, Pipeline |
| `data/paid/` | Paid agents (WS, JC, YZ) |
| `brand/wilderness/` | WS-scoped agents |
| `wilderness-vault/` | Guide Main + Briefing + Scribe |
| Nothing sensitive | Operational agents (Pipeline, Scribe) |

---

## guide-outputs/ (git-tracked, append-only)

All agent outputs land here. Git auto-commits every write. This is the audit trail.

```
guide-outputs/
├── decisions.md         ← Append-only: CapitalCore/Apex decisions
├── output-log.md        ← Append-only: all agent outputs with timestamp + agent ID
├── briefs/              ← Briefing agent outputs by date
├── alerts/              ← Anomaly alerts, threshold breaches
├── reports/
│   ├── weekly/
│   ├── monthly/
│   └── board/
└── archive/
    └── YYYY/MM/
```

**Commit pattern:** `[agent-id] YYYY-MM-DD HH:MM: <description>`

Every output is immutable history. Nick can ask "what did CapitalCore recommend last Tuesday" and it's there.

---

## Docker Mount Config (per agent)

### Paid-WS agent (brand-scoped, execution)
```yaml
volumes:
  - ./guide-vault/paid-ws:/workspace:rw
  - ./guide-shared/data/paid:/mnt/data:ro
  - ./guide-shared/brand/wilderness:/mnt/brand:ro
  - ./guide-outputs:/mnt/outputs:rw
```

### CapitalCore (cross-brand, intelligence)
```yaml
volumes:
  - ./guide-vault/capitalcore:/workspace:rw
  - ./guide-shared/data:/mnt/data:ro
  - ./guide-shared/exec:/mnt/exec:ro
  - ./guide-outputs:/mnt/outputs:rw
```

### Guide Main (orchestrator — sees everything)
```yaml
volumes:
  - ./guide-vault/main:/workspace:rw
  - ./guide-shared:/mnt/shared:ro
  - ./guide-outputs:/mnt/outputs:rw
```

### Exec instances (Nick, Hadley, Keith)
```yaml
volumes:
  - ./guide-vault/exec/nick:/workspace:rw
  - ./guide-shared/exec:/mnt/exec:ro
  - ./guide-outputs/reports:/mnt/reports:ro
```

---

## Git Strategy

| Directory | Git approach | Who manages |
|-----------|-------------|-------------|
| `guide-vault/` | One repo, per-agent subdirectories. Auto-commit on significant writes. | OpenClaw agent factory |
| `guide-outputs/` | Single repo. Auto-commit on every write. Source of truth for audit trail. | All agents via post-write hook |
| `guide-shared/` | Not git-tracked by agents. Managed by OneDrive sync (Wilderness vault) or `guide-data/` pipeline scripts. | Pipeline agent |

**Obsidian Sync stays human-facing only.** Never competes with agent git layer.

---

## OneDrive as Team Share via Symlinks

OpenClaw reads the filesystem directly — symlinks are transparent. A symlinked OneDrive folder is indistinguishable from a real directory to the agent.

```bash
# On the Guide machine (macOS)
ln -s "/Users/guide/OneDrive/Wilderness-Guide" /home/guide/guide-shared/wilderness-vault
ln -s "/Users/guide/OneDrive/Brand-Docs" /home/guide/guide-shared/brand
```

Agents mount `guide-shared/wilderness-vault` — reads straight through to OneDrive. OneDrive handles sync across all team members.

**What this enables:**
- Team members update files in OneDrive (Word, Obsidian, any editor) → immediately available to agents on next read
- No custom sync infrastructure needed
- Scott's safari KB, brand guidelines, strategy docs — all team-managed, all queryable by Guide
- Natural team workflow: people work in OneDrive as normal; Guide reads it as context

**Caveats:**
- OneDrive sync latency: seconds to minutes depending on file size. Fine for session-start context loading. Not suitable for real-time mid-session updates.
- Agents get the last saved version if a file is open. Fine for read-only access.
- Symlinks inside Docker containers require the bind mount to resolve correctly — mount the real OneDrive path, not the symlink, in `docker-compose.yml`.

```yaml
# Correct: mount the real OneDrive path
volumes:
  - /Users/guide/OneDrive/Wilderness-Guide:/mnt/wilderness-vault:ro

# Not: mount the symlink (may not resolve inside container)
# - /home/guide/guide-shared/wilderness-vault:/mnt/wilderness-vault:ro
```

---

## Agent Factory Extension

The agent factory (`guide-core/agent-factory/`) is extended to include vault mount config:

```
base/                    ← Shared identity files
overlays/
  brands/
    wilderness.yaml      ← + vault_mounts: [data/paid, brand/wilderness]
    jacada.yaml          ← + vault_mounts: [data/paid, brand/jacada]
    yellow-zebra.yaml    ← + vault_mounts: [data/paid, brand/yellow-zebra]
  roles/
    paid.yaml            ← role scope + mount permissions
    capitalcore.yaml     ← cross-brand + exec mount
    exec.yaml            ← exec vault only
```

`./generate.sh --role paid --brand wilderness` → full workspace + scoped docker-compose volume config.

---

## Per-Agent API Key Isolation

Each agent can be bound to its own Anthropic API key via `openclaw.json`. Enables separate billing, separate rate limits, complete cost isolation.

```json
{
  "id": "exec-nick",
  "workspace": "./guide-vault/exec/nick",
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-sonnet-4-6",
        "apiKey": "sk-ant-nick-key-here"
      }
    }
  }
}
```

### Recommended key structure for Guide

| Tier | Agents | Key | Budget owner |
|------|--------|-----|--------------|
| **Exec** | Nick, Hadley, Keith instances | Claude Max Plus key | Wilderness (Nick approved) |
| **Intelligence** | CapitalCore, Apex, Analyst | Sonnet key | Wilderness digital budget |
| **Operational** | Briefing, Scribe, Pipeline, HubSpot, SEO, Paid, Product | Haiku key | Wilderness digital budget |
| **Gareth** | Guide Main, Architect access | Personal Sonnet key | Gareth |

**Why it matters:** Nick approved Claude Max Plus. If that key is shared across all 20 agents, every background cron and pipeline job burns from his Max Plus capacity. Scoped keys mean Max Plus is reserved for exec interactions only. Operational agents run on Haiku at a fraction of the cost.

**Implementation:** Store keys in `guide-core/__CONFIG/keys/` (gitignored), referenced in `docker-compose.yml` as environment variables. Never hardcode in `openclaw.json` directly.

---

## Related

- [[2026-04-24 Guide Architecture — Vault Scoping & Agent Comms]] — design principles and decisions
- [[00_Guide-Project-Brief]] — master project brief and agent roster
- [[2026-04-23-Guide-Demo]] — Nick demo; hardware + Claude Max approved
