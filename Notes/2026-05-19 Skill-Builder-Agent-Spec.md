---
title: "Skill Builder Agent — Spec"
type: spec
area: ai
tags: [ai, training, agent, spec]
status: inbox
date: 2026-05-17
---

# Skill Builder Agent — Spec

## Problem

Training a distributed team on new skills (HubSpot, PPC, SEO, data literacy) is slow and uneven. One-to-one coaching doesn't scale. Static docs don't get read. We need something that meets people where they are — in chat — and adapts to their pace.

## Genesis

This came out of a conversation about Jack Sweet and the gap between what he needs to know and what he currently knows. Ashleigh Waterson was the prompt — her onboarding and the question of how to bring someone up to speed quickly without pulling senior resource into repeated 1:1s. Jack was the first concrete use case.

## What It Does

A dedicated Guide sub-agent that conducts structured, interactive training sessions with a team member. Takes them from Foundation → Working Knowledge → Applied Practice on any defined skill. Tracks progress. Reports to Gareth or the relevant team lead.

---

## Architecture

### Trigger

Invoked by Gareth or a team lead:

```
/train @Fay on HubSpot deal stages
```

Or self-service: a team member messages Guide directly and requests training on a topic.

### Session Binding

- The agent spawns a **persistent named session** per learner per skill: `session:train-{slack_user_id}-{skill_slug}`
- This means the conversation can be paused and resumed across days without losing progress
- State is preserved in the session; no external DB required at MVP

### Skill Library

Skills are defined as structured markdown files in the vault:

```
20-Projects/Skill-Library/{skill-slug}.md
```

Each skill file contains:
- Skill name and description
- The three phases with concept list
- Suggested analogies and examples per concept
- Quiz questions per phase
- The integrative scenario

The base prompt template (see `Skill-Builder-Prompt.md`) is the engine. The skill file is the content loaded into it at runtime.

### Flow

```
1. Gareth triggers: /train @Fay on HubSpot deal stages
2. Guide loads skill file: skill-library/hubspot-deal-stages.md
3. Agent spawns (or resumes) session: train-{fay_id}-hubspot-deal-stages
4. Agent opens with intro + Phase 1 overview
5. Learner responds via Slack DM or Telegram
6. Agent works through concepts, one per exchange
7. After each phase: quiz, score, flag gaps
8. On completion: integrative scenario → debrief
9. Agent writes progress log to vault
10. Summary delivered to Gareth / team lead
```

---

## State Tracking

The agent maintains a lightweight progress object in session memory:

```json
{
  "learner": "fay.davidson",
  "skill": "hubspot-deal-stages",
  "phase": 2,
  "concept": 4,
  "phase_scores": [3, null, null],
  "gaps": ["pipeline velocity definition"],
  "started": "2026-05-17",
  "last_active": "2026-05-18"
}
```

On each session resume, the agent reads this state and picks up where it left off.

---

## Reporting

On phase completion and course completion, the agent posts a structured summary:

**To Gareth or the triggering team lead (Telegram DM):**
```
Fay completed Phase 1 of HubSpot Deal Stages.
Score: 3/3. No gaps flagged.
Phase 2 starts when she's ready.
```

**On course completion:**
```
Fay completed HubSpot Deal Stages.
Phases: 3/3. Overall score: 8/9.
Gap to revisit: pipeline velocity (Phase 2).
Integrative scenario: passed.
```

Progress logs written to vault:
```
30-People/Team/fay-davidson.md → Training section
```

---

## Skill Library — Build Plan

MVP skills to build first (based on current team gaps):

| Skill | Audience | Priority |
|-------|----------|----------|
| HubSpot deal stages + pipeline | Fay, Jack, Yoann | High |
| PPC campaign structure | New hires, operators | High |
| SEO fundamentals | Non-SEO team members | Medium |
| Data literacy (reading a dashboard) | All team | Medium |
| BigQuery basics | Ashleigh, Adam | Low (they know it) |

Each skill file is ~300–500 words. One file per skill. Gareth or Guide can draft them.

---

## Channel Routing

| Learner tier | Training channel |
|---|---|
| Operator (Danny, Richard, Laura, Matt) | Telegram DM |
| Team member (Fay, Jack, etc.) | Slack DM |
| Gareth | Telegram DM |

Agent respects existing tier model. No cross-channel leakage.

---

## What Needs to Be Built

| Item                                                | Who            | Notes                              |
| --------------------------------------------------- | -------------- | ---------------------------------- |
| Skill library folder + first 2 skill files          | Gareth / Guide | Vault write                        |
| Trigger parsing (`/train @person on skill`)         | Engineer       | Slash command handler              |
| Persistent session spawn per learner+skill          | Engineer       | `session:train-{id}-{slug}`        |
| Progress state read/write in session                | Engineer       | Lightweight JSON in session memory |
| Phase completion summary → Gareth + triggering lead | Engineer       | Cron or event-driven               |
| Vault write on completion                           | Engineer       | Append to people file              |

MVP is achievable without a DB. Session persistence + vault writes cover state and reporting at this scale.

---

## Open Questions

1. **Self-service vs. gated?** Should team members be able to trigger their own training, or does Gareth/team lead always initiate? Recommendation: gated at MVP — team lead triggers, learner continues. Authorised triggers: Gareth, Danny, Richard, Laura, Matt, Ashleigh.
2. **Skill file authoring:** Does Gareth write skill files, or does Guide draft them from a brief? Both are viable. Guide drafting is faster at scale.
3. **Completion certificates / recognition?** Could post a "🎓 Fay completed HubSpot Deal Stages" to #wilderness-digital-team. Light touch, opt-in.
4. **Adaptive difficulty:** At v2, agent could adjust concept depth based on quiz scores. Not needed at MVP.

---

## Next Step

If Gareth signs off on approach: write signal to Engineer to build trigger handler + session spawn. Guide can draft the first two skill files immediately.
