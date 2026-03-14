---
name: remote-ops
description: This skill should be used when the user asks to "run a command on a server", "connect to a remote host", "SSH into", "deploy to staging/production", "check server status", "restart a service remotely", "tail logs on a remote machine", or discusses managing infrastructure or remote environments. Provides guidance for safely executing remote operations via SSH.
version: 1.0.0
---

# Remote Operations Skill

This skill guides Claude when helping users perform operations on remote hosts and infrastructure.

## When This Skill Applies

Activate when the user wants to:
- Connect to a remote server or VM via SSH
- Run commands on a remote machine
- Deploy code to staging or production environments
- Check the status of remote services or processes
- Transfer files to/from remote hosts (scp, rsync)
- Manage infrastructure (restart services, check logs, monitor resources)

## Core Principles

### 1. Safety First
- **Always confirm** before running destructive commands (`rm -rf`, `DROP TABLE`, `reboot`, etc.)
- **Warn about production** — any command targeting a production environment should get explicit confirmation
- **Show the command** before executing so the user can review it
- **Prefer dry-runs** when available (`rsync --dry-run`, `terraform plan`, etc.)

### 2. SSH Best Practices
- Use `BatchMode=yes` to prevent hanging on password prompts
- Use `ConnectTimeout=10` to fail fast on unreachable hosts
- Prefer key-based authentication; never ask users for or store passwords
- Use `-o StrictHostKeyChecking=accept-new` only when the user is aware

### 3. Diagnosing Connection Failures
When SSH fails, check in order:
1. DNS resolution: `dig <hostname>` or `nslookup <hostname>`
2. Port reachability: `nc -zv <host> <port>` or `telnet <host> <port>`
3. Key authentication: `ssh -vvv` output for auth failures
4. Firewall/security groups blocking the port

### 4. Common Remote Patterns

**Check service status:**
```bash
ssh user@host "systemctl status <service>"
```

**Tail application logs:**
```bash
ssh user@host "tail -f /var/log/<app>/app.log"
```

**Restart a service:**
```bash
ssh user@host "sudo systemctl restart <service>"
```

**Check disk/memory:**
```bash
ssh user@host "df -h && free -h && uptime"
```

**Copy files to remote:**
```bash
rsync -avz --progress ./dist/ user@host:/var/www/app/
```

## Available Commands

- `/rc-connect <user@host> [port]` — verify connectivity and show host info
- `/rc-run <user@host> <command>` — execute a single command remotely
- `/rc-deploy <environment> [branch]` — deploy current project to an environment
