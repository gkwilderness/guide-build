# Guide — Build Vault

**Guide** is the AI chief of staff for Wilderness Safaris Group — serving the digital and growth function across three safari brands (Wilderness, Jacada, Yellow Zebra) via Telegram, WhatsApp, and Slack. It runs 20+ specialised agents on a dedicated machine and handles commercial intelligence, team operations, briefs, and data pipelines.

This repo is the **Architect's vault**: specs, agent definitions, build documentation, use-case research, and session logs. It is where Guide is designed. The code that runs it lives elsewhere.

---

## The Three Repos

| Repo | Purpose |
|------|---------|
| [`guide-build`](https://github.com/gkwilderness/guide-build) ← **you are here** | Specs, architecture, agent definitions, build chunks |
| `guide-core` | OpenClaw build files — agent factory, workspace templates, operational scripts |
| `guide-engine` | Data pipelines — ETL scripts, BigQuery, HubSpot, GA4, Ads exporters |

A fourth directory (`~/guide-data/`) holds markdown exports written by `guide-engine` and read by Guide agents at runtime. It is not a repo.

---

## Three-Role Architecture

| Role | Who / Where | Responsibility |
|------|-------------|----------------|
| **Architect** | Gareth's laptop, Claude Code in this vault | Designs specs, writes build chunks, manages docs |
| **Engineer** | Guide machine, Claude Code on bare metal | Executes chunks, writes and runs code, commits to `guide-core` |
| **Vault** | Guide machine, OpenClaw runtime | Live ops — serves the team via Telegram/Slack, delivers briefs |

The Architect decides **what** to build. The Engineer decides **how**. The Vault operates it.

---

## What's In This Repo

```
guide-build/
  00_Guide-Project-Brief.md   ← Start here — mission, scope, design philosophy
  BUILD.md                    ← Build roadmap (phases + chunk index)
  FEATURES.md                 ← Current and planned features, agent roster
  INTEGRATIONS.md             ← Data integrations (status, priority)
  INFRA.md                    ← Infrastructure — machine, network, access model
  BACKLOG.md                  ← Non-chunk work items
  CLAUDE.md                   ← Instructions for Claude Code sessions in this vault
  Agents/                     ← Agent specifications (Guide-Main, Briefing, Paid, SEO, etc.)
  BUILD/DEV-CHUNKS/           ← Executable build chunks — one chunk per capability increment
  Logs/                       ← Session context handover files
  Notes/                      ← Working notes and research
  Prompts/                    ← Reusable prompt templates for Engineer sessions
  Specs/                      ← Roster, filesystem layout, personal instance architecture
  Use-cases/                  ← Functional specs — Apex, CapitalCore, SEO, Lead Quality, Paid Media
```

---

## Build Status

Guide is **live — Phase 1 mostly complete. HP Z8 G4 migration in progress.**

| Phase | Name | Status |
|-------|------|--------|
| 0 | Foundation | Mostly complete — hardening deferred to Ubuntu |
| 1 | Context Fix + Personal Instances | Mostly complete — Paperclip + Keith outstanding |
| 2 | Post-Demo Team Ops | Not started |
| 3 | Data Layer | Not started |
| 4 | Brand Scale | Not started |
| 5–7 | Intelligence, Data Integrations, Productisation | Not started |

Current machine: Mac Mini M2 Pro (interim). HP Z8 G4 Ubuntu arriving imminently — migration in progress.

---

## Where to Start

- **Understanding the project:** `00_Guide-Project-Brief.md`
- **Understanding the build:** `BUILD.md`
- **Executing a build chunk:** `BUILD/DEV-CHUNKS/_CONVENTIONS.md` (read this first), then the relevant `CHUNK-NN-*.md`
- **Architectural decisions:** `BUILD/DEV-CHUNKS/DECISIONS.md`
- **Agent specs:** `Agents/`
- **What an agent does functionally:** `Use-cases/` (read `Use-cases/CLAUDE.md` first)

---

## Conventions

- **Secrets do not live here.** API keys and tokens belong on the Guide machine in `~/.openclaw/` config. `__CONFIG/` is excluded from this repo.
- **This repo is read-only on the Guide machine.** Changes are made by the Architect and pulled down. The Engineer does not commit to `guide-build`.
- **Build chunks are the unit of work.** Each chunk in `BUILD/DEV-CHUNKS/` is self-contained, has a verification step, and is designed to be handed to the Engineer as a complete instruction set.

---

*Wilderness Safaris Group — Digital & Growth*
