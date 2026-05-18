---
title: "CHUNK-07c-ubuntu-migration"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build, migration, ubuntu]
status: pending
priority: urgent
---
# CHUNK-07c — Mac Mini → Z8 Ubuntu Migration
## GUIDE Build System | Phase 0 | macOS launchd → Linux Docker

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for paths, ports, and naming rules.
> This chunk is idempotent: every step is safe to re-run.
> The chunk is split into phases A–E. Phase A is Architect prep (done in `guide-build` vault before Engineer starts). Phases B–E run on the Mac Mini (Gareth, manual) and Z8 (Engineer Claude).
>
> **Read these in full before Phase C:**
> - `Logs/2026-05-18_mac-mini-state.md` — what's on the Mac Mini right now
> - `Logs/2026-05-18_ubuntu-server-bootstrap.md` — what's already built on the Z8
> - `BUILD/DEV-CHUNKS/DECISIONS.md` ADR-023 (Docker on Z8) and ADR-024 (channel-disabled cutover)

---

### What This Chunk Does

Migrates the live OpenClaw deployment from the Mac Mini M2 Pro (bare-metal launchd + global npm install per CHUNK-07b) to the HP Z8 G4 (`guide-server`, Ubuntu 24.04, Docker container under systemd). The Mac Mini's `~/.openclaw/` tree, credentials, agent registrations, workspace memory, and Nick's Telegram bot token all move to the Z8. The Mac Mini keeps running through validation as a hot rollback; only its OpenClaw channels go quiet at cutover.

**Why now:** the Z8 foundation is complete (see bootstrap log). The Mac Mini was always interim. Linux Docker fixes the networking issues that forced bare-metal on macOS (CHUNK-07b context), gives proper isolation, and aligns with how every other Guide service (Huginn, Paperclip, Hermes, Ollama) will be deployed on this host.

**What we keep:** every agent, workspace, session-memory file, channel binding, cron job, and Nick's personal instance. This is a faithful relocation, not a redesign. Path strings inside `openclaw.json` get rewritten Mac→Z8 (`/Users/gareth/.openclaw/` → `/srv/openclaw/`, `/Users/gareth/guide-core/` → `/srv/guide-core/`) and channels are temporarily disabled until cutover — that is the entire functional change.

**Success state:**
- `openclaw.service` (systemd) active on the Z8, healthy at `127.0.0.1:18789`.
- All 8 agents present (main + 6 channel + personal-nick), workspaces fully populated from Mac Mini.
- Telegram (default + nick) and Slack channels responding from the Z8, not the Mac Mini.
- UFW + fail2ban + SSH key-only enforced.
- Mac Mini gateway stopped (`launchctl unload`); machine itself stays online for the soak window.
- All vault docs updated to reflect Z8 as the live runtime.

---

### Prerequisites

- [ ] Z8 foundation complete per `Logs/2026-05-18_ubuntu-server-bootstrap.md`
- [ ] Engineer on Z8 is `gareth` with sudo, in groups `srv-data`, `guide-data`, `smb-users`, `docker`
- [ ] `/srv/guide-build/` is up to date: `git -C /srv/guide-build pull` returns clean
- [ ] Mac Mini OpenClaw gateway is reachable; ssh from Mac Mini → Z8 works over Tailscale
- [ ] No other Z8 services are bound to port 18789 (`ss -tlnp | grep 18789` empty)
- [ ] Docker 29.x and Docker Compose v2 verified on Z8 (`docker --version`, `docker compose version`)

---

### Deliverables

