---
title: "CHUNK-07b-bare-metal-migration"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: pending
priority: urgent
---
# CHUNK-07b — Bare Metal Migration
## GUIDE Build System | Phase 0 | Docker → npm

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.

---

### What This Chunk Does

Migrates OpenClaw from Docker Compose to a bare-metal npm install with a launchd service. The gateway runs as a native macOS process — no Docker, no Linux VM, no container networking.

**Why this matters now:** Docker-on-macOS networking is causing Node.js HTTP client timeouts that don't occur with native `curl`. The grammY Telegram client and Slack socket mode both fail inside the container despite the API being reachable. This has been blocking Telegram and Slack for days. Bare metal eliminates the Docker VM networking layer entirely.

**What we keep:** Everything. `openclaw.json` is already Docker-agnostic — all paths are host-native (`/Users/gareth/...`). Workspaces, credentials, cron config, agent registrations, channel bindings — all unchanged. This is an infrastructure swap, not a reconfiguration.

**Success state:** OpenClaw running as a launchd service (`com.guide.openclaw.plist`). Gateway healthy at `127.0.0.1:18789`. Telegram bot responding. Slack socket mode connected. All 6 agents (main + 5 channel) operational. Tailscale serve still proxying. Docker stopped and disabled.

---

### Prerequisites

