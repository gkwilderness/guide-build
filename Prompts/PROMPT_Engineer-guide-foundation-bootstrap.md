---
title: "PROMPT — Guide Z8 Foundation Bootstrap"
type: prompt
area: infra
project: Guide
tags: [infra, guide, ubuntu, linux, bootstrap, foundation, engineer]
status: ready
created: 2026-05-18
author: Architect
---

# Guide Z8 — Foundation Bootstrap Prompt

Use this prompt with Claude Code on the Guide machine (logged in as `gareth`) to build the foundation layer before any services are installed.

**Read first:** `Notes/2026-05-15 Guide Z8 Foundation Architecture.md` — full context on every decision made here.

---

## The Prompt

You are the Engineer helping me set up a new Ubuntu server called "guide" — the foundation build for a Guide AI system. I'm logged in as `gareth` (admin user, already exists). Work methodically, verify each step before moving on, and show me the output of key commands. All scripts must be idempotent (safe to re-run).

Do not proceed past any step without confirming the output with me first.

---

## Context: what this machine will host

- **OpenClaw** — Node.js AI gateway (the main Guide AI runtime). Runs in Docker. Config in /srv/openclaw/.
- **Huginn** — Ruby automation platform (self-hosted Zapier/IFTTT). Runs in Docker. Requires PostgreSQL + Redis.
- **Paperclip** — Node.js AI agent orchestrator. Runs in Docker. Requires PostgreSQL + git worktrees.
- **Hermes** — Python AI agent framework (NousResearch). Runs in Docker. Requires Python 3.11, ripgrep, ffmpeg.
- **Ollama** — Local LLM inference on RTX 3090. Runs in Docker with nvidia-container-toolkit.
- **Open WebUI** — Web interface for Ollama.
- **PostgreSQL + Redis** — Shared database containers used by multiple services.

All services run in Docker. The foundation build installs runtimes, creates the directory structure, sets up users and permissions, gets Tailscale running, and gets Samba running so the machine is accessible via the network before any services are installed.

Full architecture spec is in `/srv/guide-build/` once we clone it (Step 7 below).

---

## Step 1 — Set hostname

```bash
sudo hostnamectl set-hostname guide
hostname
```

Expected output: `guide`

---

## Step 2 — System update and base packages

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  git curl wget jq tree htop tmux \
  build-essential unzip ca-certificates gnupg lsb-release \
  samba samba-common-bin \
  ripgrep ffmpeg \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
  libsqlite3-dev libffi-dev libyaml-dev libgmp-dev
```

---

## Step 3 — Tailscale

Get remote access working now, before anything else. The tailnet already exists — this machine just needs to join it.

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

**STOP HERE.** Tailscale will print an authentication URL. Open it in a browser and log in with `gareth@wildernessdestinations.com`. Once authenticated, confirm the machine appears in the Tailscale admin console, then continue.

Verify:

```bash
tailscale ip -4
tailscale status
```

---

## Step 4 — Users and groups

The `guide` user may already exist. Check and correct rather than recreate:

```bash
# Correct the guide service user
if id guide &>/dev/null; then
  echo "guide user exists — correcting shell to nologin"
  sudo usermod --shell /usr/sbin/nologin guide
  sudo passwd -l guide
else
  echo "guide user not found — creating"
  sudo useradd --system --no-create-home --shell /usr/sbin/nologin guide
fi
```

Create the engineer user (Claude Code sessions):

```bash
if id engineer &>/dev/null; then
  echo "engineer user exists — skipping"
else
  sudo useradd --create-home --shell /bin/bash engineer
  echo "engineer user created"
fi
```

Create groups:

```bash
sudo groupadd -f guide-data
sudo groupadd -f srv-data
sudo groupadd -f smb-users
```

Add users to groups (docker group is created by the Docker installer in Step 5 — do not include it here):

```bash
sudo usermod -aG guide-data,srv-data,smb-users gareth
sudo usermod -aG guide-data,srv-data guide
sudo usermod -aG srv-data engineer
```

Verify:

```bash
id gareth
id guide
id engineer
```

---

## Step 5 — /srv/ directory structure

```bash
sudo mkdir -p \
  /srv/logs \
  /srv/guide-build \
  /srv/guide-core \
  /srv/guide-engine \
  /srv/guide-data \
  /srv/guide-outputs \
  /srv/guide-vaults/private \
  /srv/guide-vaults/personal/nick \
  /srv/guide-vaults/personal/hadley \
  /srv/guide-vaults/shared \
  /srv/guide-vaults/teams/digital \
  /srv/guide-vaults/teams/exco \
  /srv/guide-vaults/teams/sales \
  /srv/guide-vaults/teams/reservations \
  /srv/guide-vaults/teams/hr \
  /srv/openclaw/workspace \
  /srv/openclaw/config \
  /srv/hermes/profiles \
  /srv/hermes/data \
  /srv/paperclip/data \
  /srv/huginn/data \
  /srv/openwebui/data \
  /srv/ollama/models \
  /srv/landing-pages \
  /srv/compose \
  /srv/db/postgres \
  /srv/db/redis \
  /srv/backup/dumps \
  /srv/backup/config \
  /srv/onedrive
