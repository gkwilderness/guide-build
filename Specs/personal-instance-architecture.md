---
title: "Personal Instance Architecture"
type: architecture-spec
area: wilderness
project: Guide
tags: [guide, architecture, personal-instances, team-vaults, scaling]
created: 2026-04-29
status: active
supersedes: exco-agent-spec.md
---

# Personal Instance Architecture

**Status:** Active — approved by Gareth, 2026-04-29
**Owner:** Gareth Knight
**Supersedes:** [[exco-agent-spec|Exco Agent — Design Spec]] (absorbed into this architecture)

---

## Problem

Guide was designed for ~20 agents across a phased rollout: shared agents, brand-scoped channel agents, and 3 exec slots. Demand has outrun that shape.

Nick and Hadley approved the build-out and want their own instances. Keith, Dean, Caro, Scott, Simon, and Frances will too. That's 8 personal instances — not 3 exec slots — on top of existing channel and shared agents. The original exco spec (a single shared agent identifying users by phone number) doesn't meet the structural isolation or scaling requirements.

At the same time, the Wilderness-Guide vault — built for the digital team — is already live as a team operating system. Other teams will need their own vaults as Guide scales. The architecture needs to support both personal instances and team vaults as first-class concepts.

---

## The Two-Dimensional Model

Guide serves people through two dimensions:

### Personal Instances — serve an individual

One person, one agent, one private conversation, one private workspace. Nick's Guide helps Nick. Hadley's Guide helps Hadley. Each mounts the team vaults relevant to that person (read-only) plus any supplementary shared data.

### Team Vaults — serve a function

Shared operational context for a functional team. Structured with CLAUDE.md conventions, backlogs, priorities, reports. The team works in it (via Slack + OneDrive); agents read from it. Channel agents (data, seo, martech, etc.) are bound to team vaults.

### The relationship

A personal instance mounts one or more team vaults based on the person's role. Frances (performance marketing) mounts the digital team vault. Caro (reservations) mounts the reservations team vault when it exists. Nick (exec) mounts the exec vault + reads reports from any team vault.

Personal instances and team vaults are independent lifecycles. A personal instance ships when the person is ready. A team vault ships when the team is ready. Personal instances work with whatever team vaults exist — they just have less shared context until the vault is populated.

---

## Agent Structure

### Three agent categories

| Category | Serves | Workspace | Reads from | Comms |
|----------|--------|-----------|------------|-------|
| **Personal** | One person | `guide-vault/personal/{name}/` | Team vaults (ro) + supplementary shared (ro) | Telegram per-person bot |
| **Channel** | One team function | `guide-vault/channel/{role}/` | Team vault for that function (ro) | Slack channel |
| **Shared** | Everyone / system | `guide-vault/shared/{role}/` | Depends on role | Various |

### Personal agents

| Agent ID | Person | Role | Team vault(s) | Supplementary mounts |
|----------|--------|------|---------------|---------------------|
| `personal-nick` | Nick | PE/Finance | exec | `data/finance/`, `guide-outputs/reports/` |
| `personal-hadley` | Hadley | CCO | exec, digital | `guide-outputs/reports/` |
| `personal-keith` | Keith | CEO | exec | `guide-outputs/reports/` |
| `personal-scott` | Scott | Safari Sales | sales (future) | `kb/safari/`, `brand/` |
| `personal-caro` | Caro | Reservations | reservations (future) | `kb/safari/`, `data/hubspot/` |
| `personal-frances` | Frances | Perf Marketing | digital | `data/paid/` |
| `personal-simon` | Simon | B2B Sales | sales (future) | `data/hubspot/`, `brand/` |
| `personal-dean` | Dean | HR | people (future) | — |

### Channel agents

Bound to team vaults. Operate within a team's Slack channels.

| Agent ID | Team Vault | Slack Channel |
|----------|-----------|---------------|
| `channel-data` | digital | #guide-data-backlog |
| `channel-martech` | digital | #guide-martech-backlog |
| `channel-seo` | digital | #seo-guide |
| `channel-product` | digital | #guide-digital-product |
| `channel-hubspot` | digital | #guide-hubspot |
| `channel-sales` (future) | sales | TBD |
| `channel-reservations` (future) | reservations | TBD |

### Shared agents

Unchanged from original design.

| Agent ID | Role |
|----------|------|
| `main` | Orchestrator — mounts everything, routes, coordinates |
| `briefing` | Brief generation — reads team vaults + outputs |
| `scribe` | Meeting capture — reads team vaults |
| `pipeline` | Data ETL — manages guide-data/ outputs |
| `analyst` | Cross-domain analysis — reads data layer |
| `finance` | Financial reporting — reads data/finance/ |
| `capitalcore` | Capital allocation intelligence — cross-brand |
| `apex` | Competition/anomaly detection — cross-brand paid media |

---

## Filesystem Architecture

### Current State (pre-CHUNK-12)