- [ ] Guide machine accessible (SSH or local)
- [ ] Node.js 24 LTS installed via nvm (confirm: `node --version`)
- [ ] npm available
- [ ] `~/.openclaw/openclaw.json` exists and is valid
- [ ] Current Docker gateway is stopped or failing (don't run both simultaneously)

---

### Deliverables

1. OpenClaw installed globally via npm
2. `com.guide.openclaw.plist` launchd service created and loaded
3. Gateway running bare-metal at `127.0.0.1:18789`
4. Telegram bot responding to messages
5. Slack socket mode connected and bi-directional
6. All 6 agents responding from existing workspace paths
7. Tailscale serve still proxying to gateway
8. Docker Compose stopped and containers removed
9. ADR-008 updated (Docker → bare metal)

---

### Environment Variables Required

```bash
# These should already be set from the Docker .env — confirm they're in the shell environment
ANTHROPIC_API_KEY="<from ~/guide-core/docker/.env>"
```

---

### Tasks

#### Task 1 — Stop Docker and confirm current state

```bash
# Stop the Docker gateway
docker compose -f ~/guide-core/docker/docker-compose.yml down 2>/dev/null || docker stop openclaw-gateway 2>/dev/null || echo "Docker not running"

echo "✓ Docker gateway stopped"

# Confirm the port is free
lsof -i :18789 2>/dev/null && echo "✗ Port 18789 still in use" || echo "✓ Port 18789 free"

# Confirm openclaw.json exists and is valid
python3 -c "import json; json.load(open('$HOME/.openclaw/openclaw.json'))" && echo "✓ openclaw.json valid" || echo "✗ openclaw.json invalid"

# Confirm Node.js version
node --version
npm --version
```

---

#### Task 2 — Install OpenClaw globally

```bash
# Install OpenClaw via npm
npm install -g openclaw

# Verify installation
which openclaw && echo "✓ openclaw installed" || echo "✗ openclaw not found in PATH"
openclaw --version
```

**If npm install fails:** Check Node.js version (must be 24 LTS). Check npm permissions — may need `sudo npm install -g openclaw` or configure npm prefix to avoid sudo.

---

#### Task 3 — Ensure environment variables are available

The Docker setup loaded `ANTHROPIC_API_KEY` from `~/guide-core/docker/.env`. For bare metal, this needs to be in the shell environment.

```bash
# Check if the key is already exported
echo "${ANTHROPIC_API_KEY:0:10}..." 2>/dev/null && echo "✓ ANTHROPIC_API_KEY set" || echo "✗ ANTHROPIC_API_KEY not set"

# If not set, add to ~/.zshrc (or ~/.zshenv for launchd visibility)
if ! grep -q "ANTHROPIC_API_KEY" ~/.zshenv 2>/dev/null; then
  # Read from Docker .env
  API_KEY=$(grep ANTHROPIC_API_KEY ~/guide-core/docker/.env 2>/dev/null | cut -d= -f2 | tr -d '"')
  if [[ -n "$API_KEY" ]]; then
    echo "export ANTHROPIC_API_KEY=\"$API_KEY\"" >> ~/.zshenv
    export ANTHROPIC_API_KEY="$API_KEY"
    echo "✓ ANTHROPIC_API_KEY added to ~/.zshenv"
  else
    echo "✗ Could not find API key in Docker .env — set manually"
  fi
fi
```

**Note:** Using `~/.zshenv` instead of `~/.zshrc` because launchd doesn't source `.zshrc`. `.zshenv` is sourced by all zsh invocations including non-interactive ones.

---

#### Task 4 — Update openclaw.json gateway bind

In Docker, the gateway bound to `0.0.0.0` (inside the container) with port mapping to `127.0.0.1` on the host. On bare metal, bind directly to `127.0.0.1`.

```bash
python3 << 'PYEOF'
import json, os

config_path = os.path.expanduser("~/.openclaw/openclaw.json")

# Backup
import shutil
shutil.copy2(config_path, config_path + ".bak-baremetal")

with open(config_path) as f:
    config = json.load(f)

# Update gateway bind from "lan" (0.0.0.0) to "loopback" (127.0.0.1)
gateway = config.get("gateway", {})
if gateway.get("bind") == "lan":
    gateway["bind"] = "loopback"
    print("✓ gateway.bind: lan → loopback")
elif gateway.get("bind") == "loopback":
    print("⚠ gateway.bind already set to loopback")
else:
    print(f"  gateway.bind is '{gateway.get('bind', 'NOT SET')}' — check manually")

with open(config_path, "w") as f:
    json.dump(config, f, indent=2)

print("✓ openclaw.json updated (backup at .bak-baremetal)")
PYEOF
```

**Important:** Tailscale serve proxies to `localhost:18789`. Binding to loopback is correct — Tailscale handles external access. Nothing should be on `0.0.0.0`.

---

#### Task 5 — Test bare-metal gateway start

Start the gateway manually first to confirm it works before creating the launchd service.

```bash
# Start gateway in foreground (Ctrl+C to stop)
openclaw gateway &
GATEWAY_PID=$!

echo "Gateway starting (PID: $GATEWAY_PID)..."
sleep 10

# Health check
curl -s http://127.0.0.1:18789/healthz > /dev/null 2>&1 && echo "✓ Gateway healthy" || echo "✗ Gateway not responding"

# Check Telegram
echo "Manual check: message @WildernessGuideBot on Telegram — does it respond?"

# Check Slack
echo "Manual check: message Guide in a Slack channel — does it respond?"

# Stop the test instance
kill $GATEWAY_PID 2>/dev/null
echo "✓ Test gateway stopped"
```

**If the gateway fails to start:** Check logs at `/tmp/openclaw/`. Check `openclaw.json` is valid. Check that `ANTHROPIC_API_KEY` is in the environment.

**If Telegram/Slack now work:** The Docker networking was the issue. Proceed to Task 6.

**If Telegram/Slack still fail:** The problem is not Docker-specific. Check API key validity, OpenClaw version, and channel config before proceeding.

---

#### Task 6 — Create launchd service

```bash
cat > ~/Library/LaunchAgents/com.guide.openclaw.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.guide.openclaw</string>

    <key>ProgramArguments</key>
    <array>
        <string>/Users/gareth/.nvm/versions/node/v24.0.0/bin/node</string>
        <string>/Users/gareth/.nvm/versions/node/v24.0.0/bin/openclaw</string>
        <string>gateway</string>
    </array>

    <key>WorkingDirectory</key>
    <string>/Users/gareth</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>HOME</key>
        <string>/Users/gareth</string>
        <key>PATH</key>
        <string>/Users/gareth/.nvm/versions/node/v24.0.0/bin:/usr/local/bin:/usr/bin:/bin</string>
        <key>NODE_ENV</key>
        <string>production</string>
    </dict>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/tmp/openclaw/launchd-stdout.log</string>

    <key>StandardErrorPath</key>
    <string>/tmp/openclaw/launchd-stderr.log</string>

    <key>ThrottleInterval</key>
    <integer>10</integer>
</dict>
</plist>
PLIST

echo "✓ launchd plist created"
```

**IMPORTANT:** The `ProgramArguments` paths must match the actual Node.js and openclaw binary locations. Verify before loading:

```bash
# Find the actual paths
ACTUAL_NODE=$(which node)
ACTUAL_OPENCLAW=$(which openclaw)
echo "Node: $ACTUAL_NODE"
echo "OpenClaw: $ACTUAL_OPENCLAW"

# Update the plist if paths differ from the template
# The template assumes nvm with Node 24 — adapt if different
sed -i '' "s|/Users/gareth/.nvm/versions/node/v24.0.0/bin/node|$ACTUAL_NODE|g" ~/Library/LaunchAgents/com.guide.openclaw.plist
sed -i '' "s|/Users/gareth/.nvm/versions/node/v24.0.0/bin/openclaw|$ACTUAL_OPENCLAW|g" ~/Library/LaunchAgents/com.guide.openclaw.plist

echo "✓ Paths updated in plist"
```

**Note on ANTHROPIC_API_KEY:** launchd does not source `~/.zshenv`. If the API key is needed as an environment variable, add it to the plist's `EnvironmentVariables` section. However, OpenClaw may read it from `~/.openclaw/credentials/` or `openclaw.json` — check which method the current install uses before adding to the plist.

```bash
# Check if OpenClaw reads the key from credentials store
ls ~/.openclaw/credentials/ 2>/dev/null
# If credentials exist there, the env var may not be needed in the plist
```

---

#### Task 7 — Load and start the service

```bash
# Ensure log directory exists
mkdir -p /tmp/openclaw

# Load the service
launchctl load ~/Library/LaunchAgents/com.guide.openclaw.plist

echo "Waiting 10 seconds..."
sleep 10

# Check if running
launchctl list | grep com.guide.openclaw && echo "✓ Service loaded" || echo "✗ Service not loaded"

# Health check
curl -s http://127.0.0.1:18789/healthz > /dev/null 2>&1 && echo "✓ Gateway healthy" || echo "✗ Gateway not responding"

# Check logs
tail -20 /tmp/openclaw/launchd-stderr.log 2>/dev/null
tail -20 /tmp/openclaw/launchd-stdout.log 2>/dev/null
```

---

#### Task 8 — Full verification

```bash
echo "=== Bare Metal Verification ==="

# Gateway
curl -s http://127.0.0.1:18789/healthz > /dev/null 2>&1 && echo "✓ Gateway healthy" || echo "✗ Gateway down"

# Service
launchctl list | grep -q com.guide.openclaw && echo "✓ launchd service running" || echo "✗ service not running"

# Not Docker
docker ps 2>/dev/null | grep -q openclaw && echo "✗ Docker container still running!" || echo "✓ No Docker containers"

# Tailscale
curl -s https://guide.tailfbf66e.ts.net/healthz > /dev/null 2>&1 && echo "✓ Tailscale proxy working" || echo "⚠ Tailscale proxy — check tailscale serve"

echo ""
echo "Manual checks:"
echo "  1. Message @WildernessGuideBot on Telegram — confirm response"
echo "  2. Message in #guide-data-backlog on Slack — confirm response"
echo "  3. Message in a Telegram group — confirm Guide responds"
echo "  4. Check all 5 channel agents respond in their Slack channels"
```

---

#### Task 9 — Clean up Docker (non-destructive)

Only after everything is confirmed working on bare metal.

```bash
# Stop and remove Docker containers (keeps images for rollback)
docker compose -f ~/guide-core/docker/docker-compose.yml down 2>/dev/null

# Disable Docker Desktop auto-start (optional — keeps it available for other uses)
# System Preferences → General → Login Items → remove Docker Desktop

echo "✓ Docker containers removed"
echo ""
echo "Docker Desktop is still installed — available if needed for other purposes."
echo "To fully remove: brew uninstall --cask docker (only if you're sure)"
```

**Do NOT delete Docker Desktop yet.** Other tools may use it. Just stop the OpenClaw containers.

---

#### Task 10 — Commit

```bash
cd ~/guide-core
git add -A
git commit -m "feat(chunk-07b): bare-metal migration — openclaw via npm + launchd, docker removed"
git push
echo "✓ Committed"
```

---

### Verification Gate

```bash
echo "=== CHUNK-07b Verification ==="

# OpenClaw installed
which openclaw > /dev/null 2>&1 && echo "✓ openclaw binary" || echo "✗ openclaw not installed"

# Gateway healthy
curl -s http://127.0.0.1:18789/healthz > /dev/null 2>&1 && echo "✓ gateway healthy" || echo "✗ gateway down"

# launchd service
launchctl list | grep -q com.guide.openclaw && echo "✓ launchd service" || echo "✗ launchd service missing"

# Not Docker
docker ps 2>/dev/null | grep -q openclaw && echo "✗ Docker still running!" || echo "✓ no Docker containers"

# Config backup exists
[[ -f ~/.openclaw/openclaw.json.bak-baremetal ]] && echo "✓ config backup" || echo "⚠ no config backup"

# Gateway bind
python3 -c "
import json, os
with open(os.path.expanduser('~/.openclaw/openclaw.json')) as f:
    c = json.load(f)
bind = c.get('gateway', {}).get('bind', 'NOT SET')
print(f'✓ gateway.bind = {bind}' if bind == 'loopback' else f'⚠ gateway.bind = {bind}')
"

echo ""
echo "Manual: Telegram responding? Slack responding? All channels working?"
```

---

### Rollback

If bare metal doesn't work, go back to Docker:

```bash
# Stop bare-metal service
launchctl unload ~/Library/LaunchAgents/com.guide.openclaw.plist

# Restore Docker config
cp ~/.openclaw/openclaw.json.bak-baremetal ~/.openclaw/openclaw.json

# Start Docker
docker compose -f ~/guide-core/docker/docker-compose.yml up -d

echo "Rolled back to Docker"
```

---

### Git Commit

```bash
cd ~/guide-core && git add -A && git commit -m "feat(chunk-07b): bare-metal migration — openclaw via npm + launchd"
```

---

### Handoff

After this chunk:
- OpenClaw runs as a native macOS process via launchd
- All existing config, workspaces, credentials, and agent registrations are unchanged
- Restart command: `launchctl kickstart -k gui/502/com.guide.openclaw`
- Stop: `launchctl unload ~/Library/LaunchAgents/com.guide.openclaw.plist`
- Start: `launchctl load ~/Library/LaunchAgents/com.guide.openclaw.plist`
- Logs: `/tmp/openclaw/launchd-stdout.log`, `/tmp/openclaw/launchd-stderr.log`

CHUNK-12 (filesystem restructure) no longer needs Docker volume mount config. The bootstrap script (`guide-bootstrap.sh`) simplifies — no Docker entries.

---

*Created: 2026-04-29*
