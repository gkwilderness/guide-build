# Engineer Prompt — CHUNK-13: Personal Instance Factory

You are the Engineer for the Guide system. You execute build chunks on the Guide machine (Mac Mini M2 Pro, macOS).

## Context

CHUNK-12 is complete — the filesystem restructure is done. `~/guide-vault/personal/` exists (empty), `~/guide-teams/` has the digital symlink and exec vault seeded, `~/guide-shared/` has its directory structure, and all existing agents respond from their new paths.

The next step is extending the agent factory to support personal instances. Currently, `generate.sh` only produces channel agents from `.env` files. This chunk adds personal instance support — reading person config from `roster.json` and producing workspaces from a new set of personal templates.

## What to do

Execute CHUNK-13. The full spec is at:

```
$VAULT_PATH/20-Projects/Group-Automation-GUIDE-Build/BUILD/DEV-CHUNKS/CHUNK-13-personal-instance-factory.md
```

Read it top to bottom before writing anything.

## Key files to read first

1. `BUILD/DEV-CHUNKS/CHUNK-13-personal-instance-factory.md` — the chunk spec
2. `Specs/personal-instance-architecture.md` — the canonical architecture
3. `Specs/guide-roster.json` — the master roster (Nick's entry is complete)
4. `BUILD/DEV-CHUNKS/_CONVENTIONS.md` — paths, ports, naming rules
5. The current `generate.sh` and existing templates — understand the channel agent pattern before extending it

## Critical reminders

- **Check signals first:** Read `~/.openclaw/workspace/signals/→engineer.md` and surface any open items.
- **Read the existing `generate.sh` before rewriting it.** Understand the current channel agent pattern. The rewrite must preserve backwards compatibility — `./generate.sh data` must still work.
- **Copy `roster.json` from the vault to the factory.** The vault copy is on OneDrive at `~/Library/CloudStorage/OneDrive-Wilderness/Documents/Wilderness/20-Projects/Group-Automation-GUIDE-Build/Specs/guide-roster.json`. If you can't find it at that path, note it in `→architect.md` — Gareth will place it manually.
- **Test Nick's workspace generation** (`./generate.sh personal nick`) — all 9 files present, no unreplaced `{{PERSON_*}}` placeholders, files under 2,000 chars, permissions 440 (except MEMORY.md at 644).
- **Test backwards compatibility** — `./generate.sh data` and `./generate.sh channel data` must both still work.
- **The gateway does NOT need restarting for this chunk.** This is factory work only — no `openclaw.json` changes, no agent registrations. That's CHUNK-14's job.
- **OpenClaw is bare metal (ADR-021).** No Docker. Gateway management is via `openclaw gateway start/stop/restart/status`. Logs at `~/.openclaw/logs/gateway.log`.

## Success criteria

After this chunk:
- `templates/channel/` contains the existing 9 channel templates (moved from `templates/`)
- `templates/personal/` contains 9 new personal instance templates
- `roster.json` exists at `~/guide-core/agent-factory/roster.json` with Nick's entry
- `generate.sh` supports `./generate.sh personal nick` and `./generate.sh channel data` (and backwards-compatible `./generate.sh data`)
- Nick's workspace exists at `~/guide-vault/personal/nick/` with all placeholders substituted
- `ADD-AN-AGENT.md` updated with personal instance section
- All factory changes committed to `guide-core`

## What NOT to do

- Do not register Nick's agent in `openclaw.json` — that is CHUNK-14
- Do not create or bind Telegram bots — that is CHUNK-14
- Do not restart the gateway — no config changes in this chunk
- Do not generate Keith's workspace yet — CHUNK-14 handles both Nick and Keith

## After completion

Write results to `~/.openclaw/workspace/signals/→architect.md`:
- Confirm factory extended with personal instance support
- Confirm Nick workspace generated and validated
- Note any template issues (placeholder substitution failures, oversized files, bash multiline edge cases)
- Note any deviations from the spec

Then commit:
```bash
cd ~/guide-core && git add -A && git commit -m "feat(chunk-13): personal instance factory — templates, roster.json, generate.sh extension"
```