```
~/ (guide user home)
├── guide-core/                      ← EXISTS — git repo, agent factory, docker
│   └── agent-factory/
│       ├── templates/               ← Flat — 9 template files, no channel/personal split
│       ├── roles/                   ← 5 channel configs (data.env, martech.env, etc.)
│       └── generate.sh              ← Single-arg: ./generate.sh <role-id>
├── guide-engine/                    ← EXISTS — ETL scripts, pipeline code (repo)
├── guide-data/                      ← Output directory — markdown written by guide-engine, read by agents (not a repo)
└── ~/.openclaw/
    ├── openclaw.json                ← All agents registered here
    ├── workspace/                   ← Guide Main (9 identity files)
    ├── workspace-data/              ← Channel agents in flat layout
    ├── workspace-martech/
    ├── workspace-seo/
    ├── workspace-product/
    └── workspace-hubspot/
```

**What doesn't exist yet:** `guide-vault/`, `guide-teams/`, `guide-shared/`, `guide-outputs/`. Agent workspaces are flat under `~/.openclaw/workspace-*`. No personal instances. No team vault symlinks. No structured output directory.

### Target State

```
/home/guide/
├── guide-core/              ← OpenClaw runtime, agent factory, docker-compose
│   ├── agent-factory/       ← Templates, overlays, generate.sh
│   ├── docker/              ← docker-compose files
│   ├── prompts/             ← Cron prompts, reusable prompts
│   └── __CONFIG/            ← Keys (gitignored), LLM config, comms config
│
├── guide-engine/            ← ETL scripts, pipeline code (repo)
│
├── guide-data/              ← Output directory — markdown written by guide-engine (not a repo)
│
├── guide-vault/             ← Agent workspaces (private, git-tracked)
│   ├── main/
│   ├── shared/
│   │   ├── briefing/
│   │   ├── scribe/
│   │   ├── pipeline/
│   │   ├── analyst/
│   │   ├── finance/
│   │   ├── capitalcore/
│   │   └── apex/
│   ├── channel/
│   │   ├── data/
│   │   ├── martech/
│   │   ├── seo/
│   │   ├── product/
│   │   └── hubspot/
│   └── personal/
│       ├── nick/
│       ├── hadley/
│       ├── keith/
│       ├── scott/
│       ├── caro/
│       ├── frances/
│       ├── simon/
│       └── dean/
│
├── guide-teams/             ← Team vaults (shared read layer)
│   ├── digital/             ← = Wilderness-Guide vault (OneDrive sync)
│   ├── exec/                ← Executive team vault
│   ├── sales/               ← Future
│   ├── reservations/        ← Future
│   └── people/              ← Future
│
├── guide-shared/            ← Supplementary shared content (cross-team)
│   ├── brand/
│   │   ├── wilderness/
│   │   ├── jacada/
│   │   └── yellow-zebra/
│   ├── data/
│   │   ├── paid/
│   │   ├── seo/
│   │   ├── hubspot/
│   │   ├── analytics/
│   │   └── finance/
│   └── kb/
│       └── safari/
│
└── guide-outputs/           ← Agent outputs, append-only, git-tracked
    ├── decisions.md
    ├── output-log.md
    ├── briefs/
    ├── alerts/
    ├── reports/
    │   ├── weekly/
    │   ├── monthly/
    │   └── board/
    └── archive/
        └── YYYY/MM/
```

### Five top-level directories

| Directory | Purpose | Git | Write access |
|-----------|---------|-----|-------------|
| `guide-vault/` | Agent workspaces — private identity, memory, logs | Yes, auto-commit | Each agent writes only to its own subdirectory |
| `guide-teams/` | Team vaults — shared operational context | No (OneDrive-managed) | Teams via OneDrive; agents read-only |
| `guide-shared/` | Supplementary cross-team content | No (pipeline-managed) | Pipeline agent or manual; agents read-only |
| `guide-outputs/` | Agent outputs — audit trail | Yes, auto-commit per write | Shared agents (briefing, capitalcore, apex); personal agents read-only |
| `guide-core/` | Runtime, factory, config | Yes (guide-core repo) | Engineer/Architect only |

### guide-teams/ — team vaults as first-class

Team vaults are not subordinate to a generic shared layer. They have their own CLAUDE.md conventions, their own structure, their own lifecycle.

`guide-teams/digital/` = the existing Wilderness-Guide vault, symlinked from local Obsidian:

```bash
ln -s "$HOME/Obsidian/Wilderness-Guide" \
      $HOME/guide-teams/digital
```

The digital team vault is a local Obsidian vault, not on OneDrive. Future team vaults may be OneDrive-synced — each follows the same symlink pattern.

### guide-shared/ — supplementary, cross-team

For content that doesn't belong to any single team vault:
- `brand/` — brand guidelines and docs
- `data/` — pipeline outputs in markdown
- `kb/` — knowledge bases (safari KB, etc.)

