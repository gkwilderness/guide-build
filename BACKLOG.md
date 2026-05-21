---
title: "Guide — Backlog"
type: backlog
area: ai
project: "Guide"
tags: [ai, guide, backlog]
status: active
updated: 2026-05-21
---
# Guide — Backlog

Non-chunk work items. Pull-based — items move up when needed, not when added.
Role tags: `[G]` Gareth · `[E]` Engineer · `[A]` Architect · `[V]` Vault/Guide

---

## FIRE — Blocking Now

- [ ] **Z8 foundation architecture spec** `[A]` — PRIORITY. Full pre-build doc at `~/guide-build/Notes/2026-05-15 Huginn Z8 Foundation Architecture.md`. Architect to read it, answer 8 open questions, write CHUNK-17 (idempotent foundation chunk covering /srv/ structure, users, groups, SMB, databases, Ollama, OneDrive, Docker Compose, security hardening sequence). **No Engineer build sessions on Z8 until this is complete.** Also read: `Notes/2026-05-15 Z8 Security Best Practice.md` and `BUILD/DEV-CHUNKS/CHUNK-07-security-hardening.md`. (2026-05-15)

- [ ] **Fix nightly flush cron — wrong script path** `[E]` — Cron payload calls `/srv/openclaw/workspaces/main/scripts/flush-slack-sessions.sh` (does not exist inside container). Correct path: `/srv/guide-core/scripts/flush-slack-sessions.sh`. Ran manually on 2026-05-21, 30 sessions flushed OK. Fix the cron job payload in openclaw.json. (2026-05-21)

- [ ] **Register 9 new skills + refresh 8 existing** `[E]` — All staging files at `/srv/guide-staging/<skill>/SKILL.md` approved by Gareth. Full report: `/srv/guide-staging/MORNING-REPORT-2026-05-20.md`. Engineer to copy SKILL.md files and register new skills in openclaw.json, then gateway restart.
  - **New (register + copy):** prompt-rewriter (9.0), skill-improver (9.0), claude-context-generator (8.5), ppc-questions (8.5), meta-questions (8.5), seo-questions (8.0), prompt-builder (8.0), learn-a-skill (7.5), programmatic-questions (7.5)
  - **Refresh (copy only, already registered):** diagnose (9.5 — push first), hubspot-connector (9.0), handoff (9.0), grill-me (8.5), clickup-connector (8.5), write-a-skill (8.0), zoom-out (8.5), grill-with-docs (8.5)
  (2026-05-20)

- [ ] **Wire #guide-help in openclaw.json** `[E]` — Slack channel set up by Gareth (2026-05-20). Engineer to add to openclaw.json and confirm routing. Channel details to be confirmed with Gareth. (2026-05-20)

---

## HIGH — Active This Week

### Gareth actions needed

- [ ] **Provision API keys + Telegram bots for exec agents** `[G]` — Hadley, Dean, Caro, Julian, Keith all built and waiting. Engineer cannot proceed until keys and bot tokens arrive. (2026-05-20)

- [ ] **Spec 3 new skills before build starts** `[G]` — Engineer is waiting:
  - Tone of voice skill: what's the scope? Brand guidelines? Which brands?
  - Lenny skill for Laura: what does this do?
  - Slack tool skill: triggers, workflow, what Guide should do with it
  (2026-05-20)

- [ ] **Scott agent — confirm details** `[G]` — Scott from #guide-sales (C0B1Z2ETB26). Provide: full name, role, Telegram ID, data scope, and tier before Engineer builds. (2026-05-20)

### Engineer

- [ ] **Nightly activity digest — pull gemma4:26b and build script** `[E]` — Ollama installed and running on Z8. Last step: `ollama pull gemma4:26b` (18GB, fits RTX 3090 with 6GB headroom). Then build `/srv/guide-core/scripts/nightly-digest.sh` per spec in →engineer.md (2026-05-20 IN PROGRESS entry). Reads session .jsonl files, pipes to Ollama, saves to `memory/digest/YYYY-MM-DD.md`, posts to Slack #guide-logs (C0ATGQ167SN) via slack-post.sh. Update nightly-guide-logs-digest cron job when done. (2026-05-20)

