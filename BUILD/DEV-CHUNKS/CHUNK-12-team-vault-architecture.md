---
title: "CHUNK-12-team-vault-architecture"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: complete
---
# CHUNK-12 — Team Vault Architecture
## GUIDE Build System | Phase 1 | Filesystem Restructure

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.

---

### What This Chunk Does

Restructures the Guide machine filesystem from the current flat layout (`~/.openclaw/workspace-*`) into the production directory structure. Creates four new top-level directories (`guide-vault/`, `guide-teams/`, `guide-shared/`, `guide-outputs/`), migrates existing agent workspaces into them, symlinks the Wilderness-Guide vault as the first team vault, and updates `openclaw.json` to point at the new paths.

**Why this matters now:** Personal instances (CHUNK-13/14) and team vaults depend on this directory structure existing. The current flat workspace layout cannot express the two-dimensional model (personal instances × team vaults). This restructure is the foundation for everything that follows.

**Success state:** All four top-level directories exist. Existing agent workspaces are migrated. `openclaw.json` paths updated. Gateway restarts clean. Guide Main and all channel agents respond to messages at their new workspace paths. `guide-teams/digital/` symlink resolves to the Wilderness-Guide vault.

**Reference:** [[personal-instance-architecture]] is the canonical architecture spec. [[team-vault-conventions]] defines the team vault structure.

---

### Completion Notes (2026-05-01)

**Status: Complete.** The filesystem structure was built according to `Specs/guide-filesystem-layout.md` (approved 2026-05-01), which superseded the path layout in this spec before execution.

**What was actually built vs. what this spec planned:**

| This spec planned | What was actually built |
|-------------------|-------------------------|
| `~/guide-teams/` (top-level) | `~/guide-vault/teams/` |
| `~/guide-shared/` (top-level) | `~/guide-vault/shared/` |
| Workspace migration from `~/.openclaw/workspace-*` to `~/guide-vault/` | **Not done.** Agent workspaces remain at `~/.openclaw/workspace-<id>/` and `~/.openclaw/workspace-personal-<id>/`. This is now canonical per `Specs/guide-filesystem-layout.md`. |

**`~/guide-vault/` as built:**
- `~/guide-vault/personal/` — per-person vaults (not workspaces — see CHUNK-13)
- `~/guide-vault/teams/` — team vaults: `digital/` symlink, `exco/` seeded, `sales/` `reservations/` `hr/` empty
- `~/guide-vault/shared/` — shared vault, populated
- `~/guide-outputs/` — agent outputs, git-tracked

**Stale in this spec:** Any task or verification step referencing `~/guide-teams/` or `~/guide-shared/` uses the superseded paths. Reference `Specs/guide-filesystem-layout.md` for current canonical paths.

---

### Prerequisites

- [ ] CHUNK-09 complete (agent factory exists at `~/guide-core/agent-factory/`)
- [ ] Guide main agent running and healthy
- [ ] Channel agent workspaces exist at `~/.openclaw/workspace-{role}/`
- [ ] `openclaw.json` has working agent registrations
- [ ] Digital team vault exists at `~/Obsidian/Wilderness-Guide/`
- [ ] OneDrive syncing at `~/Library/CloudStorage/OneDrive-Wilderness/`

---

### Deliverables

1. `~/guide-vault/` — agent workspace tree with `main/`, `channel/`, `shared/`, `personal/` subdirectories
2. `~/guide-teams/` — team vault directory with `digital/` symlink to Wilderness-Guide vault and `exec/` seeded with minimum content
3. `~/guide-shared/` — supplementary shared directory with `brand/`, `data/`, `kb/` subdirectories
4. `~/guide-outputs/` — git-initialised output directory with `decisions.md`, `output-log.md`, and subdirectories
5. All existing workspaces migrated from `~/.openclaw/workspace*` to `~/guide-vault/`
6. `openclaw.json` updated with new workspace paths — all agents respond at new paths
7. Agent factory `generate.sh` updated to output to `~/guide-vault/channel/` instead of `~/.openclaw/workspace-*/`
8. All changes committed to `guide-core`

---

### Environment Variables Required