### Migration: current → target

| What | From | To | Action |
|------|------|----|--------|
| Guide Main workspace | `~/.openclaw/workspace/` | `~/guide-vault/main/` | Copy contents |
| Channel workspaces (×5) | `~/.openclaw/workspace-{role}/` | `~/guide-vault/channel/{role}/` | Copy contents |
| Digital team vault | OneDrive (Wilderness-Guide) | `~/guide-teams/digital/` | Symlink |
| Exec team vault | — | `~/guide-teams/exec/` | Create + seed |
| openclaw.json paths | `~/.openclaw/workspace*` paths | `~/guide-vault/*` paths | Update in-place |
| generate.sh output | `~/.openclaw/workspace-{role}/` | `~/guide-vault/channel/{role}/` | Update script |

**Dependency order:** Create directories → migrate workspaces → update openclaw.json → restart gateway → verify. Gateway must be stopped during migration.

**Old workspaces:** Keep `~/.openclaw/workspace-*` as a safety net until CHUNK-13 is confirmed working. Remove after.

### Bootstrap script: guide-bootstrap.sh

One-shot script that creates the full directory structure, migrates workspaces, symlinks team vaults, seeds exec vault, initialises git, and updates openclaw.json. The Engineer runs this once on the Guide machine as CHUNK-12.

This script is idempotent — re-running skips anything that already exists.

