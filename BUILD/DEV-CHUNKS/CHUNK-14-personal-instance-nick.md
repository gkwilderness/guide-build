---
title: "CHUNK-14-personal-instance-nick"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: complete
---
# CHUNK-14 — Personal Instances: Nick (complete) + Keith (pending)
## GUIDE Build System | Phase 1 | First Personal Instances

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> Reference `Specs/personal-instance-architecture.md` for the architecture.
> Reference `Agents/Personal/Nick.md` for the person spec.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.

---

### What This Chunk Does

Takes two personal instances from generated workspace to live operation. Verifies the OpenClaw schema supports multiple Telegram bots, registers both agents, binds their Telegram bots, and validates the full loop: message in → agent reads vault → response out → privacy confirmed.

Nick validates the architecture. Keith is the demo target (~10 May). Both use the exec tier — same API key, same team vault (exec), same permission profile. The pattern is identical; only the person config and SOUL tone differ.

**Why both in one chunk:** The factory (CHUNK-13) does the heavy lifting. Once `generate.sh personal nick` works, `generate.sh personal keith` is a 2-minute repeat. Shipping both saves a chunk boundary and gets Keith ready for the demo.

**Success state:** Nick messages `@GuideNickBot`, gets capital allocation framing. Keith messages `@GuideKeithBot`, gets controllable-vs-structural framing. Both read from the exec team vault. Conversations are isolated from each other and from Guide Main. Hybrid review model works for both.

---

### Completion Notes (2026-05-01)

**Nick: Complete.** Instance is live, tested by Gareth, and ready for handoff to Nick.

**What was built:**
- Workspace: `~/.openclaw/workspace-personal-nick/` — all 10 files generated and locked (440)
- Personal vault: `~/guide-vault/personal/nick/` — populated (FY27 CEO commitments, priorities, watchlist, investment/, performance/, board/, memory/)
- Team vault: `~/guide-vault/teams/exco/` — seeded (CLAUDE.md, PRIORITIES.md, travel policy)
- Shared vault: `~/guide-vault/shared/` — populated (brand, business, countries, regions, impact, sales)
- Registered in openclaw.json, `@WildernessGuideNickBot` bound, gateway confirmed healthy
- Onboarding will fire on Nick's first message (MEMORY.md has no `status: complete` yet)

**Multi-bot Telegram architecture confirmed (ADR documented in signals):** OpenClaw supports multiple Telegram bots via `channels.telegram.accounts`. Each named account gets its own `botToken`, `allowFrom`, `dmPolicy`, and all other Telegram properties. Agents bind via `openclaw agents bind --agent <id> --bind telegram:<accountId>`. No architectural limitation — each person gets their own bot.

**Key schema finding:** `tools.exec.ask` valid values are `"off"`, `"on-miss"`, `"always"` — NOT `"on"`. For personal instances with exec denied entirely: omit the `exec` block and put `"exec"` in `tools.deny` instead.

**Escalation path note:** Personal instance can send Telegram messages to Nick's bot conversation only. To escalate to Gareth, agent writes to a signal file. A relay mechanism (Guide Main as relay) can be built later if needed.

**Roster gates to flip for Nick:** `templateReady: true`, `workspaceGenerated: true`, `registeredInOpenClaw: true`, `garethTested: true`. Flip `personOnboarded` and set `status: production` after Nick's first real conversation.

**Keith: Not started.** Demo target: 2026-05-10. Same pattern as Nick — generate, register, bind, test.

---

**Gareth pre-task:** Before this chunk begins, Gareth must:
1. Create `@GuideNickBot` via BotFather on Telegram
2. Create `@GuideKeithBot` via BotFather on Telegram
3. Store both bot tokens in `~/guide-core/__CONFIG/keys/telegram-nick` and `telegram-keith`
4. Get Nick's Telegram chat ID (message the bot, extract from update)
5. Get Keith's Telegram chat ID (same method)

---

### Prerequisites

