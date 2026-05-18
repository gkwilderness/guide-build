---
title: "CHUNK-08-cron-ops"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: pending
---
# CHUNK-08 — Cron & Ops
## GUIDE Build System | Phase 0 | Foundation

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.

---

### Pre-Chunk Work (applied outside chunk — do not repeat)

The following were applied in ad-hoc sessions before CHUNK-08 was executed. The Engineer must check these exist and skip them rather than overwriting:

| Item | What | Applied |
|------|------|---------|
| `~/scripts/openclaw-backup.sh` | Daily 4am crontab backup of `~/.openclaw/` to `~/openclaw-backups/`, 30-day retention | 2026-04-20 |
| `session.maintenance` in `openclaw.json` | `mode: enforce`, `pruneDays: 7`, `resetArchiveRetention: 7d` | 2026-04-20 |
| `cron.sessionRetention` in `openclaw.json` | `7d` (was `24h`) | 2026-04-20 |

---

### What This Chunk Does

Configures the cron schedule, health checks, and operational monitoring. Establishes the 7 scheduled jobs from the project brief and sets up pipeline health monitoring.

**Success state:** 7 cron jobs registered in OpenClaw. Morning brief fires at 08:00. Health check fires at 09:00 (silent if healthy). All jobs use Haiku model. Cron history is being recorded.

---

### Prerequisites