```bash
#!/usr/bin/env bash
# guide-bootstrap.sh — Create Guide filesystem structure and migrate workspaces
# Run once on the Guide machine. Idempotent — safe to re-run.
#
# Usage: ./guide-bootstrap.sh [--dry-run]
#
# Prerequisites:
#   - Guide machine with OpenClaw running
#   - ~/.openclaw/workspace/ exists (Guide Main)
#   - OneDrive syncing (Wilderness-Guide vault accessible)
#   - guide-core repo cloned at ~/guide-core/

set -euo pipefail

DRY_RUN="${1:-}"
HOME_DIR="$HOME"
ONEDRIVE_ROOT="$HOME_DIR/Library/CloudStorage/OneDrive-Wilderness"

log() { echo "  $1"; }
ok()  { echo "✓ $1"; }
skip() { echo "⚠ $1 — skipping (already exists)"; }
fail() { echo "✗ $1"; exit 1; }

if [[ "$DRY_RUN" == "--dry-run" ]]; then
  echo "=== DRY RUN — no changes will be made ==="
  echo ""
fi

echo "=== Guide Filesystem Bootstrap ==="
echo ""

# --- 1. Create guide-vault/ ---
echo "--- 1/7: guide-vault/ ---"

for dir in main channel shared personal; do
  target="$HOME_DIR/guide-vault/$dir"
  if [[ -d "$target" ]]; then
    skip "guide-vault/$dir/"
  else
    [[ "$DRY_RUN" != "--dry-run" ]] && mkdir -p "$target"
    ok "guide-vault/$dir/ created"
  fi
done

# --- 2. Migrate workspaces ---
echo ""
echo "--- 2/7: Migrate workspaces ---"

# Guide Main
MAIN_SRC="$HOME_DIR/.openclaw/workspace"
MAIN_DEST="$HOME_DIR/guide-vault/main"
if [[ -d "$MAIN_SRC" ]] && [[ ! -f "$MAIN_DEST/IDENTITY.md" ]]; then
  [[ "$DRY_RUN" != "--dry-run" ]] && cp -a "$MAIN_SRC"/* "$MAIN_DEST"/
  ok "Guide Main migrated to guide-vault/main/"
elif [[ -f "$MAIN_DEST/IDENTITY.md" ]]; then
  skip "Guide Main already migrated"
else
  log "Guide Main source not found at $MAIN_SRC — manual migration needed"
fi

# Channel agents
for role in data martech seo product hubspot; do
  SRC="$HOME_DIR/.openclaw/workspace-${role}"
  DEST="$HOME_DIR/guide-vault/channel/${role}"
  if [[ -d "$SRC" ]] && [[ ! -f "$DEST/IDENTITY.md" ]]; then
    [[ "$DRY_RUN" != "--dry-run" ]] && mkdir -p "$DEST" && cp -a "$SRC"/* "$DEST"/
    ok "${role} migrated to guide-vault/channel/${role}/"
  elif [[ -f "$DEST/IDENTITY.md" ]]; then
    skip "${role} already migrated"
  else
    log "${role} source not found at $SRC — may not be generated yet"
  fi
done

# --- 3. Create guide-teams/ ---
echo ""
echo "--- 3/7: guide-teams/ ---"

[[ "$DRY_RUN" != "--dry-run" ]] && mkdir -p "$HOME_DIR/guide-teams"

# Digital team vault — symlink to OneDrive
GUIDE_VAULT_ONEDRIVE="$ONEDRIVE_ROOT/Wilderness-Guide"
DIGITAL_LINK="$HOME_DIR/guide-teams/digital"

if [[ -L "$DIGITAL_LINK" ]]; then
  skip "guide-teams/digital/ symlink"
elif [[ -d "$GUIDE_VAULT_ONEDRIVE" ]]; then
  [[ "$DRY_RUN" != "--dry-run" ]] && ln -sf "$GUIDE_VAULT_ONEDRIVE" "$DIGITAL_LINK"
  ok "guide-teams/digital/ → $GUIDE_VAULT_ONEDRIVE"
else
  log "OneDrive path not found: $GUIDE_VAULT_ONEDRIVE"
  log "Check OneDrive sync and adapt the path. Listing available folders:"
  ls "$ONEDRIVE_ROOT/" 2>/dev/null || log "OneDrive root not found either"
fi

# Exec team vault — create and seed
EXEC_DIR="$HOME_DIR/guide-teams/exec"
if [[ -f "$EXEC_DIR/CLAUDE.md" ]]; then
  skip "guide-teams/exec/ already seeded"
else
  [[ "$DRY_RUN" != "--dry-run" ]] && mkdir -p "$EXEC_DIR"
  [[ "$DRY_RUN" != "--dry-run" ]] && cat > "$EXEC_DIR/CLAUDE.md" << 'CLAUDEEOF'
# Executive Team Vault

## What This Is

Executive-level context for Guide personal instances serving Keith, Nick, and Hadley. Contains board-level outputs, capital allocation reports, strategic context, and FY targets.

## Files to Load First

| File | What it gives you |
|------|-------------------|
| `PRIORITIES.md` | Current executive priorities |

## Conventions

- All content is read-only for agents — no writes permitted
- Strategic framing: "controllable vs structural" (Keith's lens)
- Financial framing: capital allocation, ROI, proof points (Nick's lens)
- Commercial framing: pipeline health, team capacity, commercial performance (Hadley's lens)

## What Not to Do

- Do not surface internal process files (backlogs, PIE scores, sprint boards) to executives
- Do not reference Guide system internals
- Do not speculate on financials — state what the data shows
CLAUDEEOF

  [[ "$DRY_RUN" != "--dry-run" ]] && cat > "$EXEC_DIR/PRIORITIES.md" << 'PRIOEOF'
# Executive Priorities

## Current Quarter

- Team activation and capability build
- HubSpot rollout across Group
- YZ website launch
- Wilderness UHNWI ICP build
- Guide rollout to executive team

## Standing Priorities

- Capital allocation efficiency
- Digital as infrastructure, not marketing
- Controllable vs structural performance split
PRIOEOF
  ok "guide-teams/exec/ created and seeded"
fi

# Future team vault placeholders
for team in sales reservations people; do
  target="$HOME_DIR/guide-teams/$team"
  if [[ -d "$target" ]]; then
    skip "guide-teams/$team/"
  else
    [[ "$DRY_RUN" != "--dry-run" ]] && mkdir -p "$target"
    ok "guide-teams/$team/ created (empty — populated when team is ready)"
  fi
done

# --- 4. Create guide-shared/ ---
echo ""
echo "--- 4/7: guide-shared/ ---"

for dir in brand/wilderness brand/jacada brand/yellow-zebra \
           data/paid data/seo data/hubspot data/analytics data/finance \
           kb/safari; do
  target="$HOME_DIR/guide-shared/$dir"
  if [[ -d "$target" ]]; then
    skip "guide-shared/$dir/"
  else
    [[ "$DRY_RUN" != "--dry-run" ]] && mkdir -p "$target"
    ok "guide-shared/$dir/ created"
  fi
done

# --- 5. Create guide-outputs/ ---
echo ""
echo "--- 5/7: guide-outputs/ ---"

OUTPUTS_DIR="$HOME_DIR/guide-outputs"
if [[ -d "$OUTPUTS_DIR/.git" ]]; then
  skip "guide-outputs/ already git-initialised"
else
  [[ "$DRY_RUN" != "--dry-run" ]] && mkdir -p "$OUTPUTS_DIR/briefs" \
    "$OUTPUTS_DIR/alerts" \
    "$OUTPUTS_DIR/reports/weekly" \
    "$OUTPUTS_DIR/reports/monthly" \
    "$OUTPUTS_DIR/reports/board" \
    "$OUTPUTS_DIR/archive"

  [[ "$DRY_RUN" != "--dry-run" ]] && cat > "$OUTPUTS_DIR/decisions.md" << 'EOF'
# Decisions Log

Append-only. Each entry is one git commit.

Format:
```
## [YYYY-MM-DD HH:MM] [agent-id] — Decision Title

Context: ...
Decision: ...
Rationale: ...
```
EOF

  [[ "$DRY_RUN" != "--dry-run" ]] && cat > "$OUTPUTS_DIR/output-log.md" << 'EOF'
# Output Log

Append-only. Every agent output is logged here with timestamp and agent ID.

Format:
```
## [YYYY-MM-DD HH:MM] [agent-id] — Output Title

