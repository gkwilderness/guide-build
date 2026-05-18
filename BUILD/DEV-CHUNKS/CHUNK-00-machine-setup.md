---
title: "CHUNK-00-machine-setup"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: pending
---
# CHUNK-00 — Machine Setup
## GUIDE Build System | Phase 0 | Foundation

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.

---

### What This Chunk Does

Configures the Guide Mac Mini M4 from a fresh macOS install to a production-ready base system. Installs core tools, configures SSH key auth, connects to Tailscale, sets up OneDrive, and establishes the machine identity.

**Success state:** Guide machine is accessible via SSH over Tailscale from Mac and Scout. Homebrew, nvm, pyenv, Git, and Docker Desktop are installed. OneDrive is syncing. Machine hostname is `guide`.

---

### Prerequisites

- [ ] Mac Mini M4 hardware available and powered on
- [ ] macOS installed and initial setup wizard completed
- [ ] Gareth has physical or screen-sharing access to Guide
- [ ] Tailscale account credentials available
- [ ] OneDrive (Wilderness) credentials available
- [ ] Gareth's SSH public key available (from Mac)

---

### Deliverables

1. Machine hostname set to `guide`
2. Homebrew installed and updated
3. nvm installed with Node.js 24 LTS
4. pyenv installed with Python 3.11
5. Git configured (name, email, default branch)
6. SSH key pair generated (Ed25519)
7. SSH key auth enabled; password auth disabled for remote access
8. Tailscale installed and connected to tailnet
9. OneDrive installed and syncing Wilderness folder
10. Docker Desktop installed (Apple Silicon native)
11. Base directories created: `~/guide-core/`, `~/guide-data/`
12. guide-build vault synced and accessible at `$GUIDE_VAULT_PATH`
13. System info snapshot saved to `~/guide-setup-YYYY-MM-DD.txt`

---

### Environment Variables Required

```bash
# To be set in ~/.zshrc after setup
export GUIDE_VAULT_PATH="$HOME/guide-build"
export ONEDRIVE_PATH="$HOME/Library/CloudStorage/OneDrive-WildernessSafaris"
export GUIDE_CORE="$HOME/guide-core"
export GUIDE_DATA="$HOME/guide-data"
```

---

### Tasks

#### Task 1 — Set hostname

```bash
[[ "$(scutil --get ComputerName)" == "guide" ]] || {
  sudo scutil --set ComputerName "guide"
  sudo scutil --set HostName "guide"
  sudo scutil --set LocalHostName "guide"
  echo "✓ Hostname set to guide"
}
```

#### Task 2 — Install Homebrew

```bash
command -v brew &>/dev/null || {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
}
brew update
echo "✓ Homebrew $(brew --version | head -1)"
```

#### Task 3 — Install core packages

```bash
brew install git curl wget jq yq tree htop tmux
echo "✓ Core packages installed"
```

#### Task 4 — Install nvm + Node.js 24

```bash
command -v nvm &>/dev/null || {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}
nvm install 24 && nvm use 24 && nvm alias default 24
echo "✓ Node.js $(node --version)"
```

#### Task 5 — Install pyenv + Python 3.11

```bash
command -v pyenv &>/dev/null || brew install pyenv
grep -q 'pyenv init' ~/.zshrc || {
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
  echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
  echo 'eval "$(pyenv init -)"' >> ~/.zshrc
}
pyenv install -s 3.11 && pyenv global 3.11
echo "✓ Python $(python --version)"
```

#### Task 6 — Configure Git

```bash
git config --global user.name "Gareth Knight"
git config --global user.email "gareth@wildernesssafaris.com"
git config --global init.defaultBranch main
echo "✓ Git configured"
```

#### Task 7 — Generate SSH key pair

```bash
[[ -f ~/.ssh/id_ed25519 ]] || {
  ssh-keygen -t ed25519 -C "guide-machine" -f ~/.ssh/id_ed25519 -N ""
  echo "✓ SSH key pair generated"
}
echo "Public key: $(cat ~/.ssh/id_ed25519.pub)"
```

#### Task 8 — Install and add Gareth's SSH public key

```bash
mkdir -p ~/.ssh
# Add Gareth's Mac public key to authorized_keys
# OPERATOR: paste Gareth's public key below
# echo "ssh-ed25519 AAAA... gareth@mac" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
echo "✓ SSH authorized_keys configured"
```

#### Task 9 — Enable Remote Login (SSH) and harden

