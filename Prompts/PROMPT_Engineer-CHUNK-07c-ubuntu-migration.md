---
title: "PROMPT — CHUNK-07c Mac Mini → Z8 Migration"
type: prompt
area: infra
project: Guide
tags: [infra, guide, ubuntu, docker, migration, engineer, chunk-07c]
status: ready
created: 2026-05-18
author: Architect
---

# CHUNK-07c — Mac Mini → Z8 OpenClaw Migration Prompt

Use this prompt with Claude Code on the Z8 (`guide-server`, Ubuntu 24.04), logged in as `gareth`. This is the Engineer-side runbook for **Phases C → E** of CHUNK-07c. Phase B is run by Gareth on the Mac Mini before you start; Phase D is a brief joint step with Gareth.

**Read first, in this order:**
1. `/srv/guide-build/BUILD/DEV-CHUNKS/CHUNK-07c-ubuntu-migration.md` — full spec
2. `/srv/guide-build/BUILD/DEV-CHUNKS/_CONVENTIONS.md` — chunk patterns and paths
3. `/srv/guide-build/Logs/2026-05-18_mac-mini-state.md` — what's coming over from the Mac Mini
4. `/srv/guide-build/Logs/2026-05-18_ubuntu-server-bootstrap.md` — what's already on this Z8
5. `/srv/guide-build/BUILD/DEV-CHUNKS/DECISIONS.md` — ADR-023, ADR-024

---

## The Prompt

You are the Engineer on `guide-server` migrating Guide's OpenClaw runtime from the Mac Mini (bare-metal launchd + npm) to this Z8 (Docker container under systemd, `/srv/` canonical filesystem). The Mac Mini is currently serving live channels in parallel; the Z8 will come up with channels disabled until Gareth gives the cutover go-signal.

Work step-by-step. Every step in the chunk is idempotent — re-running on partial state is safe. Do not proceed past a STOP HERE marker without me confirming. Show me the output of each verification before moving on. If anything is unexpected, surface it immediately.

---

## Pre-flight — confirm baseline

Before Phase C work, run these checks. Stop and tell me if any fail.

```bash
hostname                                   # expect: guide-server
id gareth                                  # expect groups including srv-data, guide-data, docker
ss -tlnp 2>/dev/null | grep -q ':18789 ' \
  && echo "✗ port 18789 already in use" \
  || echo "✓ port 18789 free"
docker --version
docker compose version
git -C /srv/guide-build status              # expect clean working tree
ls /srv/openclaw/_inbox/ 2>/dev/null        # expect: guide-mac-mini-bundle.zip
```

If `/srv/openclaw/_inbox/guide-mac-mini-bundle.zip` is missing, **stop here and tell me Phase B is not done**. I'll go run it on the Mac Mini.

---

## Step 1 — Pull the latest vault

```bash
git -C /srv/guide-build pull --ff-only
```

Verify CHUNK-07c is present:

```bash
test -f /srv/guide-build/BUILD/DEV-CHUNKS/CHUNK-07c-ubuntu-migration.md && echo "✓ chunk present"
test -d /srv/guide-build/BUILD/DEV-CHUNKS/templates/openclaw && echo "✓ templates present"
test -f /srv/guide-build/BUILD/DEV-CHUNKS/scripts/rewrite-openclaw-paths.py && echo "✓ rewriter present"
```

---

## Step 2 — Clone guide-core and guide-engine

```bash
for repo in guide-core guide-engine; do
  if [[ -d /srv/$repo/.git ]]; then
    echo "✓ /srv/$repo already cloned"
    git -C /srv/$repo pull --ff-only
  else
    git clone git@github.com:gkwilderness/$repo.git /srv/$repo
    sudo chown -R gareth:srv-data /srv/$repo
  fi
done
ls /srv/ | grep -E 'guide-(build|core|engine)'
```

Expected output: three lines — `guide-build`, `guide-core`, `guide-engine`.

---

## Step 3 — Sanity-check the bundle

```bash
ZIP=/srv/openclaw/_inbox/guide-mac-mini-bundle.zip
[[ -f $ZIP && -s $ZIP ]] || { echo "✗ bundle missing or empty"; exit 1; }
du -h $ZIP
unzip -l $ZIP | tail -3
unzip -l $ZIP | grep -E '\.openclaw/$|telegram-nick' || echo "⚠ top-level entries not as expected"
```

Show me the listing — confirm the zip contains `.openclaw/` and `guide-core/__CONFIG/keys/telegram-nick`. If anything is off, stop and tell me — I'll rebuild on the Mac Mini.

---

## Step 4 — Extract bundle to staging

```bash
mkdir -p /srv/openclaw/_inbox/staging
unzip -q /srv/openclaw/_inbox/guide-mac-mini-bundle.zip -d /srv/openclaw/_inbox/staging
ls /srv/openclaw/_inbox/staging
# Expected: .openclaw  guide-core
ls /srv/openclaw/_inbox/staging/.openclaw | head -20
test -f /srv/openclaw/_inbox/staging/.openclaw/_migration-crontab.txt \
  && echo "✓ crontab dump present"
```

