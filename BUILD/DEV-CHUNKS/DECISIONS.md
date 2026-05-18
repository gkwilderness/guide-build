---
title: "Guide — Architectural Decisions"
type: decisions
area: ai
project: "Guide"
tags: [ai, guide, build, decisions]
status: active
updated: 2026-04-05
---
# Guide — Architectural Decisions

Decisions are numbered, immutable once made, and include rationale. Review triggers indicate when to reconsider.

---

## ADR-001: Multi-Brand Hybrid Architecture

**Date:** 2026-04-05
**Status:** Accepted

**Decision:** Use a hybrid model — shared infrastructure agents + brand-specific team agents + cross-brand intelligence agents.

**Options considered:**
- A. Shared agents with brand parameter (1 SEO agent serves all 3 brands)
- B. Fully brand-specific agents (3× everything = 36+ agents)
- **C. Hybrid (selected)** — shared infra + brand-specific team agents

**Rationale:** Teams already work in brand silos. Data is brand-scoped. But infrastructure (pipeline, briefing, orchestration) is shared. Hybrid keeps cost linear (20 agents vs 36) while respecting real team boundaries.

**Review trigger:** If brand-specific agents share >80% of their prompts/outputs, consider merging to shared-with-parameter.

---

## ADR-002: Agent Factory for Workspace Generation

**Date:** 2026-04-05
**Status:** Accepted

**Decision:** Build an agent factory that generates full OpenClaw workspaces from role templates + brand overlays. New agent spin-up is a 5-minute config task.

**Rationale:** 20 agents hand-crafted is a maintenance nightmare. `openclaw-templates` works for 2-3 agents but doesn't scale to 20. The factory extends the template pattern with brand overlays and automated registration.

**Review trigger:** If fewer than 3 brands are active, simplify to manual templates.

---

## ADR-003: Paperclip Deferred to Phase 5

**Date:** 2026-04-05
**Status:** Superseded by ADR-017 (2026-04-20) — Paperclip pulled forward to Phase 1

**Decision:** Build Phase 0–4 on OpenClaw directly. Evaluate Paperclip for orchestration in Phase 5 (CHUNK-29).

**Rationale:** Paperclip is 5 weeks old (launched March 2026) with ~1 core contributor. High momentum (47K+ GitHub stars) but volatile. Its multi-company isolation and per-agent budgets are exactly what Guide needs at scale, but the project needs 6+ months of maturity before betting production systems on it.

**Review trigger:** See ADR-017.

---

## ADR-017: Paperclip Pulled Forward to Phase 1

**Date:** 2026-04-20
**Status:** Accepted — supersedes ADR-003

**Decision:** Install Paperclip as a POC in Phase 1 (CHUNK-11), not Phase 5. Wire Wilderness Group Digital company with Data + SEO agents as departments and at least one live heartbeat for the Keith & Nick demo.

**What changed:** Two drivers:
1. **Demo requirement** — Keith & Nick presentation in 3 weeks. Paperclip's org chart + heartbeat model is the governance story. Without it the demo shows isolated agents but no governance layer.
2. **Strategic briefing (2026-04-18)** — Analysis confirmed a "minimum viable experiment" costs ~4 hours and gives clear signal within 2 weeks. Not worth deferring when the demo is imminent and the cost is low.

**Scope constraint:** Phase 1 Paperclip is a POC only — 2–3 agents, one heartbeat, demo-ready. Not production governance. Budget controls, full org chart, and Analyst/Apex integration remain Phase 3+ scope.

**Rationale for original deferral still applies at scale:** Paperclip's maturity risk hasn't changed. The POC is low-risk because it runs alongside OpenClaw with no dependency — if it breaks or proves immature, remove it. OpenClaw continues unaffected.

**Review trigger:** After demo. If Paperclip POC is stable and adds clear value → plan Phase 3 full integration. If unstable or not compelling → park until v1.0 stable.

---

## ADR-004: Greenfield Build (Not Live-System Migration)

**Date:** 2026-04-05
**Status:** Accepted

**Decision:** Guide builds from scratch on a fresh machine — greenfield, no migration.

