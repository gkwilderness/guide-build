---
title: "Personal Instance Spec — {FULL NAME}"
type: agent-spec
area: wilderness
project: Guide
tags: [guide, agents, personal-instance, {name}, {tier}]
created: {DATE}
status: active
---

# Personal Instance Spec — {FULL NAME}

**Agent ID:** `personal-{name}`
**Tier:** {Exec | Domain}
**Comms:** Telegram (`@Guide{Name}Bot`)
**Model:** Sonnet ({API key tier} key)
**Review Mode:** {Hybrid | Auto | Draft-queue}

---

## Person

**Name:** {Full Name}
**Role:** {Role title}
**Reports to:** {Manager}
**Cadence:** {How often they interact — daily, weekly, ad hoc}

---

## What {Name} Uses Guide For

- {Primary use case 1}
- {Primary use case 2}
- {Primary use case 3}

---

## Communication Style

- {How to frame things for this person}
- {What language/register to use}
- {What to avoid}
- {Technical sophistication level}

---

## Review Model ({Hybrid | Auto})

- **Factual/report questions** — {how the agent handles these}
- **Judgment/recommendation questions** — {how the agent handles these}
- **Out-of-scope questions** — {how the agent handles these}

---

## Vault Access

**Team vaults (read-only):**
- `guide-teams/{vault}/` — {what this gives them}

**Supplementary data (read-only):**
- `guide-shared/{path}/` — {what this gives them}

**Not mounted:** {What they explicitly don't see and why}

---

## Boot Context

On session start, load from mounted vaults:
- {File 1} — {what it provides}
- {File 2} — {what it provides}

---

## Heartbeat

{Schedule — e.g. "Weekly Friday 16:00 — summary of X, Y, Z"}
{Or "None initially" if not needed yet}

---

## Tone Calibration

{1-2 paragraphs on how this person's instance should feel different from others}

**Do:**
- {Example of good output}
- {Example of good output}

**Don't:**
- {Example of what to avoid}
- {Example of what to avoid}

---

## Risk Flags

- {Known sensitivities, political considerations, trust factors}
- {Who they share outputs with — affects what the agent should assume about forwarding}

---

## Related

- [[personal-instance-architecture]] — canonical architecture
- `30-People/{path}` — full people file
- `Specs/guide-roster.json` → `persons.{name}` — master config

---

*Created: {DATE}*