[output content]
```
EOF

  [[ "$DRY_RUN" != "--dry-run" ]] && cd "$OUTPUTS_DIR" && git init && git add -A && git commit -m "init: guide-outputs — append-only agent output directory"
  ok "guide-outputs/ created and git-initialised"
fi

# --- 6. Update openclaw.json workspace paths ---
echo ""
echo "--- 6/7: Update openclaw.json ---"

CONFIG="$HOME_DIR/.openclaw/openclaw.json"
if [[ ! -f "$CONFIG" ]]; then
  fail "openclaw.json not found at $CONFIG"
fi

# Check if already updated
if grep -q "guide-vault" "$CONFIG" 2>/dev/null; then
  skip "openclaw.json already contains guide-vault paths"
else
  [[ "$DRY_RUN" != "--dry-run" ]] && cp "$CONFIG" "${CONFIG}.bak-bootstrap"
  [[ "$DRY_RUN" != "--dry-run" ]] && python3 << PYEOF
import json, os, shutil

config_path = os.path.expanduser("~/.openclaw/openclaw.json")
home = os.path.expanduser("~")

with open(config_path) as f:
    config = json.load(f)

path_map = {
    "workspace": f"{home}/guide-vault/main",
    "workspace-data": f"{home}/guide-vault/channel/data",
    "workspace-martech": f"{home}/guide-vault/channel/martech",
    "workspace-seo": f"{home}/guide-vault/channel/seo",
    "workspace-product": f"{home}/guide-vault/channel/product",
    "workspace-hubspot": f"{home}/guide-vault/channel/hubspot",
}

# Update default workspace
defaults = config.get("agents", {}).get("defaults", {})
if "workspace" in defaults:
    old = defaults["workspace"]
    defaults["workspace"] = f"{home}/guide-vault/main"
    print(f"  main: {old} -> {defaults['workspace']}")

# Update agent list
for agent in config.get("agents", {}).get("list", []):
    old_ws = agent.get("workspace", "")
    aid = agent.get("id", "unknown")
    for old_suffix, new_path in path_map.items():
        if old_ws.endswith(old_suffix):
            agent["workspace"] = new_path
            print(f"  {aid}: {old_ws} -> {new_path}")
            break

with open(config_path, "w") as f:
    json.dump(config, f, indent=2)

print("  Done")
PYEOF
  ok "openclaw.json workspace paths updated (backup at ${CONFIG}.bak-bootstrap)"
fi

# --- 7. Update generate.sh output path ---
echo ""
echo "--- 7/7: Update generate.sh ---"

GENSH="$HOME_DIR/guide-core/agent-factory/generate.sh"
if [[ -f "$GENSH" ]] && grep -q "guide-vault/channel" "$GENSH" 2>/dev/null; then
  skip "generate.sh already outputs to guide-vault/"
elif [[ -f "$GENSH" ]]; then
  [[ "$DRY_RUN" != "--dry-run" ]] && sed -i.bak \
    's|WORKSPACE_DIR="\$HOME/\.openclaw/workspace-\${ROLE}"|WORKSPACE_DIR="\$HOME/guide-vault/channel/\${ROLE}"|' \
    "$GENSH"
  ok "generate.sh updated — new workspaces output to guide-vault/channel/"
else
  log "generate.sh not found at $GENSH — will be created in CHUNK-13"
fi

# --- 8. Initialise guide-vault git ---
echo ""
echo "--- 8/7: git init guide-vault/ ---"

if [[ -d "$HOME_DIR/guide-vault/.git" ]]; then
  skip "guide-vault/ already git-initialised"
else
  [[ "$DRY_RUN" != "--dry-run" ]] && cd "$HOME_DIR/guide-vault" && git init && git add -A && git commit -m "init: guide-vault — migrated workspaces to production structure"
  ok "guide-vault/ git-initialised"
fi

# --- Summary ---
echo ""
echo "=== Bootstrap Complete ==="
echo ""
echo "Verify:"
echo "  1. Restart gateway: docker compose -f ~/guide-core/docker/docker-compose.yml restart openclaw"
echo "  2. Wait 15 seconds, then check health: curl -s http://127.0.0.1:18789/health"
echo "  3. Message @WildernessGuideBot — confirm Guide Main responds"
echo "  4. Message in #guide-data-backlog — confirm Data agent responds"
echo "  5. Check symlink: ls ~/guide-teams/digital/CLAUDE.md"
echo ""
echo "If gateway fails: cp ~/.openclaw/openclaw.json.bak-bootstrap ~/.openclaw/openclaw.json && restart"
```

The script lives in this vault at `Specs/guide-bootstrap.sh`. The Engineer copies it to the Guide machine and runs it. After the script completes, the Engineer restarts the gateway and verifies all agents respond.