- [ ] **Enable Slack tool** `[E]` — Add and enable the Slack tool so Guide can post messages, react, pin/unpin, and interact with Slack programmatically from within Slack sessions. Currently blocking useful Slack interactions. (2026-05-20)

- [ ] **Slack file sending** `[E]` — Allow Guide to send and receive images and PDFs via Slack. Requires `files:read` + `files:write` OAuth scopes on the Slack app, reinstall app, update bot token in openclaw.json. (2026-05-20)

- [ ] **Fix tool calling retry loop** `[E]` — Guide looped ~15 times attempting to use the `slack` tool before giving up. Two fixes: (1) enable Slack tool for Slack session contexts; (2) add graceful fallback — detect tool unavailability on first failure and stop retrying. (2026-05-20)

- [ ] **HubSpot connector: fix for personal-nick** `[E]` — Two blockers: (1) skill calls `~/skills/hubspot-connector/scripts/hs_query.py` — fix to absolute path `/srv/openclaw/skills/hubspot-connector/scripts/hs_query.py`; (2) token is in digital vault, Nick's agent can't reach it — copy token reference to `/srv/guide-vaults/shared/`. (2026-05-19)

- [ ] **HubSpot connector: timezone handling** `[E]` — `hs_query.py` uses UTC, HubSpot UI uses BST. Add `--tz` flag, default UTC, document explicitly. Canonical number = UTC. (2026-05-19)

- [ ] **HubSpot connector: generate .md report on every run** `[E]` — Path: `/srv/guide-vaults/teams/digital/70-Reports/hubspot/YYYY-MM-DD-<action>-<object>-<brand>.md` with YAML frontmatter (date, time, brand, portal_id, action, object, timezone, query_params, record_count). (2026-05-19)

- [ ] **Fix nightly commit job — two failures** `[E]` — (1) guide-core: Permission denied on `.git/index` — repo owned uid 1001, Guide runs as uid 1002; fix ownership. (2) Workspace repo: `/srv/openclaw/workspaces/main` is not a git repo — either `git init` + remote, or fix the cron job path. Neither push completed on 2026-05-19. (2026-05-19)

### Architect

- [ ] **Wire Guide to think in compounding systems** `[A]` — Three changes needed:
  1. Add "Systems Thinking" section to SOUL.md: before completing any task, ask what system this belongs to, what it compounds into, what the second-order effect is.
  2. Add trajectory rule to AGENTS.md memory discipline: MEMORY.md captures trajectory not just facts — always note direction of travel.
  3. Create `/srv/openclaw/workspaces/main/SYSTEM-STATE.md`: living document of what's being built, what's compounding, what's fragile, what just changed, next inflection point. Read on every boot alongside MEMORY.md.
  (2026-05-20)

- [ ] **Perf team agent spec** `[A]` — Design the performance team agent: scope, data access, Slack/Telegram bindings, team members (Danny, Fay, Jack, Yoann/Brice, Frances, Claire). **This is a prerequisite for Slack allowlist and team Telegram access rollout.** (2026-05-20)

- [ ] **Sub-agents signals protocol** `[A]` — Domain agents have no awareness of the signals files or how to use them (Martech agent was first to surface this gap). Every domain agent needs to be bootstrapped with: what the signal files are, when to write to them, and the format. Add to each agent's AGENTS.md or create a shared SIGNALS.md in the workspace. (2026-05-19)

- [ ] **Token storage architecture** `[A]` — No standard pattern exists. HubSpot token in vault markdown, Telegram Nick token in `/srv/guide-core/__CONFIG/keys/`, skills hardcode paths that break across agents. Recommend: canonical store location, access pattern (env vars, key files, vault lookup, secrets manager), and which agents can access which tokens. Must account for multi-agent, multi-brand, different access tiers. (2026-05-19)

