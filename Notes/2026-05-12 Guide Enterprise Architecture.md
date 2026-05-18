---
title: "Guide — Enterprise Architecture"
type: architecture-note
area: wilderness
project: Guide
tags: [guide, architecture, enterprise, strategy, hardware, local-llm]
created: 2026-05-12
status: active
---

# Guide — Enterprise Architecture

*Written 2026-05-12. Context: Nick approved $15k hardware + Claude Max + exec instances (2026-04-24). Thinking through what Guide becomes as it moves from a digital-team tool to enterprise infrastructure.*

---

## The Inflection Point

Guide is at a transition. Phase 0 was "does it work?" — it works. Five of fifteen digital team members are active inside ten days with zero mandated adoption. Nick approved hardware and investment after one demo. Exec instances are queued.

The question now isn't operational. It's architectural: **what does Guide become when it's enterprise infrastructure, not Gareth's project?**

That question has a different shape than any individual chunk. It requires thinking about:
- Who Guide serves at enterprise scale (not 15 people — potentially 100+)
- What data flows through it (not just digital performance data — the whole business)
- What the infrastructure looks like when it has to be reliable for everyone
- How you govern 50+ agents without Gareth being the mental model
- What's genuinely novel here — and why that matters

---

## 1. The People Map at Enterprise Scale

**Current:** 15 digital team members. 8 personal instances planned (Nick, Hadley, Keith, Scott, Caro, Frances, Simon, Dean).

**Enterprise:** Every leadership layer and functional head across the three brands. Roughly:

| Layer | Who | Guide role |
|-------|-----|-----------|
| **Board/PE** | Nick, Keith + PE committee | Portfolio intelligence, capital allocation briefing, audit trail |
| **Executive** | Hadley (CCO), CFO, COO, CPO | Functional intelligence, brief generation, decision support |
| **Country managers** | East Africa, Southern Africa, West Africa leads | Regional intelligence, camp performance, operations |
| **Brand leads** | Wilderness/Jacada/YZ marketing, sales, ops leads | Brand-specific daily intelligence |
| **Sales** | B2B officers, sales teams (Scott, Simon et al.) | Agent intelligence, booking velocity, deal pipeline |
| **Reservations** | Caro + team | Camp availability, yield intelligence, booking management |
| **People/HR** | Dean + team | Hiring pipeline, retention signals, org health |
| **Finance** | Group finance + brand controllers | P&L intelligence, cost analysis, budget vs. actuals |
| **Conservation** | Impact team | Impact reporting, conservation metrics, investor outputs |

Each person at the leadership layer or above gets a personal Guide instance. Their instance is scoped to exactly their data — by architecture, not policy.

At enterprise scale this could be 40–60 personal instances. The agent factory makes this cost-linear, not cost-exponential.

---

## 2. The Data Map at Enterprise Scale

**Current plan:** GA4, Google Ads, HubSpot, Meta, Bing, DV360, BigQuery.

**What enterprise Guide needs to see:**

| Data source | Current status | Enterprise role |
|------------|---------------|----------------|
| GA4 / BigQuery | Planned (Phase 4) | Conversion intelligence across all brands |
| Google Ads, Meta, Bing, DV360 | Planned (Phase 4) | Full paid media coverage |
| HubSpot | Planned (Phase 4) | CRM + booking attribution |
| **Booking system** (Tourplan or similar) | Not yet scoped | The core revenue data — camp bookings, lead times, cancellations, yield |
| **Camp occupancy data** | Not yet scoped | Occupancy by camp by season by brand — the single most important business metric |
| **Partner/B2B data** | Not yet scoped | Agent performance, booking attribution, territory analysis |
| **Finance system** | Not yet scoped | P&L by camp/brand, cost per room, EBITDA per unit |
| **People/HRIS** | Not yet scoped | Hiring pipeline, headcount, retention — for People team agents |
| **Conservation impact** | Not yet scoped | Impact metrics for investor reporting and brand story |
| **Customer journey** | Not yet scoped | Full arc: first touch → booking → return visit |