Show me the directory listing and confirm `workspace`, `workspace-data`, `workspace-seo`, etc., are all present.

---

## Step 5 — Build the Z8 OpenClaw tree

Follow `CHUNK-07c.md` Task C5 verbatim. Key points:

- `/srv/openclaw/_inbox/staging/.openclaw/workspace/` → `/srv/openclaw/workspaces/main/`
- Each `workspace-*` directory → `/srv/openclaw/workspaces/<name>/`
- `agents/`, `credentials/`, `cron/`, `logs/`, `identity/`, `devices/`, `delivery-queue/`, `media/`, `flows/` → `/srv/openclaw/<sub>/`
- Nick's bot token → `/srv/guide-core/__CONFIG/keys/telegram-nick` (mode 600)
- Identity files (SOUL/AGENTS/TOOLS/IDENTITY/BOOT/USER) at 440
- Ownership: `guide:guide-data`

After the moves:

```bash
ls /srv/openclaw/workspaces/
# Expected: main, data, martech, seo, product, hubspot, safari, personal-nick
du -sh /srv/openclaw/workspaces/main/memory
# Expected: ~200 files (memory continuity preserved)
```

Tell me the file counts before continuing.

---

## Step 6 — Rewrite openclaw.json paths

```bash
chmod +x /srv/guide-build/BUILD/DEV-CHUNKS/scripts/rewrite-openclaw-paths.py

# Stage the Mac Mini config so the rewriter can read it
sudo cp /srv/openclaw/_inbox/staging/.openclaw/openclaw.json \
        /srv/openclaw/_inbox/openclaw.json.mac

sudo -u guide /srv/guide-build/BUILD/DEV-CHUNKS/scripts/rewrite-openclaw-paths.py \
  --in  /srv/openclaw/_inbox/openclaw.json.mac \
  --out /srv/openclaw/config/openclaw.json
```

The rewriter prints a unified diff. Show me the diff so I can sanity-check it. Then:

```bash
sudo chmod 640 /srv/openclaw/config/openclaw.json
sudo chown guide:guide-data /srv/openclaw/config/openclaw.json

grep -c "/Users/gareth" /srv/openclaw/config/openclaw.json   # expect 0
python3 -c "import json; json.load(open('/srv/openclaw/config/openclaw.json'))" \
  && echo "✓ JSON valid"

python3 -c "
import json
d = json.load(open('/srv/openclaw/config/openclaw.json'))
print('telegram.enabled:', d['channels']['telegram']['enabled'])
print('slack.enabled:   ', d['channels']['slack']['enabled'])
"
# Expected: both False
```

---

## Step 7 — Render compose + Dockerfile + systemd unit

```bash
sudo mkdir -p /srv/compose/openclaw
sudo cp /srv/guide-build/BUILD/DEV-CHUNKS/templates/openclaw/Dockerfile \
        /srv/compose/openclaw/Dockerfile
sudo cp /srv/guide-build/BUILD/DEV-CHUNKS/templates/openclaw/openclaw-compose.yml \
        /srv/compose/openclaw.yml
sudo chown -R gareth:srv-data /srv/compose

sudo cp /srv/guide-build/BUILD/DEV-CHUNKS/templates/openclaw/openclaw.service \
        /etc/systemd/system/openclaw.service
sudo chmod 644 /etc/systemd/system/openclaw.service
sudo systemctl daemon-reload
```

Render-time env vars need to be visible to systemd / docker compose. The compose file expects `HOST_UID`, `HOST_GID_GUIDE_DATA`, `OPENCLAW_VERSION`. We persist them in `/etc/systemd/system/openclaw.service.d/override.conf` so systemd injects them at unit start:

```bash
sudo mkdir -p /etc/systemd/system/openclaw.service.d
sudo tee /etc/systemd/system/openclaw.service.d/override.conf <<EOF
[Service]
Environment="HOST_UID=$(id -u gareth)"
Environment="HOST_GID_GUIDE_DATA=$(getent group guide-data | cut -d: -f3)"
Environment="OPENCLAW_VERSION=2026.5.4"
EOF
sudo systemctl daemon-reload
```

---

## Step 8 — Build the image

```bash
# Set the same env for the manual `docker compose build` invocation
export HOST_UID=$(id -u gareth)
export HOST_GID_GUIDE_DATA=$(getent group guide-data | cut -d: -f3)
export OPENCLAW_VERSION=2026.5.4

docker compose -f /srv/compose/openclaw.yml config >/dev/null && echo "✓ compose valid"
docker compose -f /srv/compose/openclaw.yml build
docker images guide/openclaw
```

Expected: image `guide/openclaw:2026.5.4` built without errors.

---

## Step 9 — Start the service

```bash
sudo systemctl enable --now openclaw.service
sleep 30
systemctl is-active openclaw.service
curl -sf http://127.0.0.1:18789/healthz && echo "" && echo "✓ gateway healthy"
docker ps --filter name=openclaw --format '{{.Status}}'
```

If unhealthy, capture logs:

```bash
sudo journalctl -u openclaw -n 100 --no-pager
docker logs openclaw --tail 100
```

