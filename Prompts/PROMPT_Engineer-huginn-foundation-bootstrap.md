---
title: "PROMPT — Huginn Z8 Foundation Bootstrap"
type: prompt
area: infra
project: Guide
tags: [infra, huginn, ubuntu, linux, bootstrap, foundation, engineer]
status: ready
created: 2026-05-18
author: Guide
---

# Huginn Z8 — Foundation Bootstrap Prompt

Use this prompt with Claude on the Huginn machine (logged in as `gareth`) to build the foundation layer before any services are installed.

**Reference:** `Notes/2026-05-15 Huginn Z8 Foundation Architecture.md` — read this alongside the prompt for full context on decisions made.

---

## The Prompt

You are helping me set up a new Ubuntu server called "huginn" — this is the foundation build for a Guide AI system. I'm logged in as "gareth" (admin user, already exists). Work methodically, verify each step before moving on, and show me the output of key commands. All scripts must be idempotent (safe to re-run).

---

## Context: what we're building

This machine will host:
- OpenClaw (AI gateway)
- Hermes, Paperclip, Huginn automation
- Ollama (local LLM inference, RTX 3090)
- Postgres, Redis, DuckDB
- Docker-based services
- Samba SMB shares

Full architecture spec is in `~/guide-build` once we clone it (Step 8 below).

---

## Step 1 — Set hostname

Set the machine hostname to "huginn":

```bash
sudo hostnamectl set-hostname huginn
hostname
```

---

## Step 2 — System update

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget jq tree htop tmux build-essential unzip ca-certificates gnupg lsb-release
```

---

## Step 3 — Create users and groups

The `guide` user may already exist on this machine. Check first and modify rather than recreate:

```bash
# guide user — ensure it exists with the right shell and no login
if id guide &>/dev/null; then
  echo "guide user exists — updating shell to nologin"
  sudo usermod --shell /usr/sbin/nologin guide
  # Lock the account if not already locked
  sudo passwd -l guide
else
  echo "guide user not found — creating"
  sudo useradd --system --no-create-home --shell /usr/sbin/nologin guide
fi
```

Create the engineer user (Claude Code sessions — restricted):

```bash
if id engineer &>/dev/null; then
  echo "engineer user exists — skipping"
else
  sudo useradd --create-home --shell /bin/bash engineer
fi
```

Create groups:

```bash
sudo groupadd -f guide-data
sudo groupadd -f srv-data
sudo groupadd -f smb-users
```

Add gareth to the groups that exist now (docker group is created by the Docker installer in Step 5 — do not include it here):

```bash
sudo usermod -aG guide-data,srv-data,smb-users gareth
```

Add guide to guide-data and srv-data:

```bash
sudo usermod -aG guide-data,srv-data guide
```

Verify group memberships:

```bash
groups gareth
```

---

## Step 4 — Create /srv/ directory structure

```bash
sudo mkdir -p /srv/guide/{vaults/{main,channel,personal,shared},teams/{digital,exec,sales,reservations,people},outputs,data}
sudo mkdir -p /srv/hermes/{profiles,data}
sudo mkdir -p /srv/paperclip/data
sudo mkdir -p /srv/huginn/data
sudo mkdir -p /srv/openwebui/data
sudo mkdir -p /srv/ollama/models
sudo mkdir -p /srv/landing-pages
sudo mkdir -p /srv/compose
sudo mkdir -p /srv/db/{postgres,redis,duckdb}
sudo mkdir -p /srv/backup/{dumps,config}
sudo mkdir -p /srv/onedrive
sudo mkdir -p /srv/logs
```

Set ownership — /srv/guide/ owned by guide-data group, group-writable:

```bash
sudo chown -R guide:guide-data /srv/guide
sudo chown -R guide:guide-data /srv/hermes
sudo chown -R guide:guide-data /srv/paperclip
sudo chown -R gareth:srv-data /srv/compose
sudo chown -R gareth:srv-data /srv/landing-pages
sudo chmod -R 775 /srv/guide
sudo chmod -R 775 /srv/hermes
sudo chmod -R 775 /srv/compose
```

Verify:

```bash
ls -la /srv/
```

---

## Step 5 — Install Docker

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker gareth
```

