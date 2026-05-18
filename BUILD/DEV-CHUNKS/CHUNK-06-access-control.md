---
title: "CHUNK-06-access-control"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: complete
---
# CHUNK-06 — Access Control
## GUIDE Build System | Phase 0 | Foundation

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.

---

### What This Chunk Does

Implements the 4-tier access model (Architect/Operator/Consumer/Executive). Configures Telegram, WhatsApp, and Slack channel bindings with appropriate permissions per tier.

**Success state:** Gareth has Architect access. Team leads have Operator access via Telegram. Slack channels are created for Consumer tier. WhatsApp Business is configured for Executive tier (or placeholder if API not yet available).

---

### Prerequisites

- [ ] CHUNK-05 complete (Guide agent operational)
- [ ] Team lead Telegram chat IDs collected
- [ ] Slack workspace available (or to be created)
- [ ] Dedicated SIM/eSIM for WhatsApp (Guide bot number)

---

### Deliverables

1. 4-tier access model documented in `openclaw.json`
2. Telegram bindings: Gareth DM (Architect), Team Lead group (Operator)
3. Slack app created and connected (Consumer tier)
4. Slack channels: `#guide-briefs`, `#guide-ops`, `#guide-alerts`
5. WhatsApp Business configured (Executive tier) — or placeholder with manual delivery
6. Access control matrix in Guide's TOOLS.md
7. Test: each tier receives appropriate level of output

---

### Tasks

#### Task 1 — ✅ DONE — Slack app and channels already created

Slack app (Guide) is live. Socket mode connected. Bot token and app token stored in OpenClaw credential store. Channels exist. No action needed.

#### Task 2 — Add Telegram operator bindings

Gareth's Architect binding is already live. Add operator bindings for the three team leads.

Merge the following into the `bindings` array in `~/.openclaw/openclaw.json`:

```json
{
  "channel": "telegram",
  "user": "8717068556",
  "agent": "main",
  "tier": "operator",
  "note": "Danny Nagra — Group Head of Performance"
},
{
  "channel": "telegram",
  "user": "8715479659",
  "agent": "main",
  "tier": "operator",
  "note": "Richard Keenan-Heard — Group Head of SEO"
},
{
  "channel": "telegram",
  "user": "8661869138",
  "agent": "main",
  "tier": "operator",
  "note": "Laura Sinclair — Group Digital Product Director"
}
```

**Added:**
- Matt Wylie (Finance RFO) — `8265788167` ✅ 2026-04-14
- Ashleigh — joins 2026-05-11 ⬜ (backlog item)

#### Task 3 — Configure Slack channel posting in openclaw.json

Slack DMs are working. Now enable channel posting for the three Guide channels.

Merge into `~/.openclaw/openclaw.json` under `channels.slack`:

```json
{
  "channels": {
    "slack": {
      "enabled": true,
      "botToken": "${credentials.slack-bot-token}",
      "appToken": "${credentials.slack-app-token}",
      "mode": "socket",
      "channels": {
        "briefs": "C0ATG3V2EDN",
        "ops": "C0ASJDN5KGV",
        "alerts": "C0ASJDP022H"
      }
    }
  }
}
```

**Note:** `#wilderness-digital-team` (`C0987SGJ9NJ`) is intentionally excluded — posting to that channel is deferred until morning briefs are ready (Phase 1).

#### Task 4 — Verify Telegram operator bindings are live

After applying Task 2, test each operator binding:

```bash
# Send a test message as Danny/Richard/Laura via Telegram
# Guide should respond to each
# Confirm operator-tier response (no shell access, no admin commands)
```

#### Task 5 — Verify Slack channel posting

After applying Task 3, test posting to each channel:

```bash
openclaw test --channel slack --target C0ATG3V2EDN --message "Guide channel test: briefs"
openclaw test --channel slack --target C0ASJDN5KGV --message "Guide channel test: ops"
openclaw test --channel slack --target C0ASJDP022H --message "Guide channel test: alerts"
```

#### Task 6 — WhatsApp via Baileys (deferred — SIM not yet purchased)

OpenClaw uses Baileys (WhatsApp Web bridge) — no Business API needed. Just a SIM + QR scan.

**When SIM is ready:**
1. Register WhatsApp on the dedicated number
2. Install the WhatsApp plugin and link:

```bash
openclaw plugins install @openclaw/whatsapp
openclaw channels login --channel whatsapp
# Scan QR code with the dedicated phone
```

3. Merge into `~/.openclaw/openclaw.json`:

```json
{
  "channels": {
    "whatsapp": {
      "enabled": true,
      "dmPolicy": "allowlist",
      "allowFrom": [
        "<HADLEY_PHONE_E164>",
        "<KEITH_PHONE_E164>",
        "<NICK_PHONE_E164>"
      ],
      "sendReadReceipts": true,
      "reactionLevel": "minimal"
    }
  }
}
```

OPERATOR: Fill in executive phone numbers (Hadley, Keith, Nick) in E.164 format (+44...) before applying.

