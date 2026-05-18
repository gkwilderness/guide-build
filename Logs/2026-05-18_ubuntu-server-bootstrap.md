---
title: "Ubuntu Server Foundation Bootstrap — Z8 Build"
type: log
area: infra
project: Guide
tags: [infra, ubuntu, z8, bootstrap, foundation, engineer, completed]
status: complete
created: 2026-05-18
author: Engineer (Claude Code on Z8)
---

# Ubuntu Server Foundation Bootstrap — Z8

**Date:** 2026-05-18
**Machine:** HP Z8 G4, Ubuntu 24.04 (kernel 6.17.0-23-generic)
**Operator:** Gareth (architect) + Claude Code as Engineer on the Z8
**Source prompt:** `Prompts/PROMPT_Engineer-guide-foundation-bootstrap.md`
**Outcome:** All 14 steps complete. Machine ready for OpenClaw and the rest of the service stack.

---

## What this was

The clean-slate foundation build for the new Guide host. Before this run, the Z8 had Ubuntu installed and `gareth`/`guide`/`engineer` users created — nothing else. After this run, the box has: hostname, base packages, Tailscale on the tailnet, full `/srv/` tree with correct ownership and modes, Samba serving three shares, Docker, scoped sudoers, GitHub SSH key registered, `guide-build` cloned, Node 24 / Python 3.11 / Ruby 3.2.2 via nvm/pyenv/rbenv, env vars in `.bashrc`, verification gate passed.

---

## Step-by-step record

| Step | What | Status | Notes |
|---|---|---|---|
| 1 | Hostname `guide-server` | ✓ | Was `guide` pre-bootstrap; renamed to `guide-server` post-verification (see Resolved Decisions) |
| 2 | Base packages | ✓ done | 12 packages were missing on top of an already-updated system; `samba samba-common-bin ripgrep ffmpeg libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libffi-dev libyaml-dev libgmp-dev` |
| 3 | Tailscale | ✓ done | Joined tailnet at `100.80.44.14`. Initially registered as `guide-1` (old Mac Mini held `guide`); renamed to `guide-server` post-bootstrap. |
| 4 | Users + groups | ✓ done | gareth/guide/engineer all existed; only `engineer` needed `srv-data` added |
| 5 | `/srv/` tree | ✓ done | 19 top-level dirs; ownership and modes per spec |
| 6 | Samba | ✓ done | Initial smb.conf with 3 named shares (`guide-teams`, `guide-outputs`, `guide-data`) installed and smbd/nmbd active. SMB password set manually by Gareth (`smbpasswd -a gareth`) and Mac → SMB verified against the 3 shares. **Final layout** (after a brief misstep — see Resolved Decisions): two shares scoped to working surfaces — `srv` at `/srv` and `home` at `/home`, both with `admin users = gareth`. |
| 7 | Docker | ✓ done | Docker 29.5.0 + Compose v5.1.3, gareth + guide added to docker group |
| 8 | Scoped sudoers | ✓ done | `/etc/sudoers.d/gareth` with scoped NOPASSWD entries for systemctl on openclaw/hermes/huginn/ollama + ufw + restic. Validated via `visudo -c`. |
| 9 | GitHub SSH + clone | ✓ done | Existing key at `~/.ssh/id_ed25519.pub` was already registered with `gkwilderness` GitHub account. `guide-build` cloned to `/srv/guide-build` and chowned to `gareth:srv-data`. |
| 10 | nvm + Node 24 | ✓ done | nvm v0.40.1, node v24.15.0, npm 11.12.1 |
| 11 | pyenv + Python 3.11 | ✓ done | Python 3.11.15. **Required a deviation — see below.** |
| 12 | rbenv + Ruby 3.2.2 | ✓ done | gem 3.4.10 |
| 13 | Env vars | ✓ done | `GUIDE_BUILD`, `GUIDE_VAULTS`, `OPENCLAW_WORKSPACE`, `OPENCLAW_CONFIG` added to `~/.bashrc` |
| 14 | Verification gate | ✓ done | All checks green (output captured below) |

---

## Deviations from the prompt

### `liblzma-dev` was missing from Step 2

When pyenv built Python 3.11.15, it warned:
```
ModuleNotFoundError: No module named '_lzma'
WARNING: The Python lzma extension was not compiled. Missing the lzma lib?
```

The Step 2 package list in the bootstrap prompt omits `liblzma-dev`. Python builds without lzma support are a known foot-gun — common libraries (e.g. `pandas` reading `.xz` files, anything via `tarfile` with xz compression) will fail at runtime in non-obvious ways.

**Fix applied:** `sudo apt install -y liblzma-dev`, then `pyenv uninstall 3.11.15` and `pyenv install 3.11` again. Verified `python -c "import lzma; print('lzma OK')"` returns `lzma OK`.

**Action item:** ~~Add `liblzma-dev` to the Step 2 package list in `Prompts/PROMPT_Engineer-guide-foundation-bootstrap.md` before this prompt is reused on another machine.~~ Done — committed in the same commit as this log.

### Temporary NOPASSWD sudoers file for unattended run

To run Steps 2–13 without per-step password prompts, a temporary `/etc/sudoers.d/gareth-bootstrap` was created with `gareth ALL=(ALL) NOPASSWD: ALL`. Removed at the end of Step 14 once the scoped `/etc/sudoers.d/gareth` was validated and in place. The current sudo posture matches the spec: scoped NOPASSWD only.

### `smbpasswd -a gareth` is interactive — left to Gareth

