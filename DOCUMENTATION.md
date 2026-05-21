---
title: "Guide — Documentation"
type: documentation
area: ai
project: "Guide"
tags: [ai, guide, documentation]
status: active
updated: 2026-05-21
---
# Guide — Documentation

## Canonical References

| Document | Location | Purpose |
|----------|----------|---------|
| Project Brief | `00_Guide-Project-Brief.md` | Mission, scope, architecture, phases |
| Build Roadmap | `BUILD.md` | Phase map, chunk index |
| Build Conventions | `BUILD/DEV-CHUNKS/_CONVENTIONS.md` | Paths, ports, naming, chunk format |
| Features | `FEATURES.md` | Feature list + agent roster |
| Integrations | `INTEGRATIONS.md` | Data source status and priority |
| Infrastructure | `INFRA.md` | Machine spec, network, access model |
| Backlog | `BACKLOG.md` | Non-chunk work items |
| CLAUDE.md | `CLAUDE.md` | Claude Code working instructions |

## External References

| Resource | URL | Purpose |
|----------|-----|---------|
| OpenClaw | [github.com/openclaw](https://github.com/openclaw/openclaw) | Agent runtime |
| Paperclip | [paperclip.ing](https://paperclip.ing/) | Future orchestration layer (Phase 5 eval) |
| CapitalCore specs | `20-Projects/Wilderness/20-Projects/Group-Automation-GUIDE/CapitalCore/` | Capital allocation system |
| Apex specs | `20-Projects/Wilderness/20-Projects/Group-Automation-GUIDE/Apex/` | Competition diagnostics |

## Engineer Context Model

The Guide machine has the guide-build vault synced and all repos locally. The Engineer Claude reads specs directly — no need to copy content into sessions.

| Resource | Path on Guide Machine | Purpose |
|----------|-----------------------|---------|
| guide-build | `/srv/guide-build/` | All specs, briefs, CLAUDE.md files, chunks (read-only mount in container) |
| guide-core | `/srv/guide-core/` | OpenClaw runtime code (agent factory, workspace templates, scripts) |
| guide-engine | `/srv/guide-engine/` | Data pipeline scripts (ETL, exporters) — code |
| guide-data | `/srv/guide-data/` | Output directory — markdown written by guide-engine, read by agents. Not a repo. |

## Known Risks — OpenClaw CLI Drift

OpenClaw is moving fast. Chunks are specced from documentation research, not tested execution. There is a real risk that flag names or subcommand signatures differ from what we wrote — e.g. `openclaw cron add` may take different flags than specced.

**The Engineer can handle this** — reading `--help` output and adapting — but expect some chunks to need an extra debugging round rather than executing clean first time. This is not a competence issue; it is a spec-vs-reality gap.

**Mitigation:** Before starting any chunk work, Engineer Claude must run:

```bash
openclaw --help
openclaw cron --help
openclaw channels --help
openclaw credentials --help
```

This surfaces the actual CLI surface before attempting chunk tasks. Adapt flags to match actual output. If a command is structurally different from the spec, surface the delta to Gareth — don't guess and push forward.

---

## Knowledge Gaps

- [x] ~~WhatsApp Business API~~ — Not needed. OpenClaw uses Baileys (WhatsApp Web bridge). Dedicated SIM + QR scan.
- [x] ~~Slack app setup~~ — Uses Slack Bolt + Socket Mode. Bot token + App token. Scopes documented in `__CONFIG/GUIDE.md`.
- [x] ~~Vault sync mechanism~~ — guide-build cloned to `/srv/guide-build/` (git pull). Digital team vault via Obsidian Sync to `/srv/guide-vaults/teams/digital/`. Exco + shared vaults populated directly.
- [ ] Data API rate limits per source (GA4, Google Ads, HubSpot, Meta, Bing, DV360)
- [ ] Multi-brand HubSpot setup — one portal or three?
- [ ] Paperclip production readiness (revisit monthly)

---

*Updated: 2026-05-21 — Engineer context paths corrected to /srv/; vault sync gap resolved*
