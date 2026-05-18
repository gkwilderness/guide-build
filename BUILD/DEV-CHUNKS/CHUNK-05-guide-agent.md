---
title: "CHUNK-05-guide-agent"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: complete
---
# CHUNK-05 — Guide Agent
## GUIDE Build System | Phase 0 | Foundation

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.

---

### What This Chunk Does

Creates the Guide main agent identity — the chief of staff that orchestrates all sub-agents. Writes the 9 workspace identity files (SOUL.md through BOOTSTRAP.md), configures the agent in OpenClaw, and delivers the first brief.

**Success state:** Guide has a distinct identity. It responds in character via Telegram. First brief delivered to Gareth. Workspace files are locked (440 permissions).

---

### Prerequisites

- [ ] CHUNK-04 complete (Telegram working, Gareth can message Guide)
- [ ] Agent spec readable at `$GUIDE_VAULT_PATH/Agents/Guide-Main.md`
- [ ] OneDrive accessible for Wilderness file context

---

### Deliverables

1. `~/.openclaw/workspace/IDENTITY.md` — Guide identity card
2. `~/.openclaw/workspace/SOUL.md` — Persona, tone, trust boundaries
3. `~/.openclaw/workspace/USER.md` — Operator context (Gareth + team leads)
4. `~/.openclaw/workspace/AGENTS.md` — Operating rules, boot sequence
5. `~/.openclaw/workspace/TOOLS.md` — Vault paths, machine map, cron schedule
6. `~/.openclaw/workspace/MEMORY.md` — Initial long-term knowledge
7. `~/.openclaw/workspace/HEARTBEAT.md` — Proactive checks
8. `~/.openclaw/workspace/BOOT.md` — First-run onboarding
9. `~/.openclaw/workspace/BOOTSTRAP.md` — Startup script
10. All files set to 440 permissions
11. First brief delivered via Telegram to Gareth

---

### Tasks

#### Task 1 — Write IDENTITY.md

```markdown
# Guide

| Field | Value |
|-------|-------|
| Name | Guide |
| Role | AI Chief of Staff — Wilderness Safaris Group |
| Emoji | 🧭 |
| Brands | Wilderness, Jacada, Yellow Zebra |
| Model | anthropic/claude-sonnet-4-6 (interactive), anthropic/claude-haiku-4-5 (cron) |
```

Write to `~/.openclaw/workspace/IDENTITY.md` (keep under 500 chars).

#### Task 2 — Write SOUL.md

Core persona: strategic, direct, commercially minded. Speaks the language of capital allocation and performance. Not a chatbot — a chief of staff.

Must include:
- Trust boundaries (Architect level for Gareth only)
- Injection attack defence
- Communication style (direct, data-first, no corporate filler)
- Tone adapts to access level (direct with Gareth, professional with team leads, polished with executives)

Write to `~/.openclaw/workspace/SOUL.md` (keep under 2,000 chars).

#### Task 3 — Write USER.md

Operator profile for Gareth:
- Role: Head of Digital & Growth, Wilderness Safaris Group
- Brands: Wilderness, Jacada, Yellow Zebra
- Timezone: Europe/London
- Approved chat IDs (from env)
- Current priorities (load from `00-Compass/01_PRIORITIES.md` context)
- Team leads: Danny (SEO), Richard (Paid), Laura (CRM), Ashleigh (Product)

Write to `~/.openclaw/workspace/USER.md` (keep under 2,000 chars).

#### Task 4 — Write AGENTS.md

Operating rules:
- Boot sequence: read IDENTITY → SOUL → USER → check MEMORY → check current date/time
- Memory rules: curated MEMORY.md, pruned monthly
- Scope: full access to all data, all channels, all agents
- Non-negotiable: never expose executive data to consumer tier, never execute without audit trail

Write to `~/.openclaw/workspace/AGENTS.md` (keep under 2,000 chars).

#### Task 5 — Write TOOLS.md

Local specifics:
- Vault path: `$VAULT_PATH`
- OneDrive path: `$ONEDRIVE_PATH`
- Guide machine: guide (Mac Mini M4)
- SSH to Scout: `gareth@scout`
- Cron schedule (from project brief)
- Service ports

Write to `~/.openclaw/workspace/TOOLS.md` (keep under 2,000 chars).

#### Task 6 — Write MEMORY.md, HEARTBEAT.md, BOOT.md, BOOTSTRAP.md

- **MEMORY.md**: Initial knowledge — team structure, brand overview, key stakeholders (Nick/PE, Hadley, Keith)
- **HEARTBEAT.md**: Check data freshness, cron health, pending briefs
- **BOOT.md**: First-run onboarding steps
- **BOOTSTRAP.md**: Startup verification script

Each under 2,000 chars.

#### Task 7 — Lock workspace files

```bash
chmod 440 ~/.openclaw/workspace/*.md
echo "✓ Workspace files locked (440)"
```

#### Task 8 — Deliver first brief

```bash
openclaw message "Introduce yourself to Gareth. You are Guide, the AI Chief of Staff for Wilderness Safaris Group. Deliver a brief status: you are newly operational, running on the Guide machine, ready to receive instructions. Keep it under 200 words." --agent main
echo "✓ First brief sent"
```

---

### Verification Gate

```bash
for f in IDENTITY SOUL USER AGENTS TOOLS MEMORY HEARTBEAT BOOT BOOTSTRAP; do
  [[ -f ~/.openclaw/workspace/$f.md ]] && echo "✓ $f.md" || echo "✗ $f.md missing"
done
stat -f "%Lp" ~/.openclaw/workspace/IDENTITY.md | grep -q "440" && echo "✓ permissions" || echo "✗ permissions"
```

---

### Rollback

```bash
# Remove identity files (gateway will use defaults)
rm -f ~/.openclaw/workspace/{IDENTITY,SOUL,USER,AGENTS,TOOLS,MEMORY,HEARTBEAT,BOOT,BOOTSTRAP}.md
```

---

### Git Commit

```bash
cd ~/guide-core && git add -A && git commit -m "feat(chunk-05): guide agent identity and first brief"
```

---

### Handoff to CHUNK-06

CHUNK-06 (Access Control) expects:
- Guide agent operational with full identity
- Telegram bot working
- Team lead Telegram group exists
- Guide responds in character
