---
title: "CHUNK-02-openclaw-install"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: pending
---
# CHUNK-02 — OpenClaw Install
## GUIDE Build System | Phase 0 | Foundation

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.

---

### What This Chunk Does

Installs OpenClaw on the Guide machine, configures the gateway, creates the main workspace, and confirms vault access via OneDrive.

**Success state:** `openclaw --version` returns current version. Gateway is running on 127.0.0.1:18789. Main workspace exists at `~/.openclaw/workspace/`. OneDrive path is accessible from the workspace.

---

### Prerequisites

- [ ] CHUNK-00 complete (Node.js 24, base setup)
- [ ] CHUNK-01 complete (Docker running)
- [ ] OneDrive syncing Wilderness folder
- [ ] Anthropic API key available

---

### Deliverables

1. OpenClaw installed globally via npm
2. OpenClaw onboarded (`openclaw onboard --install-daemon`)
3. Gateway running on 127.0.0.1:18789
4. Main workspace created at `~/.openclaw/workspace/`
5. `openclaw.json` configured with base settings
6. Vault access confirmed (can read files via OneDrive path)
7. OpenClaw Studio accessible at 127.0.0.1:3000

---

### Environment Variables Required

```bash
# In ~/.openclaw/.env or openclaw.json
ANTHROPIC_API_KEY=sk-ant-...
```

---

### Tasks

#### Task 1 — Install OpenClaw

```bash
command -v openclaw &>/dev/null || {
  npm install -g openclaw@latest
  echo "✓ OpenClaw installed"
}
echo "OpenClaw version: $(openclaw --version)"
```

#### Task 2 — Run onboarding wizard

```bash
# Interactive wizard — sets up gateway, workspace, credentials
# OPERATOR: Run this interactively and follow prompts
openclaw onboard --install-daemon
echo "✓ OpenClaw onboarded"
```

#### Task 3 — Verify gateway is running

```bash
# On macOS, OpenClaw uses launchd (not systemd)
curl -s http://127.0.0.1:18789/health | jq . && echo "✓ Gateway healthy" || echo "✗ Gateway not responding"
```

#### Task 4 — Verify workspace exists

```bash
[[ -d ~/.openclaw/workspace ]] && echo "✓ Main workspace exists" || echo "✗ No workspace"
ls ~/.openclaw/workspace/
```

#### Task 5 — Confirm OneDrive access

```bash
ONEDRIVE_PATH="$HOME/Library/CloudStorage/OneDrive-WildernessSafaris"
[[ -d "$ONEDRIVE_PATH" ]] && echo "✓ OneDrive accessible" || echo "✗ OneDrive not found"
ls "$ONEDRIVE_PATH" | head -10
```

#### Task 6 — Install OpenClaw Studio

```bash
npx openclaw-studio@latest &
sleep 5
curl -s http://127.0.0.1:3000 &>/dev/null && echo "✓ Studio running on :3000" || echo "✗ Studio not responding"
```

#### Task 7 — Test basic message

```bash
openclaw message "Hello from Guide. Confirm you can read this." --agent main
echo "✓ Test message sent"
```

---

### Verification Gate

```bash
command -v openclaw &>/dev/null && echo "✓ openclaw installed" || echo "✗ openclaw not installed"
curl -s http://127.0.0.1:18789/health &>/dev/null && echo "✓ gateway running" || echo "✗ gateway down"
[[ -d ~/.openclaw/workspace ]] && echo "✓ workspace exists" || echo "✗ no workspace"
[[ -f ~/.openclaw/openclaw.json ]] && echo "✓ config exists" || echo "✗ no config"
```

---

### Rollback

```bash
npm uninstall -g openclaw
rm -rf ~/.openclaw/
# Remove launchd plist if created
rm -f ~/Library/LaunchAgents/com.openclaw.gateway.plist
```

---

### Git Commit

```bash
cd ~/guide-core && git add -A && git commit -m "feat(chunk-02): openclaw installed and gateway running"
```

---

### Handoff to CHUNK-03

CHUNK-03 (LLM Configuration) expects:
- OpenClaw running with gateway on :18789
- `openclaw.json` exists and is editable
- Anthropic API key configured