The booking system and camp occupancy data are the most consequential gap. A safari company's most important metric is occupancy × yield. CapitalCore without booking data is incomplete.

---

## 3. The Possibilities Mapped to Architecture

The PDF identified six possibility areas. Here's what each actually requires:

### HubSpot Sales → Revenue Intelligence Layer

Beyond health checks and pipeline velocity. At enterprise scale:
- **Real-time deal intelligence** — a B2B sales officer can ask "what's our conversion rate with Cox & Kings over 2 years?" and get a sourced answer in 30 seconds
- **Attribution modeling** — which marketing channels are producing the highest-value bookings, by brand, by market
- **Lifetime value intelligence** — which agent relationships are worth protecting and developing
- **Booking window modeling** — early warning when lead times compress (signals demand changes before finance catches them)

Requires: HubSpot API (Phase 4) + booking system integration + Analyst agent with Hermes memory.

### Campaign Optimisation → Active Intelligence Loop

Current design: report anomalies. Enterprise design: close the loop.

```
Apex detects opportunity (bid inflation, competitor gap, impression share dip)
    ↓
CapitalCore models ROI (what does shifting £X here do to yield?)
    ↓
Human approval (Gareth or brand paid lead)
    ↓
Paid agent implements change (or outputs the change for manual execution)
    ↓
Apex monitors outcome — learns from it
    ↓
Loop
```

This is what Nick means by "controllable" — the AI recommends, the human approves, the AI executes, the result is logged. Full audit trail. No black box.

Requires: Hermes memory on Apex (it needs to remember what worked), Paperclip governance (approval routing), Paid agent having write access to platforms — a deliberate decision about what stays human-gated.

### Website Optimisation → Continuous CRO Intelligence