**Rationale:** There is no existing Guide system to migrate. The machine hasn't been configured yet. This means we can use CHUNK-00+ numbering and skip the snapshot/rollback complexity that a live-system migration would require.

**Review trigger:** N/A — one-time decision.

---

## ADR-005: macOS (Not Linux) for Guide Machine

**Date:** 2026-04-05
**Status:** Accepted

**Decision:** Guide runs on macOS (Mac Mini M2 Pro), not Linux like Scout.

**Rationale:** OneDrive for macOS is better supported than Linux alternatives. Docker Desktop on Apple Silicon is mature. Different OS from Scout also means different failure domain.

**Implication:** launchd instead of systemd, Homebrew instead of apt. All chunks must use macOS conventions.

**Note:** Spec originally said "Mac Mini M4" — confirmed via `system_profiler` on 2026-04-13 to be M2 Pro. All docs corrected 2026-04-14.

**Review trigger:** If Docker Desktop or OneDrive on macOS proves unreliable, consider Linux migration.

---

## ADR-007: WhatsApp via Baileys, Not Business API

**Date:** 2026-04-05
**Status:** Accepted

**Decision:** Use OpenClaw's native WhatsApp channel (Baileys/WhatsApp Web bridge) with a dedicated prepaid SIM. Do not pursue the official WhatsApp Business API.

**Rationale:** OpenClaw doesn't support the Business API — it uses Baileys, which links via QR code like WhatsApp Web. This is massively simpler: no Meta approval, no business verification, no cost, no weeks-long onboarding. Just buy a SIM, register WhatsApp, scan QR, done.