1. `/srv/guide-core/` and `/srv/guide-engine/` cloned, owned `gareth:srv-data`
2. `/srv/openclaw/{config,workspaces,agents,cron,logs,_inbox}/` populated from Mac Mini bundle
3. `/srv/openclaw/config/openclaw.json` path-rewritten, channels initially disabled
4. `/srv/compose/openclaw.yml` + `/srv/compose/openclaw/Dockerfile` rendered from templates
5. `/etc/systemd/system/openclaw.service` installed, enabled, active
6. Container image `guide/openclaw:<pinned-version>` built and running
7. UFW active with rules: 22/tcp from `100.0.0.0/8` (tailnet), 41641/udp, default-deny inbound
8. fail2ban active; SSH `PasswordAuthentication no`
9. Host crontab on Z8 carries the Mac Mini's `guide-engine` jobs with `/srv/` paths
10. Documentation updates committed: `CLAUDE.md`, `_CONVENTIONS.md`, `INFRA.md`, `00_Guide-Project-Brief.md`, `BUILD.md`, `Specs/guide-filesystem-layout.md`
11. CHUNK-07 and CHUNK-08 marked path-superseded
12. Mac Mini gateway unloaded; final state-snapshot tarball archived to `/srv/backup/`

---

### Environment Variables Required

```bash
# Already in ~/.bashrc on the Z8 (set by foundation bootstrap):
GUIDE_BUILD="/srv/guide-build"
GUIDE_VAULTS="/srv/guide-vaults"
OPENCLAW_CONFIG="/srv/openclaw/config"
OPENCLAW_WORKSPACE="/srv/openclaw/workspace"  # legacy bootstrap value; chunk renames to workspaces/main

# For the docker-compose build (typically defaulted in the compose file):
OPENCLAW_VERSION="2026.5.4"           # pinned to Mac Mini's current version, per Logs/2026-05-18_mac-mini-state.md §1
HOST_UID="$(id -u gareth)"            # used by docker compose to chown-match
HOST_GID_GUIDE_DATA="$(getent group guide-data | cut -d: -f3)"
```

---

### Tasks

The chunk runs in **five phases**. Phase A is Architect work in the vault (this file plus templates and scripts). Phase B is Gareth on the Mac Mini (one short manual session). Phase C is unattended Engineer execution on the Z8. Phase D is the cutover (Gareth + Engineer, ~5 min). Phase E is the soak + decommission.

---

#### Phase A — Architect prep (already done in this vault before Engineer reads this)

Recorded for context. These artifacts already exist in `guide-build`:

- `BUILD/DEV-CHUNKS/CHUNK-07c-ubuntu-migration.md` — this file
- `BUILD/DEV-CHUNKS/templates/openclaw/Dockerfile`
- `BUILD/DEV-CHUNKS/templates/openclaw/openclaw-compose.yml`
- `BUILD/DEV-CHUNKS/templates/openclaw/openclaw.service`
- `BUILD/DEV-CHUNKS/scripts/rewrite-openclaw-paths.py`
- `BUILD/DEV-CHUNKS/scripts/build-mac-mini-bundle.sh`
- `Prompts/PROMPT_Engineer-CHUNK-07c-ubuntu-migration.md` — Engineer entry point
- `BUILD/DEV-CHUNKS/DECISIONS.md` — ADR-024, ADR-025 appended

Architect commits + pushes the vault. Engineer pulls (Task C1) to receive everything.

---

#### Phase B — Pre-migration bundle (Gareth, on Mac Mini)

One short session, ~15 minutes. Gareth runs these steps.

##### Task B1 — Ensure the Z8 inbox directory exists

One-off from any shell that can ssh to the Z8:

```bash
ssh gareth@guide-server "mkdir -p /srv/openclaw/_inbox && chmod 775 /srv/openclaw/_inbox"
```

This makes the directory writable via the existing Samba `srv` share, so the zip drop in Task B3 just works from Finder.

##### Task B2 — Stop the Mac Mini gateway briefly

```bash
launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.plist
lsof -i :18789 || echo "✓ gateway stopped"
```

##### Task B3 — Build the bundle (zip)

```bash
chmod +x ~/guide-build/BUILD/DEV-CHUNKS/scripts/build-mac-mini-bundle.sh
~/guide-build/BUILD/DEV-CHUNKS/scripts/build-mac-mini-bundle.sh
```

