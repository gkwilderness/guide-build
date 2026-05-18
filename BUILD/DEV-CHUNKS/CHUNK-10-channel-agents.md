---
title: "CHUNK-10-channel-agents"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: pending
---
# CHUNK-10 — Channel Agents
## GUIDE Build System | Phase 1 | Context Fix + Demo

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.

---

### What This Chunk Does

Spins up 5 dedicated channel agents using the factory from CHUNK-09 and wires each to its Slack channel. This fixes the shared context window problem — each channel gets its own isolated workspace and context, rather than everything running through Guide main.

**Priority order:** Data → Martech → SEO → Digital Product → HubSpot

**Success state:** All 5 workspaces exist. Data agent is live and responding in `#guide-data`. Remaining agents are wired as their Slack channel IDs are confirmed. Guide main no longer handles those channels directly.

**What changes for the team:** Nothing visible. Same channels, same commands. The difference is each agent now knows its domain deeply and doesn't lose context from unrelated channel traffic.

---

### Prerequisites

- [ ] CHUNK-09 complete — factory working, `generate.sh` tested, Data workspace already at `~/.openclaw/workspace-data/`
- [ ] CHUNK-09 Task 1 findings documented in `→architect.md` — OpenClaw multi-agent routing confirmed
- [x] Slack channel IDs confirmed — all 5 channels confirmed 2026-04-20
- [ ] CHUNK-07 complete (security hardened)

---

### Blocking Items (OPERATOR — collect before wiring each agent)

| Agent | Channel | ID | Status |
|-------|---------|-----|--------|
| Data | `#guide-data` | `C0ASP8ZD495` | ✅ Unblocked |
| Martech | `#guide-martech` | `C0AT56RRUEP` | ✅ Unblocked |
| SEO | `#seo-guide` | `C0ATXQ8MDS5` | ✅ Unblocked |
| Digital Product | `#guide-digital-product-triage` | `C0AUT4WSPBJ` | ✅ Unblocked — confirm triage vs main with Gareth |
| HubSpot | `#guide-hubspot` | `C0AUF97NJ0H` | ✅ Unblocked |

**All channel IDs confirmed as of 2026-04-20. No operator blockers remaining.**

Note on Digital Product: two channels exist — `#guide-digital-product` (`C0ATLTNFF0X`) and `#guide-digital-product-triage` (`C0AUT4WSPBJ`). Spec assumes triage is the agent channel. Confirm with Gareth before wiring.

---

### Deliverables

1. 5 role `.env` files in `~/guide-core/agent-factory/roles/` (Data + Martech from CHUNK-09, plus SEO, Digital Product, HubSpot)
2. 5 agent workspaces generated at `~/.openclaw/workspace-{role}/`
3. Data agent registered in `openclaw.json` and live in `#guide-data`
4. Remaining agents registered and wired as channel IDs are confirmed (incremental — see Tasks 7–10)
5. Guide main BOOTSTRAP.md updated to reflect channel agent ownership
6. `__CONFIG/GUIDE.md` updated with all new channel IDs

---

### Agent Roster

| Agent ID | Name | Primary Operator | Slack Channel | Vault Path |
|----------|------|-----------------|---------------|------------|
| `data` | Data | Ashleigh Waterson (Gareth until 2026-05-11) | `#guide-data` `C0ASP8ZD495` | `10-Infra/Data/` |
| `martech` | Martech | David Hamilton | `#guide-martech` `C0AT56RRUEP` | `10-Infra/MarTech/` |
| `seo` | SEO | Richard Keenan-Heard | `#seo-guide` `C0ATXQ8MDS5` | `25-Channels/SEO/` |
| `product` | Digital Product | Laura Sinclair | `#guide-digital-product` `C0ATLTNFF0X` + `#guide-digital-product-triage` `C0AUT4WSPBJ` | `25-Channels/Digital-Product/` |
| `hubspot` | HubSpot | Richard Keenan-Heard | `#guide-hubspot` `C0AUF97NJ0H` | `25-Channels/CRM/` |

