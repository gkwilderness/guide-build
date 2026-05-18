%%
## Conversation Log — 2026-04-18

Gareth: Review Hermes & Paperclip.ing; spin up an agent to think about how Guide & Hermes could work together; and maybe with Paperclip.ing on top. Be comprehensive.

Jarvis: [Researched Hermes and Paperclip docs, spawned analysis subagent]

Gareth: Yea but how do Hermes & openclaw run together?

Jarvis: That's the right question — and it's where the architecture gets concrete. Both OpenClaw and Hermes want to own the gateway, so they can't share a platform identity. Three real options:

1. Separate bot identities (simplest) — Hermes gets its own Telegram bot and/or Slack app. No integration needed, just two bots in the same Slack workspace.
2. Slack as the shared message bus — multiple apps reading/posting to the same channels. OpenClaw agent posts to #guide-analysis-requests, Hermes picks it up, responds. Loose coupling, no direct API connection.
3. HTTP bridge — Hermes exposes an endpoint; OpenClaw calls it directly. Most powerful, most work. Phase 3+ territory.

Practically for Guide: two Docker containers on the same machine, separate bot tokens, Slack as the message bus. OpenClaw runs everything operational; Hermes Analyst bot sits in the same Slack workspace. When Guide's Finance Agent wants analysis, it posts to a shared channel — Hermes picks it up, responds. No glue code required.

Gareth: So what you're saying is that the memory Hermes offers gives us a meaningful advantage over default openclaw + sonnet; which compounds over time; and so openclaw becomes the true COS, but Hermes is the heavy lifter with analysis and context -> both reading the same vault

Jarvis: Yes — that's the right mental model. One nuance: Hermes's memory isn't just vault-reading. Both agents read the vault — that part is equal. What Hermes adds is a second memory layer OpenClaw doesn't have: recall of its own reasoning and outputs. After 6 months, Hermes Analyst has read the vault (same as OpenClaw) plus: "Last March I flagged an RPB spike → Gareth investigated → seasonal pre-booking surge → no action needed." That second layer is what compounds. It's not just knowing what the business knows — it's remembering what it tried, what worked, and what the outcome was. OpenClaw resets that every session. Hermes accumulates it.

Architecture:
- Vault = shared knowledge base (both read it, both write to it)
- Hermes = analytical memory + reasoning history + pattern recall — gets smarter the longer it runs
- OpenClaw = CoS layer — routing, comms, heartbeats, approvals, operational agents

The real prize is in 6-12 months when Hermes Analyst has lived through a full Wilderness booking cycle. At that point it's not just an analyst — it's a domain expert that's seen it before.

Gareth: Right so Hermes is just a special agent; OpenClaw is a normal agent. Kinda like: department of defence vs special forces.

Jarvis: Exactly. OpenClaw is the standing army — infrastructure, coordination, always on, handles everything routine. Hermes is special forces — deployed for specific high-value missions where accumulated expertise and pattern recognition matter. Doesn't need to be everywhere. Just needs to be exceptional at its thing. And like special forces, the longer it's operational the more dangerous it gets. The first deployment it's just well-equipped. Six months in it knows the terrain.

Gareth: Does hermes have a concept of multiple "agents" or is it just 1?

Jarvis: From what the docs show — it's primarily one agent that spawns ephemeral subagents for parallel work. Those subagents are task-scoped and temporary, not persistent named entities with their own identity and memory. That's a meaningful architectural difference from OpenClaw, which was designed multi-agent from the start — each agent has its own workspace, SOUL.md, channel bindings, separate memory.

So if you wanted to run Hermes as 12 persistent specialist agents (SEO ×3, Paid ×3, etc.) — each with its own accumulated domain memory — that's not really what it's built for. You'd be fighting the architecture.

This reinforces the special forces model:
- OpenClaw = built for agent fleets. Many agents, each with defined role, persistent identity, own memory. Native home for your 20-agent roster.
- Hermes = built for one exceptional agent that can reach out and spawn help when needed. Native home for Analyst, Apex — roles where depth matters more than breadth.

Trying to replicate Guide's full agent fleet in Hermes would be square peg / round hole. One Hermes instance, two or three at most — each a specialist. Everything else stays on OpenClaw.
%%

# Strategic Briefing: Guide × Hermes × Paperclip
**Prepared for:** Gareth Knight / Wilderness Group
**Date:** April 2026
**Status:** Decision-Ready Analysis

