---
title: "CHUNK-07-security-hardening"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: pending
---
# CHUNK-07 — Security & Hardening
## GUIDE Build System | Phase 0 | Foundation

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.

---

### ⚠️ Pre-Execution Note (added 2026-05-15)

This spec was written for macOS. The Guide machine has since migrated to Ubuntu (HP Z8 G4). Before executing:

1. **Do not delete or overwrite this file.** Preserve the macOS version — rename it to `CHUNK-07-security-hardening-macos.md` and keep it in `BUILD/DEV-CHUNKS/`.
2. Write a new `CHUNK-07-security-hardening-ubuntu.md` for the Ubuntu/Docker target environment.
3. Use `~/guide-build/Notes/2026-05-15 Z8 Security Best Practice.md` as the reference for what the Ubuntu version should cover.
4. The Ubuntu chunk must account for the full target stack: OpenClaw + Hermes Agent + Ollama + Open WebUI + Claude Code isolation.

---

### What This Chunk Does

Production security hardening for the Guide machine. Firewall, credential management, audit logging, workspace permissions, and loopback enforcement.

**Success state:** macOS firewall enabled. All services loopback-only. Credentials managed via OpenClaw credential store (not env files). Audit log captures all agent actions. Workspace files are read-only. No secrets in git.

---

### Prerequisites

- [ ] CHUNK-06 complete (access control configured)
- [ ] All services running (OpenClaw gateway, Telegram, Slack)

---

### Deliverables

1. macOS firewall enabled (block all incoming except SSH + Tailscale)
2. OpenClaw gateway confirmed loopback-only (127.0.0.1:18789)
3. All credentials in OpenClaw credential store (not .env files)
4. Audit logging enabled — all agent actions logged (schema-verified before adding config)
5. Workspace identity files locked (440)
6. `.gitignore` prevents secrets from git (merged, not overwritten)
7. Tailscale ACL reviewed — Guide accepts connections from Gareth's Mac only
8. `exec` denied by default for non-main agents (schema-verified before adding config)
9. `toolsBySender` configured — 4-tier access model enforced within shared Telegram groups
10. Slack tool identifiers pulled from `tools.byProvider` and documented in `→architect.md` (ADR-016 research step)
11. Security checklist committed to `guide-core/SECURITY.md`

---

### Tasks

#### Task 1 — Enable macOS firewall

```bash
# Enable firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
# Enable stealth mode
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
echo "✓ Firewall enabled + stealth mode"
```

#### Task 2 — Verify loopback binding

```bash
# Check OpenClaw gateway is only on loopback
lsof -i :18789 | grep -q "127.0.0.1" && echo "✓ Gateway loopback only" || echo "✗ Gateway exposed"
lsof -i :3000 | grep -q "127.0.0.1" && echo "✓ Studio loopback only" || echo "✗ Studio exposed"
```

#### Task 3 — Migrate credentials to OpenClaw store

```bash
# Ensure all secrets are in credential store, not env files
openclaw credentials list
# Remove any .env files with real secrets
[[ -f ~/guide-core/docker/.env ]] && {
  echo "⚠️ .env file found — ensure no real secrets, only references"
}
```

#### Task 4 — Enable audit logging

**First — verify the schema accepts these keys. Never add keys blindly (see ADR-016):**

```bash
docker run --rm ghcr.io/openclaw/openclaw:latest openclaw config schema 2>/dev/null \
  | grep -A10 -i "logging\|audit" | head -30
```

If `logging.audit`, `logging.auditPath`, and `logging.retentionDays` appear in the schema output, proceed. If they don't exist, note the gap in `→architect.md` and skip this task — do not add non-schema keys.

**If schema confirms the keys exist:**

```bash
chmod 644 ~/guide-core/config/openclaw.json

python3 << 'PYEOF'
import json, os
CONFIG_PATH = os.path.expanduser("~/guide-core/config/openclaw.json")
with open(CONFIG_PATH) as f:
    config = json.load(f)

if 'logging' not in config:
    config['logging'] = {
        "audit": True,
        "auditPath": "~/.openclaw/audit/",
        "retentionDays": 90
    }
    print("✓ audit logging configured")
else:
    print("⏭ logging key already present — review manually before overwriting")

with open(CONFIG_PATH, 'w') as f:
    json.dump(config, f, indent=2)
PYEOF

chmod 444 ~/guide-core/config/openclaw.json
cp ~/guide-core/config/openclaw.json ~/.openclaw/openclaw.json
chmod 444 ~/.openclaw/openclaw.json
mkdir -p ~/.openclaw/audit
echo "✓ audit dir created"
```

#### Task 5 — Lock workspace files

```bash
find ~/.openclaw/workspace* -name "*.md" -exec chmod 440 {} \;
echo "✓ All workspace files locked (440)"
```

