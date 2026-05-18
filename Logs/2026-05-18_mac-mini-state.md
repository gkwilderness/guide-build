---
title: "Mac Mini — Current Running State Snapshot"
type: log
area: infra
project: Guide
tags: [infra, mac-mini, openclaw, migration, snapshot]
status: complete
created: 2026-05-18
author: Architect (Claude Code)
---

# Mac Mini — Current Running State
**Snapshot date:** 2026-05-18  
**Purpose:** Migration reference for Engineer on HP Z8 G4 (Ubuntu). Read-only audit — nothing was changed.

---

## 1. OpenClaw Installation

- **Version:** OpenClaw 2026.5.4 (build 325df3e)
- **Install method:** npm global via Homebrew-managed npm (`/opt/homebrew/bin/openclaw`)
- **Config file:** `~/.openclaw/openclaw.json`
- **Daemon status:** Running — LaunchAgent installed, loaded, active (pid 53291, state active)
- **Port:** 18789 (loopback only — `localhost:18789`)
- **Update available:** 2026.5.12 (not yet applied)

### openclaw.json (secrets redacted)

```json
{
  "meta": {
    "lastTouchedVersion": "2026.4.26",
    "lastTouchedAt": "2026-04-30T16:07:08.179Z"
  },
  "auth": {
    "profiles": {
      "anthropic:default": {
        "provider": "anthropic",
        "mode": "api_key"
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-sonnet-4-6",
        "fallbacks": ["anthropic/claude-haiku-4-5"]
      },
      "models": {
        "anthropic/claude-sonnet-4-6": {},
        "anthropic/claude-haiku-4-5": {},
        "anthropic/claude-opus-4-6": {}
      },
      "bootstrapMaxChars": 20000,
      "workspace": "/Users/gareth/.openclaw/workspace"
    },
    "list": [
      {
        "id": "main",
        "tools": { "alsoAllow": ["exec", "process"] },
        "thinkingDefault": "adaptive"
      },
      {
        "id": "data",
        "name": "data",
        "workspace": "/Users/gareth/.openclaw/workspace-data",
        "agentDir": "/Users/gareth/.openclaw/agents/data/agent",
        "tools": {
          "profile": "full",
          "deny": ["process", "code_execution", "group:automation"],
          "exec": { "security": "full", "ask": "off" }
        }
      },
      {
        "id": "martech",
        "name": "martech",
        "workspace": "/Users/gareth/.openclaw/workspace-martech",
        "agentDir": "/Users/gareth/.openclaw/agents/martech/agent",
        "tools": {
          "profile": "full",
          "deny": ["process", "code_execution", "group:automation"],
          "exec": { "security": "full", "ask": "off" }
        }
      },
      {
        "id": "seo",
        "name": "seo",
        "workspace": "/Users/gareth/.openclaw/workspace-seo",
        "agentDir": "/Users/gareth/.openclaw/agents/seo/agent",
        "tools": {
          "profile": "full",
          "deny": ["process", "code_execution", "group:automation"],
          "exec": { "security": "full", "ask": "off" }
        }
      },
      {
        "id": "product",
        "name": "product",
        "workspace": "/Users/gareth/.openclaw/workspace-product",
        "agentDir": "/Users/gareth/.openclaw/agents/product/agent",
        "tools": {
          "profile": "full",
          "deny": ["process", "code_execution", "group:automation"],
          "exec": { "security": "full", "ask": "off" }
        }
      },
      {
        "id": "hubspot",
        "name": "hubspot",
        "workspace": "/Users/gareth/.openclaw/workspace-hubspot",
        "agentDir": "/Users/gareth/.openclaw/agents/hubspot/agent",
        "tools": {
          "profile": "full",
          "deny": ["process", "code_execution", "group:automation"],
          "exec": { "security": "full", "ask": "off" }
        }
      },
      {
        "id": "personal-nick",
        "name": "personal-nick",
        "workspace": "/Users/gareth/.openclaw/workspace-personal-nick",
        "agentDir": "/Users/gareth/.openclaw/agents/personal-nick/agent",
        "tools": {
          "profile": "full",
          "deny": ["process", "code_execution", "group:automation"],
          "exec": { "security": "full", "ask": "off" }
        },
        "thinkingDefault": "adaptive"
      },
      {
        "id": "safari",
        "name": "safari",
        "workspace": "/Users/gareth/.openclaw/workspace-safari",
        "agentDir": "/Users/gareth/.openclaw/agents/safari/agent",
        "tools": {
          "profile": "full",
          "deny": ["process", "code_execution", "group:automation"],
          "exec": { "security": "full", "ask": "off" }
        }
      }
    ]
  },
  "cron": {
    "enabled": true,
    "maxConcurrentRuns": 3,
    "sessionRetention": "7d",
    "retry": {
      "maxAttempts": 3,
      "backoffMs": [30000, 60000, 300000],
      "retryOn": ["rate_limit", "overloaded", "network", "timeout", "server_error"]
    }
  },
  "channels": {
    "slack": {
      "enabled": true,
      "botToken": "[REDACTED]",
      "appToken": "[REDACTED]",
      "mode": "socket",
      "streaming": { "mode": "partial", "nativeTransport": false },
      "dmPolicy": "pairing",
      "allowFrom": [
        "U07NDN5T57A", "U08UX404HDK", "U0AAW754GEA", "U08HDPM75FD",
        "8673327311", "U066QR70R16", "UTJ6P2935", "U03ELJG2SNP",
        "U0B3TDMB4M6", "U0B1T2X1DTL", "U0B4G2F5518"
      ],
      "channels": {
        "C0ATG3V2EDN": { "enabled": true },
        "C0ASJDN5KGV": { "enabled": true },
        "C0ASJDP022H": { "enabled": true },
        "C0987SGJ9NJ": { "enabled": true },
        "C0ASP8ZD495": { "enabled": true },
        "C0AT56RRUEP": { "enabled": true },
        "C0AFFV58ZCY": { "enabled": true },
        "C0ATGQ167SN": { "enabled": true },
        "C0ATXQ8MDS5": { "enabled": true },
        "C0AUT4WSPBJ": { "enabled": true },
        "C0AUF97NJ0H": { "enabled": true },
        "C0ATLTNFF0X": { "enabled": true },
        "C0AUBC17ZDZ": { "enabled": true },
        "C0AUS0DK30W": { "enabled": true },
        "C0AFJHHP1BM": { "enabled": true },
        "C0B1Z2ETB26": { "enabled": true },
        "C0B2DFTFCDB": { "enabled": true },
        "C0B2GU0RQJW": { "enabled": true }
      },
      "ackReaction": "eyes"
    },
    "telegram": {
      "enabled": true,
      "retry": { "attempts": 12, "minDelayMs": 2000, "maxDelayMs": 30000, "jitter": 0.3 },
      "execApprovals": { "approvers": ["6864752167"], "target": "dm" },
      "groups": {
        "-5236130644": {
          "requireMention": true,
          "allowFrom": ["6864752167","8265788167","8717068556","8715479659","8661869138","8673327311"],
          "errorPolicy": "silent",
          "errorCooldownMs": 5000
        }
      },
      "accounts": {
        "default": {
          "botToken": "[REDACTED]",
          "dmPolicy": "pairing",
          "groupPolicy": "allowlist",
          "streaming": { "mode": "partial", "preview": { "toolProgress": false } },
          "allowFrom": ["6864752167","8265788167","8661869138","8715479659","8717068556","8673327311","7971802067"]
        },
        "nick": {
          "name": "Guide Nick",
          "enabled": true,
          "tokenFile": "/Users/gareth/guide-core/__CONFIG/keys/telegram-nick",
          "dmPolicy": "pairing",
          "allowFrom": ["8516698636","6864752167","8673327311"],
          "streaming": { "mode": "partial", "preview": { "toolProgress": false } },
          "errorPolicy": "silent",
          "errorCooldownMs": 5000
        }
      }
    }
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "loopback",
    "auth": {
      "mode": "token",
      "token": "[REDACTED]",
      "rateLimit": { "maxAttempts": 10, "windowMs": 60000, "lockoutMs": 300000, "exemptLoopback": true }
    },
    "tailscale": { "mode": "off", "resetOnExit": false },
    "controlUi": {
      "allowedOrigins": [
        "http://localhost:18789",
        "http://127.0.0.1:18789",
        "https://guide.tailfbf66e.ts.net"
      ]
    }
  },
  "tools": {
    "profile": "coding",
    "web": { "search": { "enabled": false } },
    "exec": { "host": "gateway", "security": "full", "ask": "off" },
    "sessions": { "visibility": "all" }
  },
  "commands": {
    "native": "auto",
    "nativeSkills": "auto",
    "restart": true,
    "ownerDisplay": "raw",
    "allowFrom": {
      "*": ["6864752167","8715479659","8717068556","8661869138","8265788167","8673327311","7971802067","8516698636"]
    }
  },
  "session": {
    "dmScope": "per-channel-peer",
    "maintenance": { "mode": "enforce", "pruneDays": 7, "resetArchiveRetention": "7d" }
  },
  "hooks": {
    "internal": {
      "enabled": true,
      "entries": {
        "boot-md": { "enabled": true },
        "bootstrap-extra-files": { "enabled": true },
        "command-logger": { "enabled": true },
        "session-memory": { "enabled": true }
      }
    }
  },
  "skills": { "install": { "nodeManager": "npm" } },
  "plugins": {
    "entries": {
      "anthropic": { "enabled": true },
      "acpx": { "enabled": false },
      "bonjour": { "enabled": false }
    }
  },
  "messages": {
    "ackReaction": "eyes",
    "ackReactionScope": "all",
    "statusReactions": { "enabled": true }
  }
}
```

