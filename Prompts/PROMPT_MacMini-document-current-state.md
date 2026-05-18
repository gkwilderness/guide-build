---
title: "PROMPT — Mac Mini: Document Current Running State"
type: prompt
area: infra
project: Guide
tags: [infra, mac-mini, openclaw, documentation, migration]
status: ready
created: 2026-05-18
author: Architect
---

# Mac Mini — Document Current Running State

Use this prompt with Claude Code on the Mac Mini to produce a complete snapshot of everything that's running. The output will be used by the Engineer on the new Ubuntu machine (Guide Z8) to replicate the structure accurately.

**Do not change anything. Read and document only.**

---

## The Prompt

You are helping me document the current state of the Guide system running on this Mac Mini. I am migrating to a new Ubuntu machine and need an accurate picture of everything here so the Engineer on the new machine can replicate it correctly.

Read only — do not modify any files.

Produce a single markdown document saved to `~/guide-build/Logs/mac-mini-state-YYYY-MM-DD.md` (use today's actual date). Structure it exactly as follows:

---

### 1. OpenClaw installation

- OpenClaw version (`openclaw --version` or check package.json)
- Install method (npm global, source, daemon)
- Config file location and full contents of `openclaw.json` — **redact all API keys, tokens, and secrets before writing. Replace each with `[REDACTED]`**
- Whether the daemon is running (`openclaw status` or `launchctl list | grep openclaw`)
- Port it is listening on

### 2. Workspace structure

Run `find ~/.openclaw/workspace -type f | sort` and list every file. Then for each file that is not a log or binary, show its contents.

Key files to capture in full (redact any secrets):
- All SOUL files
- All AGENTS files
- All TOOLS files
- All skills files
- Any config files

### 3. Active agents

List every agent that is currently configured, with:
- Agent ID
- Which channels it is bound to (Telegram, Slack, etc.)
- Which workspace files it uses

### 4. Channel configuration

For each channel (Telegram, Slack, WhatsApp if applicable):
- Bot name and username
- Which agent it routes to
- Any allowFrom or access control settings (redact tokens)

### 5. Cron jobs

Run `crontab -l` and show all entries. Also check for any launchd plists related to Guide (`ls ~/Library/LaunchAgents/ | grep -i guide` or `openclaw`).

### 6. Active personal instances

List each personal instance (Nick, Hadley, etc.):
- Bot username
- Workspace location
- Current status (running / not running)

### 7. Directory listing

Run `find ~/.openclaw -maxdepth 3 | sort` and show the full tree.

### 8. guide-core repo state

- Current branch
- Last commit message and date
- Any uncommitted changes (`git status`)

### 9. Environment

- Node version (`node --version`)
- npm version
- Any relevant environment variables set for OpenClaw (from .zshrc, .bashrc, or .env files — redact values, show variable names only)

### 10. Known issues or deferred work

List anything that is broken, partially configured, or known to need attention during the migration.

---

Save the completed document to `~/guide-build/Logs/mac-mini-state-YYYY-MM-DD.md`, then commit and push to GitHub so the Architect and Engineer can read it.

```bash
cd ~/guide-build
git add Logs/mac-mini-state-*.md
git commit -m "Add Mac Mini state snapshot for Z8 migration"
git push
```