### Vault

- [ ] **TOOLS.md channel map update** `[V]` — C0AUT4WSPBJ listed as `#digital-product-external-triage-list` (old name). Current: `#guide-digital-product-triage-requests`. Also add 3 new Digital Product channels: C0B2DFTFCDB (`#guide-digital-product-design-review`), C0B2GU0RQJW (`#guide-digital-product-standup-digest`), C0B4M2AEPEG (`#guide-digital-product-triage-output`). (2026-05-19)

- [ ] **AGENTS.md cron table update** `[V]` — Update cron schedule table once skill registration (FIRE item above) is complete and exec agents are live. (2026-05-20)

- [ ] **USER.md exec agents update** `[V]` — Add Hadley, Dean, Caro, Julian, Keith once Telegram bots and API keys confirmed. (2026-05-20)

---

## YELLOW — Next Up

- [ ] **Build 3 new skills: tone of voice, Lenny, Slack tool** `[E]` — Waiting on Gareth spec (HIGH item above). Build after spec confirmed. (2026-05-20)

- [ ] **Install bundled skills into Dockerfile** `[E]` — Add required binaries to `/srv/compose/openclaw/Dockerfile` so they persist across image rebuilds. Skills: `nano-pdf` (pip3), `summarize` (summarize.sh), `session-logs` (jq + ripgrep), `github` + `gh-issues` (gh CLI — also needs GH_TOKEN env var in container), `obsidian` (obsidian-cli), `gemini` (Google Gemini CLI), `gog` (gogcli.sh). Skip `model-usage` (macOS only). After Dockerfile updated: rebuild image, restart service, verify with `openclaw skills list`. (2026-05-20)

- [ ] **Exec agents: provision after API keys arrive** `[E]` — Once Gareth provides keys (HIGH item above): wire Hadley, Dean, Caro, Julian, Keith into openclaw.json with Telegram bindings. (2026-05-20)

- [ ] **Slack allowlist — add perf team members** `[E]` — Waiting on perf team agent spec (HIGH item above). Gareth to provide Slack IDs when ready. (2026-05-20)

- [ ] **Team member Telegram access** `[E]` — Each team member gets own scoped agent, Telegram-bound. Waiting on perf team agent spec and Gareth providing IDs + scope per person. (2026-05-20)

- [ ] **Nick — 4 experience improvements** `[A/E]` — Nick has been onboarded. These make the agent genuinely useful:
  1. Weekly brief cron job — Fridays 16:00 Europe/London, delivers capital allocation summary to Nick's Telegram (8516698636). CPL vs FY27 target by brand, key flags from WATCHLIST.md, one decision/question to raise.
  2. Replace ONBOARDING.md LLM instructions with pre-written example questions based on Nick's actual vault content: CPL vs FY27 $212 target, digital exit readiness, top risks, HubSpot rollout status.
  3. Warm handoff WhatsApp draft for Gareth to send Nick (peer-to-peer tone, not a product pitch). Write to `/srv/guide-vaults/personal/nick/notes.md`.
  4. Populate stub files: PRIORITIES.md, performance/vs-plan.md, performance/cpl-tracker.md — Gareth to provide actuals.
  (2026-05-04)

- [ ] **Nick stub files — Gareth to provide content** `[G]` — PRIORITIES.md, performance/vs-plan.md, performance/cpl-tracker.md are empty. Nick will get "no data" responses on performance questions until populated. (2026-05-04)

- [ ] **Proper SOULs for each agent** `[A]` — Every agent (all OpenClaw channel agents, Hermes Analyst profiles, personal instances) needs a properly crafted SOUL.md — distinct voice, purpose, and character appropriate to its role and audience. Guide's SOUL.md is the quality bar, not the template. (2026-05-15)