Once Docker is installed, add gareth to the docker group (it's created by the installer):

```bash
sudo usermod -aG docker gareth
```

Verify (log out and back in first, or use `newgrp docker`):

```bash
docker --version
```

---

## Step 6 — Configure scoped sudo for gareth

We want gareth to run specific privileged commands without a password — not blanket sudo.

```bash
sudo tee /etc/sudoers.d/gareth << 'EOF'
# Gareth — scoped NOPASSWD sudo entries
# Service management
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart openclaw
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl start openclaw
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl stop openclaw
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart hermes
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl start hermes
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl stop hermes
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart huginn
gareth ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart ollama
# Firewall
gareth ALL=(ALL) NOPASSWD: /usr/sbin/ufw
# Backup
gareth ALL=(ALL) NOPASSWD: /usr/bin/restic
EOF
sudo chmod 440 /etc/sudoers.d/gareth
sudo visudo -c
```

---

## Step 7 — SSH key for GitHub

```bash
ssh-keygen -t ed25519 -C "huginn-gareth" -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub
```

**STOP HERE.** Print the public key output and add it to GitHub (github.com → Settings → SSH Keys) before continuing.

---

## Step 8 — Clone repos from GitHub

Once the SSH key is added to GitHub:

```bash
git clone git@github.com:gkwilderness/guide-core.git ~/guide-core
git clone git@github.com:gkwilderness/guide-build.git ~/guide-build
ls ~/guide-core
ls ~/guide-build
```

Note: guide-build starts in `/home/gareth/guide-build/` so Engineer (Claude Code) can work from it immediately. Once the foundation build is complete and `/srv/` permissions are stable, it will be moved to `/srv/guide-build/`. Obsidian on the Mac reads/writes as normal; the server does a `git pull` to get updates.

---

## Step 9 — Install Node.js via nvm

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install 24
nvm use 24
nvm alias default 24
node --version
```

---

## Step 10 — Install Python via pyenv

```bash
sudo apt install -y libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libffi-dev
curl https://pyenv.run | bash
```

Add to ~/.bashrc (pyenv init lines):

```bash
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

## Step 11 — Set environment variables

```bash
cat >> ~/.bashrc << 'EOF'

# Guide environment
export GUIDE_CORE="$HOME/guide-core"
export GUIDE_BUILD="$HOME/guide-build"
EOF
source ~/.bashrc
```

---

## Step 12 — Verification gate

Run this and show the full output:

```bash
echo "=== huginn foundation check ==="
hostname
id gareth
groups gareth
echo "--- /srv/ ---"
ls /srv/
echo "--- /srv/guide/ ---"
ls /srv/guide/
echo "--- versions ---"
docker --version
git --version
node --version 2>/dev/null || echo "node: reload shell first"
python --version 2>/dev/null || echo "python: reload shell first"
echo "--- repos ---"
ls ~/guide-core 2>/dev/null && echo "✓ guide-core cloned" || echo "✗ guide-core not found"
echo "=== done ==="
```

---

## After this prompt completes

**guide-build vault** — clone from GitHub (must have remote set up first):

```bash
git clone git@github.com:gkwilderness/guide-build.git ~/guide-build
```

To pull updates after edits on the Mac:

```bash
cd ~/guide-build && git pull
```

Once the foundation build is complete, move it to its permanent location:

```bash
sudo mv ~/guide-build /srv/guide-build
sudo chown -R gareth:guide-data /srv/guide-build
```

**Next steps in order:**
1. Samba (SMB shares) — `Notes/2026-05-15 Huginn Z8 Foundation Architecture.md`
2. NVIDIA drivers + nvidia-container-toolkit (for Ollama / RTX 3090)
3. Docker Compose scaffolding — one file per service in `/srv/compose/`
4. OpenClaw install (CHUNK-02, rewritten for Ubuntu)
5. Services in sequence: Postgres/Redis → Ollama → Huginn → Hermes → OpenClaw

**Architecture decisions still open before service builds begin** (from the foundation spec):
1. DuckDB or ClickHouse for analytics?
2. OneDrive client: abraunegg confirmed? Sync mode: two-way or download-only?
3. Backblaze B2 — account set up before or after foundation?
4. Engineer: system user (already created above) or devcontainer?
5. Landing pages: static (nginx) or dynamic?
6. Huginn: machine name only, or also the automation software (requires Postgres + Redis)?
7. Paperclip database requirements?
8. Monitoring stack: Grafana + Prometheus, or something lighter?

---

## Related files

- `Notes/2026-05-15 Huginn Z8 Foundation Architecture.md` — full architecture spec
- `Notes/2026-05-15 Z8 Security Best Practice.md` — security hardening, read before CHUNK-07
- `BUILD/DEV-CHUNKS/CHUNK-07-security-hardening.md` — macOS version (preserve, rewrite for Ubuntu)
