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
#
# What this does:
#   1. Creates guide-vault/ with main/, channel/, shared/, personal/
#   2. Migrates workspaces from ~/.openclaw/workspace-* to guide-vault/
#   3. Creates guide-teams/ with digital/ symlink and exec/ seed
#   4. Creates guide-shared/ directory structure
#   5. Creates guide-outputs/ with git
#   6. Updates openclaw.json workspace paths
#   7. Updates generate.sh output path
#   8. Git-initialises guide-vault/
#
# After running: restart gateway, verify all agents respond.
# If gateway fails: cp ~/.openclaw/openclaw.json.bak-bootstrap ~/.openclaw/openclaw.json && restart

set -euo pipefail

DRY_RUN="${1:-}"
HOME_DIR="$HOME"
ONEDRIVE_ROOT="$HOME_DIR/Library/CloudStorage/OneDrive-Wilderness"

log()  { echo "  $1"; }
ok()   { echo "✓ $1"; }
skip() { echo "⚠ $1 — skipping (already exists)"; }
fail() { echo "✗ $1"; exit 1; }

run() {
  if [[ "$DRY_RUN" == "--dry-run" ]]; then
    return 0
  fi
  "$@"
}

if [[ "$DRY_RUN" == "--dry-run" ]]; then
  echo "=== DRY RUN — no changes will be made ==="
  echo ""
fi

echo "=== Guide Filesystem Bootstrap ==="
echo ""

# --- 1. Create guide-vault/ ---
echo "--- 1/8: guide-vault/ ---"

for dir in main channel shared personal; do
  target="$HOME_DIR/guide-vault/$dir"
  if [[ -d "$target" ]]; then
    skip "guide-vault/$dir/"
  else
    run mkdir -p "$target"
    ok "guide-vault/$dir/ created"
  fi
done

# --- 2. Migrate workspaces ---
echo ""
echo "--- 2/8: Migrate workspaces ---"