**Note:** Baileys is unofficial. Low-volume executive briefs (a few per week) are negligible risk. Use the dedicated number only.

#### Task 7 — Update TOOLS.md with access matrix

Update `~/.openclaw/workspace/TOOLS.md` to reflect the live access model:

```markdown
## Access Tiers

| Tier | Channel | Users | Capabilities |
|------|---------|-------|-------------|
| Architect | Telegram DM, shell | Gareth (6864752167) | Full access |
| Operator | Telegram DM | Danny (8717068556), Richard (8715479659), Laura (8661869138) | Trigger agents, view outputs |
| Consumer | Slack channels | Digital team (via #guide-briefs, #guide-ops, #guide-alerts) | Read outputs |
| Executive | WhatsApp (deferred) | Hadley, Keith, Nick | Curated briefs only |
```

Remember: workspace files are `440` after write.

---

### Verification Gate

```bash
# Telegram — Gareth binding present
cat ~/.openclaw/openclaw.json | jq '.bindings[] | select(.user == "6864752167")' | grep -q "architect" && echo "✓ telegram: gareth" || echo "✗ telegram: gareth missing"

# Telegram — Operator bindings present
cat ~/.openclaw/openclaw.json | jq '.bindings[] | select(.user == "8717068556")' | grep -q "operator" && echo "✓ telegram: danny" || echo "✗ telegram: danny missing"
cat ~/.openclaw/openclaw.json | jq '.bindings[] | select(.user == "8715479659")' | grep -q "operator" && echo "✓ telegram: richard" || echo "✗ telegram: richard missing"
cat ~/.openclaw/openclaw.json | jq '.bindings[] | select(.user == "8661869138")' | grep -q "operator" && echo "✓ telegram: laura" || echo "✗ telegram: laura missing"

# Slack — channels configured
cat ~/.openclaw/openclaw.json | jq '.channels.slack.enabled' | grep -q "true" && echo "✓ slack: enabled" || echo "✗ slack: not enabled"
cat ~/.openclaw/openclaw.json | jq '.channels.slack.channels.briefs' | grep -q "C0ATG3V2EDN" && echo "✓ slack: briefs channel" || echo "✗ slack: briefs channel missing"
cat ~/.openclaw/openclaw.json | jq '.channels.slack.channels.ops' | grep -q "C0ASJDN5KGV" && echo "✓ slack: ops channel" || echo "✗ slack: ops channel missing"
cat ~/.openclaw/openclaw.json | jq '.channels.slack.channels.alerts' | grep -q "C0ASJDP022H" && echo "✓ slack: alerts channel" || echo "✗ slack: alerts channel missing"

# WhatsApp — expected to fail until SIM is purchased
openclaw channels status | grep -q "whatsapp" && echo "✓ whatsapp" || echo "⏳ whatsapp: deferred (SIM not yet purchased)"
```

---

### Rollback

```bash
# Remove access/channel config from openclaw.json
# Remove Slack app via api.slack.com
```

---

### Git Commit

```bash
cd ~/guide-core && git add -A && git commit -m "feat(chunk-06): 4-tier access control and channel bindings"
```

---

### Build Notes

**2026-04-13:**
- Slack live: socket mode, bot token + app token configured, DMs working
- Channels confirmed: #guide-briefs `C0ATG3V2EDN`, #guide-ops `C0ASJDN5KGV`, #guide-alerts `C0ASJDP022H`
- Team channel confirmed: #wilderness-digital-team `C0987SGJ9NJ` — posting deferred to Phase 1 (morning briefs)
- Gareth DM binding live (Telegram + Slack)
- Vault access rules in AGENTS.md: Wilderness vault for team, both vaults for Gareth
- guide-workspace committed to separate repo: `git@github.com:gkwilderness/guide-workspace.git`

**2026-04-14:**
- Telegram IDs collected: Danny `8717068556`, Richard `8715479659`, Laura `8661869138`
- Matt Wylie `8265788167` — binding applied ✅
- Slack user IDs collected for full digital team — see `__CONFIG/GUIDE.md`
- Ashleigh deferred — joins 2026-05-11
- All operator Telegram DM bindings applied to `openclaw.json` ✅
- Slack channel posting configured ✅
- TOOLS.md access matrix updated ✅
- CHUNK-06 complete. WhatsApp formalised as backlog item (SIM required).

**Decisions made:**
- Individual Telegram DM bindings per operator (no group binding — uses allowFrom pattern)
- `access.tiers` schema not used in openclaw.json (not natively supported — access controlled via bindings + allowFrom)
- Slack channel posting enabled for guide channels only; `#wilderness-digital-team` excluded until morning briefs ready (Phase 1)
- WhatsApp deferred — Baileys plugin not installed pending dedicated SIM purchase

---

### Handoff to CHUNK-07

CHUNK-07 (Security & Hardening) expects:
- All channels configured (Telegram, Slack; WhatsApp deferred)
- Access tiers defined
- Guide responding to appropriate users
