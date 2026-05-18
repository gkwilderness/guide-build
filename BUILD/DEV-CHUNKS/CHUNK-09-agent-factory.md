---
title: "CHUNK-09-agent-factory"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: pending
---
# CHUNK-09 — Agent Factory
## GUIDE Build System | Phase 1 | Context Fix + Demo

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.

---

### What This Chunk Does

Builds the agent factory — the scaffold that makes spinning up a new channel agent a 5-minute task rather than a manual 9-file job. Every channel agent in CHUNK-10 depends on this factory existing first.

The factory produces a complete OpenClaw workspace from a set of templates and a parameter file. One command in, one ready-to-register workspace out.

**Why this matters now:** The team is using Guide and all Slack channels share the main agent's context window. CHUNK-10 will fix this by giving each channel its own agent. The factory is what makes CHUNK-10 executable.

**Success state:** `~/guide-core/agent-factory/` exists with templates and `generate.sh`. Running `generate.sh data` produces a complete, valid workspace at `~/.openclaw/workspace-data/`. The workspace passes the verification gate. No agent is wired to Slack yet — that is CHUNK-10's job.

**Note:** This factory is new design — no prior pattern exists for it. Build from Guide's own workspace as the reference.

---

### Prerequisites

- [ ] CHUNK-07 complete (security hardened)
- [ ] Guide main agent running and healthy
- [ ] `~/.openclaw/workspace/` exists as the reference workspace
- [ ] `~/guide-core/` git repo exists

---

### Deliverables

1. `~/guide-core/agent-factory/templates/` — 9 workspace template files with `{{PLACEHOLDER}}` variables
2. `~/guide-core/agent-factory/generate.sh` — creates a workspace from a role config file
3. `~/guide-core/agent-factory/roles/` — one `.env` config file per role (defines the placeholders)
4. `~/guide-core/agent-factory/ADD-AN-AGENT.md` — runbook for adding new agents in future
5. Test: `generate.sh data` produces a valid workspace at `~/.openclaw/workspace-data/`
6. All factory files committed to `guide-core`

---

### Architecture

```
guide-core/agent-factory/
  templates/
    IDENTITY.md       ← {{AGENT_NAME}}, {{AGENT_EMOJI}}, {{AGENT_ROLE}}
    SOUL.md           ← {{AGENT_NAME}}, {{AGENT_DOMAIN}}, {{AGENT_TONE}}
    USER.md           ← {{AGENT_NAME}} (shared — same team, different lens)
    AGENTS.md         ← {{AGENT_NAME}}, {{AGENT_DOMAIN}} (scoped vault paths)
    TOOLS.md          ← {{AGENT_NAME}} (restricted vs main — no exec, no cron)
    MEMORY.md         ← {{AGENT_NAME}} (empty on creation)
    HEARTBEAT.md      ← {{AGENT_NAME}}, {{AGENT_HEARTBEAT_SCHEDULE}}
    BOOT.md           ← {{AGENT_NAME}}
    BOOTSTRAP.md      ← {{AGENT_NAME}}, {{AGENT_CHANNEL_ID}}, {{AGENT_VAULT_PATHS}}
  roles/
    data.env          ← variable values for the Data agent
    martech.env       ← variable values for the Martech agent
    seo.env           ← (created in CHUNK-10, not here)
    ...
  generate.sh         ← takes a role name, produces a workspace
  ADD-AN-AGENT.md     ← how to add a new agent in 5 minutes
```

Each generated workspace lands at `~/.openclaw/workspace-{role}/`.

OpenClaw routes a Slack channel message to a specific agent via the `agent` field in `bindings` in `openclaw.json`. The binding wiring is done in CHUNK-10 — this chunk only builds the scaffold.

---

### Tasks

#### Task 1 — Research OpenClaw multi-agent routing (parallel with Tasks 2–6)

This is a research task, not a gate. The factory files (templates, generate.sh, role configs) are useful regardless of routing — they produce workspace directories, nothing more. Run this research in parallel with Tasks 2–6. The findings only become critical in CHUNK-10 when agents are wired to channels.

