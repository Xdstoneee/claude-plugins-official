# Remote Control Plugin

Execute commands on remote hosts, manage SSH connections, and control deployments across environments directly from Claude Code.

## Features

- **SSH connectivity checks** — verify you can reach a host before trying to work on it
- **Remote command execution** — run single commands on remote machines with safety guardrails
- **Deployment automation** — deploy your project to staging or production with auto-detection of common deploy configs
- **Safety hooks** — warns before executing destructive remote commands
- **Remote ops skill** — Claude automatically applies best practices when helping with remote infrastructure tasks

## Installation

```
/plugin install remote-control@claude-code-marketplace
```

## Commands

### `/rc-connect <user@host> [port]`

Verify SSH connectivity to a remote host and display basic system information.

```
/rc-connect deploy@staging.example.com
/rc-connect admin@192.168.1.10 2222
```

### `/rc-run <user@host> <command>`

Execute a single command on a remote host and display the output.

```
/rc-run deploy@prod.example.com "systemctl status nginx"
/rc-run ubuntu@api.example.com "tail -100 /var/log/app/error.log"
```

### `/rc-deploy <environment> [branch]`

Deploy the current project to a target environment. Auto-detects Makefile targets, npm scripts, fly.toml, render.yaml, and GitHub Actions workflows.

```
/rc-deploy staging
/rc-deploy production main
```

## Safety

- Production deployments always require explicit confirmation
- Destructive remote commands (rm -rf, DROP TABLE, reboot, etc.) trigger a warning hook
- All SSH commands use `BatchMode=yes` to prevent interactive password prompts
- Commands are shown to the user before execution

## Requirements

- SSH key pair configured for target hosts
- SSH agent running locally (`ssh-agent`) or keys loaded in `~/.ssh/`