---

## Vault Access Model

OpenClaw runs bare metal on macOS (ADR-021). Access control is enforced via `openclaw.json` workspace paths and agent-level vault path restrictions in each agent's AGENTS.md and TOOLS.md. Agents can only read paths listed in their identity files.

### Personal instance (Nick — exec tier)

```
workspace (rw):     ~/guide-vault/personal/nick/
team vaults (ro):   ~/guide-teams/exec/
shared data (ro):   ~/guide-shared/data/finance/
outputs (ro):       ~/guide-outputs/reports/
```

### Personal instance (Frances — domain tier)

```
workspace (rw):     ~/guide-vault/personal/frances/
team vaults (ro):   ~/guide-teams/digital/
shared data (ro):   ~/guide-shared/data/paid/
```

### Channel agent (data)

```
workspace (rw):     ~/guide-vault/channel/data/
team vaults (ro):   ~/guide-teams/digital/
shared data (ro):   ~/guide-shared/data/
```

### Guide Main (orchestrator)

```
workspace (rw):     ~/guide-vault/main/
team vaults (ro):   ~/guide-teams/ (all)
shared data (ro):   ~/guide-shared/ (all)
outputs (rw):       ~/guide-outputs/
```

**Note on access enforcement:** On bare metal, filesystem access is enforced by the agent's identity files (AGENTS.md lists permitted vault paths, TOOLS.md restricts vault_read/vault_write). This is prompt-level enforcement, not filesystem-level. For structural enforcement equivalent to Docker `:ro` mounts, use macOS file permissions (read-only for the guide user on team vault and shared directories). The symlinks from OneDrive are inherently read-only for the agent — OneDrive manages write access.

---

## Communications

### Telegram per-person bots

Each personal instance gets a dedicated Telegram bot: `@GuideNickBot`, `@GuideHadleyBot`, etc.

- **Structural isolation** — separate bot token = physically separate conversations. One bot cannot see another bot's messages.
- **Proven stack** — Telegram already live and working.
- **WhatsApp optional upgrade later** for execs who prefer it.

Bots created via BotFather. Naming convention: `@Guide{Name}Bot`. Tokens stored in `guide-core/__CONFIG/keys/` (gitignored).

### Channel agents stay on Slack

Channel agents continue using Slack channels as designed. No change.

### Gateway

Single OpenClaw gateway for all agents. Context windows are per-agent, not per-gateway — no shared context bleed. All personal instances register as additional agents in `openclaw.json`.

Separate gateway only if performance degrades (rate limits, concurrent session contention). The factory generates machine-agnostic workspaces, so moving agents to a second gateway is a config change, not a rebuild.

---

## Model Tiers

| Tier | Persons | Interactive Model | Cron/Background | API Key |
|------|---------|-------------------|-----------------|---------|
| Exec | Nick, Hadley, Keith | Sonnet | Haiku | Claude Max Plus (Nick-approved) |
| Domain | Scott, Caro, Dean, Simon, Frances | Sonnet | Haiku | Wilderness digital budget |

All interactive use gets Sonnet. Personal instances answer questions that need quality reasoning. Haiku reserved for mechanical cron/heartbeat tasks only.

---

## Privacy & Security Architecture

Enforced through three layers (ADR-020, ADR-022):

### Layer 1: Exec deny-by-default

All personal instances and channel agents have `exec` denied in their OpenClaw tools config. This is platform-level enforcement — the agent cannot run bash commands, which means it cannot bypass path restrictions via `cat`, `cp`, or any shell command. Permission profiles are defined in `guide-roster.json` and applied via the agent factory.

| Profile | Exec | Agents |
|---------|------|--------|
| `personal` | Denied | All 8 personal instances |
| `channel` | Denied | All 5 channel agents |
| `shared` | Denied | Briefing, Scribe, Analyst, Finance, CapitalCore, Apex |
| `main` | Restricted (read-only allowlist, `ask: on`) | Guide Main only |
| `pipeline` | Scoped (ETL scripts only, `ask: on`) | Pipeline agent (future) |

### Layer 2: Vault path scoping

Agents read and write files via `vault_read` and `vault_write` tools. Each agent's TOOLS.md and AGENTS.md define which paths it can access. This is prompt-level enforcement (the agent obeys its instructions), not platform-level.

- Personal instances: read from mounted team vaults + shared data. Write only to `~/guide-vault/personal/{id}/`.
- Channel agents: read from team vault. Write only to `~/guide-vault/channel/{id}/`.
- Guide Main: read everything. Write to own workspace + `guide-outputs/` + signals.

### Layer 3: File permissions (defence in depth)

macOS file permissions provide a structural backstop even if prompt-level restrictions are bypassed:

| Path | Permissions | Rationale |
|------|------------|-----------|
| Team vaults (`~/guide-teams/`) | `444` | Agents never modify team content |
| Other agents' workspaces | `700` per workspace | Owner-only access |
| Credentials (`~/.openclaw/credentials/`) | `400` | Owner read-only |
| Own workspace identity files | `440` | Read-only after generation |
| Own MEMORY.md | `644` | Agent writes its own memory |

### Conversation isolation

Separate Telegram bot tokens per person. Different bot = different conversation space. Architecturally impossible for one bot to see another's messages.

### SOUL.md privacy statement

Each personal instance's SOUL.md includes an explicit privacy block. This statement is architecturally true before being stated — backed by exec denial, path scoping, and file permissions.

### What is logged

- Agent outputs to `guide-outputs/` (shared agents only — personal instances do not write here)
- Session metadata (timestamps, token counts) in OpenClaw's internal logs
- Agent memory in the agent's own workspace (private, not readable by other agents)

### What is not logged

- Personal conversation content is not written to any shared location
- Personal instance memory is not readable by other agents through Guide's architecture

### Honest limitation

Gareth has SSH access to the Guide machine and can read any file. The privacy boundary is between agents, not between Gareth and agents. The privacy statement to users should be honest: "Guide's architecture prevents cross-agent access. Machine-level access is limited to system administration."

### Hybrid review model (from exco spec, absorbed)

For exec personal instances:
- **Factual/report questions** — agent answers directly. "What was last week's CPL?" Data is in the reports.
- **Judgment/recommendation questions** — agent drafts a response and escalates to Gareth via Slack DM for approval before sending. "Should we cut US Generic?"
- **Out-of-scope questions** — agent says it doesn't have that context and offers to flag Gareth.

The boundary between factual and judgment is encoded in the agent's SOUL.md.

---

## Agent Factory Extension

### Factory structure

```
agent-factory/
├── templates/
│   ├── channel/              ← Channel agent templates (9 identity files)
│   └── personal/             ← Personal instance templates (9 identity files)
├── roles/                    ← Channel agent configs (data.env, seo.env, etc.)
├── roster.json               ← Master roster (copied from vault's Specs/guide-roster.json)
├── generate.sh               ← Extended with type flag
└── ADD-AN-AGENT.md           ← Updated runbook
```

### Master roster: guide-roster.json

All person configs, team vaults, channel agents, API keys, and deployment gates are defined in a single JSON file: `Specs/guide-roster.json` (this vault). This is the single source of truth.

**Maintenance flow:**
1. Gareth updates `guide-roster.json` in the vault (add a person, flip a gate, change a status)
2. Engineer copies it to `~/guide-core/agent-factory/roster.json` on the Guide machine
3. `generate.sh personal {name}` reads person config directly from roster.json
4. Channel agents still use `roles/*.env` (existing pattern, may be migrated to roster.json later)

**What the roster contains:**
- `persons` — all personal instances with identity, vault scope, comms, review model, gates, status
- `teamVaults` — all team vaults with source, status, gates
- `channelAgents` — all channel agents with Slack binding, status, gates
- `apiKeys` — all API key tiers with provisioned status, key location, budget owner
- `_meta` — status value definitions

**To add a person:** Add their entry to `guide-roster.json`, copy to machine, run `generate.sh personal {name}`.
**To check readiness:** Scan the person's `gates` object — all must be true before moving to `production` status.

### generate.sh

**Current:** `./generate.sh <role-id>`
**New:** `./generate.sh <type> <id>`

- `./generate.sh channel data` — reads from `roles/data.env`
- `./generate.sh personal nick` — reads from `roster.json["persons"]["nick"]`
- Single-arg fallback: `./generate.sh data` → `./generate.sh channel data`

Steps:
1. Select template directory (`templates/channel/` or `templates/personal/`)
2. Read config (channel: `roles/<id>.env` | personal: `roster.json`)
3. Extract variables and substitute all `{{PLACEHOLDER}}` values
4. Create workspace at `guide-vault/{type}/{id}/`
5. Set permissions (440 for identity files, 644 for MEMORY.md)
6. Output registration commands for openclaw.json

### Template differences: Personal vs Channel

| File | Channel | Personal |
|------|---------|----------|
| IDENTITY.md | "I am the {{AGENT_ROLE}} agent" | "I am {{PERSON_NAME}}'s Guide" |
| SOUL.md | Domain-scoped, routes out-of-scope | Person-scoped, broader domain. Privacy section mandatory. Hybrid review model. |
| USER.md | Generic team context | Single person: name, role, style, what they care about |
| TOOLS.md | Slack channel messaging | Telegram bot, no Slack |
| BOOTSTRAP.md | Slack channel ID + vault CLAUDE.md | Person's team vault paths + boot context chain |
| HEARTBEAT.md | Domain health check | Personal brief schedule |

---

## Team Vault Lifecycle

### Current state