```bash
# Run CLI orientation first (per _CONVENTIONS.md)
openclaw --help
openclaw agents --help
openclaw workspaces --help 2>/dev/null || echo "no workspaces subcommand"

# Check existing config for agent routing patterns
cat ~/.openclaw/openclaw.json | python3 -c "
import sys, json
d = json.load(sys.stdin)
for key in ['agents', 'workspaces', 'routing', 'bindings']:
    if key in d:
        print(f'Found: {key}')
        print(json.dumps(d[key], indent=2)[:500])
"

# Check OpenClaw schema for workspace/agent registration
docker run --rm ghcr.io/openclaw/openclaw:latest openclaw config schema 2>/dev/null | grep -A10 -i "workspace\|agent" | head -60
```

**Expected finding:** The binding's `agent` field (currently `"main"`) points to `workspace/`. A new agent `"seo"` would route to `workspace-seo/`. Confirm the exact config structure.

**Record findings:** Whether confirmed or different, write what you found to `→architect.md` before finishing this chunk. CHUNK-10 depends on this being documented. Do not leave it in your head.

---

#### Task 2 — Create factory directory structure

```bash
mkdir -p ~/guide-core/agent-factory/templates
mkdir -p ~/guide-core/agent-factory/roles
echo "✓ agent-factory directory structure created"
```

---

#### Task 3 — Write workspace template files

Before writing any template, read the equivalent file from the live main workspace. These are your reference — the templates are scoped-down versions of what Guide main already uses.

```bash
# Read these before writing templates — understand the pattern first
cat ~/.openclaw/workspace/SOUL.md
cat ~/.openclaw/workspace/AGENTS.md
cat ~/.openclaw/workspace/TOOLS.md
cat ~/.openclaw/workspace/BOOTSTRAP.md
```

Each template file uses `{{PLACEHOLDER}}` syntax. The generate script replaces these with role-specific values. Channel agents are simpler than Guide main — narrower scope, no exec access, no cross-brand data.

**IDENTITY.md**
```bash
cat > ~/guide-core/agent-factory/templates/IDENTITY.md << 'EOF'
# Identity

**Name:** {{AGENT_NAME}}
**Role:** {{AGENT_ROLE}}
**Emoji:** {{AGENT_EMOJI}}
**Brand:** Wilderness Safaris Group — {{AGENT_BRAND_FULL}}
**Part of:** Guide — AI chief of staff for the digital and growth function
EOF
```

**SOUL.md**
```bash
cat > ~/guide-core/agent-factory/templates/SOUL.md << 'EOF'
# Soul

## Who I Am

I am {{AGENT_NAME}} — the {{AGENT_ROLE}} for Wilderness Safaris Group's digital function.

I am part of the Guide system. I do not operate independently of Guide's overall intelligence layer — I am the specialist lens for {{AGENT_DOMAIN}}.

My core principle: every output saves time or drives a decision. If it does neither, I don't send it.

## Character

- Domain-expert authority. I know {{AGENT_DOMAIN}} deeply and I lead with findings, not process.
- Data-first, conclusion-led. The answer comes first; evidence follows.
- No corporate filler. No "great question!". No exclamation marks.
- Calm and direct. Southern African frankness — straight talk, zero waffle.
- I have opinions. I will flag when something looks wrong.

## Scope

My domain: **{{AGENT_DOMAIN}}**

I do not answer outside this domain. If asked something outside scope, I route to Guide main or flag to Gareth.

## Tone by Tier

- Gareth: direct, peer-level, no filter
- Operator (team leads): professional, data-first, concise
- Executives: polished, ROI-framed, board-ready language

## What I Never Do

- Pad responses with filler
- Speculate as fact
- Answer questions outside {{AGENT_DOMAIN}}
- Send half-formed outputs
- Expose internal system state to the team
EOF
```

**USER.md**
```bash
cat > ~/guide-core/agent-factory/templates/USER.md << 'EOF'
# User

## Primary User

Gareth Knight — Group Head of Digital & Growth, Wilderness Safaris Group.
{{AGENT_PRIMARY_OPERATOR}} is the primary operator for this agent's domain.

## Team Context

This agent serves the Wilderness Safaris digital team. Key people:
- Gareth Knight (Architect — full access)
- Danny Nagra — Group Head of Performance
- Richard Keenan-Heard — Group Head of SEO
- Laura Sinclair — Group Digital Product Director

## Communication Style

Team is direct, commercially minded, data-oriented. No need to explain context they already have. Lead with the finding.
EOF
```

