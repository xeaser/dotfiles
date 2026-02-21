# opencode

[opencode](https://opencode.ai/) is an AI coding assistant that runs in the terminal, with support for MCP servers, custom skills, commands, and agent model routing.

## Tracked Files

| File | Purpose |
|------|---------|
| `opencode.jsonc` | Main config: plugins, MCP server definitions, provider settings. **Sanitized** -- replace `YOUR_PASSWORD` and `YOUR_ORG_ID` placeholders with real values. |
| `ocx.jsonc` | OCX extension manager config and registry settings |
| `oh-my-opencode.json` | Agent model routing -- maps each agent (sisyphus, oracle, explore, etc.) and task category to a specific model and variant |
| `dcp.jsonc` | Dynamic Context Pruning plugin config |
| `package.json` | Plugin dependencies managed by bun/npm |

## Directories

### commands/

Slash commands that can be invoked during a session:

| Command | Description |
|---------|-------------|
| `ci.md` | `/ci` -- Check CloudBees CI build status and logs for current branch |
| `pr.md` | `/pr` -- Check GitHub PR status, comments, and reviews for current branch |

### skills/

Reusable skill definitions that agents can invoke:

| Skill | Description |
|-------|-------------|
| `aws-sso-reauth/` | Detect expired AWS SSO credentials and re-authenticate |
| `ci-status/` | Check CloudBees CI workflow status, build results, and logs |
| `pr-status/` | Check GitHub PR status, comments, and review feedback |

### profiles/default/

Default profile with OCX exclusion patterns and per-profile opencode overrides.

## Excluded Directories

These are **not tracked** in dotfiles and must be installed separately:

| Directory | Reason | How to Install |
|-----------|--------|----------------|
| `plugin/` | Contains git submodules, compiled JS, node_modules (e.g., oh-my-opencode, shell-strategy) | Plugins are declared in `opencode.jsonc` under `"plugin"` and auto-installed by opencode on first run |
| `mcp/` | Contains compiled MCP server JS and node_modules | Built/installed per-machine as needed |
| `node_modules/` | Dependency artifacts | Run `bun install` or `npm install` in `~/.config/opencode/` |

## Setup on a New Machine

1. Run `install.sh` to symlink config files and directories to `~/.config/opencode/`.
2. Edit `~/.config/opencode/opencode.jsonc`:
   - Replace `YOUR_PASSWORD` with your database password
   - Replace `YOUR_ORG_ID` with your CloudBees organization ID
   - Adjust MCP server URLs/paths as needed
3. Install plugin dependencies:
   ```bash
   cd ~/.config/opencode && bun install
   ```
4. Launch opencode -- plugins listed in `opencode.jsonc` will be auto-installed on first run.
5. For the shell-strategy plugin, clone it into `~/.config/opencode/plugin/`:
   ```bash
   mkdir -p ~/.config/opencode/plugin
   git clone <shell-strategy-repo> ~/.config/opencode/plugin/shell-strategy
   ```