---

## Framing

Guide is at an inflection point. Phase 0 is done — the foundation is in. Phase 1 will multiply agent count by ~4x and introduce the Agent Factory pattern. This is the moment strategic architecture decisions lock in for years. Getting this wrong means rebuilding under load. Getting it right means compounding leverage.

The three systems in scope have genuinely different value propositions that don't overlap as much as they appear to:
- **OpenClaw** = agent runtime (what runs the agents)
- **Hermes** = agent runtime with a learning loop (what runs the agents and gets smarter)
- **Paperclip** = agent control plane (what governs the agents above the runtime)

The real question isn't "which one?" It's "which layer does each one own, and do you need all three?"

---

## Section 1: Hermes vs OpenClaw for Guide

### What Hermes Has That OpenClaw Doesn't

**The learning loop — this is the whole argument for Hermes.**
- FTS5 full-text search across sessions means agents recall patterns, facts, and preferences without being told
- LLM summarisation distils session history into durable knowledge
- Honcho dialectic user modelling: the agent builds a model of how specific humans communicate, what they care about, what they've decided before
- Skills self-improve during use — if an approach works, the skill updates itself
- Cross-session recall is not the same as RAG over documents. It's structural memory of what the agent *did* and what *worked*

For Guide specifically: an Analyst Agent that remembers "Wilderness Safaris' RPB typically spikes in March/April ahead of Southern Africa season" after observing it once, and doesn't need re-briefing — that's compounding value. An agent that doesn't retain that has to be told every session.

**Model-agnostic routing (200+ models):**
- OpenRouter/Nous Portal means you can route cheap tasks to cheap models, complex tasks to capable models
- With 20+ agents, model routing is a meaningful cost lever
- OpenClaw locks you to configured models; Hermes makes routing a dynamic decision

**Platform breadth:**
- 15+ platforms from one gateway vs OpenClaw's more curated integration set
- WhatsApp is on Guide's roadmap — Hermes supports it natively
- Signal, Email native — potential for board-level comms through the same agent layer

**Built by model trainers:**
- NousResearch trains Hermes, Nomos, Psyche — models specifically tuned for agentic use
- Model and runtime are co-designed. The models understand the patterns Hermes uses.
- OpenClaw is model-agnostic by design; Hermes is model-agnostic in implementation but has first-party model advantage

### What OpenClaw Has That Hermes Doesn't

**Production maturity:**
- OpenClaw has been in Gareth's hands long enough to have operational scars (cron jobs, approval flows, session exports, pairing). That scar tissue is valuable.
- Hermes is 2 months old (Feb 2026). 95k stars reflects hype and NousResearch's credibility, not field-tested reliability at scale.

**Known Guide configuration:**
- Skills, crons, channel routing, Telegram/Slack integration — all working. This is not nothing.
- Migration cost is non-zero even with `hermes claw migrate`

**Deployment stability:**
- OpenClaw on Docker with known config is boring in the best way
- Hermes on newer infrastructure may have sharp edges in production

### What a Migration Looks Like

`hermes claw migrate` exists — NousResearch anticipated this path. Skills are compatible (agentskills.io standard — same spec both use).

What the migration actually handles:
- Skills transfer: likely yes, with minor adaptation
- Cron config: needs rewrite in Hermes format, but conceptually identical
- Channel routing: Hermes multi-platform gateway would absorb Telegram + Slack + WhatsApp
- State/memory: OpenClaw doesn't have cross-session learning state to migrate — you start Hermes's learning loop from zero (no loss, no gain)

### Verdict: Stay on OpenClaw for Phase 1. Run a Hermes pilot on one agent. Decide at Phase 2.

Reasons:
- Phase 1 is the wrong time to change runtime. Adding 9+ agents while migrating the foundation is a debugging nightmare.
- The learning loop is Hermes's compelling advantage, but it compounds over time — you need months of operation to see if it changes output quality in your specific domain.
- The migration path exists and is supported. The option doesn't expire. Take it deliberately, not reactively.
- If Hermes proves its value in the pilot, Phase 2 migration (before paid/SEO/HubSpot agents multiply) is the natural window.

---

## Section 2: Guide + Hermes Integration Patterns

### Pattern A: Hermes as Specialist Agents (Best First Move)