#### Task 6 — Configure exec deny for sub-agents

**First — schema check. Two things to verify:**

```bash
# 1. Check whether a deny/capabilities field exists on agents
docker run --rm ghcr.io/openclaw/openclaw:latest openclaw config schema 2>/dev/null \
  | grep -A15 -i "deny\|capabilities\|permissions" | head -40

# 2. Check current agents structure in config — CHUNK-09 will use agents as an array
#    of {id, workspace} objects. Do not add an agents.defaults object key if agents is an array.
cat ~/.openclaw/openclaw.json | python3 -c "
import sys, json
d = json.load(sys.stdin)
agents = d.get('agents')
print(f'agents type: {type(agents).__name__}')
print(f'agents value: {json.dumps(agents, indent=2)[:200]}')
"
```

**If the schema has no `deny`/`capabilities` field on agents:** note the gap in `→architect.md` and skip this task. CHUNK-09 will research the correct approach for agent-level tool restrictions.

**If schema confirms the field exists AND agents is not yet an array (or the deny field is a separate key from registration):**

```bash
chmod 644 ~/guide-core/config/openclaw.json

python3 << 'PYEOF'
import json, os
CONFIG_PATH = os.path.expanduser("~/guide-core/config/openclaw.json")
with open(CONFIG_PATH) as f:
    config = json.load(f)

# Only add if agents is a dict (not the CHUNK-09 registration array format)
agents = config.get('agents', {})
if isinstance(agents, dict):
    agents.setdefault('defaults', {})['deny'] = ['group:runtime', 'exec']
    agents.setdefault('main', {})['deny'] = []
    config['agents'] = agents
    print("✓ exec deny configured for sub-agents")
elif isinstance(agents, list):
    print("⚠ agents is a registration array (CHUNK-09 format) — exec deny config structure differs")
    print("  Surface this to Architect via →architect.md before modifying")
else:
    print(f"⚠ unexpected agents type: {type(agents)} — skip and surface to Architect")

with open(CONFIG_PATH, 'w') as f:
    json.dump(config, f, indent=2)
PYEOF

chmod 444 ~/guide-core/config/openclaw.json
cp ~/guide-core/config/openclaw.json ~/.openclaw/openclaw.json
chmod 444 ~/.openclaw/openclaw.json
```

Only the main Guide agent gets exec access. All sub-agents denied by default.

#### Task 7 — Verify .gitignore

Do not overwrite an existing `.gitignore` — merge the required entries instead.

```bash
cd ~/guide-core

REQUIRED_ENTRIES=(
  ".env"
  "*.env"
  "*.key"
  "*.pem"
  "*.p12"
  "credentials/"
  ".openclaw/"
  "node_modules/"
  "__pycache__/"
  "*.pyc"
  ".DS_Store"
)

# Create if missing, then add any entry not already present
touch .gitignore
for entry in "${REQUIRED_ENTRIES[@]}"; do
  grep -qxF "$entry" .gitignore || echo "$entry" >> .gitignore
done

echo "✓ .gitignore verified — current contents:"
cat .gitignore

# Confirm no credentials or secrets are already tracked
git ls-files | grep -E "\.(env|key|pem|p12)$" && echo "✗ WARNING: secret files tracked in git" || echo "✓ no secret files in git"
git ls-files | grep "credentials/" && echo "✗ WARNING: credentials dir tracked" || echo "✓ credentials not tracked"
```

#### Task 8 — Review Tailscale ACL

Confirm the Guide machine's Tailscale ACL only accepts inbound connections from authorised devices (Gareth's Mac). No other Tailscale device should be able to reach Guide's services.

```bash
# Check current Tailscale status and connected devices
tailscale status

# Check what's exposed via Tailscale Serve
tailscale serve status

# Tailscale ACL is managed at https://login.tailscale.com/admin/acls
# Check that the ACL does not have a blanket "allow all" rule for the Guide machine
# Expected: only Gareth's Mac (tagged or by device name) can reach guide:18789 and guide:3000
```

**What to verify:**
- OpenClaw gateway (`18789`) and Studio (`3000`) are reachable from Gareth's Mac only
- No device outside the tailnet can reach any Guide port
- `tailscale serve` is active (for OpenClaw TUI access) — this is correct and expected
- `tailscale funnel` is NOT active — this would expose Guide to the public internet

```bash
tailscale serve status | grep -i funnel && echo "✗ WARNING: funnel is active — disable immediately" || echo "✓ funnel not active"
```

If the ACL needs adjusting, Gareth must do this via the Tailscale admin console — the Engineer cannot push ACL changes from the command line.

---

#### Task 9 — Document security checklist

