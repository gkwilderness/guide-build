---
title: "CHUNK-03-llm-configuration"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: complete
---
# CHUNK-03 — LLM Configuration
## GUIDE Build System | Phase 0 | Foundation

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.

---

### What This Chunk Does

Configures Claude API model routing, cost controls, and prompt caching. Sets up the three-tier model strategy (Sonnet interactive, Haiku cron, Opus available) with spending limits.

**Success state:** `openclaw.json` has model routing configured. Sonnet responds to interactive messages. Haiku is default for cron. Monthly spending limit is set. Prompt caching is enabled.

---

### Prerequisites

- [ ] CHUNK-02 complete (OpenClaw installed, gateway running)
- [ ] Anthropic API key with sufficient credits
- [ ] `openclaw.json` exists

---

### Deliverables

1. Model routing configured: Sonnet (interactive), Haiku (cron), Opus (available)
2. Monthly spending limit set (start at £50/month, adjust based on usage)
3. Prompt caching enabled
4. Output token caps set (prevent verbose responses)
5. Session isolation configured for cron jobs
6. Model failover configured
7. Test: Sonnet responds, Haiku responds, cost tracking visible

---

### Environment Variables Required

```bash
# Already in openclaw.json from CHUNK-02
ANTHROPIC_API_KEY=sk-ant-...
```

---

### Tasks

#### Task 1 — Configure model routing in openclaw.json

Update `~/.openclaw/openclaw.json` models section:

```json
{
  "models": {
    "default": "anthropic/claude-sonnet-4-6",
    "routes": {
      "interactive": "anthropic/claude-sonnet-4-6",
      "cron": "anthropic/claude-haiku-4-5",
      "premium": "anthropic/claude-opus-4-6"
    }
  }
}
```

#### Task 2 — Set spending limits

```json
{
  "billing": {
    "monthlyLimit": 50,
    "currency": "GBP",
    "alertThreshold": 0.8
  }
}
```

#### Task 3 — Enable prompt caching

```json
{
  "agents": {
    "defaults": {
      "promptCaching": true,
      "bootstrapMaxChars": 20000
    }
  }
}
```

#### Task 4 — Set output token caps

```json
{
  "agents": {
    "defaults": {
      "maxOutputTokens": 2048
    }
  }
}
```

#### Task 5 — Configure session isolation for cron

```json
{
  "cron": {
    "defaults": {
      "session": "isolated",
      "model": "anthropic/claude-haiku-4-5"
    }
  }
}
```

#### Task 6 — Test model routing

```bash
# Test Sonnet (interactive)
openclaw message "Respond with: Sonnet confirmed." --agent main
# Test Haiku (cron model)
openclaw message "Respond with: Haiku confirmed." --agent main --model "anthropic/claude-haiku-4-5"
echo "✓ Model routing tested"
```

#### Task 7 — Verify cost tracking

```bash
openclaw billing status
echo "✓ Cost tracking verified"
```

---

### Verification Gate

```bash
cat ~/.openclaw/openclaw.json | jq '.models.default' | grep -q "sonnet" && echo "✓ sonnet default" || echo "✗ model config"
cat ~/.openclaw/openclaw.json | jq '.agents.defaults.promptCaching' | grep -q "true" && echo "✓ prompt caching" || echo "✗ no caching"
openclaw message "ping" --agent main &>/dev/null && echo "✓ LLM responding" || echo "✗ LLM not responding"
```

---

### Rollback

Restore previous `openclaw.json` from backup or remove model/billing sections.

---

### Git Commit

```bash
cd ~/guide-core && git add -A && git commit -m "feat(chunk-03): LLM configuration and cost controls"
```

---

### Build Notes (discovered during execution)

#### auth-profiles.json must be created manually

The `main` agent requires an auth-profiles.json file that is not created automatically. Without it, all model calls fail with "No API key found for provider anthropic".

Create it at `~/.openclaw/agents/main/agent/auth-profiles.json`:

```json
{
  "profiles": {
    "anthropic:default": {
      "provider": "anthropic",
      "type": "api_key",
      "key": "<contents of ~/.openclaw/credentials/anthropic>"
    }
  }
}
```

Set permissions: `chmod 600 ~/.openclaw/agents/main/agent/auth-profiles.json`

**Why not in git:** Contains the raw API key. Never commit this file.

#### Gateway WS self-connection fails inside Docker container

When running `openclaw agent` from inside the gateway container, the WS connection to `127.0.0.1:18789` fails with error 1006 (abnormal closure). This is a Docker loopback isolation limitation — the container's loopback doesn't route back to the gateway's own listener.

**Impact:** None for real usage. Telegram/WhatsApp/Slack channels connect to the gateway from outside the container and work correctly. The embedded fallback (which uses auth-profiles.json directly) also works and is sufficient for CLI testing.

---

### Handoff to CHUNK-04

CHUNK-04 (Telegram Integration) expects:
- Claude API working (Sonnet + Haiku both responding)
- Cost controls in place
- Prompt caching enabled
- `auth-profiles.json` created for main agent (see Build Notes above)
