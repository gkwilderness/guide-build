# Engineer Prompt — CHUNK-14: Personal Instances — Nick + Keith

You are the Engineer for the Guide system. You execute build chunks on the Guide machine (Mac Mini M2 Pro, macOS).

## Context

CHUNK-13 is complete — the personal instance factory works. `./generate.sh personal nick` produces a valid workspace at `~/guide-vault/personal/nick/`. The factory reads from `roster.json`.

This chunk takes Nick (and Keith) from generated workspace to live operation. The critical unknown is whether OpenClaw supports multiple Telegram bots — Task 1 answers this before anything else.

**Gareth has already:**
- Created `@WildernessGuideNickBot` via BotFather
- Nick's Telegram chat ID is in `roster.json`: `8516698636`

**Gareth pre-tasks before you start (confirm these are done):**
- Bot token stored at `~/guide-core/__CONFIG/keys/telegram-nick`
- Keith: `@GuideKeithBot` created, token stored at `~/guide-core/__CONFIG/keys/telegram-keith`, chat ID collected

If Keith's pre-tasks are not done, proceed with Nick only. Keith can be added later — the pattern is identical.

## What to do

Execute CHUNK-14. The full spec is at:

```
$VAULT_PATH/20-Projects/Group-Automation-GUIDE-Build/BUILD/DEV-CHUNKS/CHUNK-14-personal-instance-nick.md
```

Read it top to bottom before writing anything.

## Key files to read first

1. `BUILD/DEV-CHUNKS/CHUNK-14-personal-instance-nick.md` — the chunk spec
2. `Specs/personal-instance-architecture.md` — the architecture (privacy model, vault access)
3. `Specs/guide-roster.json` — Nick's and Keith's entries
4. `Agents/Personal/Nick.md` — Nick's person spec
5. `BUILD/DEV-CHUNKS/_CONVENTIONS.md` — paths, ports, naming rules
6. The current `openclaw.json` — understand existing agent registration pattern before adding

## Critical reminders

- **Check signals first:** Read `~/.openclaw/workspace/signals/→engineer.md` and surface any open items.
- **Task 1 (multi-bot Telegram schema) is BLOCKING.** Do not proceed to Task 2 until you know how OpenClaw handles multiple Telegram bots. Document findings in `→architect.md` regardless of outcome.
- **Validate against the OpenClaw schema before writing to `openclaw.json`.** Run `openclaw config schema` and check every key you add. `additionalProperties: false` means any unrecognised key causes a crash-loop. This has happened before (2026-04-17 incident — see CLAUDE.md Known Pitfalls).
- **Backup `openclaw.json` before any changes:** `cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak-chunk14`
- **Personal instances must have exec denied** (ADR-022). The tools.deny list must include `["process", "code_execution", "group:automation", "exec"]`. Do not give personal instances shell access.
- **Gateway management is via `openclaw gateway start/stop/restart/status`** (bare metal, ADR-021). Not launchctl directly. Logs at `~/.openclaw/logs/gateway.log` and `/tmp/openclaw/openclaw-YYYY-MM-DD.log`.
- **If the gateway fails to start after config changes**, restore from backup immediately:
  ```bash
  cp ~/.openclaw/openclaw.json.bak-chunk14 ~/.openclaw/openclaw.json
  openclaw gateway restart
  ```

## Success criteria

After this chunk:
- OpenClaw multi-bot Telegram support verified and documented
- `personal-nick` agent registered in `openclaw.json`
- `@WildernessGuideNickBot` bound to `personal-nick` agent
- Gateway healthy with Nick's agent live alongside Guide Main and all channel agents
- Guide Main still responds normally on Telegram and Slack
- Nick bot responds on Telegram (Gareth tests — 8 scenarios in the spec)
- If Keith is ready: same for `personal-keith` and `@GuideKeithBot`

## What NOT to do

- Do not modify Nick's workspace files — those were generated in CHUNK-13
- Do not modify the factory or templates — that was CHUNK-13
- Do not add keys to `openclaw.json` without verifying them against the schema first
- Do not give personal instances exec/bash access
- Do not skip the schema check in Task 1 — it's the critical unknown

## Hybrid review — escalation path

The SOUL.md instructs Nick's agent to escalate judgment questions to Gareth. Check whether the personal instance has access to a messaging tool that can reach Gareth (Slack DM or Telegram). If not, the escalation path needs an alternative — e.g., appending to a signal file or using Guide Main as a relay. Document whatever you find and implement.

## After completion

Write results to `~/.openclaw/workspace/signals/→architect.md`:
- Multi-bot Telegram schema findings (critical — affects all future personal instances)
- Confirm Nick registered and responding
- Confirm Keith registered and responding (if ready)
- Confirm Guide Main unaffected
- Note any deviations from the spec
- Note the escalation path implemented for hybrid review

Then commit:
```bash
cd ~/guide-core && git add -A && git commit -m "feat(chunk-14): personal-nick + personal-keith instances — registered, telegram bound, tested"
```

Gareth will then run the manual test plan (Task 5/5b in the spec) and tune SOUL.md as needed.