- [ ] **Target stack: Hermes + Open WebUI deployment chunks** `[A]` — Stack confirmed 2026-05-15. Required new chunks: (1) Hermes Agent deployment — install, profiles, API server config, Ollama model routing, MCP wiring; (2) Open WebUI deployment — Docker, instance/model scoping strategy, auth, URL. Also update guide-roster.json to mark Analyst as Hermes (not OpenClaw). Confirm Paperclip/Hermes compatibility. (2026-05-15)

- [ ] **CHUNK-15: Hermes Analyst spec** `[A]` — Write spec, execute post-demo. (2026-04-21)

- [ ] **QA persona — design and build** `[A]` — Separate agent or test mode? How does it simulate being Nick/Danny/Richard? Isolated from session flush cycle. Test criteria must go beyond "says right things" — must verify state writes (MEMORY.md flags), follow-up session handling, context breadth in narrow-question responses. (2026-05-04)

- [ ] **Session continuity rules — review for SOUL.md** `[A]` — Four rules drafted (in →engineer.md 2026-05-05 signal). Rules are sound; Gareth wants Architect sign-off before they go into runtime. (2026-05-05)

- [ ] **Slack streaming config decision** `[A]` — Current state: `nativeTransport: false` (standard delivery, no streaming). For native streaming: set `streaming.mode: "partial"`, `nativeTransport: true`, `replyToMode: "first"` — but responses appear as thread replies, not top-level. Architect to decide and implement. (2026-05-14)

- [ ] **Cross-agent session send scope review** `[A]` — `tools.sessions.visibility: "all"` set 2026-05-14. Review whether a scoped setting exists (main → domain agents only, not domain → domain). If "all" is the only option, document the risk and flag to Gareth. (2026-05-14)

- [ ] **Cross-agent mesh orchestration — design before build** `[A]` — Transport layer exists (visibility: all). Design needed: agent discovery mechanism, tasking protocol, loop/recursion guards, audit trail. Do not build until protocol designed. (2026-05-14)

- [ ] **Delivery Rule in factory templates** `[A]` — Confirm the `message` tool Delivery Rule block is in the channel agent factory template so all future agents get it. Verify threadId usage is documented. Check if Telegram has an equivalent pattern for personal instances. (2026-05-14)

- [ ] **Roster.json: add new starters when confirmed, not on day one** `[A]` — Rule: when any new starter is confirmed (even if Telegram ID is TBC), add to roster.json immediately with `status: "planned"` and all known fields. Add to ADD-AN-AGENT.md and onboarding SOP. Consider PEOPLE.md in main workspace as a forward-looking list so Guide can proactively flag upcoming start dates. (2026-05-11)

- [ ] **New Slack channel onboarding SOP in AGENTS.md** `[A]` — 4-step SOP must be formalised (add to allowlist → update BOOTSTRAP.md table → flush session → test before announcing). Currently lives only in →architect.md. Failure to follow this caused #seo-guide to launch without vault context, exposing Guide's confusion. (2026-04-17)

- [ ] **Convention: scripts called by cron must echo success on stdout** `[A]` — Rule: every script invoked by cron must echo a human-readable success line on clean exit. Format: "Script-name complete. [summary]." Do not rely on side effects as the only signal. Add to SKILL.md / coding conventions. (2026-05-04)

- [ ] **Convention: Slack ack reaction requires statusReactions.enabled** `[A]` — Three config fields must always be set together when building any new Slack-bound agent: `ackReaction`, `ackReactionScope: "all"`, `statusReactions: {enabled: true}`. Add to build docs / chunk templates. (2026-05-07)

- [ ] **`/srv/compose/` git repo** `[G]` — openclaw.yml is unversioned. Two live changes at risk: `user: "1002:1004"` and `command: sh -c "umask 002 && exec openclaw gateway"`. Gareth to create repo. (2026-05-20)