```bash
cat > ~/guide-core/SECURITY.md << 'EOF'
# Guide — Security Checklist

Last verified: <DATE>

## Hardening Status

- [ ] Firewall: macOS firewall enabled + stealth mode
- [ ] Gateway: OpenClaw bound to 127.0.0.1:18789 only
- [ ] Studio: bound to 127.0.0.1:3000 only
- [ ] Credentials: all secrets in OpenClaw credential store — no .env files with real values
- [ ] Audit: logging enabled, 90-day retention (verify schema support)
- [ ] Workspace: all workspace files at 440 permissions
- [ ] Exec: denied for sub-agents by default (verify schema support)
- [ ] Git: .gitignore blocks .env, *.key, *.pem, credentials/
- [ ] Tailscale: ACL reviewed — Guide accepts connections from Gareth's Mac only
- [ ] Tailscale Funnel: NOT active (only Serve is active)
- [ ] WhatsApp: no public API exposure (Baileys via dedicated SIM)
- [ ] toolsBySender: 4-tier access model enforced in Telegram groups (verify schema support)

## Schema Gaps (check openclaw.json on schema changes)

Note any keys that could not be added because they don't exist in the current schema.
Document in DECISIONS.md as ADR entries.

## Known Risks

See DOCUMENTATION.md "Known Risks" section for full detail on:
- ADR-016: Outbound DM gating (crash-loop incident 2026-04-17)
- toolsBySender: schema support unconfirmed
EOF
echo "✓ SECURITY.md written"
```

---

#### Task 10 — Pull Slack tool identifiers (ADR-016 research step)

ADR-016 requires knowing the exact Slack tool IDs before the Architect can spec the outbound DM deny-list plugin. This is a research task — document findings only, no config changes.

```bash
# Check what tools OpenClaw exposes, organised by provider
openclaw tools list 2>/dev/null || echo "no tools subcommand — try:"
openclaw --help | grep -i tool

# Check the config for tools.byProvider or equivalent
cat ~/.openclaw/openclaw.json | python3 -c "
import sys, json
d = json.load(sys.stdin)
tools = d.get('tools', {})
print('tools keys:', list(tools.keys()))
by_provider = tools.get('byProvider', {})
slack_tools = by_provider.get('slack', [])
print('Slack tools:', json.dumps(slack_tools, indent=2))
"

# If tools.byProvider is not in openclaw.json, check the schema for where tool IDs are declared
docker run --rm ghcr.io/openclaw/openclaw:latest openclaw config schema 2>/dev/null \
  | grep -A10 -i "byProvider\|toolId\|slack" | head -40

# Also check if OpenClaw has a runtime tools endpoint
curl -s http://127.0.0.1:18789/tools \
  -H "Authorization: Bearer $(python3 -c "import json; d=json.load(open('$HOME/.openclaw/openclaw.json')); print(d.get('gateway',{}).get('auth',{}).get('token',''))")" \
  2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); [print(t.get('id'), t.get('provider')) for t in d.get('tools',[])]" \
  || echo "no /tools endpoint or auth failed"
```

**Record findings in `→architect.md`** under `## ADR-016 Slack Tool Identifiers`:
- List all Slack tool IDs found (e.g. `slack.dm.send`, `slack.message.post`)
- Note where they were found (schema, config, runtime API)
- If no tool IDs can be found, note that too — Architect needs to know before speccing the plugin

This unblocks the Architect to design the deny-list plugin for outbound DM gating (ADR-016 Option 2).

---

#### Task 11 — Configure toolsBySender (per-user tool policy in Telegram groups)

Guide's 4-tier access model requires different tool access for different people within shared Telegram groups. OpenClaw's `toolsBySender` field enforces this at the message level.

**Tool groups used:**

| Group | Tools |
|-------|-------|
| `group:runtime` | exec, bash, process, code_execution |
| `group:fs` | read, write, edit, apply_patch |
| `group:automation` | cron, gateway |
| `group:web` | web_search, web_fetch |

**Tier mapping:**

| Tier | Who | toolsBySender config |
|------|-----|---------------------|
| Admin | Gareth | No restrictions |
| Operator | Danny, Richard, Laura, Matt | No restrictions |
| Consumer | Digital team (Fay, Maria, etc.) | Deny `group:runtime`, `group:automation` |
| Executive | Hadley, Keith, Nick | Read-only: deny `group:runtime`, `group:fs` write, `group:automation` |

**Add to `openclaw.json` under the Team Leads Telegram group config:**

```json
"channels": {
  "telegram": {
    "groups": {
      "<TEAM_LEAD_GROUP_ID>": {
        "toolsBySender": {
          "<CONSUMER_TELEGRAM_ID>": {
            "deny": ["group:runtime", "group:automation"]
          }
        }
      }
    }
  }
}
```

**Slash command gating** — restrict `openclaw` slash commands to Gareth only:

