---
title: "CHUNK-07a-google-integration"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: pending
---
# CHUNK-07a — Google Integration (Calendar + Gmail)
## GUIDE Build System | Phase 0 | Foundation

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.
> **Note:** This chunk uses the `gog` CLI for Google OAuth. The Google Cloud project `jarvis-492211` is already set up; Guide may reuse it or use a separate project (see Decision below).

---

### What This Chunk Does

Integrates Google Calendar and Gmail with Guide using the `gog` CLI. Guide gains calendar awareness (read + create events) and email awareness (unread count, search, draft). Both surface in Gareth's morning brief and are queryable via Telegram/Slack.

**Scope:** Gareth's work Google account only. This is a work agent — household accounts are out of scope.

**Success state:** Guide can list today's calendar events, create an event, search Gmail, and surface email/calendar status in a morning brief prompt. Auth persists across restarts (file-based keyring, no manual re-auth for cron).

---

### Prerequisites

- [ ] CHUNK-07c complete — security hardening done, credentials directory exists at `/srv/openclaw/credentials/`
- [ ] `gog` CLI: `command -v gog` (install if missing — see Task 1 for Linux install)
- [ ] Google Cloud project with Calendar API + Gmail API enabled
- [ ] `client_secret.json` downloaded from Google Cloud Console, placed at `/srv/openclaw/credentials/google-client_secret.json`
- [ ] Google Cloud project: create new project (do not reuse `jarvis-492211`) — name it `guide-[XXXXXX]`, Gareth to create and download `client_secret.json`
- [ ] Gmail account: create a new free Gmail address for Guide (e.g. `wilderness.guide@gmail.com` or similar) — Gareth to create and confirm address before running auth

---

### Deliverables

1. `gog` CLI installed and verified
2. Google OAuth configured for Gareth's work Google account — file-based keyring, persists across restarts
3. Calendar read + write working — `gog calendar list` returns events
4. Gmail read working — `gog gmail search` returns results
5. `TOOLS.md` updated — `gog` calendar and Gmail commands added to Guide's tool surface
6. Morning brief prompt template updated — includes today's calendar events + email status
7. Verification: Guide queries calendar and email via Telegram on demand

---

### Environment Variables Required

```
GOOGLE_ACCOUNT=[GUIDE_GMAIL_ADDRESS]   # Gareth's work Google account — confirm before running
GOG_KEYRING_PASSWORD=""                      # Empty string = file-based keyring (required for cron/headless)
```

Add `GOG_KEYRING_PASSWORD=""` to the systemd override at `/etc/systemd/system/openclaw.service.d/override.conf` (under `[Service]`, as `Environment=GOG_KEYRING_PASSWORD=`).

---

### Tasks

#### Task 1 — Install gog CLI

```bash
# Check if already installed
if command -v gog &>/dev/null; then
  echo "✓ gog already installed: $(gog --version)"
else
  # gog is a macOS-first tool by Peter Steinberger. Check for a Linux release:
  # https://github.com/steipete/gog/releases
  # If a Linux binary is available, download and install to /usr/local/bin/gog
  # If not available for Linux, raise with Gareth — may need an alternative approach
  # (e.g. direct Google API calls, or a different OAuth helper)
  echo "⚠️ gog not installed — check https://github.com/steipete/gog/releases for Linux binary"
  exit 1
fi
```

#### Task 2 — Verify credentials file exists

```bash
[[ -f /srv/openclaw/credentials/google-client_secret.json ]] \
  && echo "✓ client_secret.json present" \
  || { echo "✗ Missing: /srv/openclaw/credentials/google-client_secret.json — download from Google Cloud Console first"; exit 1; }
```

> **If not present:** Go to Google Cloud Console → your project → APIs & Services → Credentials → Download OAuth 2.0 client secret JSON → place at `/srv/openclaw/credentials/google-client_secret.json`.

#### Task 3 — OAuth auth flow (interactive — requires browser)

The `gog` auth flow opens a browser redirect at `localhost:18800`. Since Guide is headless, tunnel the port from Guide to your Mac first:

```bash
# On your Mac (in a separate terminal):
# ssh -L 18800:127.0.0.1:18800 gareth@guide
# Then open browser to http://localhost:18800 when gog prompts
```

Run auth on Guide:

```bash
export GOG_KEYRING_PASSWORD=""
export GOOGLE_ACCOUNT="[GUIDE_GMAIL_ADDRESS]"   # replace with actual account

# Auth for both Calendar and Gmail in one flow
gog auth --account "$GOOGLE_ACCOUNT" \
  --credentials /srv/openclaw/credentials/google-client_secret.json \
  --scopes calendar,gmail \
  --keyring-backend file \
  --port 18800

echo "✓ OAuth complete"
```

> **One-time only.** Tokens are stored in gog's file keyring. Subsequent cron/agent use requires only `GOG_KEYRING_PASSWORD=""` in env — no browser needed.

#### Task 4 — Verify Calendar access

```bash
export GOG_KEYRING_PASSWORD=""
GOOGLE_ACCOUNT="[GUIDE_GMAIL_ADDRESS]"

# List today's events
gog calendar list \
  --account "$GOOGLE_ACCOUNT" \
  --start "$(date -u +%Y-%m-%dT00:00:00Z)" \
  --end "$(date -u +%Y-%m-%dT23:59:59Z)" \
  --format json | head -50

echo "✓ Calendar access confirmed"
```

#### Task 5 — Verify Gmail access

