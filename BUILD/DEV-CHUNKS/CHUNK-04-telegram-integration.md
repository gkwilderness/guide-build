---
title: "CHUNK-04-telegram-integration"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: complete
---
# CHUNK-04 — Telegram Integration
## GUIDE Build System | Phase 0 | Foundation

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.

---

### What This Chunk Does

Creates the Guide Telegram bot, configures webhook delivery, and establishes the channel bindings for Gareth and team leads. Gareth can send a message to the bot and receive a response from Guide.

**Success state:** @GuideBot (or chosen name) responds to Gareth's Telegram DM. Channel bindings route messages to the correct agent. Team lead channels are created but not yet wired to sub-agents.

---

### Prerequisites

- [ ] CHUNK-03 complete (LLM configured and responding)
- [ ] Telegram account for bot creation (via @BotFather)
- [ ] Gareth's Telegram chat ID: `6864752167`
- [ ] Team lead Telegram chat IDs collected (Danny, Richard, Laura, Ashleigh)

---

### Deliverables

1. Telegram bot created via @BotFather (name: Guide or GuideWS)
2. Bot token stored securely in OpenClaw credentials
3. Webhook configured in `openclaw.json`
4. Channel binding: Gareth DM → Guide main agent
5. Team lead Telegram group created (or identified)
6. Channel binding: Team lead group → Guide main agent (read-only responses initially)
7. Test: Gareth sends message, Guide responds

---

### Environment Variables Required

```bash
# In openclaw.json or credentials
TELEGRAM_BOT_TOKEN=...
GARETH_CHAT_ID=6864752167
# Team lead IDs — to be collected
# DANNY_CHAT_ID=...
# RICHARD_CHAT_ID=...
# LAURA_CHAT_ID=...
# ASHLEIGH_CHAT_ID=...
```

---

### Tasks

#### Task 1 — Create Telegram bot

```
OPERATOR: Open Telegram, message @BotFather
/newbot
Name: Guide
Username: GuideWildernessBot (or similar available name)
Save the token.
```

#### Task 2 — Store bot token

```bash
openclaw credentials set telegram-bot-token "<TOKEN>"
echo "✓ Bot token stored"
```

#### Task 3 — Configure Telegram channel in openclaw.json

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "${credentials.telegram-bot-token}"
    }
  }
}
```

#### Task 4 — Create channel bindings

```json
{
  "bindings": [
    {
      "channel": "telegram",
      "user": "6864752167",
      "agent": "main",
      "note": "Gareth DM — full access"
    }
  ]
}
```

#### Task 5 — Test Gareth DM

```bash
# OPERATOR: Send a message to @GuideWildernessBot from Gareth's Telegram
# Expected: Guide responds via Claude Sonnet
echo "✓ Test by sending a message to the bot"
```

#### Task 6 — Create team lead Telegram group

```
OPERATOR: Create Telegram group "Guide — Team Leads"
Add: Gareth, Danny, Richard, Laura, Ashleigh
Add: @GuideWildernessBot
Note the group chat ID for CHUNK-06 (Access Control)
```

---

### Verification Gate

```bash
cat ~/.openclaw/openclaw.json | jq '.channels.telegram.enabled' | grep -q "true" && echo "✓ telegram enabled" || echo "✗ telegram not configured"
cat ~/.openclaw/openclaw.json | jq '.bindings[] | select(.user=="6864752167")' | grep -q "main" && echo "✓ gareth binding" || echo "✗ gareth not bound"
# Manual: send test message and confirm response
```

---

### Rollback

```bash
# Remove Telegram config from openclaw.json
# Delete bot via @BotFather: /deletebot
```

---

### Git Commit

```bash
cd ~/guide-core && git add -A && git commit -m "feat(chunk-04): telegram bot and channel bindings"
```

---

### Handoff to CHUNK-05

CHUNK-05 (Guide Agent) expects:
- Telegram bot operational
- Gareth can message Guide and receive responses
- Team lead group exists (binding completed in CHUNK-06)
