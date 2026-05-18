---
title: "Guide Skills — Planning & Spec"
type: architecture-note
area: wilderness
project: Guide
tags: [guide, skills, agentskills, architecture]
created: 2026-04-24
status: active
---

# Guide Skills — Planning & Spec

*Researched 2026-04-24. Source: agentskills.io spec + best practices docs.*

---

## What Are Skills

A skill is a directory with a `SKILL.md` file. Progressive disclosure — agents load name/description at startup (~100 tokens), full instructions only when task matches (~5000 tokens max), reference files only when needed.

```
skill-name/
├── SKILL.md          ← Required: frontmatter + instructions
├── scripts/          ← Optional: executable code (Python, Bash, JS)
├── references/       ← Optional: docs loaded on demand
└── assets/           ← Optional: templates, schemas, lookup tables
```

**Standard:** AgentSkills spec (agentskills.io) — adopted by Claude Code, GitHub Copilot, VS Code, Cursor, Gemini CLI, OpenHands, OpenAI Codex, Databricks, Snowflake, and 30+ others. Skills built for Guide are portable across all of them.

**Validate:** `skills-ref validate ./my-skill`

---

## SKILL.md Frontmatter

```yaml
---
name: skill-name           # lowercase, hyphens, max 64 chars, matches directory name
description: |             # max 1024 chars — what it does AND when to use it
  Specific description with keywords that trigger activation.
license: Proprietary       # optional
compatibility: Requires Python 3.11+, internet access  # optional
metadata:
  author: wilderness-guide
  version: "1.0"
---
```

**Keep SKILL.md under 500 lines / 5000 tokens.** Push detail to `references/`.

---

## Best Practices (Key Points)

**Start from real expertise, not generic LLM generation.**
Feed in Wilderness-specific material: account structures, CPL targets, brand economics, HubSpot schema, actual gotchas. Generic PPC best practices are not useful. Real Wilderness data is.

Good source material:
- Actual Google Ads account IDs, campaign structures, CPL targets per brand
- HubSpot pipeline stages, deal fields, known data quality issues
- Scott's safari KB (once converted to markdown)
- Weekly trading update formats
- Incident notes (e.g. YZ Dec pipeline allocation error)

**Gotchas sections are the highest-value content.**
Concrete corrections to mistakes an agent will make without being told:

```markdown
## Gotchas

- Jacada CPL calculations: some pipeline deals excluded by Phil. Verify raw 
  numbers before quoting CPL. Source of truth: Phil's confirmed pipeline only.
- YZ lead pipeline: Dec 2025 allocation error — leads moved to separate pipeline.
  Data before this date has incorrect CPL. Verify date range on any YZ CPL query.
- Wilderness vs Wilderness Safaris: Google Ads uses "Wilderness Safaris" in 
  campaign names. HubSpot uses "Wilderness". Never assume they match on name.
```

**Templates for output format.**
Agents pattern-match against concrete templates reliably. Store in `assets/`.

**Provide defaults, not menus.**
Pick one tool/approach, mention alternatives briefly. Not: "you can use pdfplumber, PyMuPDF, or pdf2image..." — just pick one.

**Procedures over declarations.**
Teach the agent *how to approach* a class of problems. Reusable method > specific one-off answer.

**Validation loops.**
For multi-step workflows: do → validate → fix → repeat until passes.

---

## Skills Build Order for Guide

### Priority 1 — Core intelligence

**`paid-search-analysis`**
Cross-brand paid search (Google Ads + Bing). Brand economics, CPL targets, account structure gotchas. Feeds Weekly Pulse, Apex, CapitalCore.
- Source material: Google Ads account structures (WS, JC, YZ), CPL targets, Yoann's threshold formula, historical CPL benchmarks

**`brief-generation`**
Wilderness brand voice + output templates. Morning briefs, weekly summaries, exec WhatsApp format.
- Source material: existing brief formats, SOUL.md tone guidance, Hadley's communication preferences

