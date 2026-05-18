---
title: "CHUNK-11-paperclip"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: pending
---
# CHUNK-11 — Paperclip
## GUIDE Build System | Phase 1 | Context Fix + Demo

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.
> **Model note:** This chunk involves architectural decisions about a new control plane. If uncertain about any step, surface the question to Gareth before proceeding — do not guess.

---

### What This Chunk Does

Installs Paperclip alongside Guide and configures a demo-ready POC for the Keith & Nick presentation. Paperclip is the agent control plane — it externalises the company structure, governance, and budget oversight that currently lives in Gareth's head.

This chunk does not change how OpenClaw runs. It adds a governance layer on top: Gareth's board dashboard, an org chart for Wilderness Group Digital, and at least one live heartbeat from a channel agent.

**Scope (POC only — not full production org chart):**
- Wilderness Group Digital company created in Paperclip
- Gareth as board chairman
- Guide Main as COO
- Data Agent wired as a department (always unblocked — channel ID confirmed)
- SEO Agent wired as second department (`#seo-guide` `C0ATXQ8MDS5` confirmed)
- At least one heartbeat firing and visible in the dashboard

**What the demo shows Keith & Nick:**
1. Isolated channel agents → no context bleed (CHUNK-09/10 deliverable)
2. Paperclip org chart → Wilderness Group Digital with AI agents as its team
3. Live heartbeat → one agent checking in autonomously, no human trigger
4. Board dashboard → Gareth reviews agent status, not agent conversations

**Success state:** Paperclip is accessible via Tailscale (`https://guide.tailfbf66e.ts.net:XXXX` or a named route). The Wilderness Group Digital company exists with at least Data Agent registered, one heartbeat has fired, and the org chart is visible in the Paperclip UI.

---

### Prerequisites

- [ ] CHUNK-09 complete — agent factory working, `generate.sh` tested
- [ ] CHUNK-10 complete — Data Agent live in `#guide-data`, workspace at `~/.openclaw/workspace-data/`
- [ ] CHUNK-07 complete (security hardened)
- [ ] Guide machine healthy — `openclaw gateway status` returns running
- [x] SEO channel ID confirmed — `#seo-guide` `C0ATXQ8MDS5` ✅
- [ ] Docker Desktop running on Guide machine

---

### Deliverables

1. Paperclip Docker container running on Guide, bound to `127.0.0.1`
2. Paperclip port added to `_CONVENTIONS.md` service table
3. `~/guide-core/paperclip/docker-compose.yml` — Paperclip service definition, committed to `guide-core`
4. `~/guide-core/paperclip/company.md` — human-readable record of the company structure (org chart, agent registrations, heartbeat schedule)
5. Wilderness Group Digital company created in Paperclip with Gareth as chairman and Guide Main as COO
6. At least Data Agent registered as a department in Paperclip
7. At least one heartbeat configured and confirmed to have fired (visible in dashboard or logs)
8. Paperclip accessible via Tailscale for demo

---

### Environment Variables Required

```
PAPERCLIP_PORT=3100               # Paperclip UI/API — must not conflict with existing services
PAPERCLIP_ADMIN_EMAIL=<Gareth's email>
PAPERCLIP_ADMIN_PASSWORD=<secure password — store in ~/.openclaw/credentials/>
OPENCLAW_GATEWAY_URL=http://127.0.0.1:18789   # How Paperclip calls OpenClaw agents
```

> **Note:** Store `PAPERCLIP_ADMIN_PASSWORD` in `~/.openclaw/credentials/paperclip.env`, not in any committed file. Never add to `openclaw.json`.

---

### Tasks

#### Task 1: Research Paperclip install — GATE before any other task

Before writing any config, read the actual Paperclip documentation and CLI:

```bash
# Check if Paperclip CLI is available
command -v paperclip && paperclip --version || echo "not installed"

# Check Docker Hub / paperclip registry for current image tag
docker search paperclip | grep -i paperclip
# or
curl -s "https://hub.docker.com/v2/repositories/paperclip/paperclip/tags/?page_size=5" \
  | python3 -c "import sys,json; [print(t['name']) for t in json.load(sys.stdin).get('results',[])]"

# If Paperclip has a CLI, check available commands
paperclip --help 2>/dev/null || echo "CLI not available — API/UI configuration"
```