**What it looks like:**
- OpenClaw runs Guide Main, Briefing, Scribe, Pipeline, and all operational agents
- Hermes runs Analyst Agent (and optionally Apex) in isolation
- Interaction: Slack/Telegram as the neutral channel — OpenClaw agents request analysis, Hermes delivers to the same channel

**Why Analyst is the right first candidate:**
- Highest value from cross-session learning (seasonal norms, historical anomalies, brand-specific patterns)
- Not in the operational critical path — if it's slow or wrong, nothing breaks
- Complex enough that model routing (cheap for data prep, expensive for synthesis) pays off
- Gareth can directly evaluate quality improvement over weeks

**Why Apex is the second candidate:**
- PPC diagnostics benefit enormously from remembered patterns ("this is the third time we've seen this bid inflation pattern in Q4")
- Competition hunting benefits from accumulated competitor history

**Integration seam:**
```
OpenClaw agent (Finance/Paid) → Slack message → Hermes Analyst picks up → returns analysis to Slack
```
Loose coupling. No direct API integration needed. Slack is the message bus.

### Pattern B: Hermes Handles the Learning Layer, OpenClaw Routes

- OpenClaw manages channel routing, heartbeats, and task dispatch
- Hermes hosts a shared knowledge agent — a "business memory" service
- OpenClaw agents query Hermes before responding

**Reality check:** Requires custom API integration between runtimes. Neither has a native connector. Engineering investment appropriate for Phase 3+, not Phase 1.

### Pattern C: Hermes as Data/Analysis Layer (Full Specialisation)

- Intelligence agents (Analyst, Apex, CapitalCore, Finance) on Hermes
- Operational agents (Pipeline, HubSpot, SEO, Paid) on OpenClaw
- Clean domain boundary: learning/synthesis vs execution/monitoring

Most intellectually coherent hybrid. But see risks below.

### Integration Risks (Hybrid Architecture)

**Debugging complexity:**
- "Why didn't the Paid Agent act on the Analyst's finding?" — is it an OpenClaw problem, a Hermes problem, a Slack message problem, or a timing problem? Four suspects instead of one.

**Context fragmentation:**
- Hermes's learning loop only works if it sees everything. If half the agent activity is on OpenClaw, Hermes learns from an incomplete picture. You pay the cost of two systems but get half the benefit of Hermes's core feature.

**Operational overhead:**
- Two codebases, two upgrade cycles, two configs, two support channels.

**Skills divergence:**
- Even with compatible standards, skills will drift. A skill improved on Hermes won't automatically improve its OpenClaw equivalent.

**Bottom line:** The only hybrid worth running is Pattern A — Hermes for one or two specialist agents, OpenClaw for everything else. Anything more complex requires deliberate engineering investment and a strong reason.

---

## Section 3: Paperclip as the Control Plane

### The Conceptual Fit

Paperclip's tagline is precisely right for Guide. Guide currently has Gareth as the implicit control plane — approving, prioritising, context-switching, and debugging across 20+ agents. That's not scalable past Phase 1. Paperclip externalises the company structure that currently lives in Gareth's head.

### Wilderness Group Digital Company in Paperclip

**Proposed Org Chart:**

```
BOARD
└── Gareth Knight (Chairman)
    ├── Strategy approval
    ├── Budget governance
    └── Agent hire/fire authority

C-SUITE
└── Guide Main (COO / Chief of Staff)
    ├── Receives cross-departmental heartbeats
    ├── Escalation target for department heads
    └── Daily brief synthesis

DEPARTMENTS

Marketing Intelligence
├── Finance Agent (department head)
│   ├── Lead volume, sales pipeline, media spend
└── Analyst Agent
    └── Cross-domain ad hoc analysis

Brand Operations (×3: Wilderness Safaris, Jacada, Yellow Zebra)
├── SEO Agent
├── Paid Agent
└── Product Agent

CRM & Pipeline
├── Pipeline Agent (ETL orchestration, data freshness)
└── HubSpot Agent ×3

Strategy & Intelligence
├── Apex Agent (PPC diagnostics, anomaly detection, competition)
└── CapitalCore Agent (yield curves, budget pacing, capital allocation)

Operations
├── Briefing Agent (daily/weekly/monthly outputs)
└── Scribe Agent (meeting transcription, note routing)
```

### How Heartbeats Work in Guide's Context