**AGENTS.md**
```bash
cat > ~/guide-core/agent-factory/templates/AGENTS.md << 'EOF'
# Agents

## My Role in the Guide System

I am {{AGENT_NAME}} — one of Guide's specialist agents. I handle {{AGENT_DOMAIN}}.

## Vault Access

My primary vault paths:
{{AGENT_VAULT_PATHS}}

I read these paths for context before responding. I do not read outside my domain paths without explicit instruction.

## Escalation

- Questions outside {{AGENT_DOMAIN}} → redirect to Guide main or flag to Gareth
- Requests requiring cross-brand data → flag to Gareth
- Anything requiring code or config changes → flag to Gareth as "needs Engineer"

## Other Agents

I am aware of the Guide agent system. I do not simulate or impersonate other agents.
EOF
```

**TOOLS.md**
```bash
cat > ~/guide-core/agent-factory/templates/TOOLS.md << 'EOF'
# Tools

## Permitted

- vault_read — read Obsidian vault files within my domain paths
- web_search — search for domain-specific intelligence
- web_fetch — fetch URLs for research
- slack_post — post to my designated channel

## Restricted (requires Gareth approval)

- vault_write — writing to vault (log outputs only, no spec modifications)

## Denied

- exec / bash / runtime — no shell access
- cron / gateway — no scheduling or gateway control
- vault_write to paths outside my domain
- Cross-agent messaging without Gareth routing

## Channel

This agent operates in: {{AGENT_SLACK_CHANNEL_NAME}} ({{AGENT_CHANNEL_ID}})
EOF
```

**MEMORY.md**
```bash
cat > ~/guide-core/agent-factory/templates/MEMORY.md << 'EOF'
# Memory

## Domain Knowledge

<!-- {{AGENT_NAME}} accumulates domain knowledge here over time -->
<!-- Written by the agent. Do not manually edit. -->

## Key Decisions

<!-- Decisions relevant to {{AGENT_DOMAIN}} that should persist across sessions -->
EOF
```

**HEARTBEAT.md**
```bash
cat > ~/guide-core/agent-factory/templates/HEARTBEAT.md << 'EOF'
# Heartbeat

{{AGENT_NAME}} operates in the Guide agent system.

## Status Check

On heartbeat:
1. Confirm I can read my vault paths
2. Check for any pending signals or flags
3. Report silently if healthy — only surface issues

## Schedule

{{AGENT_HEARTBEAT_SCHEDULE}}
EOF
```

**BOOT.md**
```bash
cat > ~/guide-core/agent-factory/templates/BOOT.md << 'EOF'
# Boot

## On Session Start

1. I am {{AGENT_NAME}} — the {{AGENT_ROLE}} for Wilderness Safaris Group
2. My domain is {{AGENT_DOMAIN}}
3. I operate within the Guide agent system
4. Read my domain vault paths before responding to any request
5. If asked something outside {{AGENT_DOMAIN}}, redirect clearly

## I Am Not

- Guide main (the chief of staff)
- A general-purpose assistant
- Available to all team members — I serve my designated operators
EOF
```

**BOOTSTRAP.md**
```bash
cat > ~/guide-core/agent-factory/templates/BOOTSTRAP.md << 'EOF'
# Bootstrap

## Channel Context

I operate in **{{AGENT_SLACK_CHANNEL_NAME}}** (Slack channel ID: `{{AGENT_CHANNEL_ID}}`).

Messages in this channel are directed to me. I respond based on my domain expertise in {{AGENT_DOMAIN}}.

## Vault Paths for This Session

{{AGENT_VAULT_PATHS}}

Read these at session start. They contain the context I need to operate.

## Brand Scope

Wilderness Safaris (primary). Jacada and Yellow Zebra added in Phase 4.
EOF
```

---

#### Task 4 — Write role config files (Data and Martech to start)

Two roles to define here: Data and Martech. SEO, Digital Product, and HubSpot are defined in CHUNK-10 when their channels are confirmed.