```

**Note:** `/srv/db/clickhouse/` is intentionally omitted — deferred until analytics DB decision is made.
**Note:** `/srv/ollama/models/` must be moved to the 4TB HDD before Ollama is installed — models are 20GB+ each. This is handled in the Ollama service chunk, not here.

Set ownership and permissions:

```bash
# guide-data group owns OpenClaw and vault dirs
sudo chown -R guide:guide-data /srv/openclaw
sudo chown -R guide:guide-data /srv/guide-vaults
sudo chmod -R 775 /srv/openclaw
sudo chmod -R 775 /srv/guide-vaults

# gareth owns repos and compose files
sudo chown -R gareth:srv-data /srv/guide-build
sudo chown -R gareth:srv-data /srv/guide-core
sudo chown -R gareth:srv-data /srv/guide-engine
sudo chown -R gareth:srv-data /srv/compose
sudo chown -R gareth:srv-data /srv/guide-outputs
sudo chown -R gareth:srv-data /srv/guide-data
sudo chmod -R 775 /srv/compose

# logs
sudo chown root:srv-data /srv/logs
sudo chmod 775 /srv/logs
```

Verify:

```bash
ls -la /srv/
ls -la /srv/guide-vaults/
ls -la /srv/openclaw/
```

---

## Step 6 — Samba

Configure three SMB shares so the machine is accessible via Finder/Explorer without SSH.

First, set gareth's Samba password (separate from system password):

```bash
sudo smbpasswd -a gareth
```

Back up the default config and write a clean one:

```bash
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

sudo tee /etc/samba/smb.conf << 'EOF'
[global]
   workgroup = WORKGROUP
   server string = Guide
   server role = standalone server
   log file = /var/log/samba/log.%m
   max log size = 50
   dns proxy = no
   map to guest = Bad User

[guide-teams]
   comment = Guide Team Vaults
   path = /srv/guide-vaults/teams
   valid users = gareth
   read only = no
   browsable = yes
   create mask = 0664
   directory mask = 0775

[guide-outputs]
   comment = Guide Agent Outputs
   path = /srv/guide-outputs
   valid users = gareth
   read only = no
   browsable = yes
   create mask = 0664
   directory mask = 0775

[guide-data]
   comment = Guide Pipeline Data
   path = /srv/guide-data
   valid users = gareth
   read only = no
   browsable = yes
   create mask = 0660
   directory mask = 0770
EOF
```

Test the config and restart:

```bash
sudo testparm
sudo systemctl restart smbd nmbd
sudo systemctl enable smbd nmbd
```

Verify Samba is running:

```bash
sudo systemctl status smbd
```

**STOP HERE.** From your Mac, open Finder → Go → Connect to Server → `smb://guide` (or the Tailscale IP). Log in as gareth with the Samba password you just set. Confirm you can see all three shares before continuing.

---

## Step 7 — Docker

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker gareth
sudo usermod -aG docker guide
```

Verify (you may need to log out and back in, or run `newgrp docker`):

```bash
docker --version
docker compose version
```

---

## Step 8 — Scoped sudo for gareth

Specific NOPASSWD entries — not blanket sudo:

```bash
sudo tee /etc/sudoers.d/gareth << 'EOF'
# Gareth — scoped NOPASSWD sudo entries
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart openclaw
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl start openclaw
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl stop openclaw
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart hermes
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl start hermes
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl stop hermes
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart huginn
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart ollama
gareth ALL=(ALL) NOPASSWD: /usr/sbin/ufw
gareth ALL=(ALL) NOPASSWD: /usr/bin/restic
EOF
sudo chmod 440 /etc/sudoers.d/gareth
sudo visudo -c
```

---

## Step 9 — SSH key for GitHub and clone repos

```bash
ssh-keygen -t ed25519 -C "guide-machine" -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub
```

**STOP HERE.** Print the public key and add it to the `gkwilderness` GitHub account (Settings → SSH Keys) before continuing.

Test the connection:

```bash
ssh -T git@github.com
```

Expected: `Hi gkwilderness! You've successfully authenticated...`

