# CLAUDE.md — Claude Code Plugins Official Repository

This file provides guidance for AI assistants working in this repository.

## Repository Purpose

This is the **official Claude Code plugins marketplace** maintained by Anthropic. It serves as:
- A curated registry of plugins for Claude Code (`marketplace.json`)
- Reference implementations for plugin development (internal plugins)
- Third-party partner integrations (external plugins)
- Development standards and validation tooling

External contributions are **not accepted** — PRs from non-collaborators are auto-closed by CI.

---

## Repository Structure

```
claude-plugins-official/
├── .claude-plugin/
│   └── marketplace.json          # Central registry (~950 lines, 95+ plugins)
├── .github/
│   ├── workflows/
│   │   ├── close-external-prs.yml
│   │   └── validate-frontmatter.yml
│   └── scripts/
│       └── validate-frontmatter.ts
├── plugins/                      # Internal Anthropic plugins (30 plugins)
│   ├── example-plugin/           # Reference implementation — read this first
│   ├── feature-dev/
│   ├── plugin-dev/
│   ├── code-review/
│   ├── commit-commands/
│   ├── *-lsp/                    # 12 language server plugins
│   └── ...
├── external_plugins/             # Third-party integrations (13 plugins)
│   ├── github/, gitlab/, slack/, asana/, stripe/
│   ├── firebase/, supabase/, playwright/
│   └── ...
└── README.md
```

---

## Plugin Architecture