Document findings in `~/.openclaw/workspace/signals/→architect.md` under the heading `## CHUNK-11 Paperclip Research`:
- Correct Docker image name and tag
- Correct port(s) Paperclip uses
- How agents are registered (UI, API, config file?)
- How heartbeats are configured (cron syntax? Paperclip-specific format?)
- How Paperclip connects to OpenClaw (webhook? API call? Slack message?)
- Any `docker-compose.yml` example from official docs

**If the integration mechanism between Paperclip and OpenClaw is not documented clearly:** surface this to Gareth before proceeding with Tasks 3+. Do not assume.

---

#### Task 2: Check for port conflicts and add Paperclip to _CONVENTIONS.md

```bash
# Check no service is on 3100
lsof -i :3100 2>/dev/null || echo "port 3100 free"

# If 3100 is taken, try 3101, 3200 — pick the first free one
# Record the chosen port as $PAPERCLIP_PORT for the rest of this chunk
```

Once port is confirmed, update the Service Ports table in `BUILD/DEV-CHUNKS/_CONVENTIONS.md`:

Add a row for Paperclip:
```
| Paperclip | 3100 | 127.0.0.1 | Phase 1 |
```

Update status field to match whatever phase Paperclip was added — remove "Planned" tag once live.

---

#### Task 3: Create Paperclip directory and credentials

```bash
# Create directory
mkdir -p ~/guide-core/paperclip

# Store credentials — never in git
cat > ~/.openclaw/credentials/paperclip.env << 'EOF'
PAPERCLIP_ADMIN_EMAIL=<gareth_email_from_GUIDE.md>
PAPERCLIP_ADMIN_PASSWORD=<generate a strong password: openssl rand -base64 24>
EOF
chmod 600 ~/.openclaw/credentials/paperclip.env
```

> **How to get Gareth's email:** Read `~/.openclaw/workspace/USER.md` — it lists Gareth's contact details. Do not hardcode.

---

#### Task 4: Write `~/guide-core/paperclip/docker-compose.yml`

Base the compose file on findings from Task 1. If official Paperclip docs provide an example, fork it directly.

Minimum requirements for the compose file:
- Service bound to `127.0.0.1:${PAPERCLIP_PORT}` — not `0.0.0.0`
- `restart: unless-stopped`
- Named volume for Paperclip data persistence (not a bind mount to host paths)
- Health check defined
- Loads credentials from `~/.openclaw/credentials/paperclip.env` (not hardcoded)
- Does NOT share the OpenClaw network bridge unless Paperclip → OpenClaw API calls require it (check Task 1 findings)

```bash
# Idempotency check
[[ -f ~/guide-core/paperclip/docker-compose.yml ]] && echo "compose already exists — review before overwriting" && exit 0
```

After writing:
```bash
# Validate compose syntax
docker compose -f ~/guide-core/paperclip/docker-compose.yml config --quiet \
  && echo "✓ compose valid" || echo "✗ compose invalid"
```

---

#### Task 5: Start Paperclip

```bash
# Source credentials
set -a; source ~/.openclaw/credentials/paperclip.env; set +a

# Start
docker compose -f ~/guide-core/paperclip/docker-compose.yml up -d

# Wait for healthy
for i in $(seq 1 12); do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' paperclip 2>/dev/null)
  [[ "$STATUS" == "healthy" ]] && echo "✓ Paperclip healthy" && break
  echo "Waiting... ($i/12) — status: ${STATUS:-starting}"
  sleep 5
done
[[ "$STATUS" != "healthy" ]] && echo "✗ Paperclip failed to reach healthy state — check: docker logs paperclip" && exit 1
```

---

#### Task 6: Create Wilderness Group Digital company

This step depends on how Paperclip accepts configuration — check Task 1 findings:

**Option A: If Paperclip has a CLI:**
```bash
paperclip company create \
  --name "Wilderness Group Digital" \
  --description "Digital marketing and AI operations team for Wilderness Safaris Group" \
  --chairman "Gareth Knight"
```