- [ ] **SSH authorized_keys audit** `[G]` — Review `/home/gareth/.ssh/authorized_keys`, remove oneafrikan@linode key if no longer needed. Confirm mosh is installed on Z8. Document authorised keys policy in .dev-env repo. (2026-05-19)

- [ ] **Scott safari KB — ingest into shared vault** `[G/Guide]` — Scott Vincent (Sales Director) is building his own knowledge base. Get content from Scott, confirm best format, ingest to `/srv/guide-vaults/shared/`. POC for Keith: natural language queries against the KB. Connects to Caro (Reservations) and retail sales agent. (2026-05-06)

- [ ] **Log LRN-20260520-001 to .learnings/LEARNINGS.md** `[Guide]` — Automated jobs must own their own completion. Overnight skill loop found 4 below-threshold skills, reported, stopped — should have self-chained the next pass. Pattern-Key: automation.self-chaining. (2026-05-20)

---

## WHITE — Planned / Later

- [ ] **MCP semantic search: vault isolation architecture** `[A]` — Gareth setting up obsidian-mcp-server + nomic-embed-text via Ollama. Design needed: can agents have per-agent MCP connections? Can multiple nomic-embed-text instances run with different indexed corpora? Isolation requirement: Nick's vault must not be readable by main agent or team agents. One-directional: Nick reads down into business, business cannot read up into Nick's files. (2026-05-04)

- [ ] **Exec security: scope from "full" to allowlist** `[A]` — Current: `tools.exec.security: "full"` with `ask: "off"` — unrestricted shell access as gareth/admin. Restrict to working directories. Architect to validate proposed allowlist (workspaces, guide-vaults, guide-core, guide-data, /tmp/openclaw) and answer 4 open questions before Engineer implements. (2026-04-29)

- [ ] **Vault separation: BUILD vault + remove personal vaults from server** `[A]` — Gareth's personal vaults (`Wilderness`, `Gareth_SovereignOS`) have no business being on a server with `security: full`. Move BUILD markdown into its own vault. Architect to identify what constitutes BUILD content, determine structure, update CLAUDE.md files, plan migration. Connects to exec security allowlist above. (2026-04-29)

- [ ] **File permission hardening in generate.sh** `[E]` — generate.sh applies 440/444 too broadly. Fix: immutable files (SOUL.md, IDENTITY.md, HEARTBEAT.md) → 444; all operational files (AGENTS.md, BOOT.md, MEMORY.md, TOOLS.md, USER.md) → 644. Apply to both channel and personal templates. (2026-05-01)

- [ ] **OpenClaw auto-update — decide mechanism** `[E/A]` — EACCES on `/usr/local/lib/node_modules/.openclaw-update-stage`. Guide (uid 1002) can't write global npm prefix. Not breaking anything; gateway running fine on 2026.5.4. Options: (a) `sudo npm i -g openclaw@latest` from host when needed; (b) build host-side update mechanism. (2026-05-21)

- [ ] **Fix hardcoded Obsidian/OneDrive paths in report scripts** `[E]` — Paused (`#PAUSED 2026-04-26` in `/etc/cron.d/guide`). Waiting on OneDrive mount on Z8. Affected: `llm-report-generator.sh` and `pulse-report-generator.sh` (DATA_ROOT, VAULT_REPORTS_DIR, ENV_FILE). (2026-05-19)

- [ ] **Host-level cron visibility** `[A]` — Guide runs in Docker, cannot see host-level cron. Goal: Gareth can ask "what's scheduled today" and get a complete answer. Options: migrate all host jobs into OpenClaw cron; expose read-only host cron summary to container; hybrid. Architect to decide. (2026-04-24)

- [ ] **Slack DM access control — custom plugin** `[A/E]` — ADR-015/016. Tool deny alone cannot distinguish DM vs channel post. Custom plugin needed for outbound DM gating and polite-mode enforcement. Architect to spec once tool IDs confirmed (now documented in architect signal); Engineer to implement. Config at `~/.openclaw/outbound-policy.json`, never in `openclaw.json`. (2026-04-17)