Clone repos to their permanent locations:

```bash
git clone git@github.com:gkwilderness/guide-build.git /srv/guide-build
git clone git@github.com:gkwilderness/guide-core.git /srv/guide-core
git clone git@github.com:gkwilderness/guide-engine.git /srv/guide-engine
```

Fix ownership after clone:

```bash
sudo chown -R gareth:srv-data /srv/guide-build
sudo chown -R gareth:srv-data /srv/guide-core
sudo chown -R gareth:srv-data /srv/guide-engine
```

Verify:

```bash
ls /srv/guide-build
ls /srv/guide-core
```

---

## Step 10 — Node.js via nvm

Required by OpenClaw (Node 24) and Paperclip (Node 20+).

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install 24
nvm use 24
nvm alias default 24
node --version
npm --version
```

---

## Step 11 — Python via pyenv

Required by Hermes (Python 3.11).

```bash
curl https://pyenv.run | bash

cat >> ~/.bashrc << 'EOF'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF

source ~/.bashrc
pyenv install 3.11
pyenv global 3.11
python --version
```

---

## Step 12 — Ruby via rbenv

Required by Huginn (Rails app).

```bash
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

cat >> ~/.bashrc << 'EOF'

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
EOF

source ~/.bashrc
rbenv install 3.2.2
rbenv global 3.2.2
ruby --version
gem --version
```

---

## Step 13 — Environment variables

```bash
cat >> ~/.bashrc << 'EOF'

# Guide environment
export GUIDE_BUILD="/srv/guide-build"
export GUIDE_CORE="/srv/guide-core"
export GUIDE_ENGINE="/srv/guide-engine"
export GUIDE_VAULTS="/srv/guide-vaults"
export OPENCLAW_WORKSPACE="/srv/openclaw/workspace"
export OPENCLAW_CONFIG="/srv/openclaw/config"
EOF

source ~/.bashrc
```

---

## Step 14 — Verification gate

Run this in full and show me the complete output:

```bash
echo "=== guide foundation check ==="
echo "--- hostname ---"
hostname
echo "--- users ---"
id gareth
id guide
id engineer
echo "--- tailscale ---"
tailscale ip -4
echo "--- /srv/ ---"
ls /srv/
echo "--- /srv/guide-vaults/ ---"
ls /srv/guide-vaults/
echo "--- /srv/openclaw/ ---"
ls /srv/openclaw/
echo "--- samba ---"
sudo systemctl is-active smbd
echo "--- docker ---"
docker --version
docker compose version
echo "--- versions ---"
node --version 2>/dev/null || echo "node: reload shell first"
python --version 2>/dev/null || echo "python: reload shell first"
ruby --version 2>/dev/null || echo "ruby: reload shell first"
ripgrep --version 2>/dev/null || rg --version 2>/dev/null || echo "ripgrep: not found"
ffmpeg -version 2>/dev/null | head -1 || echo "ffmpeg: not found"
echo "--- repos ---"
ls /srv/guide-build 2>/dev/null && echo "✓ guide-build" || echo "✗ guide-build not found"
ls /srv/guide-core 2>/dev/null && echo "✓ guide-core" || echo "✗ guide-core not found"
ls /srv/guide-engine 2>/dev/null && echo "✓ guide-engine" || echo "✗ guide-engine not found"
echo "=== done ==="
```

---

## After the foundation is verified

**What comes next (separate chunks, in order):**
1. CHUNK-07-ubuntu — security hardening (UFW, SSH hardening, fail2ban)
2. NVIDIA drivers + nvidia-container-toolkit (for Ollama / RTX 3090)
3. Docker Compose scaffolding — one file per service in /srv/compose/
4. Databases — PostgreSQL + Redis containers
5. OpenClaw install and config migration from Mac Mini
6. Huginn
7. Hermes
8. Paperclip
9. Ollama + Open WebUI
10. OneDrive client (abraunegg/onedrive)

**To pull Architect updates to guide-build:**
```bash
git -C /srv/guide-build pull
```

**Read next:**
- `Notes/2026-05-15 Z8 Security Best Practice.md` — before running CHUNK-07
- `BUILD/DEV-CHUNKS/CHUNK-07-security-hardening.md` — rewrite for Ubuntu before executing