Surface logs to me before proceeding.

---

## Step 10 — Smoke test (channels still disabled)

```bash
docker exec openclaw openclaw agents list
docker exec openclaw openclaw agents list --json \
  | python3 -c "import sys,json;print('count:',len(json.load(sys.stdin)))"
# Expected: count: 8
docker exec openclaw openclaw channels list | head -20
# Expected: telegram + slack reported as disabled
```

---

## STOP HERE — wait for cutover go-signal from Gareth

Write the status update:

```bash
sudo -u guide tee /srv/openclaw/workspaces/main/signals/→gareth.md > /dev/null <<EOF
$(date -Iseconds) — Z8 OpenClaw is up with channels disabled.

- Gateway: $(curl -sf http://127.0.0.1:18789/healthz >/dev/null && echo healthy || echo DOWN)
- Container: $(docker ps --filter name=openclaw --format '{{.Image}} ({{.Status}})')
- Agents: $(docker exec openclaw openclaw agents list --json 2>/dev/null \
            | python3 -c "import sys,json;print(len(json.load(sys.stdin)))")

Mac Mini still live. Ready to cut over.
EOF
```

Then poll:

```bash
until [[ -f /srv/openclaw/_inbox/CUTOVER ]]; do sleep 30; done
echo "✓ cutover go-signal received"
```

Tell me when you're at this checkpoint and I'll unload the Mac Mini gateway.

---

## Step 11 — Re-enable channels (after CUTOVER signal)

```bash
sudo cp /srv/openclaw/config/openclaw.json \
        /srv/openclaw/config/openclaw.json.bak-pre-cutover

sudo bash -c 'jq ".channels.telegram.enabled = true
              | .channels.slack.enabled = true" \
        /srv/openclaw/config/openclaw.json > /srv/openclaw/config/openclaw.json.tmp \
    && mv /srv/openclaw/config/openclaw.json.tmp /srv/openclaw/config/openclaw.json'
sudo chmod 640 /srv/openclaw/config/openclaw.json
sudo chown guide:guide-data /srv/openclaw/config/openclaw.json

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

Tell me you're done. I'll run the manual end-to-end checks (Telegram bots, Slack channels). If any fail, follow the rollback in `CHUNK-07c.md §Rollback`.

---

## Step 12 — UFW, fail2ban, SSH hardening

Run Tasks E1–E3 from `CHUNK-07c.md`. Show me the output of:

```bash
sudo ufw status verbose
sudo fail2ban-client status sshd
sudo sshd -T | grep -E 'passwordauthentication|kbdinteractiveauthentication'
```

Expected: ufw active with tailnet rules, fail2ban running on sshd, both auth options `no`.

---

## Step 13 — Migrate host crontab

```bash
sed -e 's|/Users/gareth/guide-engine/|/srv/guide-engine/|g' \
    -e 's|/Users/gareth/guide-core/scripts/|/srv/guide-core/scripts/|g' \
    -e 's|/Users/gareth/.openclaw/|/srv/openclaw/|g' \
    -e 's|/Users/gareth/openclaw-backups/|/srv/backup/dumps/|g' \
    /srv/openclaw/_inbox/staging/.openclaw/_migration-crontab.txt \
  > /tmp/z8-crontab.txt

cat /tmp/z8-crontab.txt
```

**Show me /tmp/z8-crontab.txt before installing.** Some of the Mac Mini jobs were `#PAUSED#` and may need different handling on Z8. Once I confirm:

```bash
crontab /tmp/z8-crontab.txt
crontab -l
```

---

## Step 14 — Verification gate

Run the full verification gate from `CHUNK-07c.md §Verification Gate`. All ten checks must print ✓ before we call the chunk complete. Show me the full output.

---

## Step 15 — Commit and push

```bash
cd /srv/guide-core
git add -A
git diff --cached --quiet || git commit -m "feat(chunk-07c): z8 paths + docker compose"
git -C /srv/guide-core push

# guide-build will already have the chunk + templates from the Architect's push;
# only commit if there are Engineer-side amendments
cd /srv/guide-build
git status
```

---

## After the migration is verified

- OpenClaw is live on `guide-server` (`100.80.44.14`), Docker + systemd, channels working.
- **CHUNK-07a — Google integration** (`gog` CLI, Calendar + Gmail OAuth) is the next chunk to run. Its spec needs a one-line path adaptation (`~/guide-core/` → `/srv/guide-core/`) — call this out when you start it.
- **CHUNK-15 (Keith), CHUNK-16 (Hadley)** become unblocked.
- 7-day soak begins. Daily health check per Task E8.
- Mac Mini decommission (Tailnet removal, final archive) follows the soak in a separate small chunk.

---

## What to surface to me proactively

- `/Users/gareth` strings found anywhere outside backup files
- Any agent that fails to list or register
- Any cron job auto-disabled by OpenClaw (`consecutiveErrors > 0`)
- Container restart loops (`docker ps` showing repeated `Restarting`)
- Slack or Telegram messages from the Mac Mini that should have routed to Z8 after cutover (means cutover didn't take cleanly)

Do not silently work around any of the above.