- [ ] **Camp-level CRM — tech spec** `[A]` — Offline-first PWA for camp staff: pulls guest intelligence from HubSpot pre-arrival, captures NPS/review data at checkout. Tech spec needed: PWA vs native for camp hardware (shared tablets), HubSpot API scoping, custom objects vs native properties, pilot camp recommendation. Do not build until Gareth + Richard align on scope and pilot camp. (2026-04-21)

- [ ] **PPC agent — design before build** `[A]` — Do not build yet. Phase 0: vault structure only (`25-Channels/Paid-Search/` and `25-Channels/Paid-Social/` with BACKLOG.md). Phase 1: after BigQuery is live. Phase 2: after Danny has seen Phase 1 work accurately. Build conditions: Danny consulted, Phase 0 scope agreed, vault folder structure confirmed, Gareth signs off. (2026-04-21)

- [ ] **Jules — sales reports** `[G]` — Jules wants sales reports via Guide. Define format, frequency, and data sources before Engineer builds. (2026-05-06)

- [ ] **CHUNK-07a: Google Integration** `[G then E]` — @gareth pre-tasks first: create Google Cloud project, enable Calendar + Gmail APIs, download `client_secret.json` → `~/.openclaw/credentials/google-client_secret.json`. Create Guide Gmail address. Then Engineer executes chunk. (spec written)

- [ ] **Build `page-watcher` skill** `[E]` — Lightweight page change monitor. Python: fetch URL, hash content, compare to stored hash, alert on change. Use cases: competitor pages, Google Ads policy updates, LLM provider announcements, Wilderness/Jacada/YZ site change detection. Build from scratch (clawhub `monitor` skill flagged suspicious). (2026-05-06)

- [ ] **RSS/news feed skill for Briefing agent** `[E]` — Daily industry intelligence: safari industry, luxury travel news, competitor activity, press mentions. Check `rss-reader`, `blogwatcher`, `openclaw-feeds` on clawhub. (2026-05-06)

- [ ] **HTML → Markdown converter** `[E]` — Convert HTML docs to clean markdown for vault ingestion. Tool: `html2text` or `markdownify`. Two-stage: strip/convert → Claude cleanup for frontmatter + vault naming. (2026-05-06)

- [ ] **HTML fetch skill** `[E]` — Fetch a live URL and return clean HTML or markdown. Agent-triggered web content ingestion. Wraps `web_fetch` or a headless fetch script. (2026-05-06)

- [ ] **CHUNK-07: Security hardening — rewrite for Ubuntu** `[A]` — macOS version spec exists. Rewrite for Ubuntu/Z8 context as part of the Z8 foundation sequence. (2026-05-15)

- [ ] **Morning briefs — full suite** `[E]` — After Z8 foundation is live: TODAY.md delivered to Telegram at 08:00 Mon–Fri, HubSpot daily pulse, weekly website (GA4 chunks per day), LLM checker, sales pulse. (2026-05-15)

- [ ] **Guide team intro workshops** `[G]` — Team leaders Guide intro (by team). Individual usage check-ins. (2026-05-15)

- [ ] **Brand account IDs documentation** `[G]` — Google Ads, HubSpot, GA4, Meta per brand. See `__CONFIG/GUIDE.md`. Prerequisite for API integrations. (2026-04-16)

- [ ] **WhatsApp integration** `[G then E]` — Gareth: buy prepaid SIM/eSIM, register number. Engineer: configure Baileys plugin when SIM ready. Collect exec phone numbers (E.164 format). (deferred Phase 0)

---

## WAITING — Blocked on External Input

