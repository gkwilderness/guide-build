---
title: "_CONVENTIONS — Guide Build System"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: active
---
# GUIDE Build System — Shared Conventions
# READ-ONLY: Referenced by all CHUNK files. Never duplicated. Never edited during a build session.
# Source of truth for all constants, paths, ports, and naming rules.
#
# ✅ PATHS UPDATED 2026-05-19 — CHUNK-07c complete. Guide runs on HP Z8 G4 (Ubuntu 24.04),
#    Docker + systemd, /srv/ canonical paths. All paths below reflect the live Z8 state.

---

## Three-Role Architecture

Three Claude instances operate the Guide system. As Engineer, know where you fit:

| Role | Machine | Claude | Function |
|------|---------|--------|----------|
| **Architect** | Gareth's Mac | Claude Code in vault | Designs specs, writes chunks — **not you** |
| **Engineer** | This machine (Guide) | Claude Code | Executes chunks, writes code — **you** |
| **Vault** | This machine (Guide) | OpenClaw main agent | Live ops, team comms — **what you're building** |

**As Engineer:**
- Execute what the Architect specified. Read `BUILD.md` and the CHUNK file before starting.
- Build what the Vault operates. Restart the gateway after workspace or config changes.
- Do not modify vault spec files — flag issues to Gareth for the Architect to resolve.
- BUILD.md chunk numbering is canonical (ADR-012). Trust it over git commit labels or Vault-reported numbers.
- **Check signals at session start:** read `/srv/openclaw/workspaces/main/signals/→engineer.md`. Surface any open items to Gareth before starting chunk work.
- **Run CLI orientation before CHUNK work:** OpenClaw is moving fast — specs are written from docs research, not tested execution. Flags may differ from what was specced. Before starting any chunk, run:
  ```bash
  openclaw --help
  openclaw cron --help
  openclaw channels --help
  openclaw credentials --help
  ```
  Read the actual output. Adapt chunk tasks to match real flags. If a command is structurally different from the spec, surface the delta to Gareth before proceeding.

---

## System Assumptions

Every chunk assumes:
1. Guide is an **HP Z8 G4** running Ubuntu 24.04 LTS with 128GB RAM, 1TB NVMe + 4TB HDD
2. Guide uses **systemd** (not launchd) for service management. OpenClaw runs as `openclaw.service` via Docker Compose
3. Guide has **Tailscale** live — `guide-server` at 100.80.44.14
4. **OneDrive** is not yet configured on guide-server — `/srv/guide-vaults/teams/` and `/srv/guide-data/` are empty stubs pending OneDrive setup
5. The **guide-build vault** is at `/srv/guide-build/` — Engineer Claude can read all specs, project briefs, agent specs, and CLAUDE.md files directly
6. The Engineer Claude has **full context** — it reads the vault and executes chunks. No need for Gareth to copy specs into sessions.

---

## Canonical Paths

| Name | Path |
|------|------|
| OpenClaw state dir | `/srv/openclaw/` |
| OpenClaw config file | `/srv/openclaw/openclaw.json` |
| Main agent workspace | `/srv/openclaw/workspaces/main/` |
| Personal agent workspaces | `/srv/openclaw/workspaces/personal-{name}/` |
| Channel agent workspaces | `/srv/openclaw/workspaces/{role}/` |
| Agent factory | `/srv/guide-core/agent-factory/` |
| Cron config | `/srv/openclaw/openclaw.json` (`cron` key — no separate jobs.json) |
| Session memory | `/srv/openclaw/memory/` |
| Device identity | `/srv/openclaw/identity/` |
| Credentials | `/srv/openclaw/credentials/` |
| Personal vaults | `/srv/guide-vaults/personal/{name}/` |
| Team vaults | `/srv/guide-vaults/teams/{team}/` |
| Shared data | `/srv/guide-vaults/shared/` |
| Agent outputs | `/srv/guide-outputs/` |
| Digital team vault | `/srv/guide-vaults/teams/digital/` — **live via Obsidian Sync** (2026-05-19) |
| OneDrive root | `/srv/onedrive/` (abraunegg client — pending setup) |
| Guide runtime repo | `/srv/guide-core/` |
| Guide pipeline scripts repo | `/srv/guide-engine/` |
| Guide build/specs repo | `/srv/guide-build/` |
| Guide data outputs | `/srv/guide-data/` — markdown exports written by guide-engine scripts, read by Guide agents. Not a repo — not yet populated. |
| Compose file | `/srv/compose/openclaw.yml` |
| Systemd unit | `/etc/systemd/system/openclaw.service` |
| Systemd override | `/etc/systemd/system/openclaw.service.d/override.conf` |
| OpenClaw logs | `/srv/openclaw/logs/gateway.log` |
| Signals | `/srv/openclaw/workspaces/main/signals/` |
| Filesystem layout spec | `Specs/guide-filesystem-layout.md` (canonical reference) |

