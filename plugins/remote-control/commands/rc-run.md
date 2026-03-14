---
description: Run a command on a remote host via SSH and return the output
argument-hint: <user@host> <command>
allowed-tools: [Bash]
---

# Remote Run

Execute a shell command on a remote host and display the output.

## Arguments

The user provided: $ARGUMENTS

Parse the arguments as:
- First token: `user@host` — SSH target
- Remaining tokens: the command to run remotely

Example: `rc-run deploy@prod.example.com "systemctl status nginx"`

## Instructions

1. **Validate** — ensure both `user@host` and a command are provided; if either is missing, ask the user
2. **Confirm destructive commands** — if the command contains `rm`, `drop`, `truncate`, `kill -9`, `reboot`, `shutdown`, or `format`, ask for explicit confirmation before proceeding
3. **Execute**:
   ```bash
   ssh -o ConnectTimeout=10 -o BatchMode=yes <user@host> '<command>'
   ```
4. **Display output** — show stdout and stderr clearly labeled
5. **Report exit code** — if non-zero, explain what likely went wrong

## Safety Notes

- Always use `BatchMode=yes` to prevent interactive prompts
- Never construct SSH commands from unsanitized user input without review
- Warn before running commands that modify system state on production hosts