Every plugin follows this standard directory structure:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json               # Required: plugin metadata
├── .mcp.json                     # Optional: MCP server definitions
├── commands/                     # Slash commands (*.md)
├── agents/                       # Autonomous agents (*.md)
├── skills/
│   └── skill-name/
│       └── SKILL.md              # Skill definitions
├── hooks/
│   └── hooks.json                # Event-driven hooks
└── README.md
```

Claude Code auto-discovers all components from these standard directories — no explicit registration needed beyond `marketplace.json`.

---

## File Format Conventions

### Plugin Metadata (`.claude-plugin/plugin.json`)
```json
{
  "name": "plugin-name",
  "description": "One-line description",
  "author": { "name": "Anthropic", "email": "support@anthropic.com" }
}
```

### Commands (`commands/*.md`)
```yaml
---
description: Short description shown in /help
argument-hint: <required-arg> [optional-arg]
allowed-tools: [Read, Glob, Grep, Bash]
---
Command body (system prompt / instructions)
```

### Skills (`skills/{name}/SKILL.md`)
```yaml
---
name: skill-name
description: Trigger condition — when/why Claude should invoke this
version: 1.0.0
---
Skill instructions
```

### Agents (`agents/*.md`)
```yaml
---
name: agent-name
description: Specific conditions that trigger this agent
model: claude-opus-4-6        # optional override
color: purple                  # optional
tools: [Read, Glob, Bash]      # allowed tools
---
Agent system prompt
```

### Hooks (`hooks/hooks.json`)
```json
{
  "description": "Purpose",
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/script.sh" }
        ]
      }
    ]
  }
}
```

Always use `${CLAUDE_PLUGIN_ROOT}` for portable paths within hooks.

### MCP Servers (`.mcp.json`)
```json
{
  "server-name": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@package/mcp-server"],
    "env": { "API_KEY": "${API_KEY}" }
  }
}
```

Use environment variables for credentials — never hardcode secrets.

---

## Marketplace Registry

When adding a new plugin to the marketplace, add an entry to `.claude-plugin/marketplace.json`:

```json
{
  "name": "plugin-name",
  "description": "User-facing description",
  "version": "1.0.0",
  "author": { "name": "Anthropic", "email": "support@anthropic.com" },
  "category": "development",
  "source": {
    "type": "path",
    "path": "plugins/plugin-name"
  }
}
```

Valid categories: `development`, `productivity`, `security`, `testing`, `database`, `deployment`, `communication`, `integration`.

---

## Validation & CI

### Frontmatter Validation
All PRs touching `agents/*.md`, `skills/*/SKILL.md`, or `commands/*.md` trigger automated frontmatter validation:

```bash
bun .github/scripts/validate-frontmatter.ts
```

- Agents require: `name` and `description` fields
- Skills require: `description` or `when_to_use` field
- Commands require: `description` field

### External PR Gate
The `close-external-prs.yml` workflow auto-closes PRs from authors without write/admin access. This is intentional — only Anthropic team members contribute to this repository.

---

## Key Plugins (Internal)

| Plugin | Purpose |
|--------|---------|
| `example-plugin` | Reference implementation — canonical plugin structure |
| `plugin-dev` | 7 skills covering all aspects of plugin development |
| `feature-dev` | 7-phase feature development workflow with exploration, architecture, and review agents |
| `code-review` | Confidence-scored automated PR review (80+ threshold) |
| `pr-review-toolkit` | Multi-angle PR review (types, tests, error handling, simplification) |
| `commit-commands` | Git workflow slash commands |
| `skill-creator` | Create, evaluate, and benchmark new skills |
| `agent-sdk-dev` | Development kit for Claude Agent SDK applications |
| `security-guidance` | Security reminder hooks that warn about OWASP vulnerabilities |
| `playground` | Single-file interactive HTML explorer generator |
| `*-lsp` | Language server plugins for 12 languages (TS, Python, Go, Rust, etc.) |

---

## Development Workflow

### Adding a New Internal Plugin
1. Create directory under `plugins/new-plugin-name/`
2. Add `.claude-plugin/plugin.json` with metadata
3. Add plugin components (commands, agents, skills, hooks as needed)
4. Add README.md documenting usage
5. Register in `.claude-plugin/marketplace.json`
6. Ensure all markdown frontmatter passes validation (`bun .github/scripts/validate-frontmatter.ts`)

### Adding a New External Plugin
1. Create directory under `external_plugins/service-name/`
2. Follow the same structure as internal plugins
3. Use MCP server integration via `.mcp.json`
4. Register in `.claude-plugin/marketplace.json` with `"type": "path"` source

### Installing Plugins (for users)
```
/plugin install {plugin-name}@claude-code-marketplace
```
Or browse via `/plugin > Discover` in Claude Code.

---

## Code Conventions

- **Portable paths**: Always use `${CLAUDE_PLUGIN_ROOT}` in hooks instead of absolute paths
- **Agent descriptions**: Write specific trigger phrases that clearly distinguish when an agent should activate
- **Skill descriptions**: Describe trigger conditions precisely — vague descriptions cause missed activations
- **Confidence scoring**: For review agents, use explicit confidence thresholds (e.g., 80+) to reduce false positives
- **No hardcoded credentials**: Use environment variables for all secrets in MCP configurations
- **Focused components**: Each skill/agent should have a single, clear responsibility
- **Documentation**: Every plugin must include a README.md with usage examples

## Security Practices

- Never commit API keys, tokens, or credentials
- Use `env` in `.mcp.json` with variable references (`"${VAR_NAME}"`) for sensitive values
- The `security-guidance` plugin provides hooks that warn about common vulnerabilities (XSS, command injection, SQL injection) during file edits
- External PR auto-closure prevents untrusted code injection into the marketplace

---

## Language Server Plugins

The 12 LSP plugins (`*-lsp`) follow an identical structure — refer to `typescript-lsp` as the canonical example. Each configures an MCP server that bridges Claude Code to a language server binary:

```
typescript-lsp/
├── .claude-plugin/plugin.json
├── .mcp.json                 # Defines the LSP MCP server
└── README.md
```

Supported languages: TypeScript, Python (Pyright), Go (gopls), Rust (rust-analyzer), C/C++ (clangd), PHP, Swift, Kotlin, C# (OmniSharp), Java (jdtls), Lua, Ruby.
