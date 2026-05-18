---
title: "Guide Architecture — Vault Scoping & Agent Comms"
type: architecture-note
area: wilderness
project: Guide
tags: [guide, architecture, vault, hermes, paperclip, agents]
created: 2026-04-24
status: active
---

# Guide Architecture — Vault Scoping & Agent Comms

*Decisions from 2026-04-24 morning walk. Context: post-demo (Nick approved $15k hardware + Claude Max + exec instances). Thinking through the right architecture for scale.*

---

## 1. Per-Agent Vault Scoping

### The Problem
Agents struggle with too much context. A Paid-WS agent mounting the full Wilderness vault burns tokens on SEO docs, people notes, and board decks it doesn't need. Output degrades. Cost increases. Security is trust-based, not structural.

### The Decision
Each agent gets:
- **Own workspace** — private write-access directory. SOUL.md, IDENTITY.md, memory, daily logs, backlog. Nobody else touches it.
- **Scoped read-only mounts** — Docker bind mounts of shared vaults the agent is cleared to read. Physically can't write. Can't be prompt-injected into writing.

### Tiered Shared Vault Structure

| Vault | Who mounts it | Contents |
|-------|--------------|----------|
| **Exec vault** | Nick, Hadley, Keith instances + Guide Main | Board-level outputs, capital allocation reports, exec briefs |
| **Ops vault** | Team leads, shared agents (Briefing, Scribe, Analyst) | Team context, project status, shared intelligence |
| **Brand vaults** (×3) | Brand-scoped agents (SEO-WS, Paid-WS, etc.) | Wilderness / Jacada / YZ specific data, briefs, notes |
| **Data vault** | Intelligence agents (CapitalCore, Apex, Analyst, Pipeline) | ETL outputs, performance data, markdown summaries |

### Guide Main is the Exception
Guide Main mounts everything. It's the orchestration layer — it needs full context to route correctly. Every other agent is scoped. Guide Main is the only agent that can see across all vaults.

### Implementation
In `openclaw.json`, each agent gets its own `workspace` path. Shared vaults are Docker bind mounts (`:ro`):

```yaml
volumes:
  - /home/gareth/Obsidian/Wilderness:/mnt/wilderness-vault:ro
  - /home/gareth/guide-data/outputs:/mnt/data:ro
```

Agent factory extended: `brand_overlay.yaml` + `role_template.yaml` + `vault_mounts: []` → full workspace config.

**Multiple mounts:** Agents can mount as many vaults as needed — no technical limit. Each is a separate Docker bind mount at a different path. Guide Main could mount all five vaults simultaneously. Practical constraint is access policy, not architecture. Mounting doesn't load into context — agent reads what it needs, when it needs it.

### Why This Matters
- **Security:** Access control is structural, not prompt-level
- **Context quality:** Agents get signal-dense context, not noise — better outputs, lower cost
- **Debugging:** When something goes wrong, you know exactly what the agent had access to
- **End user experience:** User doesn't care where the vault is or which machine Guide runs on. They just get the answer.

---

## 2. Agent-to-Agent Communication

### The Problem
`sessions_send` works technically but is counterintuitive for corporate users. It's an API call dressed as a message — requires thinking like a developer. Most Wilderness team members won't and shouldn't think that way.

### The Insight
Paperclip's ticket model maps to how humans already work in corporate environments:
- Raise a request (describe what you want)
- System routes to the right agent/model
- Delivery comes back
- Audit trail exists

Nobody finds this weird. It's how every project management tool works.

### The Creative Use Case (Hadley entry point)
"Describe the brief in plain English. Guide routes it to the right model. You get the draft."

- Non-technical CCO can use it immediately
- Content quality is visceral — she knows if it's good, no context needed to evaluate
- Fast feedback loop → high wow factor → habit formation
- Natural thread: content → email drafts → CapitalCore queries

### Revised Paperclip Timing
Original plan: Phase 3+ (when agent count exceeds 8).
**Revised:** Pull forward evaluation to Phase 1 end / Phase 2 start. Creative/content use case is the forcing function — it's a Hadley win that requires the ticket model to feel right.

Minimum viable experiment: install Paperclip alongside Guide, 3-agent company (Guide Main + creative agent + one brand agent), run 2 weeks. Does the ticket model reduce coordination overhead vs `sessions_send`?

---

## 3. Hermes + Vault Scoping = Right Pairing

### The Argument
Hermes's learning loop compounds on what it *sees*. A Hermes agent with a scoped vault accumulates signal-dense memory — not noise from unrelated docs. After 12 months it's a domain expert in exactly the domain it was given.