# Guide Main
MAIN_SRC="$HOME_DIR/.openclaw/workspace"
MAIN_DEST="$HOME_DIR/guide-vault/main"
if [[ -d "$MAIN_SRC" ]] && [[ ! -f "$MAIN_DEST/IDENTITY.md" ]]; then
  run cp -a "$MAIN_SRC"/* "$MAIN_DEST"/
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
    run mkdir -p "$DEST"
    run cp -a "$SRC"/* "$DEST"/
    ok "${role} migrated to guide-vault/channel/${role}/"
  elif [[ -f "$DEST/IDENTITY.md" ]]; then
    skip "${role} already migrated"
  else
    log "${role} source not found at $SRC — may not be generated yet"
  fi
done

# --- 3. Create guide-teams/ ---
echo ""
echo "--- 3/8: guide-teams/ ---"

run mkdir -p "$HOME_DIR/guide-teams"

# Digital team vault — symlink to local Obsidian vault (NOT OneDrive)
DIGITAL_VAULT="$HOME_DIR/Obsidian/Wilderness-Guide"
DIGITAL_LINK="$HOME_DIR/guide-teams/digital"

if [[ -L "$DIGITAL_LINK" ]]; then
  skip "guide-teams/digital/ symlink"
elif [[ -d "$DIGITAL_VAULT" ]]; then
  run ln -sf "$DIGITAL_VAULT" "$DIGITAL_LINK"
  ok "guide-teams/digital/ → $DIGITAL_VAULT"
else
  log "Digital team vault not found: $DIGITAL_VAULT"
  log "Check that ~/Obsidian/Wilderness-Guide/ exists on this machine"
fi

# Exec team vault — create and seed
EXEC_DIR="$HOME_DIR/guide-teams/exec"
if [[ -f "$EXEC_DIR/CLAUDE.md" ]]; then
  skip "guide-teams/exec/ already seeded"
else
  run mkdir -p "$EXEC_DIR"

  if [[ "$DRY_RUN" != "--dry-run" ]]; then
    cat > "$EXEC_DIR/CLAUDE.md" << 'CLAUDEEOF'
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

    cat > "$EXEC_DIR/PRIORITIES.md" << 'PRIOEOF'
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
  fi
  ok "guide-teams/exec/ created and seeded"
fi

# Future team vault placeholders
for team in sales reservations people; do
  target="$HOME_DIR/guide-teams/$team"
  if [[ -d "$target" ]]; then
    skip "guide-teams/$team/"
  else
    run mkdir -p "$target"
    ok "guide-teams/$team/ created (empty — populated when team is ready)"
  fi
done

# --- 4. Create guide-shared/ ---
echo ""
echo "--- 4/8: guide-shared/ ---"

for dir in brand/wilderness brand/jacada brand/yellow-zebra \
           data/paid data/seo data/hubspot data/analytics data/finance \
           kb/safari; do
  target="$HOME_DIR/guide-shared/$dir"
  if [[ -d "$target" ]]; then
    skip "guide-shared/$dir/"
  else
    run mkdir -p "$target"
    ok "guide-shared/$dir/ created"
  fi
done

# --- 5. Create guide-outputs/ ---
echo ""
echo "--- 5/8: guide-outputs/ ---"

OUTPUTS_DIR="$HOME_DIR/guide-outputs"
if [[ -d "$OUTPUTS_DIR/.git" ]]; then
  skip "guide-outputs/ already git-initialised"
else
  run mkdir -p "$OUTPUTS_DIR/briefs" \
    "$OUTPUTS_DIR/alerts" \
    "$OUTPUTS_DIR/reports/weekly" \
    "$OUTPUTS_DIR/reports/monthly" \
    "$OUTPUTS_DIR/reports/board" \
    "$OUTPUTS_DIR/archive"

  if [[ "$DRY_RUN" != "--dry-run" ]]; then
    cat > "$OUTPUTS_DIR/decisions.md" << 'EOF'
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

    cat > "$OUTPUTS_DIR/output-log.md" << 'EOF'
# Output Log

Append-only. Every agent output is logged here with timestamp and agent ID.

Format:
```
## [YYYY-MM-DD HH:MM] [agent-id] — Output Title

[output content]
```
EOF

    cd "$OUTPUTS_DIR" && git init && git add -A && git commit -m "init: guide-outputs — append-only agent output directory"
  fi
  ok "guide-outputs/ created and git-initialised"
fi

# --- 6. Update openclaw.json workspace paths ---
echo ""
echo "--- 6/8: Update openclaw.json ---"

CONFIG="$HOME_DIR/.openclaw/openclaw.json"
if [[ ! -f "$CONFIG" ]]; then
  fail "openclaw.json not found at $CONFIG"
fi

if grep -q "guide-vault" "$CONFIG" 2>/dev/null; then
  skip "openclaw.json already contains guide-vault paths"
else
  run cp "$CONFIG" "${CONFIG}.bak-bootstrap"

  if [[ "$DRY_RUN" != "--dry-run" ]]; then
    python3 << PYEOF
import json, os

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

defaults = config.get("agents", {}).get("defaults", {})
if "workspace" in defaults:
    old = defaults["workspace"]
    defaults["workspace"] = f"{home}/guide-vault/main"
    print(f"  main: {old} -> {defaults['workspace']}")

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
  fi
  ok "openclaw.json workspace paths updated (backup at ${CONFIG}.bak-bootstrap)"
fi

# --- 7. Update generate.sh output path ---
echo ""
echo "--- 7/8: Update generate.sh ---"

GENSH="$HOME_DIR/guide-core/agent-factory/generate.sh"
if [[ -f "$GENSH" ]] && grep -q "guide-vault/channel" "$GENSH" 2>/dev/null; then
  skip "generate.sh already outputs to guide-vault/"
elif [[ -f "$GENSH" ]]; then
  run sed -i.bak \
    's|WORKSPACE_DIR="\$HOME/\.openclaw/workspace-\${ROLE}"|WORKSPACE_DIR="\$HOME/guide-vault/channel/\${ROLE}"|' \
    "$GENSH"
  ok "generate.sh updated — new workspaces output to guide-vault/channel/"
else
  log "generate.sh not found at $GENSH — will be created in CHUNK-13"
fi

# --- 8. Initialise guide-vault git ---
echo ""
echo "--- 8/8: git init guide-vault/ ---"

if [[ -d "$HOME_DIR/guide-vault/.git" ]]; then
  skip "guide-vault/ already git-initialised"
else
  if [[ "$DRY_RUN" != "--dry-run" ]]; then
    cd "$HOME_DIR/guide-vault" && git init && git add -A && git commit -m "init: guide-vault — migrated workspaces to production structure"
  fi
  ok "guide-vault/ git-initialised"
fi

# --- Summary ---
echo ""
echo "=== Bootstrap Complete ==="
echo ""
echo "Next steps:"
echo "  1. Restart gateway: openclaw gateway restart"
echo "  2. Wait 15 seconds"
echo "  3. Check health:    openclaw gateway status"
echo "  4. Test Guide Main: message @WildernessGuideBot on Telegram"
echo "  5. Test channel:    message in #guide-data-backlog on Slack"
echo "  6. Check symlink:   ls ~/guide-teams/digital/CLAUDE.md"
echo ""
echo "If gateway fails:"
echo "  cp ~/.openclaw/openclaw.json.bak-bootstrap ~/.openclaw/openclaw.json"
echo "  openclaw gateway restart"