---

## Service Ports

| Service | Port | Bind | Status |
|---------|------|------|--------|
| OpenClaw gateway | 18789 | 127.0.0.1 | Planned (Phase 0) |
| OpenClaw Studio | 3000 | 127.0.0.1 | Planned (Phase 0) |
| ETL API (Python) | 5010 | 127.0.0.1 | Planned (Phase 2) |
| ChromaDB | 8000 | 127.0.0.1 | Planned (future) |
| Redis | 6379 | 127.0.0.1 | Planned (future) |

**Rule:** Every service binds to 127.0.0.1. Nothing on 0.0.0.0 without explicit operator approval.

---

## Node / Python Versions

| Runtime | Version | Manager |
|---------|---------|---------|
| Node.js | 24 LTS | nvm |
| Python | 3.11 | pyenv |

---

## Model Names (verbatim)

| Use | Model string |
|-----|-------------|
| Primary (interactive) | `anthropic/claude-sonnet-4-6` |
| Cost-efficient (cron) | `anthropic/claude-haiku-4-5` |
| Premium (available) | `anthropic/claude-opus-4-6` |

---

## Workspace File Injection Order

```
IDENTITY.md -> SOUL.md -> USER.md -> AGENTS.md -> TOOLS.md
-> MEMORY.md -> HEARTBEAT.md -> BOOT.md -> BOOTSTRAP.md
```

**Critical:** OpenClaw silently truncates at `bootstrapMaxChars` (default 20,000 chars). Keep each file under 2,000 characters. Heavy content goes in `workspace/docs/` (loaded on-demand).

---

## Agent Factory Conventions

### Three agent types

| Type | Workspace (system) | User content | Config source | Comms | Generator |
|------|-------------------|--------------|---------------|-------|-----------|
| **Channel** | `/srv/openclaw/workspaces/{role}/` | `/srv/guide-vaults/teams/{team}/` (read-write) | `roles/{role}.env` | Slack channel | `./generate.sh channel {role}` |
| **Personal** | `/srv/openclaw/workspaces/personal-{name}/` | `/srv/guide-vaults/personal/{name}/` (read-write) + `/srv/guide-vaults/teams/` + `/srv/guide-vaults/shared/` (read-write) | `roster.json["persons"]["{name}"]` | Telegram per-person bot | `./generate.sh personal {name}` |

### Naming conventions

| Item | Convention |
|------|-----------|
| Channel workspace | `/srv/openclaw/workspaces/{role}` (e.g., `workspaces/data`, `workspaces/seo`) |
| Personal workspace | `/srv/openclaw/workspaces/personal-{name}` (e.g., `workspaces/personal-nick`) |
| Personal vault | `/srv/guide-vaults/personal/{name}` (e.g., `personal/nick`) |
| Team vault | `/srv/guide-vaults/teams/{team}` (e.g., `teams/digital`, `teams/exco`) |
| Brand codes | `ws` (Wilderness), `jc` (Jacada), `yz` (Yellow Zebra) |

### Factory structure