- [x] CHUNK-13 complete (personal instance factory working) ✅
- [x] Nick workspace generated at `~/.openclaw/workspace-personal-nick/` ✅
- [ ] Keith workspace generated at `~/.openclaw/workspace-personal-keith/` — **not started**
- [x] Nick's entry in `roster.json` reviewed and accurate ✅
- [x] Gareth has created `@WildernessGuideNickBot` and stored token ✅
- [ ] Gareth creates `@GuideKeithBot` and stores token — pending
- [x] Nick's Telegram chat ID confirmed ✅ (8516698636)
- [ ] Keith's Telegram chat ID — pending
- [x] Exec team vault seeded at `~/guide-vault/teams/exco/` ✅

---

### Deliverables

**Nick (complete):**
1. ✅ OpenClaw multi-bot Telegram schema verified — `channels.telegram.accounts` pattern confirmed
2. ✅ `personal-nick` agent registered in `openclaw.json`
3. ✅ `@WildernessGuideNickBot` bound to `personal-nick` agent
4. ✅ Gateway restarted with Nick's agent live
5. ✅ Gareth-as-Nick test conversation completed (8 scenarios, capital allocation framing)
6. ✅ Privacy isolation confirmed (Guide Main cannot see Nick's conversation)

**Keith (pending — demo target 2026-05-10):**
7. `personal-keith` agent registered in `openclaw.json`
8. `@GuideKeithBot` bound to `personal-keith` agent
9. Gareth-as-Keith test conversation (controllable vs structural framing)
10. Cross-instance isolation confirmed (Nick and Keith cannot see each other)

---

### Environment Variables Required

```bash
# These must be set before starting — Gareth provides them
NICK_BOT_TOKEN="<from ~/guide-core/__CONFIG/keys/telegram-nick>"
NICK_CHAT_ID="<Nick's Telegram chat ID>"
```

---

### Tasks

#### Task 1 — Verify OpenClaw multi-bot Telegram schema

Before adding a second Telegram bot, confirm the schema supports it. This is a blocking check — if the schema doesn't support multiple bots, we need an alternative approach.

```bash
# Check the Telegram channel schema
openclaw config schema 2>/dev/null | python3 -c "
import sys, json

try:
    schema = json.load(sys.stdin)
except:
    print('Could not parse schema — run the command manually and inspect')
    sys.exit(1)

# Look for telegram-related schema sections
def find_telegram(obj, path=''):
    if isinstance(obj, dict):
        for k, v in obj.items():
            full = f'{path}.{k}'
            if 'telegram' in k.lower():
                print(f'Found: {full}')
                if isinstance(v, dict):
                    print(json.dumps(v, indent=2)[:500])
            find_telegram(v, full)
find_telegram(schema)
" 2>/dev/null || echo "Schema check failed — inspect manually"

# Also check current Telegram config
echo ""
echo "=== Current Telegram config ==="
cat ~/.openclaw/openclaw.json | python3 -c "
import sys, json
d = json.load(sys.stdin)
tg = d.get('channels', {}).get('telegram', {})
print(json.dumps(tg, indent=2))
"
```

**Three possible outcomes:**

1. **Schema supports multiple bots** (e.g., `bots` is an array or object with named entries) → proceed normally.
2. **Schema supports one bot with multiple allowFrom entries** → register Nick's chat ID alongside Gareth's, and route based on chat ID to the correct agent. Write findings to `→architect.md`.
3. **Schema supports only one bot** → need a second OpenClaw instance for personal bots. Write findings to `→architect.md` and stop — Architect must redesign before proceeding.

**Record findings in `→architect.md` regardless of outcome.**

---

#### Task 2 — Register personal-nick agent in openclaw.json

Based on Task 1 findings, add Nick's agent. The exact config shape depends on what the schema allows.

**Expected pattern (if schema supports named bots or multiple agents):**

```bash
# Backup first
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak-chunk14

python3 << 'PYEOF'
import json, os

config_path = os.path.expanduser("~/.openclaw/openclaw.json")
with open(config_path) as f:
    config = json.load(f)

home = os.path.expanduser("~")

# Add personal-nick to agents list
agents = config.setdefault("agents", {}).setdefault("list", [])

# Check if already registered
existing = [a for a in agents if a.get("id") == "personal-nick"]
if existing:
    print("⚠ personal-nick already registered — skipping")
else:
    nick_agent = {
        "id": "personal-nick",
        "name": "personal-nick",
        "workspace": f"{home}/guide-vault/personal/nick",
        "tools": {
            "profile": "full",
            "deny": ["process", "code_execution", "group:automation"],
            "exec": {"security": "full", "ask": "off"}
        }
    }
    agents.append(nick_agent)
    print("✓ personal-nick agent added to agents list")

with open(config_path, "w") as f:
    json.dump(config, f, indent=2)

print("✓ openclaw.json updated")
PYEOF
```

**Important:** The tools profile and deny list above follow the pattern from existing channel agents. Adapt if the schema has changed since CHUNK-10.

---

#### Task 3 — Bind @GuideNickBot to personal-nick agent

This task depends entirely on Task 1 findings. The implementation will vary based on how OpenClaw handles multiple Telegram bots.

**If the schema supports multiple bots:**

```bash
# Add the bot binding — exact shape TBD from Task 1
# This is pseudocode — adapt to actual schema
python3 << 'PYEOF'
import json, os

config_path = os.path.expanduser("~/.openclaw/openclaw.json")
with open(config_path) as f:
    config = json.load(f)

# Read bot token
token_path = os.path.expanduser("~/guide-core/__CONFIG/keys/telegram-nick")
with open(token_path) as f:
    bot_token = f.read().strip()

nick_chat_id = os.environ.get("NICK_CHAT_ID", "REPLACE_WITH_NICK_CHAT_ID")

# TODO: Adapt this section based on Task 1 schema findings
# The exact path in the config depends on what the schema allows
telegram_config = config.setdefault("channels", {}).setdefault("telegram", {})

# Option A: Multiple bots as array
# Option B: Named bots as object
# Option C: Additional bot tokens alongside main
# Implement whichever the schema supports

print("⚠ Adapt Telegram binding based on Task 1 findings")
print(f"  Bot token: {bot_token[:10]}... (truncated)")
print(f"  Nick chat ID: {nick_chat_id}")

with open(config_path, "w") as f:
    json.dump(config, f, indent=2)
PYEOF
```

**Before writing to openclaw.json:** Validate the change against the schema. The `additionalProperties: false` constraint means any wrong key causes a crash-loop.

**Streaming and error suppression:** When adding the Telegram account for Nick, include `streaming.preview.toolProgress: false` on the account to prevent tool progress messages leaking into chat. Also confirm these top-level settings exist (should be set once, applies system-wide):

```json
{
  "messages": { "suppressToolErrors": true },
  "channels": {
    "telegram": {
      "streaming": { "preview": { "toolProgress": false } },
      "accounts": {
        "nick": {
          "streaming": { "preview": { "toolProgress": false } }
        }
      }
    }
  }
}
```

Verify these keys exist in the schema first (`openclaw config schema`). If they don't exist, record in `→architect.md` and skip — users will see tool progress messages but the agent will still function.

```bash
# Validate config before restart
openclaw config validate 2>/dev/null || echo "⚠ Validation command may differ — check openclaw --help"
```

---

#### Task 4 — Restart gateway and verify

```bash
openclaw gateway restart

echo "Waiting 15 seconds for gateway to initialise..."
sleep 15

# Check gateway health
curl -s http://127.0.0.1:18789/health > /dev/null 2>&1 && echo "✓ Gateway healthy" || echo "✗ Gateway not responding"

# Check logs for errors
tail -30 /tmp/openclaw/launchd-stderr.log 2>/dev/null | grep -i "error\|personal-nick\|telegram" || echo "✓ No errors mentioning personal-nick"

# Confirm personal-nick agent is registered
tail -100 /tmp/openclaw/launchd-stderr.log 2>/dev/null | grep -i "personal-nick" && echo "✓ personal-nick appears in logs" || echo "⚠ personal-nick not found in logs — check registration"
```

**If gateway fails to start:**
```bash
# Restore from backup
cp ~/.openclaw/openclaw.json.bak-chunk14 ~/.openclaw/openclaw.json
openclaw gateway restart
echo "⚠ Rolled back — investigate schema violation in backup diff"
diff ~/.openclaw/openclaw.json.bak-chunk14 ~/.openclaw/openclaw.json || true
```

---

#### Task 5 — Manual testing (Gareth)

This task is performed by Gareth, not the Engineer. Document the test plan here.

```
MANUAL TEST PLAN — Nick's Personal Instance

1. BASIC RESPONSE
   - Open @GuideNickBot in Telegram
   - Send: "Hi"
   - Expected: Agent responds as Nick's Guide, not as Guide Main

2. TONE CHECK
   - Send: "What are the current priorities?"
   - Expected: Response uses capital allocation framing, PE operator register
   - NOT expected: Marketing language, exclamation marks, corporate filler

3. VAULT ACCESS
   - Send: "What does the exec vault contain?"
   - Expected: Agent reads from ~/guide-teams/exec/ and reports contents
   
4. VAULT BOUNDARY
   - Send: "What's in the SEO backlog?"
   - Expected: Agent says it doesn't have access to that data (SEO backlog is in digital team vault, not mounted for Nick)

5. PRIVACY ISOLATION
   - After messaging @GuideNickBot, message @WildernessGuideBot (Guide Main)
   - Send to Guide Main: "What did Nick just ask me?"
   - Expected: Guide Main has no knowledge of Nick's conversation

6. HYBRID REVIEW — FACTUAL
   - Send to Nick bot: "What's the FY27 revenue target?"
   - Expected: Direct answer from exec vault data (no escalation)

7. HYBRID REVIEW — JUDGMENT
   - Send to Nick bot: "Should we increase digital spend next quarter?"
   - Expected: Agent drafts a response and escalates to Gareth via Slack DM

8. HYBRID REVIEW — OUT OF SCOPE
   - Send to Nick bot: "What's the IT department's headcount?"
   - Expected: Agent says it doesn't have that context and offers to flag Gareth
```

**Record test results.** If any test fails, document what happened and what needs fixing in the SOUL.md or config.

---

#### Task 5b — Manual testing: Keith (Gareth)

Same structure as Nick. Run after Nick's tests pass.

```
MANUAL TEST PLAN — Keith's Personal Instance

1. BASIC RESPONSE
   - Open @GuideKeithBot in Telegram
   - Send: "Hi"
   - Expected: Agent responds as Keith's Guide — strategic, values-led register

2. TONE CHECK
   - Send: "What are the current priorities?"
   - Expected: Response uses controllable vs structural framing, infrastructure language
   - NOT expected: Marketing language, channel-level metrics, tactical detail

3. VAULT ACCESS
   - Send: "What are the FY27 CEO commitments?"
   - Expected: Agent reads from ~/guide-teams/exec/ and reports commitments

4. VAULT BOUNDARY
   - Send: "What's in the paid media backlog?"
   - Expected: Agent says it doesn't have access to operational backlogs

5. CROSS-INSTANCE ISOLATION
   - After messaging @GuideKeithBot, message @GuideNickBot
   - Send to Nick bot: "What did Keith just ask?"
   - Expected: Nick's agent has no knowledge of Keith's conversation

6. FRAMEWORK CHECK
   - Send to Keith bot: "How is digital spend performing this quarter?"
   - Expected: Response structured as controllable (what the team can fix) vs structural (what needs exec decision)

7. HYBRID REVIEW — JUDGMENT
   - Send to Keith bot: "Should we restructure the digital team?"
   - Expected: Agent drafts a response and escalates to Gareth

8. CONSERVATION CONTEXT
   - Send to Keith bot: "How does our digital investment connect to the conservation mission?"
   - Expected: Agent frames digital performance in terms of conservation impact, not marketing ROI
```

---

#### Task 6 — Commit

```bash
cd ~/guide-core
git add -A
git commit -m "feat(chunk-14): personal-nick + personal-keith instances — registered, telegram bound, tested"
git push
echo "✓ Nick + Keith instances committed"
```

---

### Verification Gate

```bash
echo "=== CHUNK-14 Verification ==="

# Schema research documented
[[ -f ~/.openclaw/workspace/signals/→architect.md ]] && grep -q "multi-bot\|telegram.*schema\|personal-nick" ~/.openclaw/workspace/signals/→architect.md && echo "✓ Schema findings documented" || echo "⚠ Check →architect.md for schema findings"

# Agent registered
python3 -c "
import json, os
with open(os.path.expanduser('~/.openclaw/openclaw.json')) as f:
    config = json.load(f)
agents = config.get('agents', {}).get('list', [])
found = any(a.get('id') == 'personal-nick' for a in agents)
print('✓ personal-nick registered' if found else '✗ personal-nick not registered')
"

# Workspace exists and is valid
[[ -f ~/guide-vault/personal/nick/IDENTITY.md ]] && echo "✓ nick workspace exists" || echo "✗ nick workspace missing"
PLACEHOLDER_COUNT=$(grep -r "{{" ~/guide-vault/personal/nick/ 2>/dev/null | wc -l)
[[ "$PLACEHOLDER_COUNT" -eq 0 ]] && echo "✓ no unreplaced placeholders" || echo "✗ placeholders found"

# Bot token stored
[[ -f ~/guide-core/__CONFIG/keys/telegram-nick ]] && echo "✓ bot token stored" || echo "✗ bot token missing"

# Gateway healthy
curl -s http://127.0.0.1:18789/health > /dev/null 2>&1 && echo "✓ gateway healthy" || echo "✗ gateway not responding"

# Guide Main still working
echo "Manual check: message @WildernessGuideBot — confirm Guide Main still responds normally"

# Nick bot responding
echo "Manual check: message @GuideNickBot — confirm Nick's agent responds"
```

---

### Rollback

```bash
# Restore openclaw.json
cp ~/.openclaw/openclaw.json.bak-chunk14 ~/.openclaw/openclaw.json

# Restart gateway without Nick's agent
openclaw gateway restart

# Nick workspace stays (non-destructive) — can be re-registered later
echo "✓ Rolled back — Nick's workspace remains but is not registered"
```

---

### Git Commit

```bash
cd ~/guide-core && git add -A && git commit -m "feat(chunk-14): personal-nick instance live"
```

---

### Remaining Work in This Chunk

**Keith (pending — demo target 2026-05-10):**
1. Gareth creates `@GuideKeithBot` via BotFather, stores token
2. Get Keith's Telegram chat ID
3. Add Keith entry to `guide-roster.json`, copy to machine
4. `./generate.sh personal keith` — workspace to `~/.openclaw/workspace-personal-keith/`
5. Populate `~/guide-vault/personal/keith/` with Keith context files
6. Register `personal-keith` in `openclaw.json`, bind to `telegram:keith` account
7. Restart gateway, run test plan (Task 5b)
8. Flip Keith's roster gates; set `status: production` after handoff

### Handoff to CHUNK-15+

After Keith's instance is live and demo-ready:

1. **Gareth onboards Nick** — guided first conversation (Nick's onboarding fires automatically on first message)
2. **Monitor 48 hours** — tune SOUL.md if tone or scope needs adjustment
3. **CHUNK-15: Hadley** — update `guide-roster.json` (write person spec, flip gates), create `@GuideHadleyBot`, repeat the pattern
4. **Subsequent chunks** follow rollout order in [[personal-instance-architecture]]

Each subsequent personal instance is lightweight — the factory, templates, and registration pattern are proven. The per-person workflow follows the gates in `guide-roster.json`:
- Write person spec (`Agents/Personal/{Name}.md`) → flip `personSpecWritten`
- Update `guide-roster.json` → copy to machine
- Create Telegram bot via BotFather → flip `telegramBotCreated`, fill `telegramBotUsername`
- Run `generate.sh personal {name}` → flip `workspaceGenerated`
- Register + bind in `openclaw.json` → flip `registeredInOpenClaw`
- Gareth test → flip `garethTested`
- Onboard person → flip `personOnboarded`, set status `production`, set `deployedDate`

---

### Known Unknowns

1. **Multi-bot Telegram schema:** Task 1 is the critical unknown. If OpenClaw doesn't support multiple Telegram bots in one instance, we need either: (a) a second OpenClaw process for personal bots, or (b) a single bot with chat ID routing to different agents. Task 1 determines which path.
2. **Hybrid review implementation:** The SOUL.md instructs the agent to escalate judgment questions to Gareth via Slack DM. This assumes the agent has Slack messaging capability. If the personal instance's TOOLS.md denies Slack, the escalation path needs to use a different mechanism (e.g., append to a signal file, or use Guide Main as relay). Test in Task 5.

---

*Created: 2026-04-29*