**Option B: If Paperclip is configured via API (most likely):**
```bash
# Authenticate
PAPERCLIP_TOKEN=$(curl -s -X POST "http://127.0.0.1:${PAPERCLIP_PORT}/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${PAPERCLIP_ADMIN_EMAIL}\",\"password\":\"${PAPERCLIP_ADMIN_PASSWORD}\"}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")

# Create company
curl -s -X POST "http://127.0.0.1:${PAPERCLIP_PORT}/api/companies" \
  -H "Authorization: Bearer ${PAPERCLIP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Wilderness Group Digital",
    "description": "Digital marketing and AI operations — Wilderness Safaris Group",
    "chairman": "Gareth Knight"
  }' | python3 -c "import sys,json; d=json.load(sys.stdin); print('Company ID:', d.get('id','unknown'))"
```

**Option C: If Paperclip is UI-only (no API / CLI):**
- Record steps for Gareth to complete manually in `~/guide-core/paperclip/company.md`
- Note this in `→architect.md` — Architect needs to decide whether to automate or accept manual setup

> Whichever option is used — record the Company ID in `~/guide-core/paperclip/company.md` for reference.

---

#### Task 7: Configure org chart — board and C-suite

Add board member and COO. Adapt API paths to Task 1 findings.

**Board (Gareth as Chairman):**
```bash
# Get company ID from company.md or re-query
COMPANY_ID=$(cat ~/guide-core/paperclip/company.md | grep "Company ID:" | awk '{print $NF}')

curl -s -X POST "http://127.0.0.1:${PAPERCLIP_PORT}/api/companies/${COMPANY_ID}/members" \
  -H "Authorization: Bearer ${PAPERCLIP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Gareth Knight",
    "role": "Chairman",
    "tier": "board",
    "type": "human"
  }'
```

**COO (Guide Main):**
```bash
curl -s -X POST "http://127.0.0.1:${PAPERCLIP_PORT}/api/companies/${COMPANY_ID}/members" \
  -H "Authorization: Bearer ${PAPERCLIP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Guide",
    "role": "Chief of Staff / COO",
    "tier": "c-suite",
    "type": "agent",
    "runtime": "openclaw",
    "workspace": "main"
  }'
```

---

#### Task 8: Register Data Agent as first department

```bash
# Register Data Department and wire to Data Agent workspace
curl -s -X POST "http://127.0.0.1:${PAPERCLIP_PORT}/api/companies/${COMPANY_ID}/departments" \
  -H "Authorization: Bearer ${PAPERCLIP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Data",
    "description": "Data infrastructure, ETL health, and analytics observation — #guide-data",
    "head": {
      "name": "Data Agent",
      "type": "agent",
      "runtime": "openclaw",
      "workspace": "data",
      "slack_channel": "C0ASP8ZD495"
    }
  }' | python3 -c "import sys,json; d=json.load(sys.stdin); print('Dept ID:', d.get('id','unknown'))"
```

**SEO channel ID confirmed (`C0ATXQ8MDS5`) — wire SEO department:**
```bash
SEO_CHANNEL_ID="<confirmed_id_from_architect_signal>"

curl -s -X POST "http://127.0.0.1:${PAPERCLIP_PORT}/api/companies/${COMPANY_ID}/departments" \
  -H "Authorization: Bearer ${PAPERCLIP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"SEO\",
    \"description\": \"Organic search — rankings, technical audits, content. Wilderness Safaris.\",
    \"head\": {
      \"name\": \"SEO Agent\",
      \"type\": \"agent\",
      \"runtime\": \"openclaw\",
      \"workspace\": \"seo-ws\",
      \"slack_channel\": \"${SEO_CHANNEL_ID}\"
    }
  }"
```

**Guard — skip if placeholder:**
```bash
grep -q "<confirmed_id" <<< "${SEO_CHANNEL_ID:-<confirmed_id_placeholder>}" \
  && echo "⚠ SEO channel ID not yet confirmed — skipping SEO department registration" \
  || echo "✓ SEO department registered"
```

---

#### Task 9: Configure heartbeat(s)

A heartbeat is a scheduled check-in from an agent to Paperclip — the governance equivalent of OpenClaw cron. Paperclip records the result; if an agent misses too many, the dashboard alerts.

**How heartbeats work in the POC:**