| Team Vault | Status |
|------------|--------|
| **digital** | Live — Wilderness-Guide vault, team using daily |
| **exec** | Needs creating — board docs, capital reports, exec briefs |

### Future (created as demand emerges)

| Team Vault | Trigger | Seeded by |
|------------|---------|-----------|
| **sales** | Scott + Simon instances live | Gareth + Scott |
| **reservations** | Caro instance live | Gareth + Caro |
| **people** | Dean instance live | Gareth + Dean |

### Team vault conventions

Each team vault follows the pattern established by the digital vault:
- `CLAUDE.md` at root — tells agents how to behave
- Folder-level `CLAUDE.md` files for each area
- `00-Compass/` for priorities and focus
- Backlogs with PIE scoring where appropriate
- OneDrive-synced so the team maintains it naturally

See [[team-vault-conventions]] for the full specification.

---

## Rollout

### Prerequisites

1. Filesystem restructure: `guide-vault/`, `guide-teams/`, `guide-shared/`, `guide-outputs/` created on machine
2. Existing workspaces migrated from `~/.openclaw/workspace-*` to `guide-vault/`
3. Agent factory extended with personal instance support
4. OpenClaw schema verified: multiple Telegram bot tokens in one instance
5. Privacy ADR written and architecturally enforced

### Rollout order

| # | Person | Team vault needed | Rationale |
|---|--------|-------------------|-----------|
| 1 | Nick | exec (create) | Approved budget. Clean scope. Validates exec tier. |
| 2 | Hadley | exec + digital (exists) | Co-approved. Tests broader scope. |
| 3 | Keith | exec | CEO. Gets polished version. |
| 4 | Scott | brand + kb/safari | First domain user. Safari KB forcing function. |
| 5 | Caro | brand + kb/safari | Reservations. Non-technical user test. |
| 6 | Frances | digital (exists) | Tests digital vault + paid data. |
| 7 | Simon | brand + hubspot data | B2B sales. |
| 8 | Dean | people (create) | Last — people vault needs creating first. |

### Per-person rollout process

1. Create person spec in vault (`Agents/Personal/{Name}.md`) — Architect
2. Create person.env from spec — Architect
3. Create Telegram bot via BotFather, store token — Gareth
4. Generate workspace: `./generate.sh personal {name}` — Engineer
5. Register agent + bind bot in openclaw.json — Engineer
6. Restart gateway, verify agent responds — Engineer
7. Test conversation as that person — Architect
8. Onboard the person — guided first conversation — Gareth
9. Monitor first 48 hours, tune SOUL.md if needed — Architect

---

## Multi-Machine Topology (Future)

Not needed yet — 32GB M2 Pro handles all agents (personal instances are mostly idle, activate on incoming message).

When needed:
- Each additional Mac Mini runs its own OpenClaw instance
- Split by workload class: primary (channel + shared) / personal (instances) / intelligence (CapitalCore, Apex + local LLM)
- Tailscale mesh for inter-machine connectivity
- `guide-teams/` synced via OneDrive across machines; `guide-outputs/` synced via git
- Moving an agent = copy workspace + update that machine's openclaw.json + rebind webhook

---

## Build Sequence

| Chunk | What | Blocks |
|-------|------|--------|
| CHUNK-12: Team Vault Architecture | Create filesystem, symlinks, migrate workspaces | CHUNK-13 |
| CHUNK-13: Personal Instance Factory | Extend factory: templates, persons/, generate.sh | CHUNK-14 |
| CHUNK-14: Nick Instance | First personal instance end-to-end | Subsequent rollouts |
| CHUNK-15+: Subsequent rollouts | One per person, following rollout order | — |

---

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| Exco spec absorbed into personal instances | Per-person agents with dedicated bots give stronger isolation than a shared agent identifying users by phone number |
| Telegram per-person bots, not WhatsApp | Structural isolation via separate bot tokens. Proven stack. No SIM needed. WhatsApp can be added later as an upgrade. |
| Single gateway | Context windows are per-agent, not per-gateway. Split only if performance degrades. |
| Team vaults as first-class | Wilderness-Guide vault is the template. Other teams will need their own. Not subordinate to guide-shared/. |
| guide-shared/ is supplementary | Cross-team content only (brand docs, pipeline data, KBs). Team-specific context lives in team vaults. |
| Sonnet for all interactive use | Personal instances answer questions needing quality reasoning. Haiku for cron/heartbeat only. |

---

## Related

- [[2026-04-24 Guide Filesystem Architecture]] — original filesystem design (superseded by this spec)
- [[2026-04-24 Guide Architecture — Vault Scoping & Agent Comms]] — design session notes
- [[2026-04-24 Guide Skills — Planning & Spec]] — skills architecture (unchanged)
- [[00_Guide-Project-Brief]] — master project brief (to be updated with this model)
- [[team-vault-conventions]] — how to create and structure team vaults

---

*Created: 2026-04-29 | Owner: Gareth Knight*