Beyond site metrics. The Product agents watch:
- Conversion funnels by brand by device
- Drop-off points (identified, not just reported)
- A/B test proposals (based on pattern recognition across sites)
- Outcomes tracked against proposals (the agent learns what works for each brand's audience)

At Wilderness specifically: the booking funnel is heavily research-led with long lead times. Product agents that understand this cycle are qualitatively different from generic analytics tools.

Requires: GA4 integration + Product agents with Hermes memory for A/B pattern recall.

### Content Intelligence → Hadley's Entry Point

This is the clearest entry point for the CCO. The content pipeline:

```
Brief → Creative brief (Guide reads brand guidelines, strategy docs, generates brief)
Brief → Copy draft (routed to appropriate model — different brands, different voice)
Copy → SEO validation (SEO agent checks keyword opportunity and on-page)
Copy → Approved / iterated
Copy → Published (via CMS integration — Phase 4+)
Publish → Performance tracking (GA4 + Social feeds back)
Performance → Refresh surfacing (underperforming content flagged to Content agent)
```

Why this lands for Hadley: she can evaluate the output immediately. She knows if the brief is good. She knows if the copy sounds right. This builds trust fast because the feedback loop is visceral, not abstract.

Requires: Nothing technically new. Agent factory creates a Creative/Content agent, mounts brand guidelines + strategy vaults (read-only). Day-one capability once the personal instance infrastructure is live.

### Social Monitoring → Brand Intelligence Layer

Not vanity metrics. Enterprise-grade:
- **Competitor monitoring** — other luxury safari operators. Price changes, new product announcements, PR events, negative coverage
- **Brand sentiment** — Wilderness/Jacada/YZ mentions tracked and summarised into the morning brief
- **Crisis detection** — early warning on negative narrative formation, escalated immediately to exec layer
- **Influencer and press** — relevant coverage surfaced before it's old news
- **Conservation narrative** — monitoring how the conservation story is landing vs. competitors

Plugs directly into the Briefing agent morning brief. Hadley and the brand teams get this automatically.

Requires: Brave Search skill (already in INTEGRATIONS.md), RSS feeds (BACKLOG has this), web monitoring (BACKLOG has `page-watcher` item). Largely buildable with existing planned skills.

### Local LLM → Infrastructure, Not a Feature

The M4 hardware approval changes the architecture. This isn't "add ChatGPT" — it's a different tier in the model routing stack.

**Why local LLM is non-optional at enterprise scale:**

1. **Data that can't leave the building** — HR data, board presentations, conservation strategy, financial projections, M&A analysis. These cannot go to external APIs.
2. **Cost at volume** — daily briefs × 60 people × 20 agents × Sonnet pricing = real money per month. Local inference is fixed cost.
3. **Latency for high-volume tasks** — cron jobs that run 7 daily briefings and 20 data health checks don't need Sonnet. They need fast, cheap, good-enough.
4. **Redundancy** — Guide runs on Anthropic uptime. An on-premise model means the system keeps running if the API is down.

**Hardware confirmed: HP Z8 G4 (2× Xeon Gold 6134, 128GB RAM, 1TB NVMe, 4TB HDD, Nvidia RTX 3090 24GB VRAM)**

The RTX 3090 is a dedicated CUDA GPU — better for inference throughput than Apple unified memory. The CUDA ecosystem (Ollama + CUDA backend, vLLM) is more mature than Metal.

| Model class | VRAM fit | Use case |
|-------------|----------|----------|
| 34B Q4 (Qwen 2.5 32B, Llama 3.3 34B) | Fits in 24GB VRAM | Primary local inference — fast, no CPU offload |
| 70B Q4 | ~40GB — needs CPU offload to 128GB system RAM | Viable for deep analysis on sensitive data |

**Revised model routing stack:**

| Task type | Model | Where |
|-----------|-------|-------|
| Sensitive data (HR, board, finance, M&A) | Local 34B Q4 | On-premise — Ollama + RTX 3090 |
| Background cron, data checks, formatting | Haiku | Anthropic API |
| Interactive queries, brief generation | Sonnet | Anthropic API |
| Deep reasoning, capital allocation, board-level synthesis | Opus | Anthropic API |
| Creative tasks (copy, briefs) | Sonnet or local model | Depending on data sensitivity |
| Image analysis, audio transcription | GPT-4o Vision / Whisper | OpenAI API (Scribe agent) |

The model router becomes a more sophisticated dispatch layer. Hermes handles this natively (200+ model routing via OpenRouter). Setup: Ollama with CUDA backend, integrated into OpenClaw model routing — likely part of CHUNK-07 Ubuntu hardening.

---

## 4. Enterprise Agent Roster

Current target: 20 functional agents + 8 personal instances = 28.

Enterprise adds:

### New Functional Agents

| Agent | Function | New vs. Current |
|-------|----------|----------------|
| **Reservations** | Camp availability, yield per camp, booking management intelligence | New (Caro) |
| **Sales** (×3 brands) | B2B performance, territory analysis, agent relationship intelligence | New |
| **Finance (expanded)** | P&L by camp/brand, cost analysis, budget vs. actuals, EBITDA | Expansion |
| **People/HR** | Hiring pipeline, retention signals, org health | New (Dean) |
| **Conservation** | Impact metrics, conservation reporting, investor narrative | New |
| **Country/Regional** | Regional performance synthesis (East Africa, Southern Africa, etc.) | New |
| **Creative/Content** | Brief generation, copy drafting, content performance | New (Hadley) |
| **Dev Team** (×5) | Already planned — execution and build support | Planned (Phase 5+) |

### Enterprise Personal Instance Count

At full enterprise scale: up to 40–60 instances. The agent factory makes this viable — each is a config task, not a build task.

Priority sequencing:
1. Exec tier first (Nick, Hadley, Keith) — already queued
2. Country managers (highest leverage — they're isolated by geography from the intelligence layer)
3. Sales + reservations tier
4. Functional leads (Finance, People, Conservation)
5. Wide rollout

---

## 5. The Governance Layer

At 28 agents, Gareth's mental model is the org chart. At 60 agents, it isn't.

Paperclip was scheduled for Phase 5. It needs to move to Phase 2 evaluation for a specific reason: **at enterprise scale, the system needs owners who aren't Gareth.**

The enterprise model:

| Layer | Owner | What they own |
|-------|-------|--------------|
| **Architecture** | Gareth | System design, agent factory, vault structure |
| **Brand intelligence** | Danny (Wilderness), respective brand leads | Brand-scoped agents and their data |
| **Exec intelligence** | Hadley (Creative), Nick (Portfolio) | Creative and capital allocation agents |
| **Sales intelligence** | Scott/Simon | Sales and reservations agents |
| **People intelligence** | Dean | HR/People agents |
| **Conservation intelligence** | Conservation lead | Conservation and impact agents |

Paperclip's ticket model maps to this org chart. Danny raises a request to update the Wilderness Paid agent's brief format → that's a ticket → Gareth approves → Engineer implements → logged. Gareth isn't the only escalation path; he's the board.

**When Paperclip becomes necessary:**
- Agent count exceeds 12 running simultaneously
- More than one person besides Gareth is owning an agent's outputs
- Budget governance requires per-agent cost visibility for the PE/finance layer
- Audit trail requirements (Nick will ask: "show me every recommendation CapitalCore made in Q2")

That's Phase 2, not Phase 5.

---

## 6. What Makes This Genuinely Novel

An honest assessment of what's being built that doesn't exist elsewhere.

### What enterprise AI vendors offer
- **Microsoft Copilot** — AI assistant over O365 data. Same interface for everyone. No memory. No cross-function intelligence. No org chart. No scope isolation.
- **Salesforce Einstein** — AI over CRM data. Single data source. No multi-brand portfolio view. No learning loop. Vendor-locked.
- **Google Workspace AI** — AI assistance in docs and Gmail. No business memory. No agent architecture. No data integrations.
- **Custom enterprise builds** — JPMorgan IndexGPT, Bloomberg BloombergGPT, Morgan Stanley + OpenAI. Billion-dollar R&D for narrow single-domain use cases.

None of them are doing what Guide is doing.

### What Guide has that doesn't exist elsewhere

**1. Structural privacy per person at scale**
Every person's Guide instance is their bot — a different bot token, a different workspace, a different context window. Nobody else messages it. Nobody else can see it. This is architecturally true, not just policy. At enterprise scale with sensitive HR, finance, and strategy data — structural isolation is non-negotiable. No enterprise vendor does this.

**2. Cross-brand portfolio intelligence**
CapitalCore and Apex work across three distinct brands with different audiences, competitive sets, and data profiles. When Jacada is outperforming Wilderness in a specific market segment, the capital allocation agent knows — and can model what happens if you shift budget. No single-brand vendor can do this. Multi-brand tools exist but don't have the intelligence layer.

**3. Vault-native intelligence**
Guide reads from where work actually happens — Obsidian vault, OneDrive documents, brand guidelines, strategy docs, board presentations. Not a sanitized data warehouse. The AI sees the business as it actually is: messy, contextual, political. That's what makes the intelligence useful, not just accurate.

**4. The compounding memory**
When the Hermes Analyst has watched a complete Wilderness booking cycle — including the March RPB spike, the Q3 Africa season patterns, the impact of UK winter on Southern Africa demand — it stops being a generic analyst and becomes a domain expert. No hire, no training, no knowledge transfer risk. It learned from lived experience in the business.

**5. The atomic data architecture**
Python is deterministic. Guide is intelligent. They don't mix. This makes the system auditable, debuggable, and reliable in ways that "let the LLM do everything" architectures are not. Nick (PE) can ask "how was this number calculated?" and there's an answer. Boards need that.

**6. Agent factory economics**
New capability doesn't require a new bespoke build. It requires a config task. At 60 agents, this is the difference between a maintainable system and an unmaintainable one. Nobody in the enterprise AI space has solved the economics of maintaining 60 specialist agents — they keep the number small to manage it. Guide's factory model breaks that constraint.

**7. Built on owned infrastructure, not rented SaaS**
The vault, the runtime, the data pipelines — they live on Wilderness hardware and GitHub repos. This isn't a subscription that gets cancelled. It isn't a vendor who gets acquired. The intelligence is embedded in the business. That's what Keith means by "structural vs. controllable" — it's both.

---

## 7. The Enterprise Build Sequence

What has to be true before Guide is enterprise infrastructure (not just Gareth's project):

**Gate 1 — Personal instances working reliably**
Nick, Hadley, Keith instances live. This proves the per-person model at exec level. Critical for trust.

**Gate 2 — Data layer operational**
At least one live data feed through the atomic ETL pipeline. HubSpot or Google Ads. Daily briefs with real numbers. This is what makes Guide feel like infrastructure, not a chatbot.

**Gate 3 — Agent governance in place (Paperclip)**
Before rolling out 60 personal instances and 40+ functional agents, the governance layer needs to exist. Agents need owners. Budget needs tracking. Audit trails need to be on.

**Gate 4 — Local LLM operational**
New M4 hardware deployed. Local model running for sensitive data paths. Model routing updated. This gate is required before rolling out to HR, Finance, or any function with sensitive data.

**Gate 5 — Agent factory proven at 10+ agents**
The factory has produced and is running 10+ agents in production. Reliability is established. This is the proof that enterprise scale is cost-linear.

Beyond Gate 5: expand the people map and data map aggressively. Every country manager, every functional lead, every brand sales officer gets a Guide instance. Morning briefs become the default, not the exception.

---

## 8. Open Questions for Gareth

1. **Booking system access** — What does Wilderness use for camp bookings/reservations (Tourplan, Salesforce Travel Cloud, proprietary)? This is the most important integration not yet on the roadmap. Occupancy × yield is the core business metric and CapitalCore needs it.

2. **Conservation data** — Is there a structured data source for conservation impact, or is it primarily narrative/PDF? This determines whether it's a data integration or a document intelligence problem.

3. **HR/People data** — What does Dean's function run on? HiBob, BambooHR, Excel? Shapes what the People agent can do.

4. **Country managers** — How do they currently receive commercial intelligence? Email reports? Manual dashboards? Understanding their current pain is the fastest path to Guide being indispensable for them.

5. **The Hadley content question** — Where does CCO content actually get produced today? Which tools, which team, which workflow? The content pipeline is the fastest win, but only if Guide plugs into an existing flow rather than trying to replace it.

6. **New hardware spec** — What exactly did Nick approve? M4 Mini Pro (48GB), M4 Max Mac Studio (128GB), or M4 Ultra? The memory ceiling determines what local LLM model is viable (48GB → 30B models; 128GB → 70B models; 192GB+ → 100B+ models).

7. **The PE layer** — Does Nick (and the PE firm) want a formal reporting layer? Audit logs, cost dashboards, recommendation histories? This shapes the Paperclip priority and the CapitalCore output format.

---

## 9. The One-Line Version

Guide is not a tool. It's the cognitive infrastructure of a PE-backed luxury travel group — the first system that gives every person in the organisation their own private AI instance, scoped to their role, connected to the data that matters to them, accumulating domain memory over time, and governed by an org chart that the AI itself participates in.

Nobody has built this yet. Not at this scale, not with this architecture, not with this level of structural thought.

The $15k hardware investment is the gate from Phase 0 to something genuinely different.

---

## Related Notes

- [[2026-04-18 Guide × Hermes × Paperclip Strategic Briefing]] — runtime layer analysis
- [[2026-04-24 Guide Architecture — Vault Scoping & Agent Comms]] — vault + agent comms decisions
- [[00_Guide-Project-Brief]] — master project brief
- [[BACKLOG.md]] — operational items

---

*Written: 2026-05-12 | Author: Gareth Knight / Claude Code (Architect)*
*Status: Strategic note — not yet converted to chunks. Review before Phase 2 planning.*