Option A — Paperclip triggers OpenClaw (if Paperclip supports outbound webhooks to OpenClaw gateway):
```bash
# Paperclip calls OpenClaw gateway on schedule → OpenClaw runs agent → returns status
# Check Task 1 findings for whether Paperclip supports outbound webhook triggers
```

Option B — OpenClaw calls Paperclip (if Paperclip has an inbound heartbeat API):
```bash
# Add a cron job to OpenClaw that posts a heartbeat payload to Paperclip after each run
# This is the simpler and more likely pattern for POC
```

Option C — Add a shell cron job that pings Paperclip's heartbeat endpoint directly:
```bash
# Create a heartbeat script
cat > ~/guide-core/paperclip/heartbeat-data.sh << 'EOF'
#!/bin/bash
set -euo pipefail
source ~/.openclaw/credentials/paperclip.env

# Get auth token
TOKEN=$(curl -s -X POST "http://127.0.0.1:3100/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${PAPERCLIP_ADMIN_EMAIL}\",\"password\":\"${PAPERCLIP_ADMIN_PASSWORD}\"}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")

# Post heartbeat
curl -s -X POST "http://127.0.0.1:3100/api/heartbeats" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "agent": "data",
    "status": "ok",
    "message": "Data Agent active — #guide-data monitored",
    "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
  }'
echo "Heartbeat sent: $(date)"
EOF
chmod +x ~/guide-core/paperclip/heartbeat-data.sh
```

Register in macOS crontab (runs every 15 minutes for POC demo visibility):
```bash
# Check if already registered
crontab -l 2>/dev/null | grep -q "heartbeat-data.sh" \
  && echo "heartbeat crontab already registered" \
  || (crontab -l 2>/dev/null; echo "*/15 * * * * /bin/bash ~/guide-core/paperclip/heartbeat-data.sh >> /tmp/guide-paperclip-heartbeat.log 2>&1") | crontab -
```

> **Adapt based on Task 1 findings.** Use whichever option Paperclip natively supports. If Option A (Paperclip-triggered) is available, prefer it over shell cron — it puts the schedule under Paperclip's governance, not outside it.

---

#### Task 10: Expose Paperclip via Tailscale for demo access

Paperclip is bound to `127.0.0.1`. To access it from Gareth's laptop for the demo, route it through Tailscale Serve (same pattern as OpenClaw TUI).

```bash
# Check current Tailscale Serve config
tailscale serve status

# Add Paperclip to Tailscale Serve on a dedicated path (so it doesn't conflict with OpenClaw on /)
# Pattern: https://guide.tailfbf66e.ts.net/paperclip → http://127.0.0.1:3100
tailscale serve --bg /paperclip http://127.0.0.1:${PAPERCLIP_PORT}

# Verify accessible
curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${PAPERCLIP_PORT}" \
  && echo "✓ Paperclip responding locally"
```

> **Security:** `tailscale serve` routes over the tailnet only — not public internet. This is correct. Never use `tailscale funnel` (see _CONVENTIONS.md Security Non-Negotiables).

---

#### Task 11: Write `~/guide-core/paperclip/company.md`

Record the full configuration as a human-readable document. This is the source of truth for the Paperclip org chart — update it when agents are added or the structure changes.

```bash
cat > ~/guide-core/paperclip/company.md << 'EOF'
# Paperclip — Wilderness Group Digital

## Company
- **Name:** Wilderness Group Digital
- **Created:** <date>
- **Company ID:** <ID from Task 6>
- **Paperclip URL:** https://guide.tailfbf66e.ts.net/paperclip

## Board
| Name | Role | Type |
|------|------|------|
| Gareth Knight | Chairman | Human |

## C-Suite
| Agent | Role | Runtime | Workspace |
|-------|------|---------|-----------|
| Guide | Chief of Staff / COO | OpenClaw | main |

## Departments (POC)
| Department | Agent | OpenClaw Workspace | Slack Channel | Status |
|------------|-------|-------------------|---------------|--------|
| Data | Data Agent | workspace-data | #guide-data (C0ASP8ZD495) | ✅ Live |
| SEO | SEO Agent | workspace-seo-ws | #seo-guide (C0ATXQ8MDS5) | ⬜ Wire once SEO agent is live in CHUNK-10 |

## Full Org Chart (Phase 3 target)
See `Notes/2026-04-18 Guide × Hermes × Paperclip Strategic Briefing.md` — Section 3.

## Heartbeats
| Agent | Schedule | Type | Log |
|-------|----------|------|-----|
| Data | */15 * * * * | shell cron → Paperclip API | /tmp/guide-paperclip-heartbeat.log |

## Notes
- Departments to add post-demo (CHUNK-10 must wire them first): Martech, Digital Product, HubSpot
- Budget governance: to be configured in Phase 3 once agent costs are profiled
- Full org chart: activate when Phase 3 agent count exceeds 8
EOF
```