```bash
export GOG_KEYRING_PASSWORD=""
GOOGLE_ACCOUNT="[GUIDE_GMAIL_ADDRESS]"

# Search unread inbox
gog gmail search "in:inbox is:unread" \
  --max 5 \
  --account "$GOOGLE_ACCOUNT"

echo "✓ Gmail access confirmed"
```

#### Task 6 — Add GOG_KEYRING_PASSWORD to systemd override

```bash
OVERRIDE=/etc/systemd/system/openclaw.service.d/override.conf

# Check if already present
grep -q "GOG_KEYRING_PASSWORD" "$OVERRIDE" \
  && echo "✓ Already in systemd override" \
  || {
    echo "Adding GOG_KEYRING_PASSWORD to $OVERRIDE"
    # Add under [Service] block — Gareth must run this with sudo:
    echo "  Environment=GOG_KEYRING_PASSWORD="
    echo "  (add this line manually under [Service] in $OVERRIDE, then: sudo systemctl daemon-reload && sudo systemctl restart openclaw.service)"
  }
```

The override file structure is:
```ini
[Service]
Environment=HOST_UID=1002
Environment=GOG_KEYRING_PASSWORD=
```

After editing (requires sudo):
```bash
sudo systemctl daemon-reload && sudo systemctl restart openclaw.service
```

#### Task 7 — Update TOOLS.md

Add a Google section to `/srv/openclaw/workspaces/main/TOOLS.md`:

```markdown
## Google (Calendar + Gmail)

Available via `gog` CLI. Set `GOG_KEYRING_PASSWORD=""` in env — already configured.

### Calendar

# Today's events
gog calendar list --account [GUIDE_GMAIL_ADDRESS] --start TODAY_START --end TODAY_END --format json

# Create event
gog calendar create --account [GUIDE_GMAIL_ADDRESS] --title "TITLE" --start "2026-MM-DDTHH:MM:00" --end "2026-MM-DDTHH:MM:00" --description "DESC"

# Tomorrow's events
gog calendar list --account [GUIDE_GMAIL_ADDRESS] --start TOMORROW_START --end TOMORROW_END --format json

### Gmail

# Unread count + subjects
gog gmail search "in:inbox is:unread" --max 20 --account [GUIDE_GMAIL_ADDRESS]

# Search
gog gmail search "QUERY" --max 10 --account [GUIDE_GMAIL_ADDRESS]

# Draft reply (no auto-send — always draft only)
gog gmail drafts create --account [GUIDE_GMAIL_ADDRESS] --to ADDR --subject SUBJECT --body BODY

**Rule:** Never send email directly. Always create a draft and confirm with Gareth first.
```

> **Important:** Replace `[domain].com` with the actual account. Lock TOOLS.md after writing: `sudo chown guide:guide-data /srv/openclaw/workspaces/main/TOOLS.md && chmod 440 /srv/openclaw/workspaces/main/TOOLS.md`

#### Task 8 — Update BOOTSTRAP.md with calendar context

Add to `/srv/openclaw/workspaces/main/BOOTSTRAP.md` (the morning brief section, or create one if absent):

```markdown
## Calendar & Email Context

At the start of each day (or when asked), Guide checks:
- Today's calendar events via: `gog calendar list --account [account] --start [today_start] --end [today_end]`
- Unread email summary via: `gog gmail search "in:inbox is:unread" --max 20 --account [account]`

Surface in morning brief: meetings today, any back-to-backs, unread count + any flagged/starred items.
Email drafts only — never send directly.
```

#### Task 9 — Commit

```bash
cd /srv/guide-core && git add -A && git commit -m "feat(chunk-07a): Google Calendar + Gmail integration via gog CLI"
```

---

### Verification Gate

```bash
command -v gog &>/dev/null && echo "✓ gog installed" || echo "✗ gog missing"

export GOG_KEYRING_PASSWORD=""
ACCOUNT="[GUIDE_GMAIL_ADDRESS]"

gog calendar list --account "$ACCOUNT" --start "$(date -u +%Y-%m-%dT00:00:00Z)" --end "$(date -u +%Y-%m-%dT23:59:59Z)" --format json &>/dev/null \
  && echo "✓ calendar access" || echo "✗ calendar failed"

gog gmail search "in:inbox is:unread" --max 1 --account "$ACCOUNT" &>/dev/null \
  && echo "✓ gmail access" || echo "✗ gmail failed"

grep -q "GOG_KEYRING_PASSWORD" /etc/systemd/system/openclaw.service.d/override.conf \
  && echo "✓ keyring env set in systemd override" || echo "✗ keyring env missing from systemd override"

grep -q "Google" /srv/openclaw/workspaces/main/TOOLS.md \
  && echo "✓ TOOLS.md updated" || echo "✗ TOOLS.md not updated"
```

All five must print ✓.

---

### Rollback

```bash
# Revoke tokens (gog-specific — check gog auth revoke syntax)
gog auth revoke --account [GUIDE_GMAIL_ADDRESS]

# Remove from TOOLS.md — delete Google section
# Revert BOOTSTRAP.md changes
# Remove GOG_KEYRING_PASSWORD from .env and docker-compose.yml
# docker compose restart openclaw
```

---

### Handoff to CHUNK-08

CHUNK-08 (Cron & Ops) expects:
- `gog` installed and authenticated
- `GOG_KEYRING_PASSWORD=""` in Docker environment (cron jobs need headless auth)
- Calendar and Gmail tool definitions in TOOLS.md
- Morning brief cron prompt can reference `gog calendar list` directly

---

*Written: 2026-04-17*