Output: `~/Desktop/guide-mac-mini-bundle.zip` (size + entry count printed).

##### Task B4 — Move the zip to the Z8 inbox (Samba/Finder)

In Finder: `Go → Connect to Server → smb://guide-server/srv`, navigate to `openclaw/_inbox/`, drag `~/Desktop/guide-mac-mini-bundle.zip` into it.

Equivalent CLI (if a Samba mount is already attached as `/Volumes/srv`):

```bash
cp ~/Desktop/guide-mac-mini-bundle.zip /Volumes/srv/openclaw/_inbox/
ls -lh /Volumes/srv/openclaw/_inbox/guide-mac-mini-bundle.zip
```

Either way works — Gareth picks whatever's most natural.

##### Task B5 — Resume Mac Mini gateway (parallel-during-validation)

```bash
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.plist
curl -sf http://127.0.0.1:18789/healthz && echo "✓ Mac Mini gateway resumed"
```

The Mac Mini will keep serving until cutover (Phase D), at which point Gareth unloads it again.

##### Task B6 — Tell the Engineer to start

Message the Engineer Claude on the Z8: "Bundle is at `/srv/openclaw/_inbox/guide-mac-mini-bundle.zip` — start CHUNK-07c."

---

#### Phase C — Migration execution on the Z8 (Engineer, unattended)

All commands run as `gareth` on `guide-server` unless noted otherwise. Each task is idempotent.

##### Task C1 — Pull the latest vault

```bash
git -C /srv/guide-build pull --ff-only
```

##### Task C2 — Clone guide-core and guide-engine

```bash
for repo in guide-core guide-engine; do
  if [[ -d /srv/$repo/.git ]]; then
    echo "✓ /srv/$repo already cloned"
    git -C /srv/$repo pull --ff-only
  else
    sudo -u gareth git clone git@github.com:gkwilderness/$repo.git /srv/$repo
    sudo chown -R gareth:srv-data /srv/$repo
  fi
done
```

##### Task C3 — Sanity-check the bundle landed

```bash
ZIP=/srv/openclaw/_inbox/guide-mac-mini-bundle.zip
[[ -f $ZIP && -s $ZIP ]] || { echo "✗ bundle missing or empty at $ZIP — has Gareth finished Phase B?"; exit 1; }
echo "✓ bundle: $(du -h $ZIP | cut -f1), $(unzip -l $ZIP | tail -1 | awk '{print $2}') entries"
unzip -l $ZIP | head -5 | grep -E '\.openclaw/|guide-core/__CONFIG/keys/telegram-nick' >/dev/null \
  && echo "✓ bundle contains expected top-level entries" \
  || { echo "✗ bundle missing expected entries"; exit 1; }
```

##### Task C4 — Extract bundle to staging

```bash
mkdir -p /srv/openclaw/_inbox/staging
unzip -q /srv/openclaw/_inbox/guide-mac-mini-bundle.zip -d /srv/openclaw/_inbox/staging
ls /srv/openclaw/_inbox/staging
# Expected: .openclaw/  guide-core/
ls /srv/openclaw/_inbox/staging/.openclaw/_migration-crontab.txt
# Expected: the Mac Mini crontab dump
```

##### Task C5 — Build /srv/openclaw/ tree and place files

