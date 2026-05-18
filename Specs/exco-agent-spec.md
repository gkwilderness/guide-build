# Exco Agent — Design Spec

**Status:** Superseded — absorbed into [[personal-instance-architecture]]
**Created:** 2026-04-23
**Superseded:** 2026-04-29
**Owner:** Gareth Knight

> **Note:** The personal instance architecture (2026-04-29) replaces this spec. Each exec gets their own dedicated agent with a per-person Telegram bot, rather than a single shared exco agent identifying users by phone number. The hybrid review model and per-exec framing from this spec are absorbed into each personal instance's SOUL.md.

---

## Problem

Exco (Keith, Hadley, Nick) will receive automated reports via WhatsApp (pulse, AI search readiness). They will reply with questions. We need an agent that can answer intelligently — cross-domain, strategically framed, careful with what it says.

## Proposal

Dedicated `exco` agent via the existing agent factory. New role, same infrastructure pattern as seo/data/martech/product/hubspot.

## How It Differs from Domain Agents

| Dimension | Domain agents (seo, data…) | Exco agent |
|-----------|---------------------------|------------|
| Audience | Operators | CEO, CCO, PE partner |
| Scope | Single domain | Cross-domain, report-led |
| Register | Process-level (PIE, sprints, backlogs) | Strategic (targets, pacing, threats, decisions) |
| Writes | Backlog updates, sprint comms | Nothing — read-only |
| Bound to | Slack channel | WhatsApp (once SIM is live) |

## Vault Context Chain

The agent loads these on startup:

| Source | Why |
|--------|-----|
| `00-Compass/CONTEXT.md` | Group structure, FY27 targets, team |
| `00-Compass/FY27/FY27-CEO-Commitments.md` | The numbers exco measures against |
| `00-Compass/FY27/FY27-Digital-House.md` | Strategic framing |
| `00-Compass/PRIORITIES.md` | What's active this quarter |
| `70-Reports/` | Pulse reports — performance data |
| `25-Channels/seo/__REPORTS/` | AI search readiness reports |
| `30-People/Stakeholders/` | Exec profiles — knows who it's talking to |

No access to internal process files (backlogs, PIE scores, sprint boards). The agent sees outcomes and strategy, not operating mechanics.

## Decision Required: Review Model

Three options for how the agent handles responses:

### Option 1 — Auto-respond
Agent replies directly to exco on WhatsApp. Fast. Risk: could misspeak to the CEO.

### Option 2 — Draft-and-queue
Every reply routes to Gareth for approval before delivery. Safe. Risk: Gareth becomes the bottleneck, defeats the purpose.

### Option 3 — Hybrid (recommended)
- **Factual / report questions** → agent answers directly. "What was last week's CPL?" "Where do we rank on AI search?" These are mechanical — the data is in the reports.
- **Judgment / recommendation questions** → agent drafts a response and escalates to Gareth via Slack DM for approval before sending. "Should we cut US Generic?" "Is the team big enough?"
- **Out-of-scope questions** → agent says it doesn't have that context and offers to flag Gareth.

The boundary between "factual" and "judgment" is encoded in the agent's SOUL.md.

## Per-Exec Framing

The agent adapts its register based on who it's talking to (identified via WhatsApp number):

- **Keith (CEO)** — conservation mission, vision, "digital as infrastructure not marketing". Big picture, not granular.
- **Nick (PE/Finance)** — capital allocation, ROI, plain language, no jargon. Wants proof points.
- **Hadley (CCO)** — commercial performance, team capacity, pipeline health. Gareth's line manager — more operational detail is fine.

Stakeholder profiles in `30-People/Stakeholders/` already capture these preferences.

## Build Steps

1. Create `roles/exco.env` in agent factory — vault paths, domain, tone, operator
2. Draft SOUL.md escalation rules (hybrid review boundary)
3. `generate.sh exco` → workspace
4. Register in openclaw: `agents add exco`
5. Bind to WhatsApp channel once SIM is live
6. Test with Gareth before any exec exposure

## Dependencies

- [ ] WhatsApp SIM decision (blocker for go-live, not for build)
- [ ] Review model decision (Option 1/2/3 — Gareth to confirm)
- [ ] Stakeholder profiles up to date in `30-People/Stakeholders/`

## What We Don't Need

- No new vault folders — reports and strategic context already exist
- No new CLAUDE.md files — report folders are already wired (2026-04-23)
- No changes to existing agents — exco is purely additive

---

*Drafted by Guide 🦁 | 2026-04-23*