---

## 2. Workspace Structure

### Main workspace: `~/.openclaw/workspace/`

Key files:
- `SOUL.md` — Guide's character, voice, tone, trust tiers, autonomy rules, signal inboxes
- `AGENTS.md` — Operating rules, boot sequence, cron schedule, Slack DM tiers
- `TOOLS.md` — Machine map, key paths, scripts, channel list, access tiers
- `IDENTITY.md` — Name, role, emoji, brands, model config, operator
- `BOOT.md` — What's live, what's pending, three-role architecture
- `USER.md` — Full user roster: Gareth, operators, team, executives
- `HEARTBEAT.md` — Active health checks
- `DIGEST.md` — Combined backlog view instructions + file paths
- `MEMORY.md` — Long-term memory index
- `memory/` — ~200 session memory files (2026-04-13 to 2026-05-17)
- `signals/` — Role signal inboxes (→architect.md, →engineer.md, →gareth.md, →guide.md, →vault.md, →qa.md)
- `skills/self-improving-agent/` — Installed skill with hooks
- `prompts/polite-mode.md` — Polite mode prompt
- `scripts.bak-20260512104802/` — Backed-up scripts (now superseded by guide-core/scripts/)

### Agent-specific workspaces

| Agent | Workspace path | Files present |
|-------|---------------|---------------|
| main | `~/.openclaw/workspace/` (default) | Full set |
| data | `~/.openclaw/workspace-data/` | SOUL, AGENTS, TOOLS, IDENTITY, BOOT, HEARTBEAT, MEMORY.md, memory/ |
| martech | `~/.openclaw/workspace-martech/` | Same as data |
| seo | `~/.openclaw/workspace-seo/` | Same + GSC screenshots, session HTMLs, SEO-specific files |
| product | `~/.openclaw/workspace-product/` | Same as data |
| hubspot | `~/.openclaw/workspace-hubspot/` | Same as data |
| safari | `~/.openclaw/workspace-safari/` | Same as data |
| personal-nick | `~/.openclaw/workspace-personal-nick/` | SOUL, AGENTS, TOOLS, IDENTITY, BOOT, HEARTBEAT, MEMORY.md, ONBOARDING.md, PRIORITIES.md, USER.md, memory/ |