Step 6's `sudo smbpasswd -a gareth` prompts twice for a new password and cannot run unattended. The Samba config and services were brought up by the bootstrap; Gareth set the SMB password manually and confirmed Finder → `smb://<host>` works against all three shares.

---

## End-state verification (from Step 14 gate)

```
=== guide foundation check ===
--- hostname ---
guide
--- users ---
gareth: groups=gareth,adm,cdrom,sudo,dip,plugdev,users,lpadmin,guide-data,srv-data,smb-users,docker
guide:  groups=guide,adm,cdrom,sudo,dip,plugdev,users,lpadmin,guide-data,srv-data,docker
engineer: groups=engineer,srv-data
--- tailscale ---
100.80.44.14
--- /srv/ ---
backup compose db guide-build guide-core guide-data guide-engine guide-outputs
guide-vaults hermes huginn landing-pages logs ollama onedrive openclaw openwebui paperclip
--- /srv/guide-vaults/ ---
personal private shared teams
--- /srv/openclaw/ ---
config workspace
--- samba ---
active
--- docker ---
Docker version 29.5.0, build 98f1464
Docker Compose version v5.1.3
--- versions ---
node    v24.15.0
python  3.11.15
ruby    3.2.2 (2023-03-30 revision e51014f9c0) [x86_64-linux]
ripgrep 14.1.0
ffmpeg  6.1.1-3ubuntu5
--- repos ---
✓ guide-build
=== done ===
```

---

## Network identity

| Surface | Name | Notes |
|---|---|---|
| OS hostname | `guide-server` | Renamed from `guide` post-bootstrap. Convention: box is `guide-server`, AI runtime on the box is `guide`. |
| Tailscale node | `guide-server` | Renamed from `guide-1`. Old Mac Mini still owns `guide` on the tailnet — no collision. |
| Tailscale IP | `100.80.44.14` | Reachable from any tailnet member |
| Samba | `srv` (`/srv`) + `home` (`/home`) | Two shares, both `admin users = gareth`. Working surfaces only — `/etc`, `/root`, `/var`, etc. are not exposed via SMB. Old 3-share layout retired. |

---

## Resolved decisions

### 1. Renamed the machine to `guide-server` ✓

Convention: the box is `guide-server`, the AI runtime hosted on it is `guide`. Done in two places:

- `sudo hostnamectl set-hostname guide-server`
- `sudo tailscale set --hostname=guide-server`

Bootstrap prompt (`Prompts/PROMPT_Engineer-guide-foundation-bootstrap.md`) updated to use `guide-server` in Step 1 and the intro paragraph.

**Still outstanding (architect task, not done in this session):** `CLAUDE.md`, `00_Guide-Project-Brief.md`, and `INFRA.md` still refer to "the Guide machine" / "Mac Mini M2 Pro interim" — those are architect-side spec docs and should be updated separately to reflect the `guide-server` convention and that the Z8 is now live.

### 2. Samba — scoped to working surfaces ✓

Two attempts:

**First attempt (over-permissive, corrected):** a single `everything` share rooted at `/` with `admin users = gareth`. Effectively gave SMB-as-root access to `/etc/shadow`, `/root/`, `/var/log/`, `/var/lib/docker/`, `/boot/` — far beyond what was actually wanted.

**Final layout:** two shares scoped to the working surfaces of the box.

```ini
[srv]
   path = /srv
   valid users = gareth
   admin users = gareth      ; r/w into subtrees owned by guide or root
   read only = no
   create mask = 0664
   directory mask = 0775

[home]
   path = /home
   valid users = gareth
   admin users = gareth      ; access /home/engineer alongside /home/gareth
   read only = no
   create mask = 0664
   directory mask = 0775
```

Mac mounts: `smb://guide-server/srv` and `smb://guide-server/home`.

`/etc`, `/root`, `/var`, `/boot`, `/usr`, `/opt`, `/tmp`, `/proc`, `/sys`, `/dev` — none exposed via SMB. System-level edits go through SSH + `sudo`.

---

## What's next (per the bootstrap's tail section)

1. **CHUNK-07-ubuntu** — security hardening (UFW, SSH hardening, fail2ban). Will need to be rewritten for Ubuntu before execution.
2. **NVIDIA drivers + nvidia-container-toolkit** — for Ollama on the RTX 3090
3. **Docker Compose scaffolding** — one file per service under `/srv/compose/`
4. **PostgreSQL + Redis containers** — shared by Huginn, Paperclip, etc.
5. **OpenClaw install + config migration from Mac Mini**
6. **Huginn**
7. **Hermes**
8. **Paperclip**
9. **Ollama + Open WebUI**
10. **OneDrive client** (abraunegg/onedrive)

To pull any Architect-side updates to guide-build:
```bash
git -C /srv/guide-build pull
```

---

## Files touched on the machine (outside `/srv/`)

| File | Change |
|---|---|
| `/etc/hostname` | (pre-existing as `guide`) |
| `/etc/samba/smb.conf` | rewritten; original backed up to `smb.conf.bak` |
| `/etc/sudoers.d/gareth` | scoped NOPASSWD entries |
| `/etc/sudoers.d/gareth-bootstrap` | created and deleted (used for unattended run) |
| `~/.ssh/id_ed25519` | pre-existing; registered with GitHub |
| `~/.bashrc` | nvm init, pyenv init, rbenv init, Guide env vars |
| `~/.nvm/`, `~/.pyenv/`, `~/.rbenv/` | new — toolchain installs |

---

*End of bootstrap log.*