---

#### Task 12: Trigger manual heartbeat and verify in dashboard

Before committing, confirm the heartbeat is visible end-to-end:

```bash
# Fire a manual heartbeat
bash ~/guide-core/paperclip/heartbeat-data.sh

# Confirm it appears in logs
tail -5 /tmp/guide-paperclip-heartbeat.log

# Optional: query the Paperclip API for the most recent heartbeat
curl -s "http://127.0.0.1:${PAPERCLIP_PORT}/api/heartbeats?agent=data&limit=3" \
  -H "Authorization: Bearer ${PAPERCLIP_TOKEN}" \
  | python3 -m json.tool
```

This is the final pre-commit check. The Paperclip dashboard must show at least one heartbeat from Data Agent before this chunk is considered complete.

---

#### Task 13: Commit

```bash
cd ~/guide-core
git add paperclip/
git add paperclip/company.md
git status

git commit -m "feat(chunk-11): paperclip POC — Wilderness Group Digital company, Data agent dept, heartbeat live"
git push
```

---

### Verification Gate

Run after all tasks. All checks must print ✓ before this chunk is complete.

```bash
echo "=== CHUNK-11 Verification Gate ==="

# 1. Paperclip container running
docker ps --filter name=paperclip --format "{{.Names}} {{.Status}}" \
  | grep -q "Up" && echo "✓ Paperclip container running" || echo "✗ Paperclip container not running"

# 2. Paperclip responds on expected port
PAPERCLIP_PORT=${PAPERCLIP_PORT:-3100}
curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${PAPERCLIP_PORT}" \
  | grep -qE "^(200|302|401)" && echo "✓ Paperclip HTTP responding" || echo "✗ Paperclip HTTP not responding"

# 3. company.md exists
[[ -f ~/guide-core/paperclip/company.md ]] && echo "✓ company.md exists" || echo "✗ company.md missing"

# 4. Company ID recorded in company.md (not placeholder)
grep -q "Company ID:" ~/guide-core/paperclip/company.md \
  && ! grep -q "<ID from Task 6>" ~/guide-core/paperclip/company.md \
  && echo "✓ Company ID recorded" || echo "✗ Company ID is placeholder — not yet created"

# 5. Data department registered (verify via company.md)
grep -q "Data Agent" ~/guide-core/paperclip/company.md \
  && grep -q "✅ Live" ~/guide-core/paperclip/company.md \
  && echo "✓ Data department registered" || echo "✗ Data department not yet live"

# 6. Heartbeat script exists and is executable
[[ -x ~/guide-core/paperclip/heartbeat-data.sh ]] \
  && echo "✓ heartbeat-data.sh exists and is executable" || echo "✗ heartbeat script missing"

# 7. Heartbeat log exists and has at least one entry
[[ -s /tmp/guide-paperclip-heartbeat.log ]] \
  && echo "✓ Heartbeat log has entries" || echo "✗ Heartbeat log empty — fire a manual heartbeat"

# 8. Heartbeat registered in crontab
crontab -l 2>/dev/null | grep -q "heartbeat-data.sh" \
  && echo "✓ Heartbeat in crontab" || echo "✗ Heartbeat not in crontab"

# 9. Tailscale Serve exposes Paperclip
tailscale serve status 2>/dev/null | grep -q "paperclip\|${PAPERCLIP_PORT}" \
  && echo "✓ Paperclip exposed via Tailscale Serve" || echo "✗ Paperclip not in Tailscale Serve"

# 10. Credentials not in git
git -C ~/guide-core ls-files ~/.openclaw/credentials/ 2>/dev/null | grep -q "." \
  && echo "✗ WARNING: credentials may be tracked in git" || echo "✓ Credentials not in git"

# 11. _CONVENTIONS.md updated with Paperclip port
grep -q "Paperclip" ~/Obsidian/Wilderness-Guide/20-Projects/Guide/BUILD/DEV-CHUNKS/_CONVENTIONS.md \
  && echo "✓ _CONVENTIONS.md has Paperclip port entry" || echo "✗ _CONVENTIONS.md not updated"

echo "=== Gate complete ==="
```