- [ ] **Slack allowlist: add perf team** — waiting on perf team agent spec (see HIGH → Architect → Perf team agent spec)
- [ ] **Team Telegram access** — waiting on perf team agent spec
- [ ] **Build 3 new skills** — waiting on Gareth spec (see HIGH → Gareth)
- [ ] **Scott agent build** — waiting on Gareth confirming details (see HIGH → Gareth)
- [ ] **Fix hardcoded OneDrive paths in report scripts** — waiting on OneDrive mount on Z8
- [ ] **Exec agents provisioning** — waiting on Gareth providing API keys + Telegram bot tokens

---

## COMPLETED / HISTORY

Items are in reverse-chronological order. Dates are completion dates.

### 2026-05 (May)

- [x] Exec agents built — Hadley, Dean, Caro, Julian, Keith workspaces generated and registered. Waiting on API keys. ✅ 2026-05-20
- [x] Skills review complete — all 17 skills scored overnight. 16/17 at 8.0+. Staging files at `/srv/guide-staging/`. Full report: `MORNING-REPORT-2026-05-20.md`. ✅ 2026-05-20
- [x] Fix permissions errors — guide-data group consolidated, fix-perms.sh normalises ownership on every service start. ✅ 2026-05-20
- [x] Fix .learnings write access — done, LRN-20260520-001 staged for logging. ✅ 2026-05-20
- [x] #guide-help Slack channel — set up by Gareth and wired (routing still pending openclaw.json entry). ✅ 2026-05-20
- [x] Shared vault read-only policy — applied to all 6 agent TOOLS.md files and both factory templates. ✅ 2026-05-06
- [x] Delivery Rule added to all Slack domain agent TOOLS.md — product, data, martech, seo, hubspot, safari. Also corrected product agent channel ID. ✅ 2026-05-14
- [x] Cross-agent session send enabled — `tools.sessions.visibility: "all"` added to openclaw.json. ✅ 2026-05-14
- [x] Slack delivery fix — root cause: `streaming.nativeTransport: true` with no `replyToMode` set caused silent delivery failure. Fixed with `nativeTransport: false`. ✅ 2026-05-14
- [x] Ashleigh Waterson wired — Telegram binding to data agent, roster.json entry, USER.md updated on her start date 2026-05-11. ✅ 2026-05-11
- [x] Scripts source of truth established — all operational scripts migrated to `~/guide-core/scripts/`. Runtime path `~/.openclaw/workspace/scripts/` is now a symlink. ✅ 2026-05-12
- [x] Slack ack reaction fixed — `statusReactions.enabled: true` required alongside `ackReaction`. Debugged and documented. ✅ 2026-05-07
- [x] Scott's safari knowledge base — note logged to →guide.md, follow-up with Gareth pending. ✅ 2026-05-06
- [x] Personal Nick BOOT.md patched — onboarding now wired (step 3 added: check MEMORY.md for onboarding complete flag). Session flushed. ✅ 2026-05-04
- [x] Session memory scanner — absolute paths fixed, symlink fixed (committed 33b7685). ✅ 2026-05-19
- [x] flush-slack-sessions.sh — hardcoded paths fixed, duplicate signal fixed (committed 33b7685). ✅ 2026-05-19
- [x] Nick bot token key file — chmod 640 applied. ✅ 2026-05-19
- [x] Config reload rollback protection — chmod 664 on openclaw.json.last-good. ✅ 2026-05-19
- [x] /srv/openclaw/tasks EPERM — chmod 775 tasks dir + 664 runs.sqlite. ✅ 2026-05-19
- [x] SSH access confirmed — plain `ssh gareth@100.80.44.14` working. ✅ 2026-05-19
- [x] Agent skills directory permissions — rechowned all skill subdirs to guide-data group, setgid on /srv/openclaw/skills/, fix-perms.sh runs at every service start. ✅ 2026-05-20

### 2026-04 (April — CHUNK work)

