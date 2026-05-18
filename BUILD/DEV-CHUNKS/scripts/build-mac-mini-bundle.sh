#!/usr/bin/env bash
# build-mac-mini-bundle.sh — Zip the Mac Mini's OpenClaw state for migration to the Z8.
#
# Gareth runs this on the Mac Mini once, then moves the resulting zip into the Z8's
# Samba-mounted /srv/openclaw/_inbox/ via Finder (or any other means he likes).
# Documented in CHUNK-07c §"Phase B — pre-migration bundle".
#
# Output: ~/Desktop/guide-mac-mini-bundle.zip
#
# Steps the script takes:
#   1. Refuse to run unless the OpenClaw gateway is stopped (workspace files must be quiesced).
#   2. Zip ~/.openclaw/ + ~/guide-core/__CONFIG/keys/telegram-nick + a crontab dump.
#   3. Print clear next steps for Gareth (move to Z8, restart Mac Mini gateway, tell Engineer).

set -euo pipefail

OUT="$HOME/Desktop/guide-mac-mini-bundle.zip"

# 1. Verify gateway is stopped.
if lsof -i :18789 >/dev/null 2>&1; then
  cat >&2 <<EOF
✗ OpenClaw gateway is still running on :18789 — stop it first:
    launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.plist
EOF
  exit 1
fi
echo "✓ gateway is stopped"

# 2. Verify the inputs exist.
[[ -d "$HOME/.openclaw" ]] \
  || { echo "✗ $HOME/.openclaw not found" >&2; exit 1; }
[[ -f "$HOME/guide-core/__CONFIG/keys/telegram-nick" ]] \
  || { echo "✗ Nick bot token not found at $HOME/guide-core/__CONFIG/keys/telegram-nick" >&2; exit 1; }

# 3. Crontab dump (zipped alongside the rest).
CRONTAB_DUMP="$HOME/.openclaw/_migration-crontab.txt"
crontab -l > "$CRONTAB_DUMP" 2>/dev/null || echo "# (empty crontab)" > "$CRONTAB_DUMP"
echo "✓ crontab dumped to $CRONTAB_DUMP (inside .openclaw/ so it goes into the zip)"

# 4. Build the zip from $HOME so the entries inside are relative paths.
#    -r recursive, -q quiet, -y preserve symlinks (in case the workspace has any).
rm -f "$OUT"
echo "  building zip (this can take a minute on a large workspace)..."
( cd "$HOME" && zip -ryq "$OUT" .openclaw guide-core/__CONFIG/keys/telegram-nick )

SIZE=$(du -h "$OUT" | cut -f1)
COUNT=$(unzip -l "$OUT" | tail -1 | awk '{print $2}')
echo "✓ zip: $OUT ($SIZE, $COUNT entries)"

# 5. Tear down the temp crontab dump from inside ~/.openclaw/ so we don't leave litter.
rm -f "$CRONTAB_DUMP"

cat <<EOF

=== Next steps (do these in order) ===
  1. In Finder, drag $OUT into:
         smb://guide-server/srv/openclaw/_inbox/

     (If the _inbox folder doesn't exist yet, create it first via:
        ssh gareth@guide-server "mkdir -p /srv/openclaw/_inbox && chmod 775 /srv/openclaw/_inbox")

  2. Restart the Mac Mini gateway so it keeps serving in parallel during Z8 validation:
        launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.plist

  3. Tell the Engineer Claude on the Z8: "Bundle is at /srv/openclaw/_inbox/guide-mac-mini-bundle.zip — go."
EOF
