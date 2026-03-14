---
name: service-management
description: This skill should be used when the user asks to "restart a service on the server", "start/stop nginx", "check if a process is running remotely", "reload app on production", "manage systemd service", "kill a process on remote host", "check what's using a port", "restart my application", "deploy new version and restart", or needs to manage running processes or daemons on a remote machine.
version: 1.0.0
---

# Remote Service Management

Patterns for managing services and processes on remote hosts via SSH.

## systemd Services (most Linux servers)

```bash
# Status
ssh user@host "systemctl status <service>"
ssh user@host "systemctl is-active <service>"   # simple active/inactive check

# Start / Stop / Restart / Reload
ssh user@host "sudo systemctl start <service>"
ssh user@host "sudo systemctl stop <service>"
ssh user@host "sudo systemctl restart <service>"
ssh user@host "sudo systemctl reload <service>"   # graceful config reload (if supported)

# Enable/disable at boot
ssh user@host "sudo systemctl enable <service>"
ssh user@host "sudo systemctl disable <service>"

# View recent logs for a service
ssh user@host "sudo journalctl -u <service> -n 50 --no-pager"
```

## Process Inspection

```bash
# Is a process running?
ssh user@host "pgrep -a <process-name>"

# Full process list with CPU/memory
ssh user@host "ps aux | grep <process-name>"

# What's listening on a port?
ssh user@host "sudo ss -tlnp | grep :<port>"
ssh user@host "sudo lsof -i :<port>"

# System resource snapshot
ssh user@host "top -bn1 | head -20"
ssh user@host "uptime && free -h && df -h /"
```

## Graceful vs Forceful Restart

Prefer graceful restarts to avoid dropping connections:

| Method | Command | When to use |
|--------|---------|-------------|
| Reload config | `systemctl reload <svc>` | nginx, apache — apply config without downtime |
| Graceful restart | `systemctl restart <svc>` | Most services — waits for in-flight requests |
| Kill + restart | `kill -HUP <pid>` | Apps that handle SIGHUP for hot reload |
| Force kill | `kill -9 <pid>` | Last resort — process is frozen/unresponsive |

**Always prefer `restart` or `reload` over `kill -9`** — force-killing can corrupt state, leave orphan processes, or drop database connections.

## Common Service Names

| Application | Service name |
|-------------|-------------|
| nginx | `nginx` |
| Apache | `apache2` (Debian) / `httpd` (RHEL) |
| PostgreSQL | `postgresql` |
| MySQL | `mysql` / `mysqld` |
| Redis | `redis-server` / `redis` |
| Docker | `docker` |
| Node (PM2) | use `pm2 restart <app>` instead |

## PM2 (Node.js Process Manager)

```bash
# Status of all apps
ssh user@host "pm2 list"

# Restart specific app
ssh user@host "pm2 restart <app-name>"

# Zero-downtime reload
ssh user@host "pm2 reload <app-name>"

# View logs
ssh user@host "pm2 logs <app-name> --lines 50"
```

## Safety Checklist Before Restarting

1. Check current service status first — is it actually running?
2. For production: confirm there are no active deployments in progress
3. Prefer `reload` over `restart` for web servers when only config changed
4. After restart, verify the service came back up: `systemctl is-active <service>`
5. Check logs immediately after: `journalctl -u <service> -n 20`