| Item | Path |
|------|------|
| Channel templates | `/srv/guide-core/agent-factory/templates/channel/` |
| Personal templates | `/srv/guide-core/agent-factory/templates/personal/` |
| Channel configs | `/srv/guide-core/agent-factory/roles/{role}.env` |
| Master roster | `/srv/guide-core/agent-factory/roster.json` (copied from vault `Specs/guide-roster.json`) |
| Generator script | `/srv/guide-core/agent-factory/generate.sh` |
| Runbook | `/srv/guide-core/agent-factory/ADD-AN-AGENT.md` |

### Master roster (guide-roster.json)

The master roster is the single source of truth for all personal instances, team vaults, channel agents, and API keys. It lives in the Obsidian vault at `Specs/guide-roster.json` and is copied to the Guide machine at `/srv/guide-core/agent-factory/roster.json`.

`generate.sh personal {name}` reads person config directly from roster.json. No individual `.env` files for personal instances.

### Agent registration flow

After `generate.sh` creates the workspace, agent registration requires three steps:

```bash
# 1. Register the agent
openclaw agents add <agent-id> --workspace <path> --non-interactive

# 2. Provision auth profile (LLM calls fail silently without this)
# Auth profiles are NOT auto-provisioned — new agents get an empty auth-profiles.json
# Copy from the appropriate API key tier (exec/domain/operational per roster.json apiKeyRef)

# 3. Bind to comms channel
# For Telegram personal instances:
openclaw channels add --channel telegram --account <name> --name "Guide <Name>" --token-file <path>
openclaw agents bind --agent <agent-id> --bind telegram:<accountName>
# Then set allowFrom and dmPolicy on the account in openclaw.json

# For Slack channel agents:
openclaw agents bind --agent <agent-id> --bind slack:<channelId>
```

### Pre-flight checklist — EVERY new agent

Before any new agent goes live, apply ALL known mitigations. Do not wait for bugs to resurface. Check every item:

- [ ] **Auth profile provisioned** — `openclaw agents add` creates an empty `auth-profiles.json`. Without a valid API key, LLM calls time out silently. Copy from the appropriate tier.
- [ ] **Verbose/thinking output disabled** — new agents default to verbose. Disable before first user message. No user should see internal reasoning.
- [ ] **Telegram errorPolicy + errorCooldownMs set** — without this, empty-message events (heartbeats, commands with no text) fire LLM calls with empty messages arrays, get 400 errors, and retry in a loop. Burns API credits, causes slowness. Copy the error policy config from the main bot.
- [ ] **tools.deny includes exec** — for personal instances (ADR-022). Omit the exec block entirely.
- [ ] **tools.exec.ask uses "always"** — not "on" (which is not schema-valid).
- [ ] **allowFrom and dmPolicy set** on the Telegram account — restrict who can message the bot.
- [ ] **messages.suppressToolErrors = true** — without this, tool error payloads (e.g. "⚠️ 📝 Edit failed") are shown to the user as visible messages. The agent already sees the error and can retry; there's no reason to surface it in chat. This is a top-level `openclaw.json` setting, not per-agent.
- [ ] **streaming.preview.toolProgress = false** on every Telegram account — without this, live tool progress updates (e.g. "🔧 running...") render as visible messages during partial streaming. Set on both `channels.telegram.streaming.preview.toolProgress` (global default) and `channels.telegram.accounts.<name>.streaming.preview.toolProgress` (per-account). Every new account needs this.
- [ ] **INDEX.md exists in shared directories** — agents without exec cannot list directory contents. Every directory under `guide-shared/` and `guide-outputs/` that an agent reads must have an `INDEX.md` listing its contents. Without this, the agent knows the directory exists but cannot discover files.

**This checklist exists because every item above has caused a production incident or user-facing bug.** Do not skip items. Do not assume defaults are safe.

### Telegram multi-bot pattern

OpenClaw supports multiple Telegram bots via `channels.telegram.accounts.<name>`. Each account has its own `botToken`, `allowFrom`, and `dmPolicy`. Personal instances each get a dedicated bot — separate bot token = separate conversation space = architectural privacy isolation (ADR-020).

### tools.exec — valid ask values