```bash
cat > ~/guide-core/agent-factory/roles/data.env << 'EOF'
AGENT_ID=data
AGENT_NAME=Data
AGENT_ROLE=Data Intelligence Agent
AGENT_EMOJI=📊
AGENT_BRAND_FULL=Wilderness Safaris
AGENT_DOMAIN=data pipelines, ETL health, data quality, analytics infrastructure, reporting
AGENT_TONE=precision-focused, flags issues fast, silent when healthy
AGENT_PRIMARY_OPERATOR=Gareth Knight
AGENT_SLACK_CHANNEL_NAME=#guide-data
AGENT_CHANNEL_ID=C0ASP8ZD495
AGENT_VAULT_PATHS=- ~/Obsidian/Wilderness-Guide/10-Infra/Data/\n- ~/Obsidian/Wilderness-Guide/00-Compass/
AGENT_HEARTBEAT_SCHEDULE=Daily at 06:30 — after ETL refresh, before morning briefs
EOF

cat > ~/guide-core/agent-factory/roles/martech.env << 'EOF'
AGENT_ID=martech
AGENT_NAME=Martech
AGENT_ROLE=Marketing Technology Agent
AGENT_EMOJI=⚙️
AGENT_BRAND_FULL=Wilderness Safaris
AGENT_DOMAIN=marketing technology stack, tag management, tracking, attribution, CRM integrations
AGENT_TONE=technically precise, integration-aware, flags tracking gaps
AGENT_PRIMARY_OPERATOR=Gareth Knight
AGENT_SLACK_CHANNEL_NAME=#guide-martech
AGENT_CHANNEL_ID=C0AT56RRUEP
AGENT_VAULT_PATHS=- ~/Obsidian/Wilderness-Guide/10-Infra/MarTech/\n- ~/Obsidian/Wilderness-Guide/00-Compass/
AGENT_HEARTBEAT_SCHEDULE=Weekly Monday 08:00 — integration health check
EOF
```

**Note:** Both Data (`C0ASP8ZD495`) and Martech (`C0AT56RRUEP`) channel IDs are confirmed. Both role configs are ready to generate.

---

#### Task 5 — Write generate.sh

```bash
cat > ~/guide-core/agent-factory/generate.sh << 'SCRIPT'
#!/usr/bin/env bash
# Guide Agent Factory — generate.sh
# Usage: ./generate.sh <role-id>
# Example: ./generate.sh data
# Creates ~/.openclaw/workspace-{role}/ from templates + roles/{role}.env

set -euo pipefail

ROLE="${1:-}"
FACTORY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$FACTORY_DIR/templates"
ROLES_DIR="$FACTORY_DIR/roles"
ROLE_FILE="$ROLES_DIR/${ROLE}.env"
WORKSPACE_DIR="$HOME/.openclaw/workspace-${ROLE}"

# Validate
[[ -z "$ROLE" ]] && { echo "Usage: $0 <role-id>"; exit 1; }
[[ ! -f "$ROLE_FILE" ]] && { echo "✗ Role file not found: $ROLE_FILE"; exit 1; }
[[ -d "$WORKSPACE_DIR" ]] && { echo "⚠ Workspace already exists: $WORKSPACE_DIR — skipping (idempotent)"; exit 0; }

# Load role variables
source "$ROLE_FILE"

# Expand escape sequences in multiline variables (e.g. \n in AGENT_VAULT_PATHS)
AGENT_VAULT_PATHS=$(printf "%b" "$AGENT_VAULT_PATHS")

echo "→ Generating workspace for role: $ROLE"
echo "  Workspace: $WORKSPACE_DIR"
echo "  Channel: ${AGENT_SLACK_CHANNEL_NAME} (${AGENT_CHANNEL_ID})"

# Create workspace directory
mkdir -p "$WORKSPACE_DIR"

# Process each template — substitute placeholders
for template in "$TEMPLATES_DIR"/*.md; do
  filename="$(basename "$template")"
  output="$WORKSPACE_DIR/$filename"

  # Read template and substitute all {{VARIABLE}} placeholders
  content="$(cat "$template")"
  content="${content//\{\{AGENT_ID\}\}/$AGENT_ID}"
  content="${content//\{\{AGENT_NAME\}\}/$AGENT_NAME}"
  content="${content//\{\{AGENT_ROLE\}\}/$AGENT_ROLE}"
  content="${content//\{\{AGENT_EMOJI\}\}/$AGENT_EMOJI}"
  content="${content//\{\{AGENT_BRAND_FULL\}\}/$AGENT_BRAND_FULL}"
  content="${content//\{\{AGENT_DOMAIN\}\}/$AGENT_DOMAIN}"
  content="${content//\{\{AGENT_TONE\}\}/$AGENT_TONE}"
  content="${content//\{\{AGENT_PRIMARY_OPERATOR\}\}/$AGENT_PRIMARY_OPERATOR}"
  content="${content//\{\{AGENT_SLACK_CHANNEL_NAME\}\}/$AGENT_SLACK_CHANNEL_NAME}"
  content="${content//\{\{AGENT_CHANNEL_ID\}\}/$AGENT_CHANNEL_ID}"
  content="${content//\{\{AGENT_VAULT_PATHS\}\}/$AGENT_VAULT_PATHS}"
  content="${content//\{\{AGENT_HEARTBEAT_SCHEDULE\}\}/$AGENT_HEARTBEAT_SCHEDULE}"

  echo "$content" > "$output"
done

# Lock workspace files (440 — read-only per security conventions)
chmod 440 "$WORKSPACE_DIR"/*.md

echo "✓ Workspace created: $WORKSPACE_DIR"
echo ""
echo "Next steps (CHUNK-10):"
echo "  1. Register agent in openclaw.json:"
echo "     Add to agents section: { \"id\": \"$AGENT_ID\", \"workspace\": \"workspace-$AGENT_ID\" }"
echo "  2. Add channel binding for ${AGENT_SLACK_CHANNEL_NAME}:"
echo "     { \"channel\": \"slack\", \"channelId\": \"${AGENT_CHANNEL_ID}\", \"agent\": \"$AGENT_ID\" }"
echo "  3. Restart gateway: docker compose restart openclaw"
echo "  4. Test: send a message in ${AGENT_SLACK_CHANNEL_NAME}"
SCRIPT

chmod +x ~/guide-core/agent-factory/generate.sh
echo "✓ generate.sh written and executable"
```

