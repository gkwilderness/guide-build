---
title: "Compaction — Reference Note"
type: log
area: ai
project: Guide
tags: [guide, jarvis, compaction, context, memory, architecture]
created: 2026-04-15
---

# Compaction — What It Is and How We've Solved It

*Reference note — compiled 2026-04-15 from OpenClaw docs and build decisions.*

---

## What Compaction Is

Every model has a context window — a hard cap on how many tokens it can see at once. When a conversation approaches that limit, OpenClaw **compacts**: it summarises older turns into a single entry, keeps recent messages intact, and continues. The summary is saved to the transcript on disk. The model only sees the summary + recent messages going forward.

The problem isn't compaction itself — it's what gets lost. A summary is **lossy compression**. Decisions, nuanced context, specific details, and tool outputs can all vanish. After compaction, the agent may not "remember" things it knew two hours ago. In a persistent session (like a live Guide team brief session), this degrades over the course of a long day or week.

**Secondary problems:**
- Tool outputs (file reads, exec results) inflate context fast, triggering compaction earlier than necessary
- If compaction uses the same model as the agent, it costs tokens too
- Compaction can happen silently — the user doesn't know context was lost

---

## What OpenClaw Does Natively

- **Auto-compaction** — triggers when context crosses the threshold (`contextWindow - reserveTokens`), or on overflow error (compact + retry)
- **Session pruning** — lighter complement: trims old tool results in-memory before each request, without touching conversation history. Keeps context lean between compaction cycles. Auto-enabled for Anthropic.
- **Pre-compaction memory flush** — when context hits a soft threshold *before* compaction kicks in, OpenClaw runs a silent `NO_REPLY` turn prompting the agent to write memory to disk. Runs once per compaction cycle. This is the key native mitigation.
- **Manual `/compact`** — force compaction with instructions to guide the summary
- **`/new`** — fresh session, no compaction, clean slate

---

## What We've Done for Guide

Guide's architecture is designed compaction-first — it's a multi-agent system where compaction in one role could corrupt the whole build.

**Three-role architecture (ADR-013):**
Architect, Engineer, and Vault are completely separate Claude sessions on separate machines. No single session accumulates enough context to compact badly. Each starts fresh, reads the relevant spec files, does its work, commits to files, terminates.

**Chunk-based build sessions:**
Each CHUNK is a separate Engineer session (`claude --resume <id>`). Sessions are resumed by ID, not left running indefinitely. When a chunk is done, the session is closed. `SESSIONS.md` is the handoff file — not a running conversation.

**Full vault on Guide machine (ADR-006):**
Engineer reads specs and context directly from files, not from a growing conversation with Gareth. Context never accumulates across turns.

**Signal files as cross-role comms (ADR-014):**
`→architect.md`, `→engineer.md` are written to disk, not passed through session memory. Decisions survive role switches cleanly.

**Deferred Ollama (ADR-011):**
Deferring local models until cron is live is partly a compaction-related decision — using Haiku for background tasks keeps context windows large enough that compaction rarely triggers for short-lived cron runs.

**Isolated cron sessions:**
Every cron job runs with `sessionTarget: isolated`. Each run is a fresh session — reads what it needs from vault files, delivers output, terminates. Zero accumulated context. Zero compaction risk. The vault files *are* the memory.

**Vault (the live Guide agent) — file-first memory:**
Will follow the same pattern as Jarvis once fully operational:
- `MEMORY.md` — long-term curated memory
- `memory/YYYY-MM-DD.md` — daily raw log
- Session startup reads key identity and context files to reconstruct working state

---

## What Jarvis Does (Reference)

Jarvis pioneered the same approach. Key patterns Guide inherits:

- File-first memory (MEMORY.md + daily logs)
- Hard rule: no mental notes — if it needs to be remembered, write it to a file
- Session startup reads reconstruct context after any reset or compaction
- Signals files (`→jarvis.md` etc.) externalise cross-session handoffs to disk

---

## The Core Philosophy

> Treat compaction as a given, not a problem to prevent. The answer is externalising state — memory files, vault docs, signal files, isolated sessions — so that whatever the model forgets, the files remember.