**`hubspot-query`**
CRM data patterns, pipeline stages, known gotchas (Dec YZ error, Phil's Jacada deal exclusions). Feeds HubSpot agents, CapitalCore.
- Source material: HubSpot pipeline structure, known data quality issues, stage definitions

### Priority 2 — Knowledge layer

**`ppc-library`** *(dependency of `paid-search-analysis`)*
External PPC knowledge base in LLM-readable markdown. Subscription model from ppcmastery (Yoann recommended — Gareth saw a sample file, quality looks good). Download markdown docs, drop into `references/`. Updated by subscription when Google/Microsoft change things. Covers: bidding strategies, quality score, smart campaigns, audience targeting, shopping ads, etc.

Implementation:
```
ppc-library/
├── SKILL.md              ← Load instructions per topic
├── references/
│   ├── bidding-strategies.md
│   ├── quality-score.md
│   ├── smart-campaigns.md
│   ├── audience-targeting.md
│   ├── shopping-ads.md
│   └── ...               ← Full downloaded library
└── assets/
    └── analysis-template.md
```

Generic PPC knowledge from library + Wilderness-specific gotchas in SKILL.md = better than either alone. Subscribe when budget confirmed. Note: Yoann recommending this — assess independently before committing.



**`safari-kb-query`**
Wraps Scott's safari knowledge base (Word → markdown conversion pending). Natural language queries for retail/reservations use cases.
- Prerequisite: Scott's doc converted via Marker pipeline
- POC for Keith

**Hermes is the right runtime for this skill.** Static reference material that an agent should *learn from*, not just retrieve. After 50 queries Hermes knows the Botswana camp portfolio without loading the full library every time. After 6 months it's accumulated nuances — camp-traveller fit, upsell opportunities, common objections and responses. OpenClaw loads files fresh every session; Hermes builds a domain model that compounds.

Scoped vault: Hermes KB agent mounts `guide-shared/kb/safari/` only. Clean learning loop, no noise.

This is the ideal Hermes pilot: low risk, clear quality signal, directly tied to the Keith POC. Convert Scott's doc → run Hermes for 6 weeks → evaluate whether output quality improves over time.

**`capitalcore-analysis`**
Yield curves, budget pacing, cross-brand capital allocation. Nick's priority framing: "both sides of the conversion equation."
- Source material: media spend data, booking revenue targets, CPL benchmarks

### Priority 3 — People layer

**`para-onboarding`**
PARA bootstrap for new Guide users (Hadley, Caro, Dean). Structured onboarding conversation → scaffolds workspace from answers → seeds templates → weekly nudge.
- Designed to be low-friction: start with Projects only, add complexity as user grows into it

**`llm-training`**
Modular LLM training course — one module per session/week. Socratic conversation style. Tracks progress per user. Foundation for Dean's Joburg course.

Modules:
1. What is an LLM actually doing? (token prediction, not thinking)
2. How to write a prompt that works
3. When to use which model
4. How to evaluate output quality
5. How to build a workflow (not just one-shot prompts)
6. Domain-specific: how to use Guide for paid media / sales / reservations

### Priority 4 — Operations

**`meeting-capture`**
Transcription pattern + task extraction + routing to vault. For Scribe agent.

**`anomaly-detection`**
Pattern: what constitutes an anomaly per brand per metric. Threshold definitions, escalation rules. For Apex.

---

## Skills Scoping — Per Agent

Skills can be scoped to specific agents. Two mechanisms:

**1. Physical scoping** — only put the skill in the agent's workspace/skills directory. If `guide-vault/paid-ws/skills/` has `paid-search-analysis` but `guide-vault/briefing/` doesn't — Briefing agent never sees it.

**2. Skills config in openclaw.json** — point each agent at a different skills directory:

```json
{ "id": "paid-ws", "workspace": "./guide-vault/paid-ws", "skills": "./guide-shared/skills/paid" }
{ "id": "exec-hadley", "workspace": "./guide-vault/exec/hadley", "skills": "./guide-shared/skills/exec" }
```

**Guide skills directory structure:**

```
guide-shared/skills/
├── shared/          ← All agents (brief-generation, para-onboarding, llm-training)
├── paid/            ← Paid agents only (paid-search-analysis, anomaly-detection)
├── intelligence/    ← CapitalCore, Apex, Analyst (capitalcore-analysis)
├── exec/            ← Nick, Hadley, Keith instances
└── kb/              ← safari-kb-query, hubspot-query
```

Each agent's Docker mount config includes only the skill directories it's cleared for. Same structural scoping principle as vault access — access control at the filesystem level, not prompt level.

---

## Skills Hierarchy — Three Tiers

Skills operate at three levels. One skill maintained once, consumed by exactly the right agents.

```
~/.openclaw/skills/              ← ALL agents (Jarvis, Household, Guide)
~/.openclaw/skills/jarvis/       ← Jarvis + Household only (personal, family)
guide-shared/skills/paid/        ← Paid agents only
guide-shared/skills/intelligence/ ← CapitalCore, Apex, Analyst only
guide-vault/capitalcore/skills/  ← CapitalCore only (private)
```

| Tier | Path | Who sees it | Examples |
|------|------|-------------|----------|
| **Shared** | `~/.openclaw/skills/` | All agents | Logger, weather, gog, self-improving |
| **Group** | `~/.openclaw/skills/jarvis/` or `guide-shared/skills/paid/` | Defined subset | People brief (Jarvis only), paid-search-analysis (paid agents only) |
| **Private** | Inside agent workspace | That agent only | CapitalCore-specific analysis logic |

Each agent's Docker mount config points at whichever skill directories it’s cleared for. Same structural scoping principle as vault access.

Implemented via Docker bind mounts:
```yaml
# Example: paid-ws agent
volumes:
  - ~/.openclaw/skills:/app/skills/shared:ro          # all-agent skills
  - ./guide-shared/skills/paid:/app/skills/paid:ro    # paid-only skills
  # No intelligence/ or exec/ mount — not cleared
```

---

## Skills Discovery Resources

| Resource | URL | What it has |
|----------|-----|-------------|
| **awesome-openclaw-skills** | github.com/VoltAgent/awesome-openclaw-skills | 5,200+ curated OpenClaw skills, filtered from 13,700+ on clawhub. Categorised, spam-filtered. Best starting point. `clawhub install <slug>` to install. |
| **skillsmp.com** | skillsmp.com | 1M+ agent skills organised by occupation. Key categories: Business & Financial (95k skills), Management (11k). Search here for marketing/CRM/paid media scaffolding. |
| **clawskills.sh** | clawskills.sh | Another community discovery layer for OpenClaw skills |
| **Composio** | composio.dev/claw | Managed OAuth + permissions across 1,000+ apps (HubSpot, Slack, Gmail, etc). Pre-built integrations — faster than writing from scratch |
| **clawhub.ai** | clawhub.ai | Official OpenClaw registry. JS SPA — browse in browser, not scriptable |

**Install command:** `clawhub install <skill-slug>`

**Before building any skill:** check skillsmp.com Business & Financial + Management categories first. 95k+ skills — something may already exist.

### What exists (from clawskills.sh scan, 2026-04-25)

**Available integrations relevant to Guide:**
- Google Analytics ✅ — GA4 pipeline may have existing skill
- Ahrefs ✅ — SEO tool, skills exist. Check before building SEO agent.
- Google Sheets ✅ — data output layer
- Slack ✅ — already in use
- WhatsApp ✅
- Google Calendar / Gmail ✅ — covered by gog
- Airtable ✅ — potential data layer

**Notable gaps — need to build:**
- HubSpot ❌ — no existing skill
- Google Ads ❌ — no existing skill
- Microsoft Ads / Bing ❌ — no existing skill
- Meta Ads ❌ — no existing skill

**awesome-openclaw-skills categories to browse:**
- Marketing & Sales: 103 skills
- Productivity & Tasks: 205 skills
- Communication: 146 skills

Ahrefs skill worth checking for SEO agent. GA4 skill worth checking before building pipeline. HubSpot/Google Ads/Meta = builds not installs.

---

## Publishing

Skills are portable across all AgentSkills-compatible platforms (30+). If Guide becomes a product, Guide's skills could be published to clawhub.ai. Marketing/business intelligence skills don't exist there yet — genuine whitespace.

---

## Related

- [[2026-04-24 Guide Filesystem Architecture]] — skills live in `guide-shared/` or shared `~/.openclaw/skills/`
- [[2026-04-24 Guide Architecture — Vault Scoping & Agent Comms]] — agent context design
- [[00_Guide-Project-Brief]] — master agent roster
- [[2026-04-23-Guide-Demo]] — Nick/Hadley demo context