**Risk:** Baileys is unofficial. WhatsApp can ban numbers using it. Mitigated by:
- Low volume (a few executive briefs per week, not mass messaging)
- Dedicated number (not Gareth's personal WhatsApp)
- OpenClaw's own docs recommend this exact approach

**Review trigger:** If the dedicated number gets banned, consider: (a) getting a new SIM, (b) switching to Telegram for executives, (c) evaluating Business API at that point.

---

## ADR-006: Full Vault on Guide Machine — Engineer Reads Directly

**Date:** 2026-04-05
**Status:** Accepted

**Decision:** The Guide machine has the guide-build vault synced and all repos locally. The Engineer Claude reads everything directly.

**Rationale:** Unlike a strict "Architect designs, Engineer executes blindly" model, giving the Engineer full context means:
- No bottleneck of Gareth copying specs into sessions
- Engineer can read CLAUDE.md files, agent specs, and architectural decisions without asking
- The build is faster and the Engineer makes better decisions with full context

**Implication:** The Two-Claude split is about **role** (design vs execution), not **access**. Both can read everything. The Architect decides what to build; the Engineer decides how to build it within the spec.

**Review trigger:** If vault sync causes conflicts or the Engineer starts modifying specs it shouldn't, tighten access.

---

## ADR-008: OpenClaw via Docker, Not Bare-Metal npm

**Date:** 2026-04-13
**Status:** Reversed — see ADR-021 (2026-04-29)

**Decision:** Run OpenClaw via Docker Compose (using `ghcr.io/openclaw/openclaw:latest`), not as a global npm install.

**Rationale:** Containerised runtime is isolated, reproducible, and easier to manage (restart, update, rollback). The CHUNK-02 spec called for `npm install -g openclaw` but Docker is the battle-tested approach.

**Review trigger:** ~~If Docker Desktop on macOS proves unreliable or resource-heavy, consider bare-metal.~~ **Trigger fired 2026-04-29.** See ADR-021.

---

## ADR-009: Port Mapping Instead of Host Networking on macOS

**Date:** 2026-04-13
**Status:** Accepted

**Decision:** Use Docker port mapping (`127.0.0.1:18789:18789`) instead of `network_mode: host` for the OpenClaw gateway.

**Rationale:** On Linux, `network_mode: host` binds container ports directly to the host's loopback. On macOS, Docker Desktop runs containers inside a Linux VM, so host networking doesn't expose ports to the Mac's network stack. Port mapping is the correct macOS equivalent.

**Implication:** All future services in the compose file must use explicit port mappings. Cannot rely on container ports being automatically reachable from the host.

**Review trigger:** N/A — fundamental macOS Docker constraint.

---

## ADR-010: acpx Codex Probe Failure Is Ignorable

**Date:** 2026-04-13
**Status:** Noted

**Decision:** The `acpx runtime backend probe failed` log message on gateway startup is safe to ignore.

**Rationale:** This is an optional OpenClaw plugin (Codex ACP integration) that attempts to probe on startup. It fails because the Codex binary isn't installed, which is expected — Guide doesn't use Codex. The gateway continues to operate normally and reports healthy.

**Review trigger:** If we later need Codex/ACP integration, install the dependency.

---

## ADR-011: Ollama Deferred — Evaluate After Cron Is Live

**Date:** 2026-04-14
**Status:** Deferred

**Decision:** Do not integrate Ollama now. Evaluate after CHUNK-08 (Cron & Ops) is running and real API costs are visible.

**Rationale:** Ollama on the M4 is trivial to install and would eliminate API costs for cron/background tasks. However, Guide has no running cron jobs yet — we don't know whether Haiku costs are a real problem. Haiku is ~$0.25/M input tokens; routine cron tasks processing a few KB of data will cost pennies per month. Adding Ollama now introduces complexity (local model management, quality risk, OpenClaw integration unknown) before there's evidence of a cost problem to solve.

**If/when we evaluate:**
- Install: `brew install ollama && ollama pull llama3.2` (5 minutes on M4)
- Integration path: Ollama exposes an OpenAI-compatible API at `localhost:11434/v1` — check if OpenClaw supports custom LLM endpoints natively
- If not native: write a thin adapter skill routing low-complexity prompts to Ollama
- Good candidates: health check summaries, simple data formatting, routine status messages
- Keep on Claude: strategic briefs, people context, anything requiring nuanced reasoning

**Review trigger:** After CHUNK-08 is live. If monthly Haiku spend exceeds £10, evaluate. If it's under £5, leave it.

---

---

## ADR-014: Inter-Role Communication — Signal Files + Gateway API

**Date:** 2026-04-14
**Status:** Accepted (signal files); Planned (gateway API)

**Problem:** The three roles (Architect, Engineer, Vault) had no direct communication path. Gareth was the only relay — every insight from the Vault that needed design or engineering work required manual handoff.

**Decision:** Two-layer communication model:

**Layer 1 — Signal files (live now)**
`~/.openclaw/workspace/signals/` contains three files:
- `→architect.md` — Vault writes design/spec needs; Architect reads at session start
- `→engineer.md` — Vault writes build/config needs; Engineer reads at session start
- `→gareth.md` — Vault writes operator actions (physical, purchasing, people)

Format: `[YYYY-MM-DD] [open/resolved] description`
Vault pings Gareth when writing a signal. Gareth opens the relevant session to action it.

**Layer 2 — Gateway API (when Tailscale is live)**
OpenClaw gateway (`127.0.0.1:18789`) accepts REST calls with auth token. Once Tailscale is configured:
- Engineer (same machine): can POST to gateway directly to send Vault a message or trigger workspace reload
- Architect (Mac): can POST via Tailscale hostname (`guide:18789`) to send Vault a message or query state

Gateway auth token: stored in `~/.openclaw/openclaw.json` under `gateway.auth.token`. Use `Authorization: Bearer <token>` header.

Example (Engineer, same machine):
```bash
curl -s -X POST http://127.0.0.1:18789/message \
  -H "Authorization: Bearer $(jq -r '.gateway.auth.token' ~/.openclaw/openclaw.json)" \
  -H "Content-Type: application/json" \
  -d '{"agentId": "main", "message": "Engineer: CHUNK-07 complete. Gateway restarted."}'
```

**Rationale:** Signal files require zero new infrastructure and work immediately. The gateway API is the proper solution for real-time cross-role messaging but depends on Tailscale being configured. Layer 1 now, Layer 2 when ready.

**Review trigger:** When Tailscale is live (CHUNK-08 or later), implement Layer 2 and consider whether signal files are still needed or can be replaced.

**2026-04-16 — Trigger fired:** Tailscale is now live (`guide.tailfbf66e.ts.net`). Gateway is reachable from Gareth's Mac via Tailscale. Layer 2 (REST calls to gateway) is now technically possible. Signal files remain in use for now — no decision yet to replace them. Revisit once CHUNK-08 is underway.

---

## ADR-013: Three-Role Architecture

**Date:** 2026-04-14
**Status:** Accepted

**Decision:** Formalise three distinct Claude roles — Architect, Engineer, and Vault — each with a defined machine, function, and escalation path. All three are aware of each other.

| Role | Machine | Claude | Function |
|------|---------|--------|----------|
| **Architect** | Gareth's Mac | Claude Code in Obsidian vault | Designs specs, writes chunks, manages docs, coordinates build |
| **Engineer** | Guide (Mac Mini M2 Pro) | Claude Code on bare metal | Executes chunks, writes and runs code, commits to guide-core |
| **Vault** | Guide (Mac Mini M2 Pro) | OpenClaw main agent | Live ops — serves team via Telegram/Slack, delivers briefs, observes channels |

**Handoffs:**
- Architect → Engineer: CHUNK spec committed to vault. Engineer reads and executes.
- Architect → Vault: workspace files updated. Gateway restarted. Vault picks up new rules.
- Engineer → Vault: code deployed, gateway restarted. Vault operates new capabilities.
- Vault → Gareth: surfaces what needs building (Engineer) or designing (Architect). Never self-engineers.

**Escalation rule for Vault:** Requests needing code/config changes outside the workspace → flag to Gareth as "needs Engineer." Requests needing architectural or spec changes → "needs Architect." Vault self-modifies only MEMORY.md.

**Rationale:** This workflow emerged naturally during Phase 0. Formalising it prevents role confusion, clarifies what each instance should and shouldn't do, and makes handoffs explicit. The Vault in particular needs to know it cannot self-engineer — it operates what the Engineer built.

**Review trigger:** If a fourth role emerges (e.g., a dedicated Data Claude for pipeline work), extend this ADR.

---

## ADR-012: BUILD.md Chunk Numbering Is Canonical

**Date:** 2026-04-14
**Status:** Accepted

**Decision:** BUILD.md is the single source of truth for chunk numbering. Git commit labels and agent-reported chunk numbers are secondary and may diverge.

**Background:** During the Phase 0 build, the Engineer committed Slack integration as `feat(chunk-07)` before committing access control bindings as `feat(chunk-06)` — two commits out of sequence in labeling. Both pieces of work belong to CHUNK-06 (Access Control) in the spec. CHUNK-07 (Security & Hardening) has not been executed.

Separately, when queried, the Vault Claude (Guide's own agent) reported "CHUNK-07 = workspace identity files" — which matches neither the git log nor the spec (identity files were CHUNK-05). The Vault Claude's chunk count is unreliable.

**Rule:** If there's a conflict between BUILD.md, git commit labels, and agent-reported numbers — trust BUILD.md. Use git log for actual content, not for chunk mapping.

**Review trigger:** N/A — standing rule.

---

---

## ADR-015: Tiered Slack DM Model — Outbound Allowlist + Polite Mode

**Date:** 2026-04-16
**Status:** Superseded by ADR-016 — implementation attempt caused crash-loop 2026-04-17. Decision stands; enforcement approach revised.

**Problem:** OpenClaw's `dmPolicy: "pairing"` gates inbound DMs via `allowFrom` but places no restriction on outbound. Guide can currently send a DM to any Slack workspace member if instructed to. This is an asymmetric access control gap — the tier model protects what people can ask Guide, but not who Guide can reach.

**Decision:** Implement a three-tier Slack DM model:

| Mode | Who | Guide sends | They reply | Guide responds | Vault access |
|------|-----|------------|------------|----------------|--------------|
| **Full** | Gareth, Laura, Danny, Richard | ✅ | ✅ | ✅ full | ✅ |
| **Polite** | Digital team (Maria, Fay, David, Jack, Tenneil, Adam, Claire, Frances, Yoann; Matt + Rafael pending IDs) | ✅ reminders/nudges only | ✅ | ✅ limited | ❌ |
| **None** | Everyone else | ❌ | — | — | — |

**Polite mode behaviour:**
- Guide can initiate: reminders, brief notifications, soft nudges ("your weekly summary is in #guide-briefs")
- If they reply: Guide acknowledges and redirects ("noted — I'll flag that to Gareth" / "check #guide-briefs for the full detail")
- Guide does **not** query the vault, perform actions, or treat their messages as agent requests
- "Listen but not fetch" — Guide is present but not serving them as an agent

**Implementation approach:**
- Outbound gating: skill or middleware check against a `dmOutboundAllowlist` before any DM send. If recipient not on list → block and log.
- Polite mode: second list `dmPoliteList` — if sender is on it, Guide responds with a restricted prompt that strips vault tools and enforces redirect-only behaviour
- Both lists maintained in `openclaw.json` or a separate config file

**Rationale:** The current gap means Guide could accidentally (or on instruction) open a DM channel with any team member, giving them a Guide interface they weren't intended to have. Even with `dmPolicy: "pairing"` blocking their replies, opening the channel creates confusion and erodes the tier model's clarity. Polite mode is the right middle ground — it allows Guide to be a presence for the team (reminders, nudges, directed comms) without becoming a general-purpose query interface for people who shouldn't have that.

**Review trigger:** When polite-mode users are added — confirm the vault-access restriction is working as intended before expanding the list.

---

## ADR-016: Outbound DM Enforcement — Schema Gap, Hook Option, and Revised Approach

**Date:** 2026-04-17
**Status:** Accepted — implementation pending

**Background:** ADR-015 specified outbound DM gating via `dmOutboundAllowlist` and `dmPoliteList` fields in `openclaw.json`. These keys do not exist in OpenClaw's schema (`additionalProperties: false`). Adding them caused a crash-loop on 2026-04-16 (see CLAUDE.md Known Pitfalls). The implementation was rolled back.

**Research findings:**

1. **OpenClaw has no schema-valid field for outbound DM control.** `dmPolicy`/`allowFrom` are inbound-only. This is a deliberate maintainer position — authenticated gateway callers are treated as trusted operators. Feature requests (#6324, #10157, #10616, #30560) across WhatsApp, Telegram, and Signal have all been closed as "not planned." There is no Slack-specific outbound restriction on the roadmap.

2. **Hooks are inbound-only — outbound hooks do not exist.** Confirmed 2026-04-17 by Engineer inspection of the live system. The 5 registered hooks are all internal lifecycle events: boot, file injection, command logging, session memory, and memory-core cron. There is no `message:sent`, `dm:sent`, or any post-send event. The hooks system cannot intercept or gate outbound messages. **This option is closed.**

3. **Slack API layer cannot help.** `im:write` is all-or-nothing. No per-user bot DM restriction exists at the Slack scope level.

**Decision — revised implementation approach (ranked):**

**~~Option 1: `message:sent` hook~~ — CLOSED.** Hooks are inbound-only. No outbound event hook exists in OpenClaw. Confirmed 2026-04-17.

**Option 2 (now primary): Tool deny + custom plugin**
- Deny the agent's native Slack send tool via `tools.deny`
- Write a custom OpenClaw plugin wrapping `conversations.open` + `chat.postMessage`
- Allowlist baked into the plugin — validates recipient before calling Slack API
- Most robust option if hooks aren't available — removes the unsafe tool entirely

**Option 3 (interim): Env var + tool deny**
- Set `GUIDE_OUTBOUND_DM_ALLOWLIST=U123,U456,...` on the Guide machine
- Deny native send tool
- Only custom wrapper code calls the Slack API, reading env var before sending
- Fast to implement, easy to audit, but relies on wrapper discipline

**What not to do:** Do not add `dmOutboundAllowlist` or `dmPoliteList` (or any other non-schema key) to `openclaw.json`. Verify any new key against the live schema before writing it.

**Next action for Engineer:** Pull the Slack tool identifiers from `tools.byProvider` — need exact tool IDs to design the deny list before speccing the custom plugin. Report identifiers via `→architect.md` signal.

**Review trigger:** Once Engineer pulls Slack tool identifiers and custom plugin implementation is complete.

---

## ADR-018: Personal Instances Supersede Exco Agent

**Date:** 2026-04-29
**Status:** Accepted — supersedes exco-agent-spec.md

**Decision:** Each executive (and later, domain user) gets their own dedicated Guide agent with a per-person Telegram bot, rather than a single shared exco agent that identifies users by phone number.

**What changed:** Nick and Hadley approved the build-out and asked for their own instances. Dean, Caro, Scott, Keith, Simon, and Frances will too. That's 8 personal instances — a different shape from the 3 exec slots originally designed.

**Options considered:**
- A. Shared exco agent (original spec) — one agent, identifies user by WhatsApp number, adapts register per person
- **B. Per-person agents (selected)** — each person gets their own agent, own workspace, own Telegram bot

**Rationale:** Per-person agents give stronger isolation than a shared agent. Separate bot tokens mean conversations are physically separated — one bot cannot see another's messages. Each agent has its own context window, memory, and vault scope. The trust problem ("can Gareth read my conversations?") is closed architecturally, not by policy.

The exco spec's valuable patterns — hybrid review model (factual vs judgment routing) and per-exec framing — are absorbed into each personal instance's SOUL.md.

**Review trigger:** If personal instance count exceeds 15, evaluate whether a lightweight shared routing agent (like the original exco spec) would reduce operational overhead.

---

## ADR-019: Team Vaults as First-Class Architecture

**Date:** 2026-04-29
**Status:** Accepted

**Decision:** Introduce `guide-teams/` as a top-level directory for team vaults. Team vaults are shared operational context for a functional team, mounted read-only by agents. The Wilderness-Guide vault (digital team) is the first team vault, not a one-off.

**Context:** The Wilderness-Guide vault was built for the digital team and is already live — full channel structure, PIE-scored backlogs, CLAUDE.md conventions, automated reports. As Guide scales to other teams (sales, reservations, exec, people/HR), each will need their own vault.

**What this replaces:** The April 24 filesystem architecture note designed `guide-shared/` as a monolithic shared layer with `brand/`, `data/`, `exec/` subdirectories. Team vaults are now first-class — `guide-shared/` is supplementary for cross-team content (brand docs, pipeline outputs, KBs) that doesn't belong to any single team.

**Two-dimensional model:** Guide serves people through personal instances (one person, one agent) and team vaults (one function, shared context). A personal instance mounts the team vaults relevant to that person's role.

**Team vault conventions:** Each follows the Wilderness-Guide pattern — `CLAUDE.md` at root, folder-level CLAUDE.md files, `00-Compass/` for priorities, backlogs where appropriate, OneDrive-synced. See `Specs/team-vault-conventions.md` for the full specification.

**Review trigger:** If team vaults proliferate beyond 6, evaluate whether a centralised governance layer (vault-of-vaults index, automated health checks) is needed.

---

## ADR-020: Privacy Architecture — Structural Enforcement

**Date:** 2026-04-29
**Status:** Accepted

**Decision:** Personal instance privacy is enforced structurally via filesystem isolation and Docker mount scoping. The privacy guarantees must be architecturally true before being stated to users.

**Five structural guarantees:**

1. **Workspace isolation** — each personal workspace is the only rw mount for that agent. The agent physically cannot write to shared vaults, team vaults, other personal workspaces, or guide-outputs/.
2. **Team vault read-only** — agents read team vaults via `:ro` Docker bind mounts. Cannot modify team content.
3. **No cross-personal access** — no agent can read another agent's personal workspace. Docker mount scoping enforces this — the path is simply not mounted.
4. **Conversation isolation** — separate Telegram bot tokens per person. Different bot = different conversation space. Architecturally impossible for one bot to see another's messages.
5. **Memory privacy** — personal instance MEMORY.md lives in the agent's private workspace. Not readable by Guide Main, Gareth, or any other agent through Guide's architecture.

**What is logged:**
- Agent outputs to `guide-outputs/` (shared agents only — personal instances do not write here)
- Session metadata (timestamps, token counts) in OpenClaw's internal logs
- Agent memory in the agent's own workspace (private)

**What is not logged:**
- Personal conversation content is not written to any shared location
- Personal instance memory is not readable by other agents or the system architect

**Rationale:** The project brief identified trust as the critical adoption risk: "If team members believe their interactions are monitored, adoption won't happen voluntarily." The original brief proposed per-person bot isolation as the architectural solution. This ADR formalises the privacy guarantees and requires them to be architecturally enforced before being communicated to users.

**What this does NOT guarantee:** Gareth has SSH access to the Guide machine and could theoretically read any file. This ADR addresses the Guide system architecture, not physical machine access. The privacy statement to users should be honest: "Guide's architecture prevents cross-agent access. Machine-level access is limited to system administration."

**Review trigger:** Before any personal instance goes live, verify all 5 guarantees are structurally true. Before communicating privacy to users, re-verify.

---

## ADR-021: Bare Metal — Reverse Docker Decision

**Date:** 2026-04-29
**Status:** Accepted — reverses ADR-008

**Decision:** Run OpenClaw as a bare-metal npm install with a launchd service. Remove Docker from the OpenClaw runtime path.

**What happened:** Docker-on-macOS networking caused Node.js HTTP client timeouts in the grammY Telegram client and Slack socket mode. `curl` worked from inside the container but the Node.js `fetch` stack timed out after 65 seconds on every API call. The root cause is the Linux VM layer that macOS Docker Desktop interposes — Node.js resolves network differently than `curl` inside the container. Both Telegram and Slack were down for days.

**Why bare metal is better on macOS:**
- Eliminates the Docker VM networking layer entirely — Node.js uses the Mac's native network stack
- Symlinks (OneDrive, team vaults) work transparently — no Docker volume mount config
- Simpler debugging — one process, one set of logs, no container abstraction
- The personal instance architecture (CHUNK-12+) adds many filesystem paths — each would need a Docker volume mount. On bare metal, paths just work.
- launchd is the native macOS service manager — proper restart, logging, crash recovery

**Why Docker made sense on Linux but not macOS (Guide):**
- On Linux, Docker is native — no VM, host networking works, `network_mode: host` binds directly
- On macOS, Docker Desktop interposes a Linux VM — port mapping required (ADR-009), volume mount resolution differs, network stack is different
- The Docker advantage (isolation, reproducibility) is real on Linux. On macOS the VM layer costs more than it saves.

**What's preserved:** Everything. `openclaw.json` is Docker-agnostic — all paths are already host-native. Workspaces, credentials, cron config, agent registrations, channel bindings — unchanged.

**Service management:**
- Start: `launchctl load ~/Library/LaunchAgents/com.guide.openclaw.plist`
- Stop: `launchctl unload ~/Library/LaunchAgents/com.guide.openclaw.plist`
- Restart: `launchctl kickstart -k gui/502/com.guide.openclaw`
- Logs: `/tmp/openclaw/launchd-stdout.log`, `/tmp/openclaw/launchd-stderr.log`

**Review trigger:** If OpenClaw introduces breaking changes that require containerised dependencies, reconsider. If Guide moves to Linux hardware in future, Docker becomes viable again.

---

## ADR-022: Bare Metal Security — Exec Deny-by-Default, Scoped Vault Access

**Date:** 2026-04-29
**Status:** Accepted

**Problem:** On Docker, the container was the blast radius boundary — agents could run exec inside the container without affecting the host. On bare metal (ADR-021), there is no container. An agent with `exec` access and `ask: "off"` can run any command the `gareth` user can run — read API keys, read other agents' private workspaces (breaking ADR-020 privacy guarantees), delete files, push to git, SSH via Tailscale, or exfiltrate data via curl.

The privacy architecture (ADR-020) states "no agent can read another agent's personal workspace" — but with bash access, any agent can `cat` any file on the system. **The privacy guarantee is not structurally enforced until exec is locked down.**

**Decision:** Deny exec for all agents by default. Grant restricted exec only to agents that demonstrably need it, with command and path allowlists. Enforce `ask: "on"` for any agent retaining exec.

**Permission profiles (defined in `guide-roster.json`):**

| Profile | Exec | Who uses it | Rationale |
|---------|------|-------------|-----------|
| `personal` | Denied | All 8 personal instances | Privacy guarantee. No exec = cannot read other workspaces. |
| `channel` | Denied | All 5 channel agents | Read vaults, respond in Slack. No bash needed. |
| `shared` | Denied | Briefing, Scribe, Analyst, Finance, CapitalCore, Apex | Intelligence/reporting agents. Read data, produce outputs. |
| `main` | Restricted | Guide Main only | Orchestrator may need read-only system state checks. Allowlisted commands + paths. `ask: "on"`. |
| `pipeline` | Scoped | Pipeline agent (future) | Runs Python ETL scripts. Scoped to `~/guide-engine/` (scripts) and `~/guide-shared/data/`. `ask: "on"`. |

**Two layers of access control:**

| Layer | Mechanism | What it controls | Enforcement |
|-------|-----------|-----------------|-------------|
| **vault_read / vault_write** | OpenClaw tools, scoped by AGENTS.md + TOOLS.md | Which files an agent can read and write via the normal tool interface | Prompt-level (agent obeys its TOOLS.md). Not structural. |
| **exec / bash** | OpenClaw tools.deny in openclaw.json | Whether an agent can run arbitrary shell commands | Platform-level (OpenClaw enforces deny list). Structural. |

**Key insight:** `vault_write` is how agents legitimately write markdown — updating MEMORY.md, appending to backlogs, producing briefs. This does NOT require exec/bash. An agent writing a file via `vault_write` is scoped by its TOOLS.md path list. An agent with exec can bypass all path restrictions via `cat`, `cp`, `echo >`, etc.

**vault_write path scoping per agent type:**
- Personal instances: write only to `~/guide-vault/personal/{id}/`
- Channel agents: write only to `~/guide-vault/channel/{id}/`
- Shared agents: write to `~/guide-vault/shared/{id}/` + `~/guide-outputs/` (append only)
- Guide Main: write to `~/guide-vault/main/` + `~/guide-outputs/` + `~/.openclaw/workspace/signals/`

**Defence in depth — file permissions:**

Even with exec denied at the OpenClaw level, a future vulnerability or prompt injection could potentially bypass tool restrictions. File-level permissions provide a second layer:

| Path | Permissions | Rationale |
|------|------------|-----------|
| `~/guide-teams/` (team vaults) | `444` (read-only) | Agents should never modify team vault content |
| `~/guide-vault/personal/{other}/` | `700` per agent or `000` from other agents' perspective | Agents cannot read other agents' private workspaces |
| `~/.openclaw/credentials/` | `400` | API keys readable only by owner |
| `~/.zshenv` | `400` | Contains ANTHROPIC_API_KEY |
| `~/guide-vault/personal/{own}/MEMORY.md` | `644` | Agent needs to write its own memory |
| `~/guide-vault/personal/{own}/*.md` (except MEMORY) | `440` | Identity files are read-only after generation |

**Implementation:**
- Permission profiles are defined in `guide-roster.json` under `permissionProfiles`
- Each agent references its profile via `permissionProfile` field
- `generate.sh` reads the profile and generates the appropriate TOOLS.md deny list
- The Engineer applies file permissions during CHUNK-12 (filesystem restructure)
- CHUNK-07 (security hardening, unexecuted) should include the file permission sweep

**What this does NOT solve:**
- Gareth has SSH access to the Guide machine and can read any file. This is accepted — the privacy boundary is between agents, not between Gareth and agents.
- `vault_write` path scoping in TOOLS.md is prompt-level, not platform-level. If OpenClaw adds workspace-level write restrictions in a future version, adopt them. Until then, the TOOLS.md instruction + file permissions are the enforcement layers.

**Review trigger:** When OpenClaw adds platform-level vault path restrictions (not just prompt-level TOOLS.md), migrate to that mechanism. Check each OpenClaw release for workspace scoping features.

---

*Updated: 2026-04-29*