**Pipeline Agent (hourly):**
- Wake → check data freshness across all ETL sources
- Threshold breach → escalate to Guide Main → Gareth notified if critical
- Normal → log status, HEARTBEAT_OK

**Paid Agents ×3 (daily, 8am):**
- Wake → pull spend vs budget from ad platforms
- Anomaly (>15% deviation) → escalate to Finance Agent → Finance decides whether to escalate to Gareth or self-correct

**HubSpot Agents ×3 (daily, 9am):**
- Wake → check pipeline health (stale deals, lead velocity, stage conversion)
- Issues → flag to Finance Agent with specifics

**Apex Agent (daily, 7am — before Paid Agents):**
- PPC diagnostics, competition scan
- Findings → brief Paid Agents for their heartbeat cycle
- Anomalies → direct escalation to Gareth via governance channel

**Briefing Agent (daily 6am, weekly Monday, monthly 1st):**
- Aggregates previous day's heartbeat outputs
- Synthesises into brief → delivers to Slack/Telegram

**CapitalCore Agent (weekly):**
- Yield curve analysis, budget pacing across brands
- Monthly: capital allocation recommendation to Gareth for approval

### What Gareth's Role Becomes

With Paperclip:
- **Board of directors**, not day-to-day manager
- You approve strategy, review budget requests, handle exception escalations
- You don't context-switch between 20 agent conversations — you review tickets
- Agents that hit budget limits stop automatically — no runaway spend
- Every decision has an immutable audit log — you can reconstruct any agent's reasoning

### What Becomes Autonomous

- Daily performance monitoring across all 3 brands
- Routine anomaly detection and escalation
- Brief generation and delivery
- CRM health checks
- Data freshness monitoring
- Budget pacing alerts

### What Stays Human-Gated

- Strategy changes
- Budget approvals above threshold
- Hiring new agents / retiring existing ones
- Override decisions (pause, redirect, reassign)

---

## Section 4: The Full Stack — Paperclip + Hermes + OpenClaw/Guide

### Is This a Coherent Architecture?

Yes, with caveats. The three layers are genuinely non-overlapping:

```
LAYER 3 — CONTROL PLANE
Paperclip
├── Org chart, goals, heartbeats, governance
├── Budget enforcement
└── Gareth's board dashboard

LAYER 2 — RUNTIME (choose one or hybrid)
OpenClaw (current) ←→ Hermes (future)
├── Agent execution
├── Channel routing (Telegram, Slack, WhatsApp)
├── Skills system
└── Cron / scheduling

LAYER 1 — INTELLIGENCE
Hermes learning loop (if adopted)
├── Cross-session recall
├── Skill self-improvement
└── User modelling
```

### Tensions and Overlaps

**Heartbeats overlap:**
- Both OpenClaw and Paperclip have heartbeat concepts
- Paperclip's heartbeat is the governance trigger; OpenClaw's is the operational check
- In a combined stack you'd need to decide which heartbeat owns what — or Paperclip's heartbeat triggers the OpenClaw agent's heartbeat

**Cron overlap:**
- OpenClaw has cron. Hermes has cron. Paperclip has heartbeats which are effectively cron.
- Triple redundancy creates maintenance burden — where is the schedule of record?
- Resolution: Paperclip owns scheduling at the company level. OpenClaw/Hermes execute when called.

**Cost tracking overlap:**
- Paperclip tracks per-agent token spend
- OpenClaw tracks session usage
- These need to be reconciled — ideally Paperclip is the source of truth, OpenClaw data feeds it

**Memory overlap:**
- Hermes has structural memory
- Guide has Obsidian vault as knowledge store
- Paperclip has goal/task history
- Three different memory systems. They need conventions to stay coherent, not contradictory.

### Is It Engineering Complexity for Its Own Sake?

For Phase 0-1: yes. Running all three now would be complexity without payoff. The full stack makes sense when:
- You have 15+ agents running simultaneously
- Gareth is spending >2 hours/week on agent coordination overhead
- Budget overruns or missed tasks have actually happened
- The Agent Factory is producing agents faster than manual oversight can track

That's Phase 3+ territory. The full stack is the destination, not the starting point.

---

## Section 5: Timing and Sequencing

### Should Paperclip Evaluation Be Pulled Forward?

**Current plan:** Phase 5 (productisation)
**Recommendation:** Pull forward to Phase 2 evaluation, Phase 3 implementation