Schema-valid values for `tools.exec.ask`: `"off"`, `"on-miss"`, `"always"`. Note: `"on"` is NOT valid. For personal instances with exec denied, omit the exec block entirely and put `"exec"` in `tools.deny`.

### INDEX.md — directory listing for agents without exec

OpenClaw has no directory listing tool. Agents with exec denied (all personal and channel agents) cannot run `ls` — they can only `vault_read` a file by exact path. Without INDEX.md, agents know a directory exists but cannot discover its contents.

**Convention:** Every directory that an agent reads must contain an `INDEX.md` listing its files.

```markdown
# Index

| File | Description | Updated |
|------|-------------|---------|
| weekly-2026-04-25.md | Weekly capital allocation summary | 2026-04-25 |
| monthly-2026-04.md | April board report | 2026-04-30 |
```

**Who maintains it:**
- `guide-teams/` — the team that owns the vault (manually or via a cron job)
- `guide-shared/` — whoever populates the data (Pipeline agent, Engineer, Gareth)
- `guide-outputs/` — the agent that writes outputs appends to INDEX.md in the same commit

**When to update:** Every time a file is added or removed from the directory.

### Boot context files

The `bootContext` field in roster.json lists files the agent should read at session start (e.g., `PRIORITIES.md`, `FY27-CEO-Commitments.md`). These are **not copied into the workspace** — the agent reads them from its mounted team vaults at runtime. If a boot context file is missing, the issue is a content gap in the team vault, not a factory problem.

The roster includes deployment gates (boolean checklists) and status tracking per person, team vault, and channel agent. Gareth maintains it; Engineer consumes it.

---

## Coding Standards

| Language | Rules |
|----------|-------|
| Bash | `set -euo pipefail`. All vars quoted. ShellCheck-clean. Functions over inline. |
| TypeScript (Skills) | Strict mode. Typed I/O. JSDoc on exports. Try/catch on all async. |
| Python (ETL/services) | PEP 8. Type hints. Docstrings. `loguru` logging. `pydantic` models. `httpx` for HTTP. |
| systemd | Unit files in `/etc/systemd/system/`. Use overrides for env vars. `sudo systemctl restart openclaw.service` to apply changes. |
| Git | Conventional commits: `feat(chunk-NN): description` |

---

## Security Non-Negotiables

1. No hardcoded secrets, IPs, usernames, passwords anywhere
2. Chat IDs always from config or env — never literal in scripts
3. OpenClaw gateway bind: `loopback` only
4. Tailscale Serve on tailnet — never Tailscale Funnel
5. `exec` deny-by-default in TOOLS.md for non-Guide agents
6. All workspace identity files `440` after write
7. No services exposed to public internet without explicit operator approval
8. Brand data isolation — agents cannot cross-access other brands' data
9. Executive channel outputs reviewed by Guide orchestrator before delivery

---

## Ubuntu/Linux Conventions

| Item | Convention |
|------|-----------|
| Service management | systemd — `sudo systemctl restart openclaw.service` |
| Package manager | apt |
| Container runtime | Docker Engine (Linux native — not Docker Desktop) |
| Compose file | `/srv/compose/openclaw.yml` |
| Env vars | systemd override: `/etc/systemd/system/openclaw.service.d/override.conf` |
| Firewall | UFW — default deny inbound, tailnet-only SSH |
| Docker | Docker Desktop for Mac (Apple Silicon native) — not used for OpenClaw (ADR-021) |
| File permissions | Same `440` rule for workspace files |

---

## Cron Conventions

### Cron Prompt File Convention

All cron job prompts live as standalone markdown files in `/srv/guide-core/prompts/cron/<job-name>.md`. Each job's `--message` is a single file-reference instruction:

```
Read the file at /home/<user>/guide-core/prompts/cron/<job-name>.md and follow the instructions exactly.
```

**Why:** Humans own content, Guide executes it. No gateway restart is needed when a prompt changes — the file is read fresh at each cron run. All prompts are versioned, diffable, and editable in any editor.