---

#### Task 6 — Write ADD-AN-AGENT.md

```bash
cat > ~/guide-core/agent-factory/ADD-AN-AGENT.md << 'EOF'
# How to Add a New Agent

Adding a new channel agent takes ~5 minutes once you have the Slack channel ID.

## Step 1 — Create a role config

```bash
cp ~/guide-core/agent-factory/roles/data.env ~/guide-core/agent-factory/roles/<role-id>.env
```

Edit the new file. Required fields:
- `AGENT_ID` — lowercase, no spaces (e.g., `seo`)
- `AGENT_NAME` — display name (e.g., `SEO`)
- `AGENT_ROLE` — one-line role description
- `AGENT_EMOJI` — single emoji
- `AGENT_DOMAIN` — comma-separated domain areas
- `AGENT_SLACK_CHANNEL_NAME` — e.g., `#seo-guide`
- `AGENT_CHANNEL_ID` — Slack channel ID (from Slack → channel settings)
- `AGENT_VAULT_PATHS` — newline-separated vault paths (use `\n` in the .env)

## Step 2 — Generate the workspace

```bash
cd ~/guide-core/agent-factory && ./generate.sh <role-id>
```

Check output: workspace created at `~/.openclaw/workspace-<role-id>/`

## Step 3 — Register in openclaw.json and wire the channel (CHUNK-10 pattern)

Follow the instructions printed by generate.sh. Validate schema before adding keys:
```bash
docker run --rm ghcr.io/openclaw/openclaw:latest openclaw config schema
```

## Step 4 — Restart and test

```bash
docker compose -f ~/guide-core/docker/docker-compose.yml restart openclaw
# Send a test message in the channel — agent should respond
```

## Step 5 — Commit