---

### Known Unknowns

These items could not be confirmed at spec time. Task 1 must resolve them before Tasks 3+ proceed.

| Unknown | Impact | Resolution |
|---------|--------|-----------|
| Paperclip Docker image name and tag | Blocks Task 4 compose file | Task 1 research |
| How Paperclip registers agents (UI / API / config) | Determines Tasks 6–8 approach | Task 1 research |
| How Paperclip connects to OpenClaw | Determines heartbeat pattern (Task 9) | Task 1 research |
| API authentication format | Affects all API calls | Task 1 research |
| SEO channel ID | ✅ Confirmed — `C0ATXQ8MDS5` | No action needed |

**If Paperclip is UI-only (no API/CLI):** Record the manual setup steps in `company.md` and `→architect.md`. Flag to Gareth — the heartbeat automation in Task 9 will need adaptation, but the demo can still proceed with manual configuration.

---

### Demo Flow (Keith & Nick)

Gareth opens `https://guide.tailfbf66e.ts.net/paperclip` on his laptop.

1. **Company view** — "Wilderness Group Digital" org chart shows. Gareth points to the board (himself), the COO (Guide), and the Data department.
2. **Heartbeat view** — Live heartbeat log shows Data Agent checking in every 15 minutes. "This agent is running autonomously — no human trigger."
3. **Context isolation** (back in Slack) — Send a message to `#guide-data`. Data Agent responds. Then show `#general` — Guide Main responds. Different agents, isolated contexts, no bleed.
4. **The pitch** — "This is the governance layer. As we add agents for SEO, Martech, HubSpot — each one appears here. Gareth stops being the dispatcher and becomes the board chairman."

---

### Rollback

```bash
# Stop and remove Paperclip container
docker compose -f ~/guide-core/paperclip/docker-compose.yml down

# Remove from Tailscale Serve
tailscale serve --remove /paperclip

# Remove heartbeat from crontab
crontab -l | grep -v "heartbeat-data.sh" | crontab -

# Remove Paperclip data volume (DESTRUCTIVE — company config is lost)
# Only run this if a full rollback is needed:
# docker volume rm paperclip_data

# OpenClaw is unaffected — it has no dependency on Paperclip
openclaw gateway status
```

---

### Git Commit

```bash
cd ~/guide-core
git add paperclip/
git commit -m "feat(chunk-11): paperclip POC — Wilderness Group Digital, Data dept, heartbeat live"
git push
```

---

### Handoff to CHUNK-12

CHUNK-12 is the Briefing Agent — the demo output layer that delivers daily performance digests, weekly summaries, and monthly board packs.

**What CHUNK-12 expects from this chunk:**
- Paperclip running and accessible
- At least Data Agent registered as a department
- Heartbeat firing regularly (CHUNK-12 briefing agent will aggregate heartbeat status as part of its daily output)

**Outstanding items to track:**
- SEO department: register once SEO channel ID is confirmed (see Blocking Items in CHUNK-10)
- Martech, Digital Product, HubSpot departments: register as remaining channel IDs come in
- Budget governance: configure per-agent token budgets once Phase 1 cost profile is known (Phase 3 backlog item)
- Full org chart: build out in Phase 3 once agent count warrants it — see `Notes/2026-04-18 Guide × Hermes × Paperclip Strategic Briefing.md` Section 3 for the target org chart

**Signal to leave for Architect:**
After completing this chunk, write a brief in `~/.openclaw/workspace/signals/→architect.md` under `## CHUNK-11 Complete`:
- Which agents are registered in Paperclip
- Which heartbeat pattern was used (Option A/B/C from Task 9)
- Any gaps between the spec and actual Paperclip capability discovered during build
- Recommended next wiring steps for CHUNK-12

---

*Written: 2026-04-20 | Architect session — Phase 1 Demo build*