```bash
# Create target tree
sudo mkdir -p /srv/openclaw/{config/credentials,workspaces,agents,cron,logs}
sudo chown -R guide:guide-data /srv/openclaw
sudo chmod -R 775 /srv/openclaw

# Move workspaces — Mac Mini "workspace" → Z8 "workspaces/main"
STAGED=/srv/openclaw/_inbox/staging/.openclaw

# Main workspace (handle the rename)
[[ -d $STAGED/workspace ]] && sudo rsync -a --delete \
  $STAGED/workspace/ /srv/openclaw/workspaces/main/

# Per-agent workspaces — workspace-data → workspaces/data, etc.
for ws in $STAGED/workspace-*; do
  [[ -d $ws ]] || continue
  name="${ws##*/workspace-}"
  sudo rsync -a --delete "$ws/" "/srv/openclaw/workspaces/$name/"
done

# Agents, credentials, cron, logs, identity, etc. — preserve structure
for sub in agents credentials cron logs identity devices delivery-queue media flows; do
  [[ -d $STAGED/$sub ]] && sudo rsync -a --delete "$STAGED/$sub/" "/srv/openclaw/$sub/"
done

# Stage the Mac Mini openclaw.json for the rewrite step
sudo cp $STAGED/openclaw.json /srv/openclaw/_inbox/openclaw.json.mac

# Nick's bot token — Mac Mini ~/guide-core/__CONFIG/keys/telegram-nick is included in the bundle
sudo mkdir -p /srv/guide-core/__CONFIG/keys
sudo cp /srv/openclaw/_inbox/staging/guide-core/__CONFIG/keys/telegram-nick \
        /srv/guide-core/__CONFIG/keys/telegram-nick
sudo chown gareth:srv-data /srv/guide-core/__CONFIG/keys/telegram-nick
sudo chmod 600 /srv/guide-core/__CONFIG/keys/telegram-nick

# Identity files (SOUL, AGENTS, TOOLS, IDENTITY, BOOT, USER) get 440 per security rule #6
sudo find /srv/openclaw/workspaces -maxdepth 2 \
  \( -name SOUL.md -o -name AGENTS.md -o -name TOOLS.md \
     -o -name IDENTITY.md -o -name BOOT.md -o -name USER.md \) \
  -exec chmod 440 {} \;

# Ownership: guide:guide-data
sudo chown -R guide:guide-data /srv/openclaw
```

##### Task C6 — Rewrite openclaw.json paths and disable channels

```bash
chmod +x /srv/guide-build/BUILD/DEV-CHUNKS/scripts/rewrite-openclaw-paths.py

sudo -u guide /srv/guide-build/BUILD/DEV-CHUNKS/scripts/rewrite-openclaw-paths.py \
  --in  /srv/openclaw/_inbox/openclaw.json.mac \
  --out /srv/openclaw/config/openclaw.json

# Verify
sudo chmod 640 /srv/openclaw/config/openclaw.json
sudo chown guide:guide-data /srv/openclaw/config/openclaw.json
grep -c "/Users/gareth" /srv/openclaw/config/openclaw.json
# Expected: 0
python3 -c "import json; json.load(open('/srv/openclaw/config/openclaw.json'))" \
  && echo "✓ JSON valid"
```

##### Task C7 — Render Docker compose + systemd unit

```bash
# Compose root
sudo mkdir -p /srv/compose/openclaw
sudo cp /srv/guide-build/BUILD/DEV-CHUNKS/templates/openclaw/Dockerfile \
        /srv/compose/openclaw/Dockerfile
sudo cp /srv/guide-build/BUILD/DEV-CHUNKS/templates/openclaw/openclaw-compose.yml \
        /srv/compose/openclaw.yml
sudo chown -R gareth:srv-data /srv/compose

# systemd unit
sudo cp /srv/guide-build/BUILD/DEV-CHUNKS/templates/openclaw/openclaw.service \
        /etc/systemd/system/openclaw.service
sudo chmod 644 /etc/systemd/system/openclaw.service
sudo systemctl daemon-reload
```

##### Task C8 — Build image, validate compose

```bash
# Capture host UID/GID for the compose user: spec
export HOST_UID=$(id -u gareth)
export HOST_GID_GUIDE_DATA=$(getent group guide-data | cut -d: -f3)
export OPENCLAW_VERSION=2026.5.4

# Validate compose syntax
docker compose -f /srv/compose/openclaw.yml config >/dev/null && echo "✓ compose syntax OK"

# Build the image (pinned version)
docker compose -f /srv/compose/openclaw.yml build
docker images | grep guide/openclaw
```

