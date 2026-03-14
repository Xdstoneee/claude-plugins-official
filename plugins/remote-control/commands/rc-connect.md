---
description: Connect to a remote host and open an interactive SSH session or run a diagnostic check
argument-hint: <user@host> [port]
allowed-tools: [Bash, Read]
---

# Remote Connect

Connect to a remote host via SSH and verify connectivity.

## Arguments

The user provided: $ARGUMENTS

Parse the arguments as:
- First argument: `user@host` (required) — SSH target in standard format
- Second argument: `port` (optional, default 22)

## Instructions

1. **Validate arguments** — ensure `user@host` is provided; if missing, ask the user
2. **Test connectivity** — run a quick SSH connectivity check:
   ```bash
   ssh -o ConnectTimeout=5 -o BatchMode=yes -p <port> <user@host> "echo connected" 2>&1
   ```
3. **Report status** — clearly indicate success or failure with any relevant error details
4. **On success** — show basic host info:
   ```bash
   ssh -p <port> <user@host> "uname -a && uptime && df -h /"
   ```
5. **On failure** — diagnose the issue: DNS resolution, port reachability, key authentication, etc.

## Safety Notes

- Never prompt for or store passwords; rely on SSH key authentication
- Do not expose private key paths in output
- Warn the user if connecting as root