```json
"commands": {
  "allowFrom": {
    "*": ["<GARETH_TELEGRAM_ID>"]
  }
}
```

**Important:** Verify these field names exist in the current schema before writing to `openclaw.json`:
```bash
docker run --rm ghcr.io/openclaw/openclaw:latest openclaw config schema | grep -A5 toolsBySender
```
If the field does not exist, note it in `DECISIONS.md` as a gap and skip this task. Do not add non-schema keys.

**Reference:** `DECISIONS.md` ADR-005 (toolsBySender pattern).

---

### Verification Gate

```bash
echo "=== CHUNK-07 Verification Gate ==="

# 1. Firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate \
  | grep -q "enabled" && echo "✓ macOS firewall enabled" || echo "✗ firewall not enabled"

# 2. Stealth mode
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode \
  | grep -q "enabled" && echo "✓ stealth mode enabled" || echo "✗ stealth mode off"

# 3. Gateway loopback only
lsof -i :18789 2>/dev/null | grep -q "127.0.0.1" \
  && echo "✓ gateway loopback only (18789)" || echo "✗ gateway port 18789 exposed or not running"

# 4. Studio loopback only (may not be running — warning only)
lsof -i :3000 2>/dev/null | grep -q "127.0.0.1" \
  && echo "✓ studio loopback only (3000)" || echo "⚠ studio port 3000 not detected (may not be running)"

# 5. Audit dir
[[ -d ~/.openclaw/audit ]] && echo "✓ audit dir exists" || echo "⚠ audit dir missing (schema may not support it — check →architect.md)"

# 6. Workspace permissions
find ~/.openclaw/workspace -name "*.md" 2>/dev/null | while read f; do
  perm=$(stat -f "%Lp" "$f" 2>/dev/null)
  [[ "$perm" == "440" ]] || echo "✗ wrong permissions on $f: $perm"
done
echo "✓ workspace permissions check complete (errors printed above if any)"

# 7. .gitignore present and covers secrets
[[ -f ~/guide-core/.gitignore ]] && echo "✓ .gitignore exists" || echo "✗ .gitignore missing"
grep -q "\.env" ~/guide-core/.gitignore && echo "✓ .env in .gitignore" || echo "✗ .env not in .gitignore"
grep -q "credentials/" ~/guide-core/.gitignore && echo "✓ credentials/ in .gitignore" || echo "✗ credentials/ not in .gitignore"

# 8. No secrets tracked in git
cd ~/guide-core
git ls-files | grep -E "\.(env|key|pem|p12)$" \
  && echo "✗ WARNING: secret files tracked in git" || echo "✓ no secret files tracked"

# 9. Tailscale Funnel not active
tailscale serve status 2>/dev/null | grep -qi funnel \
  && echo "✗ WARNING: Tailscale funnel active" || echo "✓ Tailscale funnel not active"

# 10. SECURITY.md exists
[[ -f ~/guide-core/SECURITY.md ]] && echo "✓ SECURITY.md exists" || echo "✗ SECURITY.md missing"

# 11. toolsBySender — schema-dependent, warn not fail
cat ~/.openclaw/openclaw.json | python3 -c "
import sys,json
d=json.load(sys.stdin)
found = any('toolsBySender' in str(v) for v in d.values())
print('✓ toolsBySender configured' if found else '⚠ toolsBySender not in config (may require schema update)')
"

# 12. ADR-016 tool IDs documented
grep -q "ADR-016 Slack Tool Identifiers" ~/.openclaw/workspace/signals/→architect.md 2>/dev/null \
  && echo "✓ ADR-016 Slack tool IDs documented in →architect.md" \
  || echo "✗ ADR-016 Slack tool IDs not yet documented — Task 10 incomplete"

echo "=== Gate complete ==="
```

---

### Rollback

```bash
# Firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off

# Workspace permissions (if reverting to writable for debugging)
chmod 644 ~/.openclaw/workspace/*.md

# Audit config — edit openclaw.json to remove logging key
# (use python3 JSON manipulation, same pattern as Tasks 4/6)

# Gateway/OpenClaw unaffected — no changes made to runtime
```

---

### Git Commit

```bash
cd ~/guide-core
git add SECURITY.md .gitignore
git commit -m "feat(chunk-07): security hardening — firewall, permissions, gitignore, audit"
git push
```

---

### Handoff to CHUNK-09

CHUNK-09 (Agent Factory) expects:
- macOS firewall enabled
- Workspace files at 440 permissions
- `.gitignore` blocking secrets
- All services confirmed loopback-only
- ADR-016 Slack tool IDs documented in `→architect.md` (enables Architect to spec the outbound DM plugin)

**Note:** CHUNK-08 (Cron & Ops) is deferred — waiting on data layer. CHUNK-09 follows directly from CHUNK-07.