```bash
# Enable Remote Login via System Settings > General > Sharing > Remote Login
# Or via command line:
sudo systemsetup -setremotelogin on
echo "✓ Remote Login enabled"
```

#### Task 10 — Install Tailscale

```bash
brew install --cask tailscale
# OPERATOR: Open Tailscale app and authenticate
echo "✓ Tailscale installed — authenticate via GUI"
```

#### Task 11 — Install OneDrive

```bash
brew install --cask onedrive
# OPERATOR: Open OneDrive app and sign in with Wilderness credentials
echo "✓ OneDrive installed — sign in via GUI"
```

#### Task 12 — Install Docker Desktop

```bash
brew install --cask docker
# OPERATOR: Open Docker Desktop and complete setup
echo "✓ Docker Desktop installed"
```

#### Task 13 — Create base directories

```bash
mkdir -p ~/guide-core ~/guide-data
echo "✓ Base directories created"
```

#### Task 14 — Sync guide-build vault

```bash
# OPERATOR: Set up guide-build vault sync (git clone or Syncthing)
# The guide-build vault must be accessible locally at ~/guide-build
# Verify:
[[ -d "$HOME/guide-build/BUILD/DEV-CHUNKS" ]] && echo "✓ Vault synced" || echo "✗ Vault not found — set up sync"
```

#### Task 15 — Set environment variables

```bash
grep -q 'GUIDE_VAULT_PATH' ~/.zshrc || cat >> ~/.zshrc << 'EOF'

# Guide environment
export GUIDE_VAULT_PATH="$HOME/guide-build"
export ONEDRIVE_PATH="$HOME/Library/CloudStorage/OneDrive-WildernessSafaris"
export GUIDE_CORE="$HOME/guide-core"
export GUIDE_DATA="$HOME/guide-data"
EOF
echo "✓ Environment variables set"
```

#### Task 15 — System info snapshot

```bash
cat > ~/guide-setup-$(date +%Y-%m-%d).txt << EOF
Guide Machine Setup — $(date)
Hostname: $(scutil --get ComputerName)
macOS: $(sw_vers -productVersion)
Chip: $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Apple Silicon")
RAM: $(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 " GB"}')
Homebrew: $(brew --version | head -1)
Node: $(node --version)
Python: $(python --version)
Git: $(git --version)
Docker: $(docker --version 2>/dev/null || echo "Not running yet")
Tailscale: $(tailscale version 2>/dev/null || echo "Not authenticated yet")
SSH key: $(cat ~/.ssh/id_ed25519.pub 2>/dev/null || echo "Not generated")
EOF
echo "✓ System info snapshot saved"
```

---

### Verification Gate

```bash
[[ "$(scutil --get ComputerName)" == "guide" ]] && echo "✓ hostname" || echo "✗ hostname"
command -v brew &>/dev/null && echo "✓ homebrew" || echo "✗ homebrew"
command -v node &>/dev/null && echo "✓ node" || echo "✗ node"
command -v python &>/dev/null && echo "✓ python" || echo "✗ python"
command -v git &>/dev/null && echo "✓ git" || echo "✗ git"
[[ -f ~/.ssh/id_ed25519 ]] && echo "✓ ssh key" || echo "✗ ssh key"
command -v tailscale &>/dev/null && echo "✓ tailscale" || echo "✗ tailscale"
command -v docker &>/dev/null && echo "✓ docker" || echo "✗ docker"
[[ -d ~/guide-core ]] && echo "✓ guide-core dir" || echo "✗ guide-core dir"
[[ -d ~/guide-data ]] && echo "✓ guide-data dir" || echo "✗ guide-data dir"
[[ -d "$HOME/guide-build/BUILD/DEV-CHUNKS" ]] && echo "✓ vault synced" || echo "✗ vault not found"
```

---

### Rollback

This chunk only installs software and creates directories. To reverse:
- `brew uninstall` individual packages
- Remove `~/guide-core/`, `~/guide-data/`
- Remove added lines from `~/.zshrc`
- Disable Remote Login: `sudo systemsetup -setremotelogin off`

---

### Git Commit

```bash
cd ~/guide-core && git init && git add -A && git commit -m "feat(chunk-00): machine setup complete"
```

---

### Handoff to CHUNK-01

CHUNK-01 (Docker) expects:
- Docker Desktop installed and running
- Homebrew available
- Guide machine accessible via Tailscale SSH