```bash
# Confirm OneDrive path before starting
ONEDRIVE_ROOT="$HOME/Library/CloudStorage/OneDrive-Wilderness"
DIGITAL_VAULT="$HOME/Obsidian/Wilderness-Guide"   # Local Obsidian vault, not OneDrive
```

---

### Tasks

#### Task 1 — Confirm current state and OneDrive path

Before any changes, confirm what exists and where.

```bash
# Current workspace locations
echo "=== Current workspaces ==="
ls -d ~/.openclaw/workspace* 2>/dev/null || echo "No workspaces found"

# Current openclaw.json workspace paths
echo ""
echo "=== Workspace paths in openclaw.json ==="
cat ~/.openclaw/openclaw.json | python3 -c "
import sys, json
d = json.load(sys.stdin)
agents = d.get('agents', {}).get('list', [])
for a in agents:
    ws = a.get('workspace', 'NOT SET')
    print(f'  {a[\"id\"]}: {ws}')
main_ws = d.get('agents', {}).get('defaults', {}).get('workspace', 'NOT SET')
print(f'  main (default): {main_ws}')
"

# Digital team vault — local Obsidian vault
echo ""
echo "=== Digital team vault ==="
ls "$HOME/Obsidian/Wilderness-Guide/CLAUDE.md" 2>/dev/null && echo "✓ Digital team vault found" || echo "✗ Not found at ~/Obsidian/Wilderness-Guide/"

# OneDrive root
echo ""
echo "=== OneDrive ==="
ls "$HOME/Library/CloudStorage/OneDrive-Wilderness/" 2>/dev/null || echo "OneDrive path not found — check exact path"
```

**Confirm the digital team vault is at `~/Obsidian/Wilderness-Guide/`.** If the path differs, adapt the symlink command in Task 3. Write findings to `→architect.md` if unexpected.

---

#### Task 2 — Create guide-vault/ directory structure

```bash
# Create the top-level workspace tree
mkdir -p ~/guide-vault/main
mkdir -p ~/guide-vault/channel
mkdir -p ~/guide-vault/shared
mkdir -p ~/guide-vault/personal

echo "✓ guide-vault/ directory structure created"
ls -la ~/guide-vault/
```

---

#### Task 3 — Create guide-teams/ with symlinks

```bash
# Create the team vaults directory
mkdir -p ~/guide-teams

# Symlink the digital team vault (local Obsidian vault, NOT OneDrive)
DIGITAL_VAULT="$HOME/Obsidian/Wilderness-Guide"

if [[ -d "$DIGITAL_VAULT" ]]; then
  ln -sf "$DIGITAL_VAULT" ~/guide-teams/digital
  echo "✓ guide-teams/digital/ symlinked"
  echo "  Target: $DIGITAL_VAULT"
  # Verify the symlink resolves
  ls ~/guide-teams/digital/CLAUDE.md 2>/dev/null && echo "✓ CLAUDE.md readable through symlink" || echo "⚠ CLAUDE.md not found — check vault contents"
else
  echo "✗ Digital team vault not found: $DIGITAL_VAULT"
  echo "  Check that ~/Obsidian/Wilderness-Guide/ exists"
  exit 1
fi

# Create and seed the exec team vault
mkdir -p ~/guide-teams/exec

cat > ~/guide-teams/exec/CLAUDE.md << 'EOF'
# Executive Team Vault

## What This Is

Executive-level context for Guide personal instances serving Keith, Nick, and Hadley. Contains board-level outputs, capital allocation reports, strategic context, and FY targets.

## Files to Load First

| File | What it gives you |
|------|-------------------|
| `PRIORITIES.md` | Current executive priorities |
| `FY27-CEO-Commitments.md` | The numbers exco measures against |

## Conventions

- All content is read-only for agents — no writes permitted
- Strategic framing: "controllable vs structural" (Keith's lens)
- Financial framing: capital allocation, ROI, proof points (Nick's lens)
- Commercial framing: pipeline health, team capacity, commercial performance (Hadley's lens)

## What Not to Do

- Do not surface internal process files (backlogs, PIE scores, sprint boards) to executives
- Do not reference Guide system internals
- Do not speculate on financials — state what the data shows
EOF

mkdir -p ~/guide-teams/exec
cat > ~/guide-teams/exec/PRIORITIES.md << 'EOF'
# Executive Priorities

<!-- Seed file — update with current priorities from 00-Compass/ -->

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
EOF

echo "✓ guide-teams/exec/ created and seeded"

# Create placeholder directories for future team vaults
mkdir -p ~/guide-teams/sales
mkdir -p ~/guide-teams/reservations
mkdir -p ~/guide-teams/people

echo "✓ Future team vault directories created (empty — populated when teams are ready)"
ls -la ~/guide-teams/
```

