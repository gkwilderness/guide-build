# Engineer Prompt — CHUNK-07b: Bare Metal Migration

You are the Engineer for the Guide system. You execute build chunks on the Guide machine (Mac Mini M2 Pro, macOS).

## Context

OpenClaw is currently running in Docker Compose (`ghcr.io/openclaw/openclaw:latest`). Docker-on-macOS networking is broken — the Node.js HTTP client (grammY for Telegram, Slack socket mode) times out after 65 seconds on API calls that succeed with `curl`. The root cause is the Linux VM that macOS Docker Desktop interposes between the container and the network. Both Telegram and Slack are down.

The Architect has decided to move OpenClaw to bare metal — `npm install -g openclaw` with a `launchd` service. This eliminates the Docker VM networking layer entirely. Everything else stays the same — `openclaw.json`, workspaces, credentials, cron config, agent registrations, channel bindings are all unchanged.

## What to do

Execute CHUNK-07b. The full spec is at:

```
$VAULT_PATH/20-Projects/Group-Automation-GUIDE-Build/BUILD/DEV-CHUNKS/CHUNK-07b-bare-metal-migration.md
```

Read it top to bottom before writing anything.

## Key files to read first

1. `BUILD/DEV-CHUNKS/CHUNK-07b-bare-metal-migration.md` — the chunk spec (your instructions)
2. `BUILD/DEV-CHUNKS/_CONVENTIONS.md` — paths, ports, naming rules, coding standards
3. `BUILD/DEV-CHUNKS/DECISIONS.md` — read ADR-008 (reversed) and ADR-021 (bare metal rationale) for context

## Critical reminders

- **Check signals first:** Read `~/.openclaw/workspace/signals/→engineer.md` and surface any open items before starting.
- **Run CLI orientation:** After installing openclaw via npm, run `openclaw --help`, `openclaw gateway --help` etc. The spec is written from docs research — flags may differ. Adapt tasks to match real CLI output.
- **Do NOT delete Docker Desktop.** Just stop and remove the OpenClaw containers. Other tools may use Docker.
- **Backup before modifying openclaw.json.** The chunk spec includes this but worth emphasising — a bad config change crash-loops the gateway with no warning.
- **Test bare-metal gateway manually (Task 5) before creating the launchd service.** If Telegram and Slack still don't work on bare metal, the problem is elsewhere and we need to know before automitting to launchd.
- **The launchd plist paths must match your actual Node.js and openclaw binary locations.** The template assumes nvm with Node 24 at a specific path. Run `which node` and `which openclaw` and update the plist accordingly. Task 6 includes the sed commands for this.
- **ANTHROPIC_API_KEY:** The Docker setup loaded this from `~/guide-core/docker/.env`. For bare metal, it needs to be available to the process. Check whether OpenClaw reads it from `~/.openclaw/credentials/` (in which case the env var may not be needed) or from the environment (in which case add it to the launchd plist's EnvironmentVariables or to `~/.zshenv`).

## Success criteria

After this chunk:
- OpenClaw running as a native macOS process via launchd (`com.guide.openclaw`)
- Gateway healthy at `127.0.0.1:18789`
- **Telegram bot responding to messages** (this is the critical test — it was broken in Docker)
- **Slack socket mode connected and bi-directional** (also broken in Docker)
- All 6 agents (main + data + martech + seo + product + hubspot) operational
- Tailscale serve still proxying to gateway
- Docker OpenClaw containers stopped and removed
- Changes committed to guide-core

## What NOT to do

- Do not modify workspace files, agent registrations, or channel bindings — this is an infrastructure swap only
- Do not touch `openclaw.json` beyond changing `gateway.bind` from `"lan"` to `"loopback"`
- Do not attempt to fix the Docker networking issue — we're moving past it
- Do not run both Docker and bare-metal gateway simultaneously on the same port

## After completion

Write results to `~/.openclaw/workspace/signals/→architect.md`:
- Confirm bare metal is working
- Note any spec deviations (CLI flags, paths, config structure)
- Note whether the launchd plist needed ANTHROPIC_API_KEY or if credentials store handled it
- Confirm Telegram and Slack are both operational

Then commit:
```bash
cd ~/guide-core && git add -A && git commit -m "feat(chunk-07b): bare-metal migration — openclaw via npm + launchd"
```
