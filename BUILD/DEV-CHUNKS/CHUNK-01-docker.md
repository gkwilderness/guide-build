---
title: "CHUNK-01-docker"
type: note
area: ai
project: "Guide"
tags: [ai, guide, build]
status: pending
---
# CHUNK-01 — Docker
## GUIDE Build System | Phase 0 | Foundation

> **Claude Code instructions:** Read this file top to bottom before writing anything.
> Reference `BUILD/DEV-CHUNKS/_CONVENTIONS.md` for all paths, ports, and naming rules.
> This chunk is idempotent: re-running must make zero changes to an already-configured system.

---

### What This Chunk Does

Configures Docker Desktop for production use. Creates the container strategy, base compose files, and network configuration. Establishes the pattern for all future containerised services.

**Success state:** Docker Desktop is running with resource limits set. A `guide-network` Docker network exists. Base `docker-compose.yml` in `~/guide-core/docker/` is ready for services. `docker ps` shows no errors.

---

### Prerequisites

- [ ] CHUNK-00 complete (Docker Desktop installed)
- [ ] Docker Desktop running (open app if needed)
- [ ] `~/guide-core/` directory exists

---

### Deliverables

1. Docker Desktop resource limits configured (16GB RAM, 4 CPU cores — half of machine)
2. `guide-network` Docker bridge network created
3. `~/guide-core/docker/` directory structure created
4. Base `docker-compose.yml` with network and common labels
5. `.env.example` template for Docker secrets
6. Docker health check verified

---

### Environment Variables Required

```bash
# Docker-specific (in ~/guide-core/docker/.env)
COMPOSE_PROJECT_NAME=guide
```

---

### Tasks

#### Task 1 — Configure Docker Desktop resources

```bash
# Docker Desktop on macOS uses a VM — configure via settings
# OPERATOR: Open Docker Desktop > Settings > Resources
# Set: 16GB RAM, 4 CPUs, 64GB disk
# Or configure via settings.json:
DOCKER_SETTINGS="$HOME/Library/Group Containers/group.com.docker/settings-store.json"
echo "✓ Docker Desktop resource limits — configure via GUI: 16GB RAM, 4 CPUs"
```

#### Task 2 — Create Docker network

```bash
docker network inspect guide-network &>/dev/null || {
  docker network create guide-network
  echo "✓ guide-network created"
}
```

#### Task 3 — Create directory structure

```bash
mkdir -p ~/guide-core/docker
echo "✓ Docker directory created"
```

#### Task 4 — Create base docker-compose.yml

```bash
[[ -f ~/guide-core/docker/docker-compose.yml ]] || cat > ~/guide-core/docker/docker-compose.yml << 'EOF'
# Guide — Base Docker Compose
# All services bind to 127.0.0.1 (loopback only)
# Remote access via Tailscale, not port exposure

networks:
  guide-network:
    external: true

# Services added by subsequent chunks
services: {}
EOF
echo "✓ Base docker-compose.yml created"
```

#### Task 5 — Create .env.example

```bash
[[ -f ~/guide-core/docker/.env.example ]] || cat > ~/guide-core/docker/.env.example << 'EOF'
# Guide Docker Environment
# Copy to .env and fill in values. Never commit .env to git.
COMPOSE_PROJECT_NAME=guide
ANTHROPIC_API_KEY=sk-ant-...
TELEGRAM_BOT_TOKEN=...
EOF
echo "✓ .env.example created"
```

#### Task 6 — Create .gitignore for docker dir

```bash
[[ -f ~/guide-core/docker/.gitignore ]] || cat > ~/guide-core/docker/.gitignore << 'EOF'
.env
*.key
*.pem
EOF
echo "✓ .gitignore created"
```

---

### Verification Gate

```bash
docker info &>/dev/null && echo "✓ docker running" || echo "✗ docker not running"
docker network inspect guide-network &>/dev/null && echo "✓ guide-network" || echo "✗ guide-network"
[[ -f ~/guide-core/docker/docker-compose.yml ]] && echo "✓ compose file" || echo "✗ compose file"
[[ -f ~/guide-core/docker/.env.example ]] && echo "✓ env example" || echo "✗ env example"
```

---

### Rollback

```bash
docker network rm guide-network 2>/dev/null
rm -rf ~/guide-core/docker/
```

---

### Git Commit

```bash
cd ~/guide-core && git add -A && git commit -m "feat(chunk-01): docker foundation"
```

---

### Handoff to CHUNK-02

CHUNK-02 (OpenClaw Install) expects:
- Docker Desktop running
- `guide-network` exists
- `~/guide-core/docker/` structure ready