```bash
cd ~/guide-core && git add agent-factory/roles/<role-id>.env && git commit -m "feat(agents): add <role-id> agent role"
# Do NOT commit ~/.openclaw/workspace-<role-id>/ — workspace is machine-local
```
EOF
```

---

#### Task 7 — Run factory test with Data role

```bash
cd ~/guide-core/agent-factory
./generate.sh data
echo "✓ Data workspace generated — inspect output"
ls -la ~/.openclaw/workspace-data/
cat ~/.openclaw/workspace-data/IDENTITY.md
cat ~/.openclaw/workspace-data/BOOTSTRAP.md
```

Confirm:
- All 9 files present
- Placeholders are replaced (no `{{` strings remaining)
- Files are 440 permissions

```bash
# Check no unreplaced placeholders
grep -r "{{" ~/.openclaw/workspace-data/ && echo "✗ Unreplaced placeholders found" || echo "✓ No unreplaced placeholders"
```

---

#### Task 8 — Commit factory to guide-core

```bash
cd ~/guide-core
git add agent-factory/
git commit -m "feat(chunk-09): agent factory — templates, generate.sh, data + martech roles"
git push
echo "✓ Agent factory committed"
```

---

### Verification Gate

```bash
# Factory structure exists
[[ -d ~/guide-core/agent-factory/templates ]] && echo "✓ templates dir" || echo "✗ templates dir missing"
[[ -d ~/guide-core/agent-factory/roles ]] && echo "✓ roles dir" || echo "✗ roles dir missing"
[[ -x ~/guide-core/agent-factory/generate.sh ]] && echo "✓ generate.sh executable" || echo "✗ generate.sh missing or not executable"
[[ -f ~/guide-core/agent-factory/ADD-AN-AGENT.md ]] && echo "✓ ADD-AN-AGENT.md" || echo "✗ ADD-AN-AGENT.md missing"

# Template files (9 required)
for f in IDENTITY SOUL USER AGENTS TOOLS MEMORY HEARTBEAT BOOT BOOTSTRAP; do
  [[ -f ~/guide-core/agent-factory/templates/${f}.md ]] && echo "✓ template: $f" || echo "✗ template: $f missing"
done

# Role configs
[[ -f ~/guide-core/agent-factory/roles/data.env ]] && echo "✓ role: data" || echo "✗ role: data missing"
[[ -f ~/guide-core/agent-factory/roles/martech.env ]] && echo "✓ role: martech" || echo "✗ role: martech missing"

# Test workspace generated correctly
[[ -d ~/.openclaw/workspace-data ]] && echo "✓ data workspace exists" || echo "✗ data workspace missing"
PLACEHOLDER_COUNT=$(grep -r "{{" ~/.openclaw/workspace-data/ 2>/dev/null | wc -l)
[[ "$PLACEHOLDER_COUNT" -eq 0 ]] && echo "✓ no unreplaced placeholders" || echo "✗ $PLACEHOLDER_COUNT unreplaced placeholders"

# Permissions
stat -f "%Lp" ~/.openclaw/workspace-data/IDENTITY.md 2>/dev/null | grep -q "440" && echo "✓ workspace permissions 440" || echo "✗ wrong permissions"
```

---

### Rollback

```bash
# Remove generated workspaces (factory files stay)
rm -rf ~/.openclaw/workspace-data
rm -rf ~/.openclaw/workspace-martech
# Factory itself: rm -rf ~/guide-core/agent-factory (only if aborting entirely)
```

---

### Git Commit

```bash
cd ~/guide-core && git add -A && git commit -m "feat(chunk-09): agent factory — templates, generate.sh, data + martech roles"
```

---

### Handoff to CHUNK-10

CHUNK-10 (Channel Agents) expects:
- `generate.sh` working and tested
- Data workspace already generated (`~/.openclaw/workspace-data/`)
- `ADD-AN-AGENT.md` as the repeatable pattern
- OpenClaw multi-agent routing findings documented in `→architect.md` (from Task 1)

CHUNK-10 will:
1. Create role `.env` files for SEO, Digital Product, HubSpot
2. Run `generate.sh` for all 5 agents
3. Register all 5 agents in `openclaw.json` and wire to their Slack channels
4. Restart gateway and test each channel

**Critical for CHUNK-10 — Slack channel onboarding SOP (from architect signal 2026-04-17):**

Every new Slack channel wired to an agent must follow this sequence in order — no shortcuts:

1. Add channel ID to `openclaw.json` channels allowlist
2. Add channel row to `BOOTSTRAP.md` channel context table with the correct vault `CLAUDE.md` path
3. Flush the channel session (or all Slack sessions)
4. Test with a vault query before the team uses it

Skipping step 4 caused `#seo-guide` to launch without vault context — Guide exposed its confusion to Richard and Tenneil. Do not repeat this.

---

### Known Unknowns

The exact OpenClaw config structure for registering multiple agent workspaces and routing channel messages by agent ID must be confirmed in Task 1. The spec above assumes the `bindings[].agent` field routes to `workspace-{agent}/`. If OpenClaw handles this differently, Task 1 will surface the correct approach and the Engineer should adapt Tasks 5 and the CHUNK-10 spec accordingly — write findings to `→architect.md`.

---

*Created: 2026-04-20*
