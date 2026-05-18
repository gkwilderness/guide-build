---
title: "Team Vault Conventions"
type: architecture-spec
area: wilderness
project: Guide
tags: [guide, architecture, team-vaults, conventions]
created: 2026-04-29
status: active
---

# Team Vault Conventions

**Status:** Active
**Owner:** Gareth Knight

---

## What Is a Team Vault

A team vault is a shared Obsidian-structured directory that serves as the operational context for a functional team. It lives in `guide-teams/{name}/` on the Guide machine, synced via OneDrive so the team maintains it naturally.

Team vaults are the shared read layer for Guide agents. Channel agents read from them to operate within Slack channels. Personal instances mount them (read-only) to access team-level context relevant to the person's role.

The Wilderness-Guide vault (digital team) is the first team vault and the reference implementation for all others.

---

## When to Create a Team Vault

Create a new team vault when:
- A team has at least one personal instance or channel agent that needs shared context
- The team has operational content (backlogs, priorities, reports) that doesn't belong in another team's vault
- The team is willing to maintain the vault via OneDrive

Do not create a team vault speculatively. Personal instances work without one — they just have less shared context.

---

## Directory Structure

Every team vault follows this convention. Not all directories are required from day one — start with what the team needs, add structure as it earns its place.

```
{team-vault}/
├── CLAUDE.md                    ← REQUIRED: root instructions for agents
├── 00-Compass/                  ← Team priorities and focus
│   ├── PRIORITIES.md            ← Current quarter priorities
│   ├── TODAY.md                 ← Daily focus (updated by Guide or team lead)
│   └── ROADMAP.md               ← 12-month horizon
├── 10-Areas/                    ← Functional areas within the team
│   └── {area}/
│       └── CLAUDE.md            ← Area-specific agent instructions
├── 25-Channels/                 ← Delivery channels (if applicable)
│   └── {channel}/
│       ├── CLAUDE.md            ← Channel-specific agent instructions
│       ├── BACKLOG.md           ← PIE-scored backlog
│       ├── IDEAS.md             ← Unscored items
│       ├── ROADMAP.md           ← Channel roadmap
│       └── RESULTS.md           ← Completed items with outcomes
├── 30-People/                   ← Team member profiles
│   ├── TEAM.md                  ← Team structure overview
│   └── {person}/                ← Individual profiles
├── 40-Meetings/                 ← Meeting notes (YYYY-MM-DD-Topic.md)
├── 50-Notes/                    ← Working notes and summaries
├── 70-Reports/                  ← Automated and manual reports
│   └── pulse/                   ← Cron-generated pulse reports
├── __INBOX/                     ← Capture and triage
└── _Logs/                       ← Agent write log (scratch space)
```

### Required files

Only two files are required for a team vault to be functional:

1. **`CLAUDE.md`** — Root-level agent instructions. Tells any agent mounting this vault: what the team does, what files to load first, what conventions to follow, and what not to do.

2. **`00-Compass/PRIORITIES.md`** — Current priorities. Without this, agents have no orientation for the team's work.

Everything else is added as the team's operational maturity grows.

---

## CLAUDE.md Convention

Every folder that agents will read must have a `CLAUDE.md`. This is the instruction layer — it tells agents how to behave in that context.

### Root CLAUDE.md template

```markdown
# {Team Name} — Team Vault

## What This Is

{One paragraph: what the team does, who it serves, what this vault contains.}

## Files to Load First

| File | What it gives you |
|------|-------------------|
| `00-Compass/PRIORITIES.md` | Current quarter priorities |
| `30-People/TEAM.md` | Team structure |

## Conventions

- {Key convention 1}
- {Key convention 2}

## What Not to Do

- Do not modify files outside `_Logs/` without explicit instruction
- Do not surface internal process files (backlogs, PIE scores) to executives
```

### Folder-level CLAUDE.md

Shorter. Scoped to that folder's purpose:

```markdown
# {Folder Name}

{What this folder contains and how agents should use it.}

## Key files

- `BACKLOG.md` — PIE-scored task list. Read before any channel work.
- `ROADMAP.md` — Longer-horizon planning. Read for strategic context.
```

---

## Backlog Convention (PIE Scoring)

Team vaults that manage delivery work use the PIE-scored backlog system proven in the digital team vault.

### BACKLOG.md format