##### Task C9 — Start the service

```bash
sudo systemctl enable --now openclaw.service
sleep 30  # let the container start + healthcheck stabilise

# Health
curl -sf http://127.0.0.1:18789/healthz && echo "" && echo "✓ gateway healthy"

# systemd
systemctl is-active openclaw.service
docker ps --filter name=openclaw --format '{{.Status}}'
```

##### Task C10 — Smoke test: agents present, gateway responds

```bash
# Inside the container
docker exec openclaw openclaw agents list

# Expected: 8 entries — main, data, martech, seo, product, hubspot, safari, personal-nick
docker exec openclaw openclaw agents list --json \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('count:', len(d))"

# Channels (should report telegram + slack disabled)
docker exec openclaw openclaw channels list | head -20
```

##### Task C11 — STOP HERE: Gareth go/no-go for cutover

Write a note for Gareth in the architect signal inbox and stop:

```bash
cat > /srv/openclaw/workspaces/main/signals/→gareth.md <<EOF
Z8 OpenClaw is up with channels disabled.

- Container: $(docker ps --filter name=openclaw --format '{{.Image}} ({{.Status}})')
- Gateway: $(curl -sf http://127.0.0.1:18789/healthz && echo OK || echo DOWN)
- Agents: $(docker exec openclaw openclaw agents list --json 2>/dev/null | python3 -c "import sys,json;print(len(json.load(sys.stdin)))")

Mac Mini is still serving (channels live there).

Ready to cut over when you give the go-signal:
  echo "go" > /srv/openclaw/_inbox/CUTOVER
EOF
```

