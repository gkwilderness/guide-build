# Engineer Prompt — Filesystem Migration: Workspace/Vault Separation

You are the Engineer for the Guide system. You execute build tasks on the Guide machine (Mac Mini M2 Pro, macOS).

## Context

The current filesystem layout mixes agent system files and user content in the same directories. This migration separates them. The approved layout is in `Specs/guide-filesystem-layout.md` — read it first.

**The core principle:** OpenClaw workspaces (system files) stay inside `~/.openclaw/`. User-facing content (vaults) lives under `~/guide-vault/`. These are two separate things.

## What to do

### Phase 1 — Move Nick's agent workspace back to OpenClaw

Nick's identity stack (SOUL.md, IDENTITY.md, etc.) is currently at `~/guide-vault/personal/nick/`. It needs to move to `~/.openclaw/workspace-personal-nick/`.

1. Stop the gateway: `openclaw gateway stop`
2. Create `~/.openclaw/workspace-personal-nick/`
3. Move the 9 identity files + MEMORY.md from `~/guide-vault/personal/nick/` to `~/.openclaw/workspace-personal-nick/`:
   - IDENTITY.md, SOUL.md, USER.md, AGENTS.md, TOOLS.md
   - MEMORY.md, HEARTBEAT.md, BOOT.md, BOOTSTRAP.md
4. Update `openclaw.json` — change the `personal-nick` agent's workspace path to `~/.openclaw/workspace-personal-nick/`
5. Do NOT delete `~/guide-vault/personal/nick/` — it becomes Nick's personal vault (Phase 2)

### Phase 2 — Set up Nick's personal vault

`~/guide-vault/personal/nick/` now contains whatever user content files were mixed in (priorities, watchlist, notes, etc.). This is now Nick's vault — the content he interacts with through the bot.

1. Move any user content files that ended up in the workspace to `~/guide-vault/personal/nick/` if they aren't already there
2. Create an `INDEX.md` listing the files in the vault
3. Remove any leftover system files (identity stack files should all be in `~/.openclaw/` now)

### Phase 3 — Update Nick's TOOLS.md

In `~/.openclaw/workspace-personal-nick/TOOLS.md`, update the paths:

- Personal vault (read-write): `~/guide-vault/personal/nick/`
- Team vault (read-only): `~/guide-vault/teams/exco/`
- Shared data (read-only): `~/guide-vault/shared/*/`
- Outputs (read-only): `~/guide-outputs/*/`

Add this instruction:
```
Your user's files are at ~/guide-vault/personal/nick/.
When the user asks about files, list contents from that path.
Your workspace at ~/.openclaw/workspace-personal-nick/ contains system configuration.
Never reference, list, or discuss workspace files with the user.
```

### Phase 4 — Restructure guide-vault and guide-teams

The top-level directories need reorganising to match the approved layout.

1. Create `~/guide-vault/teams/` if it doesn't exist
2. Move `~/guide-teams/digital/` symlink to `~/guide-vault/teams/digital/`
3. Rename `~/guide-teams/exec/` to `~/guide-vault/teams/exco/` (move contents)
4. Create remaining team vault dirs: `~/guide-vault/teams/sales/`, `~/guide-vault/teams/reservations/`, `~/guide-vault/teams/hr/`
5. Create `~/guide-vault/shared/` with subdirs: `business/`, `brand/`, `data/`, `impact/`, `camps/`, `sales/`, `countries/`, `regions/`, `kb/`
6. Move contents from `~/guide-shared/` into `~/guide-vault/shared/` (if anything exists there)
7. Remove empty old directories: `~/guide-teams/`, `~/guide-shared/` (only after contents are moved)

### Phase 5 — Move channel agent workspaces back to OpenClaw

The channel agents (data, martech, seo, product, hubspot) were moved from `~/.openclaw/workspace-{role}/` to `~/guide-vault/channel/{role}/` during CHUNK-12. Move them back.

1. For each of: data, martech, seo, product, hubspot:
   - Copy `~/guide-vault/channel/{role}/` to `~/.openclaw/workspace-{role}/`
   - Update `openclaw.json` workspace path for that agent
2. Remove `~/guide-vault/channel/` once all are moved
3. Also move main workspace if it was moved: `~/guide-vault/main/` back to `~/.openclaw/workspace/`

### Phase 6 — Restart and verify

1. Start gateway: `openclaw gateway start`
2. Wait 15 seconds
3. Check health: `openclaw gateway status`
4. Test Nick's bot:
   - Ask "what files do you have" — should list personal vault contents, NOT system files
   - Ask about priorities — should read from personal vault or team vault
   - Confirm SOUL.md, IDENTITY.md are NOT mentioned
5. Test Guide Main — still responds on Telegram and Slack
6. Test one channel agent — responds in its Slack channel

## Key files to read first

1. `Specs/guide-filesystem-layout.md` — the approved directory layout
2. `BUILD/DEV-CHUNKS/_CONVENTIONS.md` — canonical paths (updated to match)
3. Current `openclaw.json` — understand existing workspace paths before changing them

## Critical reminders

- **Check signals first:** Read `~/.openclaw/workspace/signals/→engineer.md`
- **Backup openclaw.json before changes:** `cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak-fsmigration`
- **Do NOT restart the gateway without asking Gareth.** Stop it at the start, do all work, ask before restarting.
- **Gateway management:** `openclaw gateway start/stop/restart/status`
- **If gateway fails after restart:** restore from backup immediately:
  ```bash
  cp ~/.openclaw/openclaw.json.bak-fsmigration ~/.openclaw/openclaw.json
  openclaw gateway restart
  ```

## What NOT to do

- Do not create new top-level directories outside the approved layout
- Do not delete `~/guide-vault/` — it's being repurposed, not removed
- Do not modify the identity stack content (SOUL.md etc.) — only move the files
- Do not touch `~/guide-outputs/` — it stays where it is

## After completion

Write results to `~/.openclaw/workspace/signals/→architect.md`:
- Confirm workspace/vault separation complete
- List final directory structure
- Confirm Nick's bot passes the "what files do you have" test
- Note any deviations