---

#### Task 4 — Create guide-shared/ directory structure

```bash
# Supplementary shared content (cross-team)
mkdir -p ~/guide-shared/brand/wilderness
mkdir -p ~/guide-shared/brand/jacada
mkdir -p ~/guide-shared/brand/yellow-zebra
mkdir -p ~/guide-shared/data/paid
mkdir -p ~/guide-shared/data/seo
mkdir -p ~/guide-shared/data/hubspot
mkdir -p ~/guide-shared/data/analytics
mkdir -p ~/guide-shared/data/finance
mkdir -p ~/guide-shared/kb/safari

echo "✓ guide-shared/ directory structure created"
```

---

#### Task 5 — Create guide-outputs/ with git

```bash
mkdir -p ~/guide-outputs/briefs
mkdir -p ~/guide-outputs/alerts
mkdir -p ~/guide-outputs/reports/weekly
mkdir -p ~/guide-outputs/reports/monthly
mkdir -p ~/guide-outputs/reports/board
mkdir -p ~/guide-outputs/archive

# Seed the append-only log files
cat > ~/guide-outputs/decisions.md << 'EOF'
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

cat > ~/guide-outputs/output-log.md << 'EOF'
# Output Log

Append-only. Every agent output is logged here with timestamp and agent ID.

Format:
```
## [YYYY-MM-DD HH:MM] [agent-id] — Output Title

[output content]
```
EOF

# Initialise git
cd ~/guide-outputs
git init
git add -A
git commit -m "init: guide-outputs — append-only agent output directory"

echo "✓ guide-outputs/ created and git-initialised"
```

---

#### Task 6 — Migrate existing workspaces

This is the breaking change. Stop the gateway, move workspaces, then restart.

```bash
echo "=== Pre-migration state ==="
echo "Workspaces to migrate:"
ls -d ~/.openclaw/workspace* 2>/dev/null

echo ""
echo "⚠ This will stop the gateway. Guide will be offline during migration."
echo "  Expected downtime: < 2 minutes"
```

```bash
# Stop the gateway
# Stop the gateway (bare metal — openclaw CLI)
openclaw gateway stop

echo "✓ Gateway stopped"
```

```bash
# Migrate Guide Main workspace
if [[ -d ~/.openclaw/workspace ]] && [[ ! -d ~/guide-vault/main/IDENTITY.md ]]; then
  cp -a ~/.openclaw/workspace/* ~/guide-vault/main/
  echo "✓ Guide Main workspace migrated to ~/guide-vault/main/"
else
  echo "⚠ Main workspace already migrated or not found — skipping"
fi

# Migrate channel agent workspaces
for role in data martech seo product hubspot; do
  SRC="$HOME/.openclaw/workspace-${role}"
  DEST="$HOME/guide-vault/channel/${role}"
  if [[ -d "$SRC" ]] && [[ ! -f "$DEST/IDENTITY.md" ]]; then
    mkdir -p "$DEST"
    cp -a "$SRC"/* "$DEST"/
    echo "✓ ${role} workspace migrated to ~/guide-vault/channel/${role}/"
  else
    echo "⚠ ${role}: already migrated or source not found — skipping"
  fi
done

echo ""
echo "=== Post-migration state ==="
ls ~/guide-vault/main/
echo "---"
for role in data martech seo product hubspot; do
  echo "${role}:"
  ls ~/guide-vault/channel/${role}/ 2>/dev/null || echo "  (empty)"
done
```

---

#### Task 7 — Update openclaw.json workspace paths

