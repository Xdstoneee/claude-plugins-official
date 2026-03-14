---
name: environment-management
description: This skill should be used when the user asks to "check environment variables on the server", "update .env on production", "set an env var remotely", "manage secrets on remote host", "read config from server", "compare staging and production env", "add environment variable to systemd service", or needs to inspect or update runtime configuration on a remote machine.
version: 1.0.0
---

# Remote Environment Management

Patterns for inspecting and managing environment variables and config files on remote hosts.

## Inspecting Environment Variables

```bash
# Print all env vars for a running process (by PID)
ssh user@host "cat /proc/<pid>/environ | tr '\0' '\n'"

# Print env for a specific systemd service
ssh user@host "sudo systemctl show myapp --property=Environment"

# Check what a service sees at startup
ssh user@host "sudo cat /etc/systemd/system/myapp.service | grep -A 20 '\[Service\]'"

# List env vars matching a pattern
ssh user@host "env | grep -i database"
```

## Reading .env Files

```bash
# View .env (never print to terminal in production without need)
ssh user@host "cat /srv/app/.env"

# Check if a specific key exists without showing its value
ssh user@host "grep -q '^DATABASE_URL=' /srv/app/.env && echo 'set' || echo 'missing'"

# List only the keys (not values) — safer for sharing
ssh user@host "grep -o '^[^=]*' /srv/app/.env"
```

## Updating Environment Variables

**For .env files:**
```bash
# Add or update a single key (safe — uses sed to replace if exists, appends if not)
ssh user@host "grep -q '^LOG_LEVEL=' /srv/app/.env \
  && sed -i 's/^LOG_LEVEL=.*/LOG_LEVEL=debug/' /srv/app/.env \
  || echo 'LOG_LEVEL=debug' >> /srv/app/.env"
```

**For systemd EnvironmentFile:**
```bash
# Same pattern — edit the environment file, then reload
ssh user@host "sudo sed -i 's/^NODE_ENV=.*/NODE_ENV=production/' /etc/myapp/env"
ssh user@host "sudo systemctl daemon-reload && sudo systemctl restart myapp"
```

**For systemd Environment= directives directly:**
```bash
# Use systemctl set-environment (session-only, not persistent)
ssh user@host "sudo systemctl set-environment MY_VAR=value"

# For persistent changes, edit the unit file:
ssh user@host "sudo systemctl edit myapp"
# Then add under [Service]: Environment="MY_VAR=value"
ssh user@host "sudo systemctl daemon-reload && sudo systemctl restart myapp"
```

## Comparing Environments

To diff staging vs production env (keys only, not values):
```bash
# Get sorted key lists
ssh user@staging.example.com "grep -o '^[^=]*' /srv/app/.env | sort" > /tmp/staging-keys.txt
ssh user@prod.example.com "grep -o '^[^=]*' /srv/app/.env | sort" > /tmp/prod-keys.txt
diff /tmp/staging-keys.txt /tmp/prod-keys.txt
```

## Security Guidelines

- **Never print secret values** to terminal output that could be captured in logs or shell history
- **Never store secrets in shell history** — use file editing over `echo VAR=secret >> .env`
- **Prefer secrets managers** (AWS SSM Parameter Store, HashiCorp Vault, Doppler) for production secrets over .env files
- **Limit .env file permissions**: `chmod 600 /srv/app/.env` — readable only by the app user
- **After any env change**, restart or reload the service to apply it, then verify the change took effect