---

## 3. Active Agents

| Agent ID | Workspace | Channels bound | Notes |
|----------|-----------|---------------|-------|
| `main` | `~/.openclaw/workspace/` | Telegram DM (Gareth 6864752167, Matt 8265788167, Danny 8717068556), Slack DMs (Gareth U07NDN5T57A, Laura U08UX404HDK, others), Slack channels (#wilderness-digital-team C0987SGJ9NJ, #alerts C0AFFV58ZCY, #guide-logs C0ATGQ167SN, #guide-exco C0AUS0DK30W), Telegram group (-5236130644) | Primary orchestration agent |
| `data` | `~/.openclaw/workspace-data/` | Telegram DM (7971802067), Slack channel #guide-data (C0ASP8ZD495) | Data pipeline agent |
| `martech` | `~/.openclaw/workspace-martech/` | Telegram DM (Danny 8673327311), Slack channel #guide-martech-backlog (C0AT56RRUEP) | MarTech agent |
| `seo` | `~/.openclaw/workspace-seo/` | Telegram DM (Richard 8715479659), Slack channel #seo-guide (C0ATXQ8MDS5) | SEO intelligence agent |
| `product` | `~/.openclaw/workspace-product/` | Telegram DM (Laura 8661869138), Slack channels #digital-product-external-triage-list (C0AUT4WSPBJ), #guide-digital-product (C0ATLTNFF0X), #group-budget (C0B2DFTFCDB), #C0B2GU0RQJW | Product agent |
| `hubspot` | `~/.openclaw/workspace-hubspot/` | Slack channel #guide-hubspot (C0AUF97NJ0H) | HubSpot agent |
| `personal-nick` | `~/.openclaw/workspace-personal-nick/` | Telegram account `nick` (all DMs to @WildernessGuideNickBot) | Nick Stone personal instance |
| `safari` | `~/.openclaw/workspace-safari/` | Slack channel #guide-sales (C0B1Z2ETB26) | Safari/TD agent (battle testing) |

---

## 4. Channel Configuration

### Telegram

| Account | Bot | Status | Routes to | Allow list |
|---------|-----|--------|-----------|-----------|
| `default` | @WildernessGuideBot | ✅ Live | Bindings-based (see §3) | 6864752167, 8265788167, 8661869138, 8715479659, 8717068556, 8673327311, 7971802067 |
| `nick` | @WildernessGuideNickBot (token file: `~/guide-core/__CONFIG/keys/telegram-nick`) | ✅ Live | `personal-nick` agent | 8516698636, 6864752167, 8673327311 |

- Telegram group `-5236130644` → `main` agent, `requireMention: true`
- exec approvals: Gareth (6864752167) via DM

### Slack

- **Mode:** Socket mode (not webhook)
- **Bot token:** stored in `~/.openclaw/credentials/slack-bot-token` + in openclaw.json `[REDACTED]`
- **App token:** stored in `~/.openclaw/credentials/slack-app-token` + in openclaw.json `[REDACTED]`
- **dmPolicy:** pairing
- **ackReaction:** :eyes:

Active Slack channel bindings:

| Channel ID | Name | Agent | Type |
|------------|------|-------|------|
| C0ATG3V2EDN | #guide-briefs | main | enabled |
| C0ASJDN5KGV | #guide-ops | main | enabled |
| C0ASJDP022H | #guide-alerts | main | enabled |
| C0987SGJ9NJ | #wilderness-digital-team | main | post-only |
| C0ASP8ZD495 | #guide-data | data | route |
| C0AT56RRUEP | #guide-martech-backlog | martech | route |
| C0AFFV58ZCY | #alerts | main | monitor |
| C0ATGQ167SN | #guide-logs | main | Gareth-only, nightly digest |
| C0ATXQ8MDS5 | #seo-guide | seo | route |
| C0AUT4WSPBJ | #digital-product-external-triage-list | product | route |
| C0AUF97NJ0H | #guide-hubspot | hubspot | route |
| C0ATLTNFF0X | #guide-digital-product | product | route |
| C0AUBC17ZDZ | #guide-testing | main | enabled |
| C0AUS0DK30W | #guide-exco | main | exec comms |
| C0AFJHHP1BM | #group-budget-mtd-check-in | main | Gareth+Danny+Matt |
| C0B1Z2ETB26 | #guide-sales | safari | battle testing |
| C0B2DFTFCDB | (product channel) | product | route |
| C0B2GU0RQJW | (product channel) | product | route |

### WhatsApp
- **Status:** Deferred — SIM required (executive tier)

---

## 5. Cron Jobs

### crontab -l

```
### OpenClaw
0 4 * * * /Users/gareth/guide-core/scripts/openclaw-backup.sh >> /Users/gareth/openclaw-backups/backup.log 2>&1

### Pulse
TZ=Europe/London
0 8 * * * /Users/gareth/guide-engine/google-ads-api-utils/run_all.sh

### Pulse Reports (Mon + Wed + Fri 8:30am London) — PAUSED 2026-04-26
#PAUSED# 30 8 * * 1,3,5 /Users/gareth/.openclaw/workspace/scripts/pulse-report-generator.sh

### LLMs
0 5 * * * /Users/gareth/guide-engine/llm-checker/run_all.sh

### LLM Reports (Mon + Thu 8am London) — PAUSED 2026-04-26
#PAUSED# 0 8 * * 1,4 /Users/gareth/.openclaw/workspace/scripts/llm-report-generator.sh

### SEO Tickler (TZ=Europe/London)
0 9 8 5 * openclaw message send --channel telegram --target 8715479659 --message '...'
```

### OpenClaw cron jobs (`~/.openclaw/cron/jobs.json`)

| ID | Name | Schedule | Status | Notes |
|----|------|----------|--------|-------|
| `7fdb2566` | Nightly Slack session flush | `0 3 * * *` UTC | ✅ enabled | Runs `flush-slack-sessions.sh` |
| `nightly-guide-logs-digest` | Nightly activity digest → #guide-logs | `0 1 * * *` Europe/London | ✅ enabled | Isolated session |
| `nightly-workspace-commit-push` | Nightly workspace commit + push | `15 5 * * *` UTC | ✅ enabled | Commits workspace + guide-core |
| `0022ee36` | Nightly session memory scanner | `30 20 * * *` UTC | ✅ enabled | Runs `session-memory-scan.sh` |
| `2dd2bf43` | Jacada SEO tasks due today | One-off 2026-05-11T08:15Z | ❌ disabled, deleteAfterRun | Already fired |

### LaunchAgents (relevant)

| Plist | Status |
|-------|--------|
| `ai.openclaw.gateway.plist` | ✅ Running (pid 53291) |
| `ai.openclaw.remind.redirect-bug.plist` | Loaded, not running |
| `ai.openclaw.seo-tickler-ahrefs-agent.plist` | Loaded, not running |
| `com.guide.loginmonitor.plist` | Present |

---

## 6. Active Personal Instances

| Instance | Bot | Telegram account | Workspace | Status |
|----------|-----|-----------------|-----------|--------|
| Nick Stone | @WildernessGuideNickBot | `nick` (token file `~/guide-core/__CONFIG/keys/telegram-nick`) | `~/.openclaw/workspace-personal-nick/` | ✅ Live — last session 2d ago |

**Pending personal instances:**
- Hadley Allen — CHUNK-16, Thursday reveal (per CLAUDE.md). Bot: @GuideHadleyBot. Status: pending.
- Keith Vincent — CHUNK-15. Status: deferred.

---

## 7. Directory Listing (`~/.openclaw` to depth 3)

```
~/.openclaw/
├── agents/
│   ├── data/agent/, data/sessions/
│   ├── hubspot/agent/, hubspot/sessions/
│   ├── main/agent/, main/sessions/
│   ├── martech/agent/, martech/sessions/
│   ├── personal-nick/agent/, personal-nick/sessions/
│   ├── product/agent/, product/sessions/
│   ├── safari/agent/, safari/sessions/
│   ├── seo/agent/, seo/sessions/
│   └── slack/sessions/
├── browser/openclaw/user-data/
├── canvas/index.html
├── credentials/
│   ├── anthropic
│   ├── slack-app-token
│   ├── slack-bot-token
│   ├── slack-pairing.json
│   ├── telegram-bot-token
│   ├── telegram-default-allowFrom.json
│   └── telegram-pairing.json
├── cron/
│   ├── jobs.json
│   ├── jobs.json.bak
│   ├── jobs-state.json
│   └── runs/ (14 run files + 2 named: nightly-guide-logs-digest.jsonl, nightly-workspace-commit-push.jsonl)
├── delivery-queue/failed/
├── devices/paired.json, pending.json
├── exec-approvals.json
├── flows/registry.sqlite
├── identity/device-auth.json, device.json
├── logs/
│   ├── commands.log
│   ├── config-audit.jsonl
│   ├── config-health.json
│   ├── gateway-restart.log
│   ├── gateway.err.log
│   ├── gateway.log
│   └── stability/ (4 crash logs from 2026-04-26)
├── media/browser/ (9 PNGs), inbound/ (CVs, images, docs)
├── openclaw.json
├── workspace/ (main — see §2)
├── workspace-data/
├── workspace-hubspot/
├── workspace-martech/
├── workspace-personal-nick/
├── workspace-product/
├── workspace-safari/
└── workspace-seo/
```

---

## 8. guide-core Repo State

- **Branch:** `main`
- **Last commit:** `0cf472f — fix: explicit vault pre-load on boot for all 5 channel agents`
- **Recent commits:**
  ```
  0cf472f fix: explicit vault pre-load on boot for all 5 channel agents
  79b7f7a chore: nightly sync 2026-05-14
  aa63209 chore: session snapshot 2026-05-12
  10d3276 feat: add openclaw-backup.sh to scripts — crontab updated to new path
  1b310a7 docs: add three-repos table to CLAUDE.md
  ```
- **Uncommitted changes:** None (clean)
- **Notable contents:** `__CONFIG/keys/telegram-nick` — Nick's bot token (referenced by openclaw.json `tokenFile`)

---

## 9. Environment

- **Node:** v25.9.0
- **npm:** 11.12.1
- **OpenClaw binary:** `/opt/homebrew/bin/openclaw` (npm global via Homebrew)
- **Shell:** zsh
- **No OpenClaw-specific env vars** found in `~/.zshrc`
- **Credentials stored in:** `~/.openclaw/credentials/` (credential files, not env vars)
- **API keys stored in:** `~/.openclaw/credentials/anthropic` (Anthropic key)
- **No `.env` files** found in `~/.openclaw/` or `~/guide-core/`

---

## 10. Known Issues / Deferred Work

### Active issues
- **Tailscale not in PATH** on this session — `tailscale` command not found via shell. The openclaw status shows Tailscale as `mode: off`. TOOLS.md notes Tailscale is "planned (not yet configured)" on this machine. The CLAUDE.md references `guide.tailfbf66e.ts.net` but controlUi allowedOrigins only — not actively serving.
- **Stability crash logs** present from 2026-04-26 (4 `unhandled_rejection` crashes). Likely resolved by the config incident fix (ADR: `dmOutboundAllowlist`/`dmPoliteList` crash from invalid openclaw.json keys). Monitor on Z8.
- **scripts.bak-20260512104802/** — old script copies in main workspace. Superseded by `guide-core/scripts/`. Safe to omit on Z8 migration.
- **Pulse report + LLM report cron jobs PAUSED** since 2026-04-26. Need decision on whether to re-enable on Z8 or redesign.

### Deferred work (not yet built)
- **CHUNK-07** — Security hardening (deferred to Ubuntu)
- **CHUNK-08** — Cron ops (deferred to Ubuntu)
- **CHUNK-11** — Paperclip (deferred to Ubuntu)
- **CHUNK-15** — Keith personal instance
- **CHUNK-16** — Hadley personal instance (Thursday reveal)
- **WhatsApp** — SIM required, executive tier
- **Slack DM outbound control** — No schema-valid field in openclaw.json. Polite-mode enforcement is behavioural only (ADR-016). Proper enforcement requires a custom plugin.
- **ETL / data pipelines** — `guide-data/` directory exists but not yet populated. Phase 4 work.

### Migration notes for Engineer (Z8)
- All credential files are in `~/.openclaw/credentials/` — these need to be transferred securely, not via git.
- Nick's Telegram bot token is at `~/guide-core/__CONFIG/keys/telegram-nick` — transfer separately.
- Gateway auth token is in `openclaw.json` `gateway.auth.token` — regenerate or transfer securely.
- Anthropic API key is in `~/.openclaw/credentials/anthropic`.
- Slack bot + app tokens are in `credentials/slack-bot-token` and `credentials/slack-app-token`.
- The `workspace/` and all `workspace-*/` directories contain live memory and session data — migrate these to preserve continuity.
- OpenClaw install on Ubuntu: use npm (not Homebrew). Check Ubuntu-compatible install path.
- LaunchAgent plists (`~/Library/LaunchAgents/ai.openclaw.gateway.plist`) are macOS-only — use systemd service on Ubuntu instead.
- crontab entries for `guide-engine` scripts need paths verified on Z8.
- `openclaw.json` paths use `/Users/gareth/` — update to `/home/gareth/` (or wherever) on Ubuntu.
