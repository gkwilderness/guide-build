# Guide — OpenClaw container image
# Built once on the Z8, run by docker compose under systemd.
# Pin OPENCLAW_VERSION to match the version migrated from the Mac Mini snapshot
# (Logs/2026-05-18_mac-mini-state.md §1 records the live version at migration time).

FROM node:24-bookworm

ARG OPENCLAW_VERSION=2026.5.4

# Runtime deps: curl for healthcheck, ca-certificates for TLS, tini as PID 1.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl ca-certificates tini \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g openclaw@${OPENCLAW_VERSION} \
    && openclaw --version

# OpenClaw expects to be able to write to its config + workspace tree.
# These paths are bind-mounted from /srv/ at run time; nothing is baked into the image.
WORKDIR /srv/openclaw

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["openclaw", "gateway"]