Read the current config, update all workspace paths, write back. **Validate against the schema before writing.**

```bash
# First — check the schema to confirm workspace path field name
openclaw config schema 2>/dev/null | python3 -c "
import sys, json
schema = json.load(sys.stdin)
# Find workspace-related fields
def find_workspace(obj, path=''):
    if isinstance(obj, dict):
        for k, v in obj.items():
            if 'workspace' in k.lower():
                print(f'{path}.{k}')
            find_workspace(v, f'{path}.{k}')
find_workspace(schema)
" 2>/dev/null || echo "Schema check: adapt command if openclaw config schema format differs"
```

```bash
# Update workspace paths in openclaw.json
# IMPORTANT: Read current config, update paths, write back. Do NOT overwrite unrelated fields.

python3 << 'PYEOF'
import json, os, shutil

config_path = os.path.expanduser("~/.openclaw/openclaw.json")

# Backup first
shutil.copy2(config_path, config_path + ".bak-chunk12")
print(f"✓ Backup: {config_path}.bak-chunk12")

with open(config_path) as f:
    config = json.load(f)

home = os.path.expanduser("~")

# Map old workspace paths to new
path_map = {
    "workspace": f"{home}/guide-vault/main",
    "workspace-data": f"{home}/guide-vault/channel/data",
    "workspace-martech": f"{home}/guide-vault/channel/martech",
    "workspace-seo": f"{home}/guide-vault/channel/seo",
    "workspace-product": f"{home}/guide-vault/channel/product",
    "workspace-hubspot": f"{home}/guide-vault/channel/hubspot",
}

# Update default workspace (Guide Main)
defaults = config.get("agents", {}).get("defaults", {})
if "workspace" in defaults:
    old = defaults["workspace"]
    for old_suffix, new_path in path_map.items():
        if old.endswith(old_suffix) or old_suffix == "workspace":
            defaults["workspace"] = f"{home}/guide-vault/main"
            print(f"  main: {old} → {defaults['workspace']}")
            break

# Update agent list workspaces
agents = config.get("agents", {}).get("list", [])
for agent in agents:
    old_ws = agent.get("workspace", "")
    agent_id = agent.get("id", "unknown")
    for old_suffix, new_path in path_map.items():
        if old_ws.endswith(old_suffix):
            agent["workspace"] = new_path
            print(f"  {agent_id}: {old_ws} → {new_path}")
            break

with open(config_path, "w") as f:
    json.dump(config, f, indent=2)

print("✓ openclaw.json updated")
PYEOF
```

---

#### Task 8 — Update agent factory generate.sh

The factory currently outputs to `~/.openclaw/workspace-{role}/`. Update it to output to `~/guide-vault/channel/{role}/`.

```bash
# Read current generate.sh to understand the exact line to change
grep "WORKSPACE_DIR" ~/guide-core/agent-factory/generate.sh
```

```bash
# Update the workspace output path
# The variable assignment should change from:
#   WORKSPACE_DIR="$HOME/.openclaw/workspace-${ROLE}"
# To:
#   WORKSPACE_DIR="$HOME/guide-vault/channel/${ROLE}"

sed -i.bak 's|WORKSPACE_DIR="\$HOME/\.openclaw/workspace-\${ROLE}"|WORKSPACE_DIR="\$HOME/guide-vault/channel/\${ROLE}"|' ~/guide-core/agent-factory/generate.sh

echo "✓ generate.sh updated — new workspaces will output to ~/guide-vault/channel/{role}/"
grep "WORKSPACE_DIR" ~/guide-core/agent-factory/generate.sh
```

**Note:** This only updates the channel path. CHUNK-13 extends generate.sh to support `./generate.sh personal {name}` which outputs to `~/guide-vault/personal/{name}/`.

---

#### Task 9 — Restart gateway and verify

```bash
# Restart the gateway
# Restart the gateway (bare metal — openclaw CLI)
openclaw gateway start

echo "Waiting 10 seconds for gateway to initialise..."
sleep 10

# Check gateway health
curl -s http://127.0.0.1:18789/healthz 2>/dev/null && echo "✓ Gateway healthy" || echo "⚠ Gateway not responding — check logs"

# Check logs for workspace errors
tail -30 /tmp/openclaw/launchd-stderr.log 2>/dev/null | grep -i "error\|workspace\|not found" || echo "✓ No workspace errors in logs"
```