**Workflow for editing a prompt:**
```bash
nano /srv/guide-core/prompts/cron/<job-name>.md
git -C /srv/guide-core add prompts/cron/<job-name>.md && git commit -m "prompt: <description>" && git push
# No restart needed — file is read fresh at each cron run
```

**Never store prompt content inline in `jobs.json` or as a `--message` argument.** Inline prompts have no version history, cannot be diffed, and can in principle be overwritten by the agent.

Reference: 19 live prompt files in `~/jarvis-core/prompts/cron/` — fork these for Guide briefs.

---

### Cron Schedule Rules

1. **Data fetch before briefs** — ETL/pipeline jobs run before any brief or summary job
2. **No more than 2 jobs at the same minute** — stagger concurrent jobs to avoid simultaneous model calls
3. **≥5 minute gap between heavy brief jobs** — synthesis jobs (morning brief, strategic brief) should not fire within 5 minutes of each other
4. **Rationale:** If 4 jobs fire simultaneously and all fall back to the same model under load, they hit TPM rate limits together — jobs get auto-disabled before anyone notices.

Guide reference schedule order:
```
06:00  etl-daily-refresh           ← data fetch first, every day
07:30  performance-morning-brief   ← synthesis after data is ready
08:00  gareth-strategic-brief      ← 30 min gap
09:00  pipeline-health-check       ← ops check, weekdays
09:05  monthly-board-digest        ← staggered from health check (1st of month)
12:00  midday-anomaly-scan         ← lower priority, later
17:00  weekly-performance-summary  ← end of week
```

---

### Cron Health Monitoring

Cron jobs can be silently disabled by OpenClaw after consecutive errors — no alert fires by default. Check job health regularly:

```bash
# Disabled jobs
cat /srv/openclaw/openclaw.json | python3 -c "
import sys, json
d = json.load(sys.stdin)
disabled = [j['name'] for j in d.get('cron',{}).get('jobs',[]) if not j.get('enabled', True)]
print('Disabled:', disabled if disabled else 'none')
"

# Jobs with consecutive errors
cat /srv/openclaw/openclaw.json | python3 -c "
import sys, json
d = json.load(sys.stdin)
for j in d.get('cron',{}).get('jobs',[]):
    errs = j.get('state', {}).get('consecutiveErrors', 0)
    if errs > 0:
        print(f'{j[\"name\"]}: {errs} errors — {j[\"state\"].get(\"lastError\",\"\")[:80]}')
"
```

Add these checks to the CHUNK-08 verification gate and the daily health-check cron job.

Reference: `DECISIONS.md` ADR-006 (cron prompt files).

---

## Idempotency Rule

Every chunk must be safe to re-run on a partially or fully complete state.
Check before creating: `[[ -f path ]]`, `command -v tool`, `brew list | grep tool`.
Never blindly overwrite existing config files — check first, skip if already correct.

---

## OpenClaw-First Rule

Before writing any custom code:
1. Does OpenClaw handle this natively?
2. Does ClawHub have a community Skill? `openclaw skills search <term>`
3. Only then write a custom Skill or service.

---

## Chunk File Format Contract

Every CHUNK-NN.md must contain exactly these sections, in order:

```
# CHUNK-NN — TITLE
## GUIDE Build System | Phase X | Status Badge

> Claude Code instructions block

### What This Chunk Does
[Description + Success state]

### Prerequisites
[Checklist — prior chunks, env vars, running services]

### Deliverables
[Numbered list of concrete, verifiable outputs]

### Environment Variables Required
[From .env or openclaw.json]

### Tasks
[Numbered, idempotent, Claude Code executable]

### Verification Gate
[Bash checks — all must print checkmark]

### Rollback
[How to reverse this chunk's changes if needed]

### Git Commit
[Conventional commit command]

### Handoff to CHUNK-N+1
[What the next chunk expects]
```

Claude Code reads each chunk in isolation. It must be able to complete every task without needing the master spec or other chunk files in context. It references this file for constants only.

---

*Guide conventions — 2026-04-05 | CLI drift protocol added: 2026-04-17 | Extracted to standalone vault: 2026-05-12*
