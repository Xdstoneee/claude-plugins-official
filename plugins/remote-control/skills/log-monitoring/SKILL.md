---
name: log-monitoring
description: This skill should be used when the user asks to "tail logs on a remote server", "watch remote logs", "check application logs on production", "monitor error logs", "stream logs from server", "search logs for errors", "grep remote logs", "follow log file on remote host", or wants to investigate what's happening on a running remote system through its logs.
version: 1.0.0
---

# Remote Log Monitoring

Patterns for reading, tailing, and searching logs on remote hosts via SSH.

## Live Log Tailing

Stream logs in real time — press Ctrl+C to stop:
```bash
# Single file
ssh user@host "tail -f /var/log/app/production.log"

# Multiple files simultaneously
ssh user@host "tail -f /var/log/nginx/access.log /var/log/nginx/error.log"

# Follow with grep filter (only show errors)
ssh user@host "tail -f /var/log/app/app.log" | grep -i "error\|exception\|fatal"

# Using journald (systemd systems)
ssh user@host "sudo journalctl -u myapp -f"
ssh user@host "sudo journalctl -u myapp -f --output=json" | jq '.MESSAGE'
```

## Reading Recent Logs

```bash
# Last 100 lines
ssh user@host "tail -100 /var/log/app/app.log"

# Last N lines with timestamps
ssh user@host "sudo journalctl -u myapp -n 100 --no-pager"

# Logs since a point in time
ssh user@host "sudo journalctl -u myapp --since '2024-01-15 10:00:00' --no-pager"

# Today's logs only
ssh user@host "sudo journalctl -u myapp --since today --no-pager"
```

## Searching Logs

```bash
# Find all occurrences of a pattern
ssh user@host "grep -n 'ERROR' /var/log/app/app.log | tail -50"

# Case-insensitive search with context
ssh user@host "grep -i -A 3 -B 1 'exception' /var/log/app/app.log | tail -100"

# Count errors per hour (useful for spotting spikes)
ssh user@host "grep 'ERROR' /var/log/app/app.log | awk '{print \$1, \$2}' | cut -c1-13 | sort | uniq -c"

# Search across rotated/compressed log files
ssh user@host "zgrep 'pattern' /var/log/app/app.log*"
```

## Common Log Locations

| Service | Log path |
|---------|----------|
| nginx | `/var/log/nginx/access.log`, `/var/log/nginx/error.log` |
| Apache | `/var/log/apache2/` or `/var/log/httpd/` |
| PostgreSQL | `/var/log/postgresql/` |
| MySQL/MariaDB | `/var/log/mysql/error.log` |
| systemd services | `journalctl -u <service>` |
| Node.js (PM2) | `pm2 logs <app>` or `~/.pm2/logs/` |
| Docker containers | `docker logs <container>` |
| Syslog | `/var/log/syslog` (Debian) or `/var/log/messages` (RHEL) |
| Auth events | `/var/log/auth.log` (Debian) or `/var/log/secure` (RHEL) |

## Efficient Long-Session Log Watching

For extended monitoring sessions, prefer `ssh -t` with a persistent command:
```bash
# Keep watching even if output is slow
ssh -t user@host "sudo journalctl -u myapp -f --no-hostname"
```

For very high-volume logs, pipe through `grep` remotely to reduce bandwidth:
```bash
# Filter on the remote side — only transmit matching lines
ssh user@host "tail -f /var/log/app/app.log | grep --line-buffered ERROR"
```