Engineer Claude polls for `/srv/openclaw/_inbox/CUTOVER` (or simply waits for Gareth's next message in this session).

---

#### Phase D — Cutover (Gareth + Engineer)

##### Task D1 — Gareth: stop the Mac Mini gateway

On the Mac Mini:

```bash
launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.plist
lsof -i :18789 || echo "✓ Mac Mini gateway stopped"
echo "go" | ssh gareth@guide-server "cat > /srv/openclaw/_inbox/CUTOVER"
```

##### Task D2 — Engineer: re-enable channels on Z8

```bash
# Re-run the rewriter with --no-disable-channels — it will flip flags back on
sudo cp /srv/openclaw/config/openclaw.json \
        /srv/openclaw/config/openclaw.json.bak-pre-cutover

# Single-purpose edit: telegram + slack enabled = true. Use jq to be precise.
sudo bash -c 'jq ".channels.telegram.enabled = true
             | .channels.slack.enabled = true" \
        /srv/openclaw/config/openclaw.json > /srv/openclaw/config/openclaw.json.tmp \
     && mv /srv/openclaw/config/openclaw.json.tmp /srv/openclaw/config/openclaw.json'
sudo chmod 640 /srv/openclaw/config/openclaw.json
sudo chown guide:guide-data /srv/openclaw/config/openclaw.json

# Verify
python3 -c "
import json
d = json.load(open('/srv/openclaw/config/openclaw.json'))
assert d['channels']['telegram']['enabled'] is True
assert d['channels']['slack']['enabled'] is True
print('✓ channels enabled')
"

sudo systemctl restart openclaw.service
sleep 20
curl -sf http://127.0.0.1:18789/healthz && echo "✓ gateway healthy post-cutover"
```

##### Task D3 — Gareth: manual end-to-end checks

Gareth runs these checks. Each must pass.

| Check | How | Pass criterion |
|---|---|---|
| Telegram (default bot) | DM `@WildernessGuideBot` "ping" | response within 30s |
| Telegram (Nick bot) | DM `@WildernessGuideNickBot` "ping" | response within 30s |
| Telegram group | Message `-5236130644` with `@WildernessGuideBot` mention | response |
| Slack DM | DM Guide in `#guide-ops` | response |
| Slack channel — data | Post in `#guide-data` | data agent response |
| Slack channel — seo | Post in `#seo-guide` | seo agent response |
| Slack channel — martech | Post in `#guide-martech-backlog` | martech agent response |
| Slack channel — product | Post in `#guide-digital-product` | product agent response |
| Slack channel — hubspot | Post in `#guide-hubspot` | hubspot agent response |
| Cron | Trigger `openclaw cron run nightly-guide-logs-digest` via gateway | run recorded in `/srv/openclaw/cron/runs/` |

Any failure → Engineer follows the rollback section below.

---

#### Phase E — Hardening, cron, and soak

These run after cutover succeeds (Gareth gives the all-clear).

##### Task E1 — UFW firewall

```bash
# Allow SSH from tailnet only, allow Tailscale UDP, default-deny inbound
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 100.0.0.0/8 to any port 22 proto tcp comment 'SSH via Tailscale'
sudo ufw allow 41641/udp comment 'Tailscale'
# Samba is already in use — limit to LAN only
sudo ufw allow from 192.168.0.0/16 to any port 445 proto tcp comment 'Samba LAN'
sudo ufw allow from 192.168.0.0/16 to any port 139 proto tcp comment 'Samba NetBIOS'
sudo ufw --force enable
sudo ufw status verbose
```

##### Task E2 — fail2ban

```bash
sudo apt-get install -y fail2ban
sudo tee /etc/fail2ban/jail.d/sshd.local <<'EOF'
[sshd]
enabled = true
bantime = 1h
findtime = 10m
maxretry = 5
EOF
sudo systemctl enable --now fail2ban
sudo fail2ban-client status sshd
```

##### Task E3 — SSH key-only

```bash
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' /etc/ssh/sshd_config
sudo sshd -t && sudo systemctl reload sshd
```

##### Task E4 — Workspace identity perms

Already applied in Task C5 for the SOUL/AGENTS/TOOLS/IDENTITY/BOOT/USER set. Re-run to confirm (idempotent):

```bash
sudo find /srv/openclaw/workspaces -maxdepth 2 \
  \( -name SOUL.md -o -name AGENTS.md -o -name TOOLS.md \
     -o -name IDENTITY.md -o -name BOOT.md -o -name USER.md \) \
  -exec chmod 440 {} \;
echo "✓ identity files locked at 440"
```

##### Task E5 — Host crontab for guide-engine jobs

The Mac Mini's crontab is dumped inside the bundle at `staging/.openclaw/_migration-crontab.txt` (the bundle script tucks the crontab inside `.openclaw/` so it travels in a single zip entry). Rewrite `/Users/gareth/` → `/srv/`, install for user `gareth` on the Z8:

```bash
sed -e 's|/Users/gareth/guide-engine/|/srv/guide-engine/|g' \
    -e 's|/Users/gareth/guide-core/scripts/|/srv/guide-core/scripts/|g' \
    -e 's|/Users/gareth/.openclaw/|/srv/openclaw/|g' \
    -e 's|/Users/gareth/openclaw-backups/|/srv/backup/dumps/|g' \
    /srv/openclaw/_inbox/staging/.openclaw/_migration-crontab.txt \
  > /tmp/z8-crontab.txt

# Review the result before installing
cat /tmp/z8-crontab.txt

crontab /tmp/z8-crontab.txt
crontab -l | head -20
```

OpenClaw-internal cron (`jobs.json`) was migrated as part of Task C5 (`/srv/openclaw/cron/jobs.json`). No re-registration needed.

##### Task E6 — Final state snapshot from Mac Mini (cold rollback bundle)

Gareth runs on the Mac Mini once cutover is confirmed:

```bash
# Mac Mini is already stopped from Task D1. Take a final tar.
tar -czf ~/guide-mac-mini-final-$(date +%Y%m%d).tar.gz -C $HOME .openclaw guide-core
scp ~/guide-mac-mini-final-*.tar.gz gareth@guide-server:/srv/backup/dumps/
```

##### Task E7 — Doc updates and commits

Engineer pulls the Architect's updated docs and confirms they apply:

```bash
git -C /srv/guide-build pull --ff-only
```

(The Architect updates `CLAUDE.md`, `_CONVENTIONS.md`, `INFRA.md`, `00_Guide-Project-Brief.md`, `BUILD.md`, `Specs/guide-filesystem-layout.md`, marks CHUNK-07 + CHUNK-08 path-superseded, in a separate commit; see Phase A.)

Then Engineer commits any Z8-side changes:

```bash
cd /srv/guide-core
git add -A
git commit -m "feat(chunk-07c): z8 migration — paths /srv/, docker, systemd"
git push
```

##### Task E8 — Begin 7-day soak

Daily checks (Architect or Engineer):

```bash
# Gateway uptime
systemctl status openclaw.service --no-pager | head -15

# Errors
sudo journalctl -u openclaw -n 100 --no-pager | grep -iE 'error|fail' || echo "✓ no errors"

# OpenClaw-internal cron
docker exec openclaw openclaw cron list --json \
  | python3 -c "
import sys,json
d=json.load(sys.stdin)
disabled=[j['name'] for j in d.get('jobs',[]) if not j.get('enabled',True)]
print('disabled:', disabled or 'none')"

# Workspace memory writes (should be increasing daily)
ls /srv/openclaw/workspaces/main/memory | wc -l
```

After 7 clean days, follow up chunk decommissions the Mac Mini (Tailnet removal, archive).

---

### Verification Gate

```bash
echo "=== CHUNK-07c verification ==="

# 1. systemd active
systemctl is-active openclaw.service | grep -q '^active$' && echo "✓ systemd active" \
  || echo "✗ systemd not active"

# 2. gateway healthy
curl -sf http://127.0.0.1:18789/healthz >/dev/null && echo "✓ gateway healthy" \
  || echo "✗ gateway down"

# 3. 8 agents present
COUNT=$(docker exec openclaw openclaw agents list --json 2>/dev/null \
        | python3 -c "import sys,json;print(len(json.load(sys.stdin)))")
[[ "$COUNT" == "8" ]] && echo "✓ 8 agents present" || echo "✗ agent count = $COUNT (expected 8)"

# 4. no /Users/gareth strings in the config
grep -q '/Users/gareth' /srv/openclaw/config/openclaw.json \
  && echo "✗ stray /Users/gareth in openclaw.json" \
  || echo "✓ no stray macOS paths in openclaw.json"

# 5. UFW
sudo ufw status | grep -q '^Status: active' && echo "✓ ufw active" || echo "✗ ufw inactive"

# 6. SSH key-only
sudo sshd -T | grep -E '^passwordauthentication no' && echo "✓ ssh password auth disabled" \
  || echo "✗ ssh password auth still enabled"

# 7. fail2ban
systemctl is-active fail2ban | grep -q '^active$' && echo "✓ fail2ban active" \
  || echo "✗ fail2ban down"

# 8. Identity files at 440
BAD=$(sudo find /srv/openclaw/workspaces -maxdepth 2 \
        \( -name SOUL.md -o -name AGENTS.md -o -name IDENTITY.md -o -name TOOLS.md \
           -o -name BOOT.md -o -name USER.md \) \
        ! -perm 440 | wc -l)
[[ "$BAD" == "0" ]] && echo "✓ all identity files at 440" || echo "✗ $BAD identity files have wrong perms"

# 9. Mac Mini gateway stopped (run from this host via SSH if reachable)
if ssh -o ConnectTimeout=5 gareth@<mac-mini-tailscale-name> "lsof -i :18789" 2>/dev/null | grep -q LISTEN; then
  echo "✗ Mac Mini gateway still running"
else
  echo "✓ Mac Mini gateway stopped (or unreachable, treat as stopped)"
fi

# 10. Cron job ran on Z8 in last 24h
COUNT=$(find /srv/openclaw/cron/runs -mtime -1 -type f 2>/dev/null | wc -l)
(( COUNT > 0 )) && echo "✓ cron has run ($COUNT recent jobs)" || echo "⚠ no recent cron runs"

echo "=== end ==="
```

All ten checks must print ✓ before the chunk is considered complete.

---

### Rollback

#### Mid-migration (Phase C — before cutover)

Everything in Phase C is idempotent. The Mac Mini is still serving. Engineer can:

```bash
sudo systemctl stop openclaw.service
sudo systemctl disable openclaw.service
docker compose -f /srv/compose/openclaw.yml down -v
# Optionally wipe /srv/openclaw to start fresh:
sudo rm -rf /srv/openclaw/{config,workspaces,agents,cron,logs}
# Mac Mini is unaffected — channels are live on Mac Mini throughout Phase C.
```

#### Cutover failure (Phase D)

```bash
# On Z8:
sudo systemctl stop openclaw.service

# On Mac Mini:
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.plist
# Channels resume on Mac Mini.

# Capture diagnostics:
sudo journalctl -u openclaw -n 500 --no-pager > /srv/openclaw/logs/cutover-failure-$(date +%s).log
docker logs openclaw > /srv/openclaw/logs/container-cutover-failure-$(date +%s).log 2>&1
```

Surface logs to Architect via `signals/→architect.md`. Mac Mini remains source of truth until fixed.

#### Post-soak regression (Phase E)

Mac Mini final tarball lives at `/srv/backup/dumps/guide-mac-mini-final-YYYYMMDD.tar.gz`. Restore by re-running Tasks C4–C9 with that tarball in place of the migration bundle, and re-loading the Mac Mini's launchd plist.

---

### Git Commit

```bash
cd /srv/guide-build && git add -A && git commit -m "feat(chunk-07c): mac mini → z8 ubuntu migration"
git -C /srv/guide-build push

cd /srv/guide-core && git add -A
git diff --cached --quiet || git commit -m "feat(chunk-07c): z8 paths + docker compose"
git -C /srv/guide-core push
```

---

### Handoff to CHUNK-07a (Google integration)

After 07c completes:

- OpenClaw is live on `guide-server` (`100.80.44.14`), Docker + systemd, channels working.
- CHUNK-07a (Google integration — `gog` CLI, Calendar + Gmail OAuth) can now run against the Z8 environment. Its tasks need a one-line path adaptation from `~/guide-core/` to `/srv/guide-core/` — call this out when executing.
- CHUNK-15 (Keith), CHUNK-16 (Hadley) become unblocked.
- Phase 0 is complete.

### Deliberate non-goal: Tailscale Serve on Z8

The Mac Mini's `openclaw.json` lists `https://guide.tailfbf66e.ts.net` in `gateway.controlUi.allowedOrigins` — this is the Mac Mini's Tailscale Serve URL (HTTPS access to the control UI via `*.ts.net`). On the Z8, Tailscale Serve is **not yet configured**.

For CHUNK-07c we deliberately do nothing about this:

- The stale Mac Mini origin is left in `allowedOrigins`. It's an unused string — harmless.
- The control UI on Z8 is accessible via `http://127.0.0.1:18789` (loopback) or via Tailscale at `http://100.80.44.14:18789` (no TLS — only over the tailnet).
- Z8 Tailscale Serve setup (capturing the new `*.ts.net` URL, adding it to `allowedOrigins`, removing the Mac Mini one) is a separate small follow-on chunk — call it CHUNK-07d when we get to it.

Skip this only if you want browser-with-HTTPS access to the control UI during the soak window; otherwise the loopback / tailnet IP paths cover every workflow CHUNK-07c needs to validate.

---

*Created: 2026-05-18 — supersedes CHUNK-07 hardening + CHUNK-07b bare-metal direction for Z8 deployment.*
