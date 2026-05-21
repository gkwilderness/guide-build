---
date: 2026-05-20
type: note
status: unprocessed
topic: Tailscale file transfer speed
---

# Tailscale File Transfer Speed — Notes

Added from Telegram conversation 2026-05-20 02:08.

## Quick wins

**1. Use `rsync` over Tailscale SSH (fastest)**
```bash
rsync -avz --progress /local/path/ gareth@100.80.44.14:/remote/path/
```
Direct SSH tunnel, no relay overhead. Much faster than Taildrop for large files.

**2. Check direct vs relay**
```bash
tailscale ping 100.80.44.14
```
- `via DERP` = relaying through Tailscale servers = slow
- `direct` = already optimal

**3. Force direct connection**
Ensure UDP port 41641 is open on both devices. Direct connections are 2-5x faster than DERP relay.

**4. `scp` or `sftp` for raw speed**
```bash
scp -r /local/path gareth@100.80.44.14:/remote/path
```

## To investigate
- Check if Z8 ↔ Mac is going direct or via DERP
- If via DERP, check firewall rules on Z8 for UDP 41641
