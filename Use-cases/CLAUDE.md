# CLAUDE.md — Group-Automation-GUIDE-Use-cases

## What This Folder Is

This is the **functional specification layer** for Guide's intelligence modules — what CapitalCore, Apex, Lead Quality Engineering, and SEO agents actually *do*, expressed as use cases, module definitions, data requirements, and frameworks.

It is distinct from `~/guide-build/`, which is the runtime/build layer (agent behaviour, OpenClaw config, build chunks, infrastructure).

**Rule:** If you're designing what a module should do and why → this folder. If you're building or configuring how it runs → guide-build.

---

## Folder Map

| Folder | Contents |
|--------|----------|
| `CapitalCore/` | Capital allocation intelligence — firebreak modules, API specs, DB schema, system architecture, deployment guide, dev phases |
| `Apex/` | PPC diagnostic engine — diagnostic stack, use cases, skills, MVP playbook, data requirements, session logs |
| `Lead_Quality_Engineering/` | Lead quality frameworks — tactics, paid media structure, HNW ad copy language |
| `SEO/` | SEO as a Guide use case — Richard's advanced SEO diagnostic system, YZ SEO analysis |
| `Library/` | Reference data — camp lists, live URLs, TripAdvisor pages, wildlife regions |
| `_META/` | Strategic narratives — CapitalCore vs Apex boundaries, Nick pitch, onboarding |
| `_Notes/` | Working notes |
| `Templates/` | Project templates |

---

## Relationship to guide-build

| Layer | Location | Contains |
|-------|----------|----------|
| **Functional specs** | This folder (Wilderness vault) | What modules do, use cases, data requirements, module definitions |
| **Agent specs** | `~/guide-build/Agents/` | How agents behave — routing, persona, tool access, OpenClaw config |
| **Build chunks** | `~/guide-build/BUILD/DEV-CHUNKS/` | Executable implementation steps for the Engineer role |
| **Runtime code** | `~/guide-core/` | OpenClaw build files, agent factory |
| **Data pipelines** | `~/guide-engine/` | ETL scripts, BQ tools, GA4/Ads exporters |

---

## Key Files to Read First

- `CapitalCore/CapitalCore_INDEX.md` — module index and project status
- `Apex/Apex_INDEX.md` — diagnostic stack overview and project status
- `_META/CapitalCore vs Apex Boundaries.md` — where each system's scope begins and ends

---

*Updated: 2026-05-13*