**Trigger conditions for earlier adoption:**
- Agent count exceeds 8 running simultaneously
- Gareth loses track of what any agent is doing
- A budget event (runaway spend or missed budget) occurs
- Board-level reporting requires audit trail

**Minimum viable experiment:**
- Install Paperclip locally alongside Guide (one machine, two services)
- Create a single "company" with 3 agents (Guide Main + Briefing + one brand agent)
- Run for 2 weeks — does the ticket/heartbeat model reduce your coordination overhead?
- Cost: ~4 hours setup. Payoff signal: clear within 2 weeks.

### Should Hermes Be Evaluated Now?

**Current plan:** Not explicitly scheduled (mentioned as "evaluate Paperclip monthly from Phase 3")
**Recommendation:** Start a single-agent pilot during Phase 1 build

**The right pilot:**
- Hermes running Analyst Agent only, alongside existing OpenClaw setup
- No migration, no integration — just run it in parallel for 6 weeks
- Feed it the same Slack analysis requests you'd give OpenClaw's Analyst
- After 6 weeks: has its output improved? Has it retained useful domain knowledge?

**Minimum viable experiment:**
- Install Hermes on the Guide machine (separate Docker container)
- Configure one agent with Guide's Analyst context
- Route analysis requests to both — compare output
- Cost: ~3 hours setup + 6 weeks of parallel running

**Decision gate:**
- If Hermes Analyst is meaningfully better after 6 weeks → plan full migration at Phase 2
- If no material difference → defer to Phase 3, reassess with more mature Hermes codebase

---

## Section 6: Recommendation

### The Clear Path

**Now (Phase 0 → Phase 1 transition):**
1. Finish CHUNK-07 (security hardening) — this is the gate for everything else
2. Start Hermes pilot: install Hermes in a separate container, configure Analyst Agent, run parallel for 6 weeks alongside Phase 1 build
3. Install Paperclip locally, create a minimal 3-agent company structure — low-cost experiment that gives you visceral feel for the governance model

**Phase 1 (Agent Factory + Team Ops):**
4. Build the Agent Factory on OpenClaw as planned — don't let the Hermes pilot distract
5. After 6 weeks: assess Hermes Analyst quality. If compelling → plan Phase 2 migration window
6. After Paperclip experiment: if governance value is clear → plan Phase 2 integration

**Phase 2 (Data Layer — natural migration window):**
7. Decision point: full Hermes migration or stay on OpenClaw. Phase 2 is before the agent count explodes — last clean window.
8. If migrating: use `hermes claw migrate`, rebuild crons in Hermes format, port skills
9. Integrate Paperclip as control plane — set up full org chart, heartbeat schedule, budget governance

**Phase 3+ (Team Scale):**
10. Agent Factory produces agents. Paperclip manages them. Hermes (or OpenClaw) runs them.
11. Full stack operational — you're operating as board chairman, not agent wrangler.

### What to Watch

- **Hermes production stability** — is it breaking for people? Watch NousResearch Discord and GitHub issues
- **Paperclip Clipmart** — when company templates ship, evaluate if a "digital marketing agency" template exists that maps to Guide's structure
- **OpenClaw roadmap** — is OpenClaw building anything resembling a learning loop? If so, the Hermes migration argument weakens

### Open Questions for Gareth to Answer

1. **How much does cross-session learning matter to you?** If the Analyst Agent forgetting everything each session doesn't bother you in practice, Hermes's core value proposition is weaker than it looks.
2. **Are you willing to maintain two runtimes during a hybrid period?** Even a 6-week pilot adds maintenance overhead. Is that acceptable given current workload?
3. **Does Paperclip's "board" model match how you want to work?** If you actually prefer direct agent conversations over ticket-based governance, Paperclip may be the wrong model regardless of its technical merits.
4. **What's the real cost ceiling for Guide?** Paperclip's per-agent budgets only matter if you've thought about what you want to spend per agent per month. Have you?

### The One-Line Version

**Stay on OpenClaw for Phase 1. Run a cheap Hermes experiment now. Pull Paperclip forward to Phase 2. Don't over-engineer before you have the problem.**

---

*Generated: 2026-04-18 | Source: Jarvis strategic analysis subagent*
*File these findings: [[Group-Automation-GUIDE-Build/BACKLOG]] — update Paperclip evaluation timing*
