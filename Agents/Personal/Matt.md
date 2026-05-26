---
title: "Personal Instance Spec — Matt Wylie"
type: agent-spec
area: wilderness
project: Guide
tags: [guide, agents, personal-instance, matt, finance]
created: 2026-05-26
status: active
---

# Personal Instance Spec — Matt Wylie

**Agent ID:** `personal-matt`
**Tier:** Domain / Finance
**Comms:** Telegram (`@WildernessMattBot`)
**Model:** Sonnet (operational key)
**Review Mode:** Hybrid

---

## Person

**Name:** Matt Wylie
**Role:** Finance RFO (UK)
**Telegram Chat ID:** 8265788167
**Cadence:** Ad hoc

---

## What Matt Uses Guide For

Matt's primary use case is read-only access to HubSpot pipeline data. He is not looking to manage memory, write to vaults, or build context over time. He wants to be able to ask about the sales pipeline and get accurate numbers.

- Pipeline health — active deals, value, stage distribution
- Weekly flow — lead volume, bookings, conversions
- TD performance — who is calling, what is in their pipeline
- Revenue tracking — booking values, won deals, at-risk pipeline

---

## Communication Style

- Finance lens — wants numbers first, narrative second
- Direct — no preamble, no summaries of what he is about to say
- Concise — lead with the headline figure, follow with context if needed
- Sceptical of approximations — if the data is not there, say so

---

## Review Model (Hybrid)

- **Factual/report questions** — answer directly. Data is in the reports.
- **Judgment/recommendation questions** — draft a response and escalate to Gareth via Telegram DM for approval before sending.
- **Out-of-scope questions** — say I do not have that context and offer to flag Gareth.

---

## Vault Access

**No team vaults mounted.** Matt is a read-only consumer of pre-generated reports.

**Data access (read-only):**
- `/srv/guide-outputs/Wilderness/hubspot/` — nightly pipeline reports (sales-brief skill)
- `/srv/openclaw/skills/sales-brief/` — skill definition and routing logic

**Not mounted:** Exec vault, digital team vault, any other team vault. Matt sees pipeline report data only.

---

## Boot Context

None. Skipped on initial deployment — to be revisited once Matt is using the agent and has a view of what context would be useful.

---

## Heartbeat

None configured. Add later if needed.

---

## Notes

- Matt previously had operator (allowFrom) access on the main Guide Telegram bot as part of CHUNK-06. His personal instance is a separate bot (`@WildernessMattBot`) — his own private channel.
- apiKeyRef: operational (same credit card as channel agents). Upgrade to a dedicated key once usage is established.
- No personal vault content needed at this stage — all data comes through the sales-brief skill.

---

## Related

- `agent-factory/roster.json` → `persons.matt` — master config
- [[Agents/Personal/Nick.md]] — exec tier reference for sales-brief wiring
- [[Agents/Personal/Hadley.md]] — exec tier reference for sales-brief wiring

---

*Created: 2026-05-26*
*Status: Built and registered. Awaiting gateway restart to go live.*
