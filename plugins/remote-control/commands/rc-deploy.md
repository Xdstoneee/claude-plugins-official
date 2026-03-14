---
description: Deploy the current project to a remote environment (staging or production)
argument-hint: <environment> [branch]
allowed-tools: [Bash, Read, Glob]
---

# Remote Deploy

Deploy the current project to a target environment.

## Arguments

The user provided: $ARGUMENTS

Parse the arguments as:
- First argument: `environment` — target environment name (e.g., `staging`, `production`, `prod`)
- Second argument: `branch` (optional) — git branch to deploy (defaults to current branch)

## Instructions

1. **Identify current branch** if not specified:
   ```bash
   git rev-parse --abbrev-ref HEAD
   ```

2. **Look for deploy configuration** — check for these files in order:
   - `.deploy.json` or `deploy.json`
   - `Makefile` targets named `deploy-<environment>`
   - `package.json` scripts named `deploy:<environment>` or `deploy-<environment>`
   - `Procfile` or `fly.toml` (Fly.io)
   - `render.yaml` (Render)
   - `.github/workflows/deploy*.yml`

3. **Confirm before deploying to production** — if environment is `prod` or `production`, always ask for explicit confirmation showing:
   - Target environment
   - Branch being deployed
   - Any detected deploy command

4. **Execute the deploy** using the detected mechanism, or guide the user if no deploy config is found

5. **Report outcome** — show deployment logs and final status

## Safety Notes

- Always confirm production deployments
- Show the user exactly what command will be run before executing
- If deploying from an uncommitted or dirty working tree, warn the user