### Right Agents for Hermes (intelligence layer)

| Agent | Vault scope | What Hermes learns |
|-------|------------|-------------------|
| **CapitalCore** | Data vault (financial outputs only) | Full booking-cycle memory of yield curves, budget pacing, brand performance |
| **Apex** | Data vault (paid media only) | Every anomaly, bid inflation pattern, competitor move — diagnosis improves over time |
| **Analyst** | Ops vault + data vault | Cross-domain pattern recognition — seasonal norms, brand-specific signals |

### OpenClaw agents (operational layer)
Briefing, Scribe, Pipeline, HubSpot, SEO, Product, Paid — no accumulated memory needed, executing defined tasks. OpenClaw is correct here.

### Hermes Pilot Timing
Start the pilot now with a scoped vault from day one. Giving Hermes a clean, scoped feed from the start is what makes the learning loop valuable. Don't start it with everything mounted and scope it down later — the early memory will be noisy.

---

## 4. PDF → Markdown Pipeline

### Problem
Large brand PDF docs (brand guidelines, strategy docs, etc.) need to be in markdown for vault ingestion and agent context.

### Two-Stage Pipeline
1. **Marker** (open source, local) — batch converts PDFs to markdown, handles complex layouts, tables, images. `pip install marker-pdf`.
2. **Claude cleanup** — structure the output, add frontmatter, map to vault naming conventions.

Set up on Scout or Guide machine. Run once per brand doc set, then maintain in markdown going forward.

---

## 5. Concurrent Access & Atomic Versioning

### The Problem
Obsidian is a single-user app — running n instances isn't the answer. But agents don't use Obsidian. Obsidian is just a UI for markdown files on a filesystem. Agents read and write files directly. Obsidian is irrelevant to the agent architecture.

The real concurrency problem: multiple agents writing to the same file simultaneously. Solution: each agent has its own write-scoped workspace (already designed). Shared vaults are read-only mounts. Writes never conflict because agents only write to their own space.

### What Production Systems Do

**Plain filesystem with access control** — agents read/write markdown directly. Concurrent reads are safe. Concurrent writes are safe when scoped correctly. This is the right model for Guide.

**Git worktrees** — multiple agents each get a separate branch + working directory backed by one `.git` store. Conflicts surface at merge time. Used by GitHub Copilot Squad. Relevant for coding agents, overkill for knowledge vaults.

**tick-md / append-only shared log pattern** — coordination via a shared append-only markdown file. Agents append structured blocks, never overwrite. Async, version-controlled, no real-time sync needed. Right pattern for Guide's audit trail.

**Vector database as shared layer** — agents query embeddings rather than reading files directly. Better for large-scale retrieval, worse for human readability. Not needed at current Guide scale — relevant for CapitalCore as data volume grows.

### Atomic Versioning — The Answer: Git

Obsidian Sync gives version history, conflict resolution, and rollback — but it's designed for human conflict resolution, not programmatic audit trails.

For agents, git is strictly better:
- Auto-commit after every agent write
- Every write is versioned, attributable, rollback-able
- `git log` = full audit trail: who wrote what, when, what changed
- Diff any two versions
- Nick can ask "what did CapitalCore recommend last Tuesday" — you can show him exactly

**Commit pattern:** `[agent-id] YYYY-MM-DD HH:MM: <description>` — every output is immutable history.

### Clean Separation: Human Layer vs Agent Layer

| Layer | Tool | Who uses it |
|-------|------|------------|
| Human read/write | Obsidian Sync | Gareth, team (personal vault, Wilderness work notes) |
| Agent write | Git auto-commit | All Guide agents — output paths only |

Obsidian Sync stays on human-facing vaults. Git handles agent-facing paths. They never compete. No overlap, no conflict.

### Append-Only Shared Log

For cross-agent coordination and Nick's audit trail requirements:
- `guide-shared/output-log.md` — agents append structured blocks, never overwrite
- `guide-shared/decisions.md` — CapitalCore/Apex decisions appended with timestamp and agent ID
- Each append is one git commit — atomic, attributable, durable

This is the pattern GitHub Squad uses internally. Async coordination that scales without real-time sync complexity.

---

## Related Notes

- [[2026-04-18 Guide × Hermes × Paperclip Strategic Briefing]] — full Hermes/Paperclip analysis
- [[00_Guide-Project-Brief]] — master project brief
- [[2026-04-23-Guide-Demo]] — Nick demo milestone; $15k hardware + Claude Max approved

---

*Captured from morning ruck, 2026-04-24. Needs review before CHUNK integration.*