**If the gateway fails to start:** Restore from backup and investigate.
```bash
# Emergency rollback (only if gateway won't start)
cp ~/.openclaw/openclaw.json.bak-chunk12 ~/.openclaw/openclaw.json
openclaw gateway restart
```

---

#### Task 10 — Test agent responses

Send a test message to each channel to confirm agents respond from their new workspace paths.

```bash
echo "Manual verification required:"
echo "  1. Send a message in Telegram to @WildernessGuideBot — confirm Guide Main responds"
echo "  2. Send a message in #guide-data-backlog — confirm Data agent responds"
echo "  3. Send a message in #seo-guide — confirm SEO agent responds"
echo "  4. Check that Guide Main can read guide-teams/digital/ (the Wilderness-Guide vault)"
echo ""
echo "If any agent fails to respond, check:"
echo "  - tail -50 /tmp/openclaw/launchd-stderr.log"
echo "  - Workspace path in openclaw.json matches actual directory"
echo "  - Files exist at the new path (ls ~/guide-vault/channel/{role}/)"
```

---

#### Task 11 — Initialise guide-vault git tracking

```bash
cd ~/guide-vault
git init
git add -A
git commit -m "init: guide-vault — migrated workspaces to production directory structure"

echo "✓ guide-vault/ git-initialised with migrated workspaces"
```

---

#### Task 12 — Commit factory changes

```bash
cd ~/guide-core
git add agent-factory/generate.sh
git commit -m "feat(chunk-12): update generate.sh output path to guide-vault/channel/"
git push
echo "✓ Factory changes committed"
```

---

### Verification Gate

```bash
echo "=== CHUNK-12 Verification ==="

# Top-level directories exist
[[ -d ~/guide-vault ]] && echo "✓ guide-vault/" || echo "✗ guide-vault/ missing"
[[ -d ~/guide-teams ]] && echo "✓ guide-teams/" || echo "✗ guide-teams/ missing"
[[ -d ~/guide-shared ]] && echo "✓ guide-shared/" || echo "✗ guide-shared/ missing"
[[ -d ~/guide-outputs ]] && echo "✓ guide-outputs/" || echo "✗ guide-outputs/ missing"

# guide-vault subdirectories
[[ -d ~/guide-vault/main ]] && echo "✓ guide-vault/main/" || echo "✗ guide-vault/main/ missing"
[[ -d ~/guide-vault/channel ]] && echo "✓ guide-vault/channel/" || echo "✗ guide-vault/channel/ missing"
[[ -d ~/guide-vault/shared ]] && echo "✓ guide-vault/shared/" || echo "✗ guide-vault/shared/ missing"
[[ -d ~/guide-vault/personal ]] && echo "✓ guide-vault/personal/" || echo "✗ guide-vault/personal/ missing"

# Guide Main workspace migrated
[[ -f ~/guide-vault/main/IDENTITY.md ]] && echo "✓ main workspace has IDENTITY.md" || echo "✗ main workspace incomplete"
[[ -f ~/guide-vault/main/SOUL.md ]] && echo "✓ main workspace has SOUL.md" || echo "✗ main SOUL.md missing"

# Channel workspaces migrated
for role in data martech seo product hubspot; do
  [[ -f ~/guide-vault/channel/${role}/IDENTITY.md ]] && echo "✓ ${role} workspace migrated" || echo "✗ ${role} workspace missing"
done

# Team vault symlink
[[ -L ~/guide-teams/digital ]] && echo "✓ guide-teams/digital/ is a symlink" || echo "✗ guide-teams/digital/ is not a symlink"
[[ -f ~/guide-teams/digital/CLAUDE.md ]] && echo "✓ digital team vault CLAUDE.md readable" || echo "✗ cannot read through symlink"

# Exec vault seeded
[[ -f ~/guide-teams/exec/CLAUDE.md ]] && echo "✓ exec vault CLAUDE.md exists" || echo "✗ exec vault not seeded"
[[ -f ~/guide-teams/exec/PRIORITIES.md ]] && echo "✓ exec vault PRIORITIES.md exists" || echo "✗ exec vault PRIORITIES.md missing"

# guide-shared directories
[[ -d ~/guide-shared/brand/wilderness ]] && echo "✓ guide-shared/brand/" || echo "✗ guide-shared/brand/ missing"
[[ -d ~/guide-shared/data/paid ]] && echo "✓ guide-shared/data/" || echo "✗ guide-shared/data/ missing"
[[ -d ~/guide-shared/kb/safari ]] && echo "✓ guide-shared/kb/" || echo "✗ guide-shared/kb/ missing"

# guide-outputs git
[[ -d ~/guide-outputs/.git ]] && echo "✓ guide-outputs/ is git-tracked" || echo "✗ guide-outputs/ not git-tracked"

# openclaw.json paths updated
python3 -c "
import json, os
home = os.path.expanduser('~')
with open(os.path.join(home, '.openclaw/openclaw.json')) as f:
    config = json.load(f)
defaults = config.get('agents', {}).get('defaults', {})
ws = defaults.get('workspace', '')
if 'guide-vault/main' in ws:
    print('✓ openclaw.json main workspace path updated')
else:
    print(f'✗ main workspace path not updated: {ws}')
agents = config.get('agents', {}).get('list', [])
for a in agents:
    ws = a.get('workspace', '')
    if 'guide-vault' in ws:
        print(f'✓ {a[\"id\"]} workspace path updated')
    else:
        print(f'✗ {a[\"id\"]} workspace path not updated: {ws}')
"

# Gateway healthy
curl -s http://127.0.0.1:18789/health > /dev/null 2>&1 && echo "✓ gateway healthy" || echo "✗ gateway not responding"

# generate.sh updated
grep -q "guide-vault/channel" ~/guide-core/agent-factory/generate.sh && echo "✓ generate.sh outputs to guide-vault/channel/" || echo "✗ generate.sh still uses old path"
```