**Note on Vault paths:** All paths are relative to `~/Obsidian/Wilderness-Guide/`. Each agent also reads `00-Compass/` for operational context (priorities, today's focus, roadmap).

---

### Slack Channel Onboarding SOP

Every channel wired in this chunk must follow this sequence in full — no shortcuts. This is in `~/Obsidian/Wilderness-Guide/CLAUDE.md` and repeated here:

1. Add channel ID to `openclaw.json` channels allowlist
2. Add channel row to agent's `BOOTSTRAP.md` channel context table with the correct vault `CLAUDE.md` path
3. Flush the channel session (or all Slack sessions)
4. Test with a vault query before the team uses it

The `#seo-guide` incident (2026-04-17): Guide launched without vault context because steps 2–4 were skipped. Richard and Tenneil saw Guide fumble in public. Do not repeat this.

---

### Tasks

#### Task 1 — Confirm routing mechanism from CHUNK-09 Task 1

Read `→architect.md` signal. Confirm the Engineer's findings on multi-agent routing before writing any config. If routing works differently than the spec assumes, adjust Tasks 6–10 accordingly and flag the delta to Gareth.

```bash
cat ~/.openclaw/workspace/signals/→architect.md | grep -A20 "routing\|workspace\|agent"
```

If no findings are documented yet — stop. Run CHUNK-09 Task 1 first, document the findings, then return here.

---

#### Task 2 — Create role configs for SEO, Digital Product, HubSpot

Data and Martech configs were written in CHUNK-09. Write the remaining three. All channel IDs are confirmed — role configs are ready to generate immediately.

```bash
cat > ~/guide-core/agent-factory/roles/seo.env << 'EOF'
AGENT_ID=seo
AGENT_NAME=SEO
AGENT_ROLE=SEO Intelligence Agent
AGENT_EMOJI=🔍
AGENT_BRAND_FULL=Wilderness Safaris
AGENT_DOMAIN=organic search, keyword rankings, technical SEO, content strategy, link building, search visibility
AGENT_TONE=data-driven, ranking-obsessed, flags drops fast, links findings to commercial outcomes
AGENT_PRIMARY_OPERATOR=Richard Keenan-Heard
AGENT_SLACK_CHANNEL_NAME=#seo-guide
AGENT_CHANNEL_ID=C0ATXQ8MDS5
AGENT_VAULT_PATHS=- ~/Obsidian/Wilderness-Guide/25-Channels/SEO/\n- ~/Obsidian/Wilderness-Guide/10-Areas/\n- ~/Obsidian/Wilderness-Guide/00-Compass/
AGENT_HEARTBEAT_SCHEDULE=Weekly Monday 08:30 — ranking movements, crawl health, content pipeline
EOF

cat > ~/guide-core/agent-factory/roles/product.env << 'EOF'
AGENT_ID=product
AGENT_NAME=Digital Product
AGENT_ROLE=Digital Product Intelligence Agent
AGENT_EMOJI=🖥️
AGENT_BRAND_FULL=Wilderness Safaris
AGENT_DOMAIN=website performance, UX, conversion rate optimisation, A/B testing, digital product roadmap
AGENT_TONE=user-outcome focused, conversion-minded, flags friction in the funnel
AGENT_PRIMARY_OPERATOR=Laura Sinclair
AGENT_SLACK_CHANNEL_NAME=#guide-digital-product-triage
AGENT_CHANNEL_ID=C0AUT4WSPBJ
# Second channel — both wire to workspace-product (see Task 9 for second binding)
AGENT_SLACK_CHANNEL_NAME_2=#guide-digital-product
AGENT_CHANNEL_ID_2=C0ATLTNFF0X
AGENT_VAULT_PATHS=- ~/Obsidian/Wilderness-Guide/25-Channels/Digital-Product/\n- ~/Obsidian/Wilderness-Guide/00-Compass/
AGENT_HEARTBEAT_SCHEDULE=Weekly Tuesday 08:30 — site health, conversion trends, active experiments
EOF

cat > ~/guide-core/agent-factory/roles/hubspot.env << 'EOF'
AGENT_ID=hubspot
AGENT_NAME=HubSpot
AGENT_ROLE=HubSpot Intelligence Agent
AGENT_EMOJI=🔗
AGENT_BRAND_FULL=Wilderness Safaris
AGENT_DOMAIN=CRM health, lead pipeline, deal stages, contact management, HubSpot workflows, booking attribution
AGENT_TONE=pipeline-focused, flags stale deals and conversion drops, speaks revenue not vanity metrics
AGENT_PRIMARY_OPERATOR=Richard Keenan-Heard
AGENT_SLACK_CHANNEL_NAME=#guide-hubspot
AGENT_CHANNEL_ID=C0AUF97NJ0H
AGENT_VAULT_PATHS=- ~/Obsidian/Wilderness-Guide/25-Channels/CRM/\n- ~/Obsidian/Wilderness-Guide/00-Compass/
AGENT_HEARTBEAT_SCHEDULE=Weekly Wednesday 08:30 — pipeline health, lead velocity, stage conversion
EOF
```

**Note:** Martech channel ID (`C0AT56RRUEP`) is already in `~/guide-core/agent-factory/roles/martech.env` from CHUNK-09.

---

#### Task 3 — Generate all 5 workspaces

Data workspace was already generated in CHUNK-09. Generate the remaining four — but only after their role configs have real channel IDs. Use placeholders only if the workspace is needed for inspection; do not wire a placeholder workspace to a live channel.

```bash
cd ~/guide-core/agent-factory

# Data — already done in CHUNK-09, skip if exists
[[ -d ~/.openclaw/workspace-data ]] && echo "⏭ data workspace exists — skipping" || ./generate.sh data

# Martech — only if channel ID is confirmed in martech.env
grep -q "<MARTECH_CHANNEL_ID>" roles/martech.env \
  && echo "⚠ martech: channel ID not yet confirmed — skipping generate" \
  || ./generate.sh martech

# SEO — only if channel ID is confirmed
grep -q "<SEO_CHANNEL_ID>" roles/seo.env \
  && echo "⚠ seo: channel ID not yet confirmed — skipping generate" \
  || ./generate.sh seo

# Digital Product — only if channel ID is confirmed
grep -q "<PRODUCT_CHANNEL_ID>" roles/product.env \
  && echo "⚠ product: channel ID not yet confirmed — skipping generate" \
  || ./generate.sh product

# HubSpot — only if channel ID is confirmed
grep -q "<HUBSPOT_CHANNEL_ID>" roles/hubspot.env \
  && echo "⚠ hubspot: channel ID not yet confirmed — skipping generate" \
  || ./generate.sh hubspot

echo "Generated workspaces:"
ls ~/.openclaw/ | grep workspace
```

---

#### Task 4 — Verify all generated workspaces

For each workspace that exists, confirm it's clean:

```bash
for role in data martech seo product hubspot; do
  WORKSPACE="$HOME/.openclaw/workspace-$role"
  if [[ -d "$WORKSPACE" ]]; then
    FILE_COUNT=$(ls "$WORKSPACE"/*.md 2>/dev/null | wc -l)
    PLACEHOLDER_COUNT=$(grep -r "{{" "$WORKSPACE/" 2>/dev/null | wc -l)
    echo "$role: $FILE_COUNT files, $PLACEHOLDER_COUNT unreplaced placeholders"
  else
    echo "$role: workspace not yet generated"
  fi
done
```

All generated workspaces should show: 9 files, 0 unreplaced placeholders.

---

#### Task 5 — Register Data agent in openclaw.json

**First verify the exact config schema** (per ADR-016 lesson — always check before adding keys):

```bash
docker run --rm ghcr.io/openclaw/openclaw:latest openclaw config schema 2>/dev/null | grep -A20 -i "agents\|workspace" | head -40
```

Then add the Data agent registration. The exact JSON structure depends on Task 1 findings — use whatever schema field was confirmed. The pattern below assumes `agents` array with `id` + `workspace` fields; adapt if schema differs:

```bash
# Edit the canonical config (never edit live config directly)
# chmod 644 to allow editing, then re-lock after
chmod 644 ~/guide-core/config/openclaw.json

# Add Data agent registration — use python3 to safely edit JSON
python3 << 'PYEOF'
import json, sys

CONFIG_PATH = f"{__import__('os').path.expanduser('~')}/guide-core/config/openclaw.json"

with open(CONFIG_PATH) as f:
    config = json.load(f)

# Add agent if not already present
agents = config.setdefault('agents', [])
agent_ids = [a.get('id') for a in agents]

if 'data' not in agent_ids:
    agents.append({
        "id": "data",
        "workspace": "workspace-data",
        "activated": True,
        "note": "Data Intelligence Agent — #guide-data"
    })
    print("✓ data agent added")
else:
    print("⏭ data agent already registered — skipping")

with open(CONFIG_PATH, 'w') as f:
    json.dump(config, f, indent=2)
PYEOF

chmod 444 ~/guide-core/config/openclaw.json
```

---

#### Task 6 — Wire Data agent to #guide-data

Add the channel binding for Data agent. This routes messages from `#guide-data` to `workspace-data` instead of Guide main.

```bash
chmod 644 ~/guide-core/config/openclaw.json

python3 << 'PYEOF'
import json, os

CONFIG_PATH = os.path.expanduser("~/guide-core/config/openclaw.json")

with open(CONFIG_PATH) as f:
    config = json.load(f)

bindings = config.setdefault('bindings', [])

# Check if binding already exists
existing = [b for b in bindings if b.get('channelId') == 'C0ASP8ZD495']
if not existing:
    bindings.append({
        "channel": "slack",
        "channelId": "C0ASP8ZD495",
        "channelName": "#guide-data",
        "agent": "data",
        "note": "Data agent — wired 2026-04-20"
    })
    print("✓ data binding added")
else:
    print("⏭ data binding already exists — skipping")

with open(CONFIG_PATH, 'w') as f:
    json.dump(config, f, indent=2)
PYEOF

chmod 444 ~/guide-core/config/openclaw.json

# Copy live
cp ~/guide-core/config/openclaw.json ~/.openclaw/openclaw.json
chmod 444 ~/.openclaw/openclaw.json
echo "✓ config copied live"
```

---

#### Task 7 — Follow Slack channel onboarding SOP for Data agent

Step 2 of the SOP: add the channel row to the Data workspace BOOTSTRAP.md channel context table.

```bash
# Unlock, update, re-lock
chmod 644 ~/.openclaw/workspace-data/BOOTSTRAP.md

cat >> ~/.openclaw/workspace-data/BOOTSTRAP.md << 'EOF'

## Channel Context Table

| Channel | ID | Vault CLAUDE.md path |
|---------|----|----------------------|
| #guide-data | C0ASP8ZD495 | ~/Obsidian/Wilderness-Guide/10-Infra/Data/CLAUDE.md |

Load the vault CLAUDE.md for this channel at session start before responding to any message.
EOF

chmod 440 ~/.openclaw/workspace-data/BOOTSTRAP.md
echo "✓ BOOTSTRAP.md channel context table updated"
```

Step 3 — flush the channel session:

```bash
# Flush Slack sessions so Data agent starts fresh with its new context
openclaw sessions flush --channel slack 2>/dev/null \
  || echo "⚠ sessions flush command not available — restart gateway instead"

docker compose -f ~/guide-core/docker/docker-compose.yml restart openclaw
echo "✓ gateway restarted"
```

Step 4 — test before the team uses it:

```bash
echo "Manual test required:"
echo "1. Send a message in #guide-data: 'what is the current data backlog?'"
echo "2. Confirm Data agent responds (not Guide main)"
echo "3. Confirm it can read ~/Obsidian/Wilderness-Guide/10-Infra/Data/"
echo "4. Only mark this step done after a successful vault-grounded response"
```

**Do not proceed to wire other agents until this test passes.**

---

#### Task 8 — Update Guide main BOOTSTRAP.md

Tell Guide main that `#guide-data` is now owned by the Data agent. This prevents the main agent from attempting to also answer messages in that channel.

```bash
chmod 644 ~/.openclaw/workspace/BOOTSTRAP.md

# Append channel ownership table if not already present
grep -q "Channel Ownership" ~/.openclaw/workspace/BOOTSTRAP.md || cat >> ~/.openclaw/workspace/BOOTSTRAP.md << 'EOF'

## Channel Ownership — Dedicated Agents

The following channels are handled by dedicated agents. If a message arrives from these channels, do not respond directly — it is routed to the specialist agent.

| Channel | Agent | Wired Since |
|---------|-------|-------------|
| #guide-data (C0ASP8ZD495) | Data agent (workspace-data) | 2026-04-20 |

EOF

chmod 440 ~/.openclaw/workspace/BOOTSTRAP.md
echo "✓ Guide main BOOTSTRAP.md updated with channel ownership"
```

---

#### Task 9 — Wire remaining agents (incremental — repeat per agent as IDs are confirmed)

For each of Martech, SEO, Digital Product, HubSpot — run this sequence once the channel ID is in the role config:

```bash
# Replace ROLE_ID and CHANNEL_ID with actual values each time
ROLE_ID="seo"          # e.g. seo, martech, product, hubspot
CHANNEL_ID="CXXXXXXXXX" # confirmed Slack channel ID

# 1. Update role config with real channel ID
sed -i '' "s/<.*_CHANNEL_ID>/$CHANNEL_ID/" ~/guide-core/agent-factory/roles/${ROLE_ID}.env

# 2. Generate workspace
cd ~/guide-core/agent-factory && ./generate.sh $ROLE_ID

# 3. Register agent in openclaw.json (same pattern as Task 5)
chmod 644 ~/guide-core/config/openclaw.json
python3 << PYEOF
import json, os
CONFIG_PATH = os.path.expanduser("~/guide-core/config/openclaw.json")
with open(CONFIG_PATH) as f:
    config = json.load(f)
agents = config.setdefault('agents', [])
if '$ROLE_ID' not in [a.get('id') for a in agents]:
    agents.append({"id": "$ROLE_ID", "workspace": "workspace-$ROLE_ID", "activated": True})
    print("✓ $ROLE_ID agent added")
with open(CONFIG_PATH, 'w') as f:
    json.dump(config, f, indent=2)
PYEOF
chmod 444 ~/guide-core/config/openclaw.json

# 4. Add channel binding (same pattern as Task 6)
# 5. Follow SOP steps 2-4 (update BOOTSTRAP.md, flush session, test)
# 6. Update Guide main BOOTSTRAP.md channel ownership table (same pattern as Task 8)
# 7. Copy config live and restart gateway
# 8. Update __CONFIG/GUIDE.md with confirmed channel ID
```

**Special case — Digital Product agent has two channels.** After wiring the primary binding (`C0AUT4WSPBJ`), add a second binding for `#guide-digital-product`:

```bash
# Second binding for product agent — #guide-digital-product (main channel)
chmod 644 ~/guide-core/config/openclaw.json
python3 << PYEOF
import json, os
CONFIG_PATH = os.path.expanduser("~/guide-core/config/openclaw.json")
with open(CONFIG_PATH) as f:
    config = json.load(f)
bindings = config.setdefault('bindings', [])
if 'C0ATLTNFF0X' not in [b.get('channelId') for b in bindings]:
    bindings.append({
        "channel": "slack",
        "channelId": "C0ATLTNFF0X",
        "channelName": "#guide-digital-product",
        "agent": "product",
        "note": "Digital Product agent — main channel (both channels route to workspace-product)"
    })
    print("✓ second product binding added")
with open(CONFIG_PATH, 'w') as f:
    json.dump(config, f, indent=2)
PYEOF
chmod 444 ~/guide-core/config/openclaw.json
cp ~/guide-core/config/openclaw.json ~/.openclaw/openclaw.json
chmod 444 ~/.openclaw/openclaw.json
```

Also add both channels to `workspace-product/BOOTSTRAP.md` channel context table (SOP step 2):

```bash
chmod 644 ~/.openclaw/workspace-product/BOOTSTRAP.md
cat >> ~/.openclaw/workspace-product/BOOTSTRAP.md << 'EOF'

## Channel Context Table

| Channel | ID | Vault CLAUDE.md path |
|---------|----|----------------------|
| #guide-digital-product | C0ATLTNFF0X | ~/Obsidian/Wilderness-Guide/25-Channels/Digital-Product/CLAUDE.md |
| #guide-digital-product-triage | C0AUT4WSPBJ | ~/Obsidian/Wilderness-Guide/25-Channels/Digital-Product/CLAUDE.md |

Both channels route to this agent. Context is shared across both.
EOF
chmod 440 ~/.openclaw/workspace-product/BOOTSTRAP.md
```

Repeat for each remaining agent. Test before announcing to the team. Update the Blocking Items table at the top of this chunk as each one goes live.

---

#### Task 10 — Update __CONFIG/GUIDE.md with confirmed channel IDs

As each channel is confirmed and wired, add the ID to the canonical config:

```bash
# Edit ~/guide-core/config/ or the vault file directly
# Add rows to the Slack channels table in __CONFIG/GUIDE.md
# e.g.:
# | `#guide-martech` channel | `CXXXXXXXXX` | ✅ Wired to Martech agent |
```

---

### Verification Gate

```bash
echo "=== Workspace check ==="
for role in data martech seo product hubspot; do
  WORKSPACE="$HOME/.openclaw/workspace-$role"
  if [[ -d "$WORKSPACE" ]]; then
    FILE_COUNT=$(ls "$WORKSPACE"/*.md 2>/dev/null | wc -l)
    echo "✓ workspace-$role: $FILE_COUNT files"
  else
    echo "⏳ workspace-$role: not yet generated (blocked on channel ID)"
  fi
done

echo ""
echo "=== Agent registration ==="
cat ~/.openclaw/openclaw.json | python3 -c "
import sys, json
d = json.load(sys.stdin)
agents = d.get('agents', [])
for role in ['data', 'martech', 'seo', 'product', 'hubspot']:
    found = any(a.get('id') == role for a in agents)
    print(f'{'✓' if found else '⏳'} agent: {role}')
"

echo ""
echo "=== Channel bindings ==="
cat ~/.openclaw/openclaw.json | python3 -c "
import sys, json
d = json.load(sys.stdin)
bindings = d.get('bindings', [])
slack_bindings = [b for b in bindings if b.get('channel') == 'slack']
for b in slack_bindings:
    print(f'✓ {b.get(\"channelName\", b.get(\"channelId\"))} → {b.get(\"agent\")}')
"

echo ""
echo "=== SOP compliance ==="
for role in data martech seo product hubspot; do
  BOOTSTRAP="$HOME/.openclaw/workspace-$role/BOOTSTRAP.md"
  if [[ -f "$BOOTSTRAP" ]]; then
    grep -q "Channel Context Table" "$BOOTSTRAP" \
      && echo "✓ $role: channel context table present" \
      || echo "✗ $role: channel context table MISSING — SOP step 2 incomplete"
  fi
done
```

---

### Rollback

```bash
# Remove a specific agent workspace
rm -rf ~/.openclaw/workspace-{role}

# Remove agent registration and binding from openclaw.json (edit canonical, copy live)
# Restart gateway
# Revert Guide main BOOTSTRAP.md channel ownership table entry
```

---

### Git Commit

```bash
cd ~/guide-core
git add agent-factory/roles/
git commit -m "feat(chunk-10): channel agent role configs — data, martech, seo, product, hubspot"
git push
# Note: workspace dirs (~/.openclaw/workspace-*) are machine-local — do not commit
```

---

### Handoff to CHUNK-11

CHUNK-11 (Paperclip) expects:
- At minimum, Data agent live and responding in `#guide-data` ✅
- SEO agent live and responding in its channel (needed for the demo POC)
- Both agents accessible as named entities for Paperclip to reference in its org chart

If SEO channel ID is still not confirmed when CHUNK-11 begins — proceed with Data agent only for the Paperclip wiring. The demo still works with one live agent.

---

### Known Unknowns

1. **Multi-agent routing schema** — exact `openclaw.json` structure for per-channel agent routing must be confirmed from CHUNK-09 Task 1 findings before Tasks 5–6. If the `bindings[].agent` field doesn't work as expected, the wiring pattern in Tasks 5–9 needs adapting.
2. **Session isolation** — confirm that wiring `#guide-data` to `workspace-data` means Guide main no longer receives those messages. If both agents receive the message and both respond, a deny-list or channel exclusion on Guide main may be needed.

---

*Created: 2026-04-20*
