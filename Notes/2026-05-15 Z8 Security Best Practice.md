---
title: "Z8 Security Best Practice"
type: note
area: infra
project: Guide
tags: [security, z8, ubuntu, docker, claude-code, openclaw]
status: active
created: 2026-05-15
---

# Z8 Security Best Practice

Reference note for CHUNK-07 hardening execution. Run through all sections when the Ubuntu migration is stable.

---

## Host-Level (Ubuntu Z8)

- UFW firewall — default deny inbound. Only SSH and Tailscale allowed. Everything else closed.
- SSH — key-only auth, password auth disabled, root login disabled, non-standard port optional
- Fail2ban on SSH
- Unattended security upgrades enabled
- All services bind 127.0.0.1 or Docker internal network only. Nothing exposed to LAN or internet directly.
- Tailscale is the only remote access path — keep it that way

---

## Docker

- Services run as non-root users inside containers
- Read-only filesystems where possible
- Docker socket (`/var/run/docker.sock`) access locked down — if a container gets it, it effectively owns the host
- Resource limits per container (CPU, memory) — especially Ollama and Hermes which can be hungry
- Network isolation between container groups — Guide containers shouldn't be able to reach Hermes containers directly unless designed to

---

## Secrets

- No API keys baked into images or config files in plaintext where avoidable
- `.env` files with restricted permissions (600, root-owned)
- Separate API keys per service — Telegram tokens, Anthropic keys, Slack tokens all distinct
- Rotate periodically

---

## Claude Code on the Z8

Claude Code has broad filesystem and shell access by design. On a production server running Guide, that's a real exposure vector.

- Engineer Claude Code sessions run in a Docker container or devcontainer with a defined working directory — not loose on the host
- Scoped to `~/guide-core/` and `~/guide-engine/` only — not `~/.openclaw/` or vault dirs
- Separate system user for Engineer sessions with restricted home
- Never run Claude Code as root
- Architect runs on Gareth's Mac (not the Z8) — maintain that separation

---

## OpenClaw / Guide

- CHUNK-07 hardening spec was written but deferred to Ubuntu — execute it early, before the full stack is live
- Per-agent `tools.exec` permissions — keep them tight
- `allowFrom` lists locked down on every channel/account
- Gateway token rotated periodically
- Session retention limits — already set

---

## Monitoring

- Login monitor cron — already running
- Failed auth alerts (SSH, gateway token failures)
- Anthropic API usage monitoring — catch runaway agent loops early
- Docker container health checks

---

## Priority

Run CHUNK-07 before any new agents (Hermes, Open WebUI, Ollama) go live on the Z8.