Items scored on three dimensions (1-10):
- **P** (Potential) — impact if completed
- **I** (Importance) — urgency / strategic alignment
- **E** (Ease) — effort to complete (10 = easiest)

Score = average of P + I + E. Items sorted by score descending.

```markdown
## Active

| # | Item | P | I | E | Score | Status |
|---|------|---|---|---|-------|--------|
| 1 | Implement lead scoring v2 | 9 | 8 | 6 | 7.7 | In progress |
| 2 | Fix GA4 event tracking | 7 | 9 | 8 | 8.0 | Ready |
```

### IDEAS.md

Unscored items. When an item is scored, it moves to BACKLOG.md.

### RESULTS.md

Completed items with outcomes. What was done, what happened, what was learned.

---

## OneDrive Sync

Team vaults are synced via OneDrive so the team can maintain them using any editor (Obsidian, Word, VS Code, etc.).

On the Guide machine, team vaults are symlinked from the OneDrive sync location:

```bash
# Local vaults (e.g. digital team vault):
ln -s "$HOME/Obsidian/{vault-name}" $HOME/guide-teams/{team-id}

# OneDrive-synced vaults (future team vaults):
ln -s "$HOME/Library/CloudStorage/OneDrive-Wilderness/Documents/Wilderness/{vault-name}" \
      $HOME/guide-teams/{team-id}
```

### Naming convention

| OneDrive folder name | guide-teams/ symlink |
|---------------------|---------------------|
| `Wilderness-Guide` | `guide-teams/digital` |
| `Wilderness-Exec` | `guide-teams/exec` |
| `Wilderness-Sales` | `guide-teams/sales` |
| `Wilderness-Reservations` | `guide-teams/reservations` |
| `Wilderness-People` | `guide-teams/people` |

### Caveats

- OneDrive sync latency: seconds to minutes. Fine for session-start context loading. Not suitable for real-time mid-session updates.
- Agents get the last saved version if a file is open. Fine for read-only access.
- Docker containers must mount the real OneDrive path (not the symlink) to resolve correctly inside the container.

---

## Agent Mount Convention

When mounting a team vault into an agent container:

On bare metal (ADR-021), agents access team vaults via the symlinks at `~/guide-teams/{team-id}/`. Path scoping is enforced via TOOLS.md (prompt-level). Agents never write to team vaults.

Agent writes go to:
- The agent's own workspace (`/workspace:rw`) for memory, logs, scratch
- `guide-outputs/` for shared outputs (shared agents only)

---

## Creating a New Team Vault

### Checklist

1. [ ] Create OneDrive folder: `Wilderness-{TeamName}`
2. [ ] Create `CLAUDE.md` at root
3. [ ] Create `00-Compass/PRIORITIES.md` with initial priorities
4. [ ] Share OneDrive folder with team members
5. [ ] On Guide machine: create symlink `guide-teams/{team-id}` → OneDrive path
6. [ ] Update Docker mounts for relevant agents (personal instances, channel agents)
7. [ ] Update `openclaw.json` with new volume paths
8. [ ] Restart gateway, verify agents can read the vault

### Seeding content

Start minimal. A team vault with two files (CLAUDE.md + PRIORITIES.md) is functional. Add structure as the team starts using it:

- Week 1: CLAUDE.md + PRIORITIES.md
- Week 2-4: Add TEAM.md, first backlog (if delivery-oriented)
- Month 2+: Add channel structure, meeting notes, reports

The digital team vault took months to reach its current depth. Don't front-load structure that hasn't been earned.

---

## Current Team Vaults

| Team ID | Status | Content depth | Agents reading it |
|---------|--------|---------------|-------------------|
| `digital` | Live | Deep — full channel structure, backlogs, reports, people | channel-data, channel-martech, channel-seo, channel-product, channel-hubspot, personal-hadley, personal-frances |
| `exec` | To create | Minimal — board docs, capital reports, FY27 targets | personal-nick, personal-hadley, personal-keith |
| `sales` | Future | — | personal-scott, personal-simon, channel-sales |
| `reservations` | Future | — | personal-caro, channel-reservations |
| `people` | Future | — | personal-dean |

---

## Related

- [[personal-instance-architecture]] — how personal instances mount team vaults
- [[00_Guide-Project-Brief]] — master project brief
- [[2026-04-24 Guide Filesystem Architecture]] — original filesystem design

---

*Created: 2026-04-29 | Owner: Gareth Knight*