- [ ] CHUNK-07 complete (security hardened, audit logging active)
- [ ] Guide agent operational with identity
- [ ] Telegram bot working
- [ ] Slack channels created (#guide-ops)

---

### Deliverables

1. Cron prompt files written and committed in `~/guide-core/prompts/cron/` (one file per job)
2. 7 OpenClaw cron jobs registered — each pointing to its prompt file, not inline content
3. All cron jobs use Haiku model (cost-efficient)
4. All cron jobs use isolated sessions (no context bleed)
5. Schedule staggered: data fetch at 06:00, briefs from 07:30, ≥5 min gap between heavy jobs
6. Health check job: silent if green, reports to #guide-ops if issues
7. Workspace git sync: `~/.openclaw/workspace/` is a git repo, syncing to `guide-workspace` on a crontab schedule
8. Cron health monitoring script at `~/guide-core/scripts/cron-health.sh`
9. Operational runbook for cron management

---

### Tasks

#### Task 1 — Create cron prompt files

All cron prompts live as versioned files in `~/guide-core/prompts/cron/`. Each job's `--message` is a single file-reference instruction. The `guide-core` Docker mount is `:ro` — Guide can read but not modify prompt files. No gateway restart needed when editing a prompt.

**Reference:** `~/jarvis-core/prompts/cron/` has 19 live prompts — fork content from there.

```bash
mkdir -p ~/guide-core/prompts/cron
```

Write each file:

```bash
cat > ~/guide-core/prompts/cron/etl-daily-refresh.md << 'EOF'
# ETL Daily Refresh

Trigger daily ETL refresh for all connected data sources. Check each source connector for last-run status. Log results to the pipeline health log. Report only on failure — if all sources refreshed successfully, stay silent.
EOF

cat > ~/guide-core/prompts/cron/performance-morning-brief.md << 'EOF'
# Performance Morning Brief

Generate a morning performance brief for the Guide team leads group.

Check data freshness from Pipeline agent outputs. Summarise:
- Key metrics movement across WS/Jacada/YZ (24h)
- Any anomalies or alerts
- Today's top 3 priorities for the team

Format for Telegram. Keep under 300 words. Direct, no filler.
EOF

cat > ~/guide-core/prompts/cron/gareth-strategic-brief.md << 'EOF'
# Gareth Strategic Brief

Generate a strategic morning brief for Gareth (Telegram DM).

Include:
- Overnight performance summary across WS/Jacada/YZ
- Any alerts from Pipeline agent
- Today's scheduled meetings or key events (from calendar if available)
- Top 3 decisions or actions needed today

Format for Telegram DM. Keep under 400 words. Lead with the most important item.
EOF

cat > ~/guide-core/prompts/cron/pipeline-health-check.md << 'EOF'
# Pipeline Health Check

Run a pipeline health check across all connected data sources.

Verify:
- ETL last run times (flag any source not refreshed in >25 hours)
- Data freshness per source
- Any failed jobs in the last 24 hours
- Disk usage on Guide machine (flag if >80%)

Report ONLY if issues found. If all green, stay silent. Report to #guide-ops.
EOF

cat > ~/guide-core/prompts/cron/midday-anomaly-scan.md << 'EOF'
# Midday Anomaly Scan

Run a midday anomaly scan across all connected data sources.

Check for:
- Spend spikes >20% vs prior day same time
- Conversion rate drops >15%
- Traffic anomalies (volume or source mix)
- Any new pipeline alerts since morning

Report ONLY if anomalies found. If clean, stay silent. Report to team leads group.
EOF

cat > ~/guide-core/prompts/cron/weekly-performance-summary.md << 'EOF'
# Weekly Performance Summary

Generate a weekly performance summary for the executive team.

Include:
- WoW performance by brand (WS/Jacada/YZ) — leads, spend, conversions
- Media spend vs weekly budget
- Conversion trend (improving/declining/flat)
- Top wins this week
- Top risks or flags for next week

Use capital allocation language. Format for WhatsApp. Keep under 500 words.
EOF

cat > ~/guide-core/prompts/cron/monthly-board-digest.md << 'EOF'
# Monthly Board Digest

Generate a monthly board digest for Gareth's review before executive distribution.

Include:
- MoM performance by brand (WS/Jacada/YZ)
- Capital allocation efficiency (spend vs lead volume vs pipeline value)
- Media ROI summary
- Pipeline velocity (leads → enquiries → bookings)
- Competitive landscape summary if data available

Board-ready language. Nick responds to capital allocation framing — lead with that. Keep under 800 words.
EOF
```

Commit before registering jobs:

```bash
cd ~/guide-core && git add prompts/ && git commit -m "feat(chunk-08): add cron prompt files" && git push
```

---

#### Task 2 — Register cron jobs

Each job references its prompt file. The message is a file-read instruction only — never inline content.

**Determine the `guide-core` mount path inside the container before running:**
```bash
docker inspect openclaw | python3 -c "import sys,json; mounts=[m for m in json.load(sys.stdin)[0]['Mounts'] if 'guide-core' in m['Source']]; print(mounts[0]['Destination'] if mounts else 'not found')"
```
Replace `/home/<user>/guide-core` in the commands below with the actual container-internal path.

```bash
# Job 1: ETL refresh (daily, silent — data fetch FIRST, before any brief jobs)
openclaw cron add \
  --name "etl-daily-refresh" \
  --cron "0 6 * * *" \
  --tz "Europe/London" \
  --agent main \
  --session isolated \
  --model "anthropic/claude-haiku-4-5" \
  --message "Read the file at /home/<user>/guide-core/prompts/cron/etl-daily-refresh.md and follow the instructions exactly." \
  --timeout-seconds 300

# Job 2: Performance morning brief — 07:30 (after ETL at 06:00)
openclaw cron add \
  --name "performance-morning-brief" \
  --cron "30 7 * * 1-5" \
  --tz "Europe/London" \
  --agent main \
  --session isolated \
  --model "anthropic/claude-haiku-4-5" \
  --message "Read the file at /home/<user>/guide-core/prompts/cron/performance-morning-brief.md and follow the instructions exactly." \
  --to "<TEAM_LEAD_GROUP_ID>" \
  --channel telegram \
  --timeout-seconds 120

# Job 3: Gareth strategic brief — 08:00 (30 min after team brief)
openclaw cron add \
  --name "gareth-strategic-brief" \
  --cron "0 8 * * 1-5" \
  --tz "Europe/London" \
  --agent main \
  --session isolated \
  --model "anthropic/claude-haiku-4-5" \
  --message "Read the file at /home/<user>/guide-core/prompts/cron/gareth-strategic-brief.md and follow the instructions exactly." \
  --to "6864752167" \
  --channel telegram \
  --timeout-seconds 120

# Job 4: Pipeline health check — 09:00
openclaw cron add \
  --name "pipeline-health-check" \
  --cron "0 9 * * 1-5" \
  --tz "Europe/London" \
  --agent main \
  --session isolated \
  --model "anthropic/claude-haiku-4-5" \
  --message "Read the file at /home/<user>/guide-core/prompts/cron/pipeline-health-check.md and follow the instructions exactly." \
  --to "slack:#guide-ops" \
  --channel slack \
  --timeout-seconds 120

# Job 5: Monthly board digest — 09:05 on 1st of month (staggered 5 min from pipeline-health-check)
openclaw cron add \
  --name "monthly-board-digest" \
  --cron "5 9 1 * *" \
  --tz "Europe/London" \
  --agent main \
  --session isolated \
  --model "anthropic/claude-haiku-4-5" \
  --message "Read the file at /home/<user>/guide-core/prompts/cron/monthly-board-digest.md and follow the instructions exactly." \
  --to "6864752167" \
  --channel telegram \
  --timeout-seconds 300

# Job 6: Midday anomaly scan — 12:00
openclaw cron add \
  --name "midday-anomaly-scan" \
  --cron "0 12 * * 1-5" \
  --tz "Europe/London" \
  --agent main \
  --session isolated \
  --model "anthropic/claude-haiku-4-5" \
  --message "Read the file at /home/<user>/guide-core/prompts/cron/midday-anomaly-scan.md and follow the instructions exactly." \
  --to "<TEAM_LEAD_GROUP_ID>" \
  --channel telegram \
  --timeout-seconds 120

# Job 7: Weekly performance summary — 17:00 Friday
openclaw cron add \
  --name "weekly-performance-summary" \
  --cron "0 17 * * 5" \
  --tz "Europe/London" \
  --agent main \
  --session isolated \
  --model "anthropic/claude-haiku-4-5" \
  --message "Read the file at /home/<user>/guide-core/prompts/cron/weekly-performance-summary.md and follow the instructions exactly." \
  --to "6864752167" \
  --channel telegram \
  --timeout-seconds 180
```

#### Task 3 — Verify all jobs registered

```bash
openclaw cron list
echo "Expected: 7 jobs"
```

#### Task 4 — Test one job manually

```bash
openclaw cron run --name "gareth-strategic-brief"
echo "✓ Manual run test — check Telegram for output"
```

#### Task 5 — Workspace git sync

The workspace accumulates irreplaceable state: MEMORY.md, signal files, session notes. Back it up to the `guide-workspace` GitHub repo on a crontab schedule. This is a shell job, not an OpenClaw job — no LLM needed.

**Step 1 — Confirm workspace is a git repo**

```bash
cd ~/.openclaw/workspace
git status 2>/dev/null || git init
git remote -v 2>/dev/null | grep -q guide-workspace \
  || git remote add origin git@github.com:gkwilderness/guide-workspace.git
git fetch origin 2>/dev/null && git branch --set-upstream-to=origin/main main 2>/dev/null || true
```

**Step 2 — Write sync script**

```bash
cat > ~/guide-core/scripts/workspace-sync.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
LOG="/tmp/openclaw/workspace-sync.log"

cd "$WORKSPACE"

# Only commit if there are changes
if git diff --quiet && git diff --cached --quiet; then
  exit 0
fi

git add -A
git commit -m "chore: workspace sync $(date -u +%Y-%m-%dT%H:%M:%SZ)"
git push
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] workspace synced" >> "$LOG"
EOF
chmod +x ~/guide-core/scripts/workspace-sync.sh
```

**Step 3 — Register with crontab**

```bash
# Add to crontab — runs every 6 hours
(crontab -l 2>/dev/null; echo "0 */6 * * * /bin/bash $HOME/guide-core/scripts/workspace-sync.sh >> /tmp/openclaw/workspace-sync.log 2>&1") | crontab -
crontab -l | grep workspace-sync && echo "✓ workspace-sync cron registered"
```

**Step 4 — Test manually**

```bash
cd ~/.openclaw/workspace && touch .sync-test && bash ~/guide-core/scripts/workspace-sync.sh
git log --oneline -3
rm .sync-test && bash ~/guide-core/scripts/workspace-sync.sh
echo "✓ workspace-sync tested"
```

**Note:** Pull from any machine with `cd guide-workspace && git pull`. Edit workspace files there and the next cron push from Guide picks up changes if not conflicting. For conflict-free edits, prefer editing via the Vault or Engineer on Guide directly.

---

#### Task 6 — Cron health monitoring script

OpenClaw silently disables jobs after consecutive errors — no alert fires by default. This script checks for disabled or erroring jobs and alerts to `#guide-ops`.

```bash
cat > ~/guide-core/scripts/cron-health.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

JOBS_FILE="$HOME/.openclaw/cron/jobs.json"
ISSUES=()

# Check for disabled jobs
while IFS= read -r name; do
  ISSUES+=("DISABLED: $name")
done < <(python3 -c "
import sys, json
with open('$JOBS_FILE') as f:
    d = json.load(f)
disabled = [j['name'] for j in d['jobs'] if not j.get('enabled', True)]
print('\n'.join(disabled))
")

# Check for jobs with consecutive errors
while IFS= read -r line; do
  [[ -n "$line" ]] && ISSUES+=("ERRORS: $line")
done < <(python3 -c "
import sys, json
with open('$JOBS_FILE') as f:
    d = json.load(f)
for j in d['jobs']:
    errs = j.get('state', {}).get('consecutiveErrors', 0)
    if errs > 0:
        msg = j['state'].get('lastError','')[:80]
        print(f'{j[\"name\"]}: {errs} consecutive errors — {msg}')
")

if [[ ${#ISSUES[@]} -gt 0 ]]; then
  echo "⚠️ Guide cron health issues:"
  for issue in "${ISSUES[@]}"; do
    echo "  - $issue"
  done
  # TODO: pipe to #guide-ops via OpenClaw gateway when Layer 2 comms are live (ADR-014)
  exit 1
else
  echo "✓ All cron jobs healthy"
fi
EOF
chmod +x ~/guide-core/scripts/cron-health.sh
```

Register as a daily crontab check (shell job, no LLM needed):

```bash
(crontab -l 2>/dev/null; echo "30 8 * * 1-5 /bin/bash $HOME/guide-core/scripts/cron-health.sh >> /tmp/openclaw/cron-health.log 2>&1") | crontab -
crontab -l | grep cron-health && echo "✓ cron-health check registered"
```

Test it:
```bash
bash ~/guide-core/scripts/cron-health.sh
```

---

#### Task 7 — Document cron management

Write to `~/guide-core/docs/cron-runbook.md`:
- How to list jobs: `openclaw cron list`
- How to run manually: `openclaw cron run --name <name>`
- How to pause: `openclaw cron pause --name <name>`
- How to view history: `openclaw cron history --name <name>`
- How to delete: `openclaw cron delete --name <name>`
- How to edit a prompt: edit `~/guide-core/prompts/cron/<name>.md`, commit, push — no restart needed
- How to check job health: `bash ~/guide-core/scripts/cron-health.sh`

---

### Verification Gate

```bash
CRON_COUNT=$(openclaw cron list --json | jq '. | length')
[[ "$CRON_COUNT" -ge 7 ]] && echo "✓ $CRON_COUNT cron jobs" || echo "✗ only $CRON_COUNT jobs"
openclaw cron list --json | jq '.[].model' | grep -q "haiku" && echo "✓ haiku model" || echo "✗ wrong model"
# Verify jobs use file-reference messages (not inline content)
openclaw cron list --json | python3 -c "
import sys, json
jobs = json.load(sys.stdin)
for j in jobs:
    msg = j.get('payload', {}).get('message', '')
    if 'Read the file at' not in msg:
        print(f'✗ {j[\"name\"]} has inline message — should use file reference')
    else:
        print(f'✓ {j[\"name\"]} uses file reference')
"
# Check prompt files exist
for name in etl-daily-refresh performance-morning-brief gareth-strategic-brief pipeline-health-check midday-anomaly-scan monthly-board-digest weekly-performance-summary; do
  [[ -f "$HOME/guide-core/prompts/cron/$name.md" ]] && echo "✓ prompt: $name" || echo "✗ missing: $name"
done
# Run health check
bash ~/guide-core/scripts/cron-health.sh
```

---

### Rollback

```bash
# Delete all cron jobs
for name in performance-morning-brief gareth-strategic-brief pipeline-health-check midday-anomaly-scan weekly-performance-summary monthly-board-digest etl-daily-refresh; do
  openclaw cron delete --name "$name" 2>/dev/null
done
```

---

### Git Commit

```bash
cd ~/guide-core && git add -A && git commit -m "feat(chunk-08): cron schedule and operational monitoring"
```

---

### Handoff to Phase 1

Phase 0 complete. Guide is:
- Running on the Mac Mini M2 Pro
- Tailscale: planned, not yet configured (backlog item)
- Responding via Telegram + Slack
- Security hardened (CHUNK-07)
- 7 OpenClaw cron jobs scheduled
- Workspace syncing to `guide-workspace` repo every 6 hours
- Audit logging active

Phase 1 (CHUNK-09) begins with the Agent Factory — the foundation for scaling to 20 agents.
