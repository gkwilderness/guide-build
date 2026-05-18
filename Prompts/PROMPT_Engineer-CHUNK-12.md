# Engineer Prompt — CHUNK-12: Team Vault Architecture

You are the Engineer for the Guide system. You execute build chunks on the Guide machine (Mac Mini M2 Pro, macOS).

## Context

Guide is now running bare metal (CHUNK-07b complete). OpenClaw is a launchd service — no Docker.

The next step is restructuring the filesystem for the personal instance architecture. Currently, agent workspaces live as flat directories under `~/.openclaw/workspace-*`. The new structure organises them into `~/guide-vault/` (agent workspaces), `~/guide-teams/` (team vaults), `~/guide-shared/` (supplementary data), and `~/guide-outputs/` (audit trail).

This is a **migration** — existing workspaces move from their current locations into the new structure. `openclaw.json` paths must be updated simultaneously.

## What to do

Execute CHUNK-12. The full spec is at:

```
$VAULT_PATH/20-Projects/Group-Automation-GUIDE-Build/BUILD/DEV-CHUNKS/CHUNK-12-team-vault-architecture.md
```

Read it top to bottom before writing anything.

**There is also a bootstrap script** that automates most of the work:

```
$VAULT_PATH/20-Projects/Group-Automation-GUIDE-Build/Specs/guide-bootstrap.sh
```

Copy it to the Guide machine and run it. It is idempotent and has `--dry-run` support. Run `--dry-run` first to preview, then run for real. The script handles:
1. Creating `guide-vault/` with `main/`, `channel/`, `shared/`, `personal/`
2. Migrating workspaces from `~/.openclaw/workspace-*`
3. Creating `guide-teams/` with digital vault symlink and exec vault seed
4. Creating `guide-shared/` directory structure
5. Creating `guide-outputs/` with git init
6. Updating `openclaw.json` workspace paths
7. Updating `generate.sh` output path
8. Git-initialising `guide-vault/`

After the script, restart the gateway and verify.

## Key files to read first

1. `BUILD/DEV-CHUNKS/CHUNK-12-team-vault-architecture.md` — the chunk spec
2. `Specs/guide-bootstrap.sh` — the automation script
3. `Specs/personal-instance-architecture.md` — the canonical architecture (for context on why this structure)
4. `BUILD/DEV-CHUNKS/_CONVENTIONS.md` — paths, ports, naming rules

## Critical reminders

- **Check signals first:** Read `~/.openclaw/workspace/signals/→engineer.md` and surface any open items.
- **Run the bootstrap script with `--dry-run` first.** Review the output before running for real.
- **The gateway must be stopped during workspace migration.** The script does NOT stop the gateway — you must do this manually before running it:
  ```bash
  openclaw gateway stop
  ```
- **After the script completes, restart the gateway:**
  ```bash
  openclaw gateway start
  ```
- **The digital team vault is a local Obsidian vault at `~/Obsidian/Wilderness-Guide/` — NOT on OneDrive.** The symlink `~/guide-teams/digital/` points there. OneDrive root is `~/Library/CloudStorage/OneDrive-Wilderness/` (note: `-Wilderness`, not `-WildernessSafaris`). Task 1 confirms both paths.
- **Do NOT delete the old `~/.openclaw/workspace-*` directories yet.** They are the safety net. Remove them only after CHUNK-13 is confirmed working.
- **OpenClaw is bare metal now (ADR-021).** No Docker commands. Gateway management is via `openclaw gateway start/stop/restart/status`. Logs are at `~/.openclaw/logs/gateway.log` and `/tmp/openclaw/openclaw-YYYY-MM-DD.log`.

## Success criteria

After this chunk:
- `~/guide-vault/` exists with `main/`, `channel/` (5 agents), `shared/`, `personal/` (empty)
- `~/guide-teams/digital/` is a symlink to the Wilderness-Guide vault on OneDrive — and the symlink resolves (test: `ls ~/guide-teams/digital/CLAUDE.md`)
- `~/guide-teams/exec/` exists with `CLAUDE.md` and `PRIORITIES.md`
- `~/guide-shared/` has `brand/`, `data/`, `kb/` subdirectories
- `~/guide-outputs/` is git-initialised with seed files
- `openclaw.json` workspace paths all point to `~/guide-vault/*`
- `generate.sh` outputs to `~/guide-vault/channel/`
- Gateway is healthy, all 6 agents respond from their new paths
- Telegram and Slack both working (confirm — they were just fixed in CHUNK-07b)

## What NOT to do

- Do not create personal instance workspaces — that is CHUNK-13/14
- Do not modify agent registrations or channel bindings — this is a filesystem restructure only
- Do not delete old workspaces yet
- Do not use Docker commands — OpenClaw is bare metal now

## After completion

Write results to `~/.openclaw/workspace/signals/→architect.md`:
- Confirm filesystem structure created
- Note the exact OneDrive path used for the digital vault symlink
- Confirm all agents respond from new paths
- Note any deviations from the spec

Then commit:
```bash
cd ~/guide-core && git add -A && git commit -m "feat(chunk-12): team vault architecture — filesystem restructure, workspace migration"
```

Also commit the guide-vault:
```bash
cd ~/guide-vault && git add -A && git commit -m "init: guide-vault — production directory structure"
```