- [x] CHUNK-14: Personal Instance Nick live — @WildernessGuideNickBot bound, exec denied, allowFrom Nick + Gareth. Multi-bot Telegram schema findings documented (ADR). ✅ 2026-04-30
- [x] CHUNK-13: Personal Instance Factory — templates/channel/ and templates/personal/ reorganised, roster.json added, generate.sh rewritten, ADD-AN-AGENT.md updated. ✅ 2026-04-30
- [x] CHUNK-12: Team Vault Architecture — filesystem restructure via guide-bootstrap.sh, all 6 agent workspace paths updated in openclaw.json, guide-vault/ git-initialised. ✅ 2026-04-30
- [x] CHUNK-07b: Bare metal migration — OpenClaw migrated from Docker Compose to npm install + systemd (now on Z8 with systemd, not launchd). Gateway healthy, both channels connected. ✅ 2026-04-29
- [x] ADR-016 Slack tool identifiers — tool groups, byProvider schema, toolsBySender documented. dmOutboundAllowlist and dmPoliteList confirmed phantom keys — removed from AGENTS.md. ✅ 2026-04-29
- [x] CHUNK-10: Channel Agents — Data, Martech, SEO, Digital Product, HubSpot. All wired to Slack channels. ✅ 2026-04-20
- [x] CHUNK-09: Agent Factory — scaffold for all channel agents built and verified. ✅ 2026-04-20
- [x] Slack tool identifiers research — all valid tool group shorthand strings documented. ✅ 2026-04-20
- [x] Caro dedicated agent — personal-caro built alongside other exec agents. ✅ 2026-05-20
- [x] Digital Product CLAUDE.md — rewritten to triage-only scope. HOW-TO-WORK-WITH-GUIDE.md created for Laura. ✅ 2026-04-21
- [x] Meeting notes pattern resolved — dated subfolder files confirmed: `MEETINGS/YYYY-MM-DD.md` per channel. ✅ 2026-04-21
- [x] Collect team Slack IDs — all 5 channel IDs confirmed. ✅ 2026-04-20
- [x] Architect specs written — CHUNK-09, CHUNK-10, CHUNK-11, CHUNK-12, CHUNK-13. ✅ 2026-04-20
- [x] Create `guide-core` GitHub repo (private) — @gareth ✅ 2026-04-13
- [x] Create `guide-engine` GitHub repo (private) — @gareth ✅ 2026-04-13
- [x] Confirm Anthropic API key credits — @gareth ✅ 2026-04-14
- [x] Create Telegram bot (@WildernessGuideBot) — @gareth ✅ 2026-04-13
- [x] Collect team lead Telegram IDs: Danny, Richard, Laura — @gareth ✅ 2026-04-14
- [x] Create "Guide — Team Leads" Telegram group (ID: -5236130644) — @gareth ✅ 2026-04-14
- [x] Create Slack app — @gareth ✅ 2026-04-13
- [x] Create Slack channels: #guide-briefs, #guide-ops, #guide-alerts — @gareth ✅ 2026-04-13
- [x] Fill in `__CONFIG/GUIDE.md` values — @gareth ✅ 2026-04-14
- [x] Matt Wylie (8265788167) — Telegram operator access added ✅ 2026-04-14
- [x] Slack #wilderness-digital-team (C0987SGJ9NJ) — post-only channel added ✅ 2026-04-14
- [x] Slack #guide-data-inbox (C0ASP8ZD495) — inbound channel added ✅ 2026-04-16
- [x] Laura Sinclair — added to Slack operator DM access ✅ 2026-04-16
- [x] Slack member IDs added: Maria, Fay, Laura ✅ 2026-04-16
- [x] AGENTS.md strategic context loading + autonomy rules added ✅ 2026-04-16
- [x] Tailscale — configured, `tailscale serve` → gateway ✅ 2026-04-15
- [x] Wilderness personal vault removed from Guide's scope ✅ 2026-04-15
- [x] OpenClaw TUI/dashboard accessible via Tailscale ✅ 2026-04-16

---

*Updated: 2026-05-21 — full migration from signals files (→architect.md, →engineer.md, →gareth.md, →guide.md, →vault.md, →qa.md)*
