#!/usr/bin/env python3
"""rewrite-openclaw-paths.py — Mac Mini → Z8 openclaw.json migrator.

Reads the Mac Mini openclaw.json (extracted from the migration bundle),
applies a deterministic Mac→Z8 path map, disables Telegram and Slack channels
(re-enabled at cutover), and writes the rewritten config alongside a diff.

Idempotent: re-running on an already-rewritten config is a no-op. Always writes
a `.bak` next to the output before mutating, and emits a unified diff to stdout
so the engineer can sanity-check the changes before restarting OpenClaw.

Usage:
    rewrite-openclaw-paths.py \\
        --in  /srv/openclaw/_inbox/openclaw.json.mac \\
        --out /srv/openclaw/config/openclaw.json

Path map and channel-disable logic come from
BUILD/DEV-CHUNKS/CHUNK-07c-ubuntu-migration.md §"Path rewrite map".
"""

from __future__ import annotations

import argparse
import difflib
import json
import re
import shutil
import sys
from pathlib import Path

# Path map: regex pattern -> replacement. Applied to every string in the JSON tree.
# Ordering matters — the longest, most specific patterns come first so they win.
PATH_MAP = [
    (re.compile(r"^/Users/gareth/\.openclaw/workspace$"), "/srv/openclaw/workspaces/main"),
    (re.compile(r"^/Users/gareth/\.openclaw/workspace-(.+)$"), r"/srv/openclaw/workspaces/\1"),
    (re.compile(r"^/Users/gareth/\.openclaw/agents/(.+)$"), r"/srv/openclaw/agents/\1"),
    (re.compile(r"^/Users/gareth/\.openclaw/(.+)$"), r"/srv/openclaw/\1"),
    (re.compile(r"^/Users/gareth/guide-core/(.+)$"), r"/srv/guide-core/\1"),
    (re.compile(r"^/Users/gareth/guide-engine/(.+)$"), r"/srv/guide-engine/\1"),
    (re.compile(r"^/Users/gareth/guide-build/(.+)$"), r"/srv/guide-build/\1"),
    (re.compile(r"^/Users/gareth/(.+)$"), r"/home/gareth/\1"),  # safety net
]


def rewrite_string(value: str) -> str:
    """Apply path map to a single string. First matching pattern wins."""
    for pattern, replacement in PATH_MAP:
        new_value, n = pattern.subn(replacement, value)
        if n > 0:
            return new_value
    return value


def walk(obj):
    """Recursively rewrite every string in a JSON-loaded structure."""
    if isinstance(obj, dict):
        return {k: walk(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [walk(item) for item in obj]
    if isinstance(obj, str):
        return rewrite_string(obj)
    return obj


def disable_channels(config: dict) -> list[str]:
    """Flip Telegram + Slack enabled flags to false. Returns list of paths flipped.

    The migration brings Z8 up with channels OFF so the Mac Mini and Z8 don't both
    poll Telegram / hold Slack socket connections simultaneously. They're re-enabled
    at cutover (CHUNK-07c Phase D)."""
    flipped = []

    channels = config.get("channels", {})

    for name in ("telegram", "slack"):
        block = channels.get(name)
        if isinstance(block, dict) and block.get("enabled") is True:
            block["enabled"] = False
            flipped.append(f"channels.{name}.enabled")

    # Per-account Telegram enables (e.g. accounts.nick.enabled) — leave True since
    # account-level enable is gated by the top-level channels.telegram.enabled anyway.
    # Flipping them too would mean re-flipping at cutover for each account; minimise that.

    return flipped


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--in", dest="src", required=True, type=Path,
                        help="Mac Mini openclaw.json (extracted from migration bundle)")
    parser.add_argument("--out", dest="dst", required=True, type=Path,
                        help="Z8 destination path (typically /srv/openclaw/config/openclaw.json)")
    parser.add_argument("--no-disable-channels", action="store_true",
                        help="Do NOT flip channels.{telegram,slack}.enabled to false. "
                             "Use this at cutover time when re-enabling channels.")
    args = parser.parse_args()

    if not args.src.exists():
        print(f"✗ input not found: {args.src}", file=sys.stderr)
        return 2

    original_text = args.src.read_text()
    try:
        original = json.loads(original_text)
    except json.JSONDecodeError as e:
        print(f"✗ input is not valid JSON: {e}", file=sys.stderr)
        return 2

    rewritten = walk(original)
    flipped = [] if args.no_disable_channels else disable_channels(rewritten)

    rewritten_text = json.dumps(rewritten, indent=2) + "\n"

    # Idempotency: if dst already exists and matches what we'd write, do nothing.
    if args.dst.exists() and args.dst.read_text() == rewritten_text:
        print(f"✓ {args.dst} already up to date — no changes")
        return 0

    # Back up dst if it exists.
    if args.dst.exists():
        backup = args.dst.with_suffix(args.dst.suffix + ".bak-premigration")
        shutil.copy2(args.dst, backup)
        print(f"  backup: {backup}")

    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(rewritten_text)

    # Emit a unified diff input→output for the engineer to eyeball.
    diff = difflib.unified_diff(
        original_text.splitlines(keepends=True),
        rewritten_text.splitlines(keepends=True),
        fromfile=str(args.src),
        tofile=str(args.dst),
        n=2,
    )
    sys.stdout.writelines(diff)

    print()
    print(f"✓ wrote {args.dst}")
    if flipped:
        print(f"✓ disabled channels: {', '.join(flipped)}")
    else:
        print("  (channels not flipped — either already disabled or --no-disable-channels)")

    # Final sanity check: nothing should reference /Users/gareth/ in the output.
    stray = [line for line in rewritten_text.splitlines() if "/Users/gareth" in line]
    if stray:
        print("✗ stray /Users/gareth references remain — investigate:", file=sys.stderr)
        for line in stray:
            print(f"    {line.strip()}", file=sys.stderr)
        return 3

    print("✓ no stray /Users/gareth references")
    return 0


if __name__ == "__main__":
    sys.exit(main())
