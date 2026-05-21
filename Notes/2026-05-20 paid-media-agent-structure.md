---
date: 2026-05-20
author: Guide (sub-agent)
status: for-review
topic: Paid media agent structure decision
---

# Paid Media Agent Structure: Option A vs Option B

**For:** Gareth Knight — decision required
**Context:** Structuring Guide's paid media intelligence layer across three channels (paid search, paid social, programmatic) and three brands (WS, JC, YZ)

---

## The Two Options

**Option A — Single paid media agent**
One agent covering paid search, paid social, and programmatic. Routes internally. Talks to Danny.

**Option B — Three specialist agents**
Paid search agent + Paid social agent + Programmatic agent. Each specialised. Danny gets output from three sources.

---

## Analysis

### Data scope and access

| Channel | Data source | Brands |
|---------|------------|--------|
| Paid search | Google Ads, Microsoft Ads | WS, JC, YZ |
| Paid social | Meta Business Manager | WS, JC, YZ |
| Programmatic | DV360, TTD | WS, JC, YZ (varies) |

Each channel has a distinct API surface, schema, and metric vocabulary. Paid search talks CPC, Quality Score, impression share. Meta talks CPM, frequency, ROAS, pixel events. DV360/TTD talks CPM, deal IDs, viewability, DSP pacing. These are meaningfully different enough that a single context window carrying all three risks shallow treatment of each.

However: from Danny's perspective, the questions are almost always cross-channel. "Where should I shift budget this week?" requires all three in the same answer.

### Team structure — who uses what

| Person | Primary channel | Agent they'd reach for |
|--------|----------------|----------------------|
| Danny Nagra | All three (oversight) | Needs consolidated view |
| Fay Davidson | Paid search (Jacada only) | Search-specific |
| Jack Sweet | Paid search (WS + YZ) | Search-specific |
| Yoann Ferrand | Paid search (consultant) | Search-specific |
| Frances | Meta + Programmatic | Two agents or one? |
| Claire | Paid search (YZ only) | Search-specific |

The team structure actually creates a natural split: four people are search-only, one person (Frances) spans social and programmatic, and one person (Danny) needs all three. 

Frances is the edge case that complicates Option B — she'd need to interact with two agents for her daily work. Not insurmountable, but friction.

### Skill alignment

Guide already has three separate skills: `ppc-questions`, `meta-questions`, `programmatic-questions`. These are the knowledge layer — they answer channel-specific questions. Agent structure is the execution layer above that. The skills exist regardless of how agents are structured; an Option A single agent would still invoke these skills internally when routing to the right domain.

The existing skill split actually argues for Option B — the knowledge is already partitioned, so the agents naturally inherit that separation.

### Context depth vs maintenance

**Option B (split) wins on depth:**
- Each agent can hold richer channel context — account structure, brand-level nuance, historical patterns — without competing for context space with two other channels
- Prompts stay focused; fewer failure modes from cross-channel confusion
- Easier to update one agent when Meta changes its API or a new campaign type launches

**Option A (single) wins on coherence:**
- Cross-channel budget questions get answered in one pass
- Danny doesn't have to aggregate outputs from three agents himself
- Fewer agents to maintain, version, and debug
- Single audit trail for paid media decisions

**Maintenance comparison:**
Option B triples the maintenance surface. Three agents to prompt-tune, three to monitor for drift, three to update when channel mechanics change. For a lean digital ops setup, this is non-trivial overhead.

### How outputs reach Danny

This is where Option A has a structural advantage.

If Danny asks "should I shift £20k from search to social this week?" —
- Option A answers it directly, with cross-channel context baked in
- Option B requires either: (a) Danny querying three agents and synthesising himself, or (b) a fourth orchestration layer that aggregates across the three

Option B without an orchestration layer pushes synthesis work onto Danny. That's the opposite of what Guide should do.

Option B *with* an orchestration layer (a "paid media director" meta-agent) adds architectural complexity: now you have four agents to maintain instead of three, and the meta-agent needs enough context to route and aggregate intelligently.

### Edge cases

**Frances (social + programmatic):** In Option B she'd use two agents. Minor friction, but manageable — her questions are rarely cross-channel within a single query. Social campaign analysis stays social; programmatic deal review stays programmatic.

**Danny's cross-channel view:** The biggest edge case. Option A handles it natively. Option B needs a solution.

**Brand-level isolation:** Neither option naturally enforces brand isolation. Fay works Jacada-only; Jack works WS + YZ. This is a permissions/context question that's orthogonal to the A vs B choice — it applies to either architecture.

**Budget consolidation for Matt Wylie:** Finance-level questions (MTD spend across all channels) cut across all three. Option A is cleaner here.

---

## Recommendation: Option A with internal routing

**Single paid media agent, with channel-aware internal routing.**

The reasoning:

1. **Danny's use case dominates.** He's the primary consumer. His questions are almost always cross-channel. Option A serves him without extra synthesis steps.

2. **The skill layer already handles specialisation.** `ppc-questions`, `meta-questions`, `programmatic-questions` provide the depth. The agent doesn't need to be split to get channel-specific intelligence — it invokes the right skill.

3. **Maintenance overhead is real.** Three agents means three times the prompt engineering, monitoring, and update cycles. For the current team size and maturity of the Guide platform, this is premature.

4. **Frances's edge case is minor.** She's one person; Option B doesn't simplify enough for her to justify the overhead for everyone else.

5. **Option B's real value emerges at scale** — when each channel has its own dedicated ops analyst running that agent independently, and the data volumes are large enough that isolated context is genuinely necessary. The team isn't there yet.

**Implementation note:** Build Option A, but structure the internal routing to make a future Option B migration clean. Use skill-based routing (`ppc-questions` / `meta-questions` / `programmatic-questions`) as the internal dispatch mechanism. If the team grows and channel-specific agents become justified, the split is architectural, not a rebuild.

---

## Summary table

| Factor | Option A | Option B |
|--------|----------|----------|
| Cross-channel questions | ✅ Native | ⚠️ Requires aggregation |
| Channel depth | ⚠️ Shared context | ✅ Dedicated context |
| Maintenance burden | ✅ Lower | ⚠️ 3× surface |
| Frances (social + programmatic) | ✅ One agent | ⚠️ Two agents |
| Danny's view | ✅ Unified | ⚠️ Fragmented |
| Team search-only users | ✅ Works fine | ✅ Cleaner |
| Skill alignment | ✅ Routes internally | ✅ Natural fit |
| Migration path to B | ✅ Clean if built right | — |

**Verdict: Option A.** Single agent with skill-based internal routing. Revisit when channel teams are running independently and data volumes justify isolation.