---

### Rollback

```bash
# Restore openclaw.json from backup
cp ~/.openclaw/openclaw.json.bak-chunk12 ~/.openclaw/openclaw.json

# Restore generate.sh from backup
cp ~/guide-core/agent-factory/generate.sh.bak ~/guide-core/agent-factory/generate.sh

# Copy workspaces back (non-destructive — new dirs remain)
cp -a ~/guide-vault/main/* ~/.openclaw/workspace/ 2>/dev/null
for role in data martech seo product hubspot; do
  cp -a ~/guide-vault/channel/${role}/* ~/.openclaw/workspace-${role}/ 2>/dev/null
done

# Restart gateway with original paths
openclaw gateway restart
```

---

### Git Commit

```bash
cd ~/guide-core && git add -A && git commit -m "feat(chunk-12): team vault architecture — filesystem restructure, workspace migration"
```

---

### Handoff to CHUNK-13

CHUNK-13 (Personal Instance Factory) expects:
- `~/guide-vault/personal/` directory exists (empty, ready for generated workspaces)
- `~/guide-teams/` exists with `digital/` symlink resolving and `exec/` seeded
- `~/guide-shared/` exists with subdirectory structure
- `generate.sh` outputs channel workspaces to `~/guide-vault/channel/`
- All existing agents respond from their new paths

CHUNK-13 will:
1. Split `agent-factory/templates/` into `templates/channel/` and `templates/personal/`
2. Create 9 personal instance template files
3. Copy `roster.json` from vault to factory (master config for personal instances)
4. Extend `generate.sh` to read personal instance config from `roster.json`
5. Update `ADD-AN-AGENT.md` with personal instance section

---

### Known Unknowns

1. **Digital vault path:** The Wilderness-Guide vault is expected at `~/Obsidian/Wilderness-Guide/`. Task 1 confirms this before the symlink is created.
2. **Old workspace cleanup:** After migration is confirmed working, the old `~/.openclaw/workspace-*` directories can be removed. Do not remove them during this chunk — leave them as a safety net until CHUNK-13 is complete.

---

*Created: 2026-04-29*
