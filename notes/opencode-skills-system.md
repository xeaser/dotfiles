# OpenCode Skills System

How OpenCode discovers, loads, and prioritizes skills. Covers repo-level skills, worktree support, config hierarchy, and known gotchas.

---

## 1. Skill Placement

Skills are directories containing a `SKILL.md` file. Place them in any of these locations:

| Location | Scope | Example |
|----------|-------|---------|
| `~/.config/opencode/skills/<name>/SKILL.md` | User (global) | Shared across all repos |
| `~/.claude/skills/<name>/SKILL.md` | User (global) | Claude-compatible path |
| `~/.agents/skills/<name>/SKILL.md` | User (global) | Agent-compatible path |
| `<repo>/.opencode/skills/<name>/SKILL.md` | Project | Repo-specific |
| `<repo>/.claude/skills/<name>/SKILL.md` | Project | Claude-compatible, repo-specific |
| `<repo>/.agents/skills/<name>/SKILL.md` | Project | Agent-compatible, repo-specific |
| Paths in `opencode.json` `skills.paths` | Project | Extra directories |

## 2. Discovery Priority (low to high)

Later sources overwrite earlier ones when names collide:

1. Global external: `~/.claude/skills/**`, `~/.agents/skills/**`
2. Project external: `<repo>/.claude/skills/**`, `<repo>/.agents/skills/**`
3. Config dirs: `~/.config/opencode/skills/**` (user), `<repo>/.opencode/skills/**` (project)
4. `skills.paths` from `opencode.json`
5. Cache dirs

## 3. Discovery vs Auto-Injection

Skills are **discovered** (listed in the `skill` tool description) but **NOT auto-injected** into agent context. The agent loads them on demand via `skill({ name: "..." })`.

There is no "auto-inject on folder open" mechanism. If you need guaranteed injection, use `instructions` in `opencode.json` instead.

## 4. Worktree Support

- `findWorktreeRoot()` walks up to `.git` file/directory
- Uses `git rev-parse --git-common-dir` to find the main repo
- Skills placed at the main repo root are visible from all worktrees
- Worktree-local `.opencode/skills/` also works if present in the worktree directory

## 5. Config Hierarchy (low to high)

```
Remote well-known defaults
  -> ~/.config/opencode/config.json
    -> global opencode.jsonc
      -> $OPENCODE_CONFIG (env var, path to file)
        -> project opencode.json/jsonc (walked CWD -> git root)
          -> .opencode/opencode.jsonc
            -> $OPENCODE_CONFIG_CONTENT (env var, raw JSON)
              -> console/org overrides
                -> MDM policies
```

`instructions` arrays are **concatenated** across layers, not replaced.

## 6. Skills Config in opencode.json

```json
{
  "skills": {
    "paths": ["./extra-skills-dir", "/absolute/path/to/skills"],
    "urls": ["https://example.com/skill-bundle.tar.gz"]
  }
}
```

## 7. .opencode/ Directory Structure

```
.opencode/
├── opencode.jsonc       # project config
├── skills/              # project skills (auto-discovered)
├── agent/               # custom agent definitions
├── command/             # custom slash commands
├── plugins/             # auto-discovered plugins (*.ts, *.js)
├── tool/                # custom tools
├── glossary/            # glossary files
└── themes/              # TUI themes
```

Plugins in `.opencode/plugins/` are auto-discovered. Scope (global/local) is inferred from whether the source path is inside a git worktree.

## 8. Known Issues and Gotchas

| Issue | Description |
|-------|-------------|
| [#18848](https://github.com/anomalyco/opencode/issues/18848) | Worktree sandbox bug -- symlinked `.claude/skills` not followed |
| [#20305](https://github.com/anomalyco/opencode/issues/20305) | No path-based auto-activation (`paths:` frontmatter requested) |
| [#25043](https://github.com/anomalyco/opencode/issues/25043) | Cross-repo skill bleed -- repo-specific skills load in wrong repos |
| [#16524](https://github.com/anomalyco/opencode/issues/16524) | Parent dir skills above git root silently ignored |
| [#16457](https://github.com/anomalyco/opencode/issues/16457) | Discovery fails without `.git` directory |
| [#19344](https://github.com/anomalyco/opencode/issues/19344) | Agent-scoped skills (feature request) |
| [#23035](https://github.com/anomalyco/opencode/issues/23035) | Configurable discovery directories (feature request) |

### Practical Implications

- **Symlinks in worktrees**: If you symlink `.claude/skills` into a worktree, discovery may fail (#18848). Copy or use `.opencode/skills/` instead.
- **Multi-repo setups**: Skills from one repo can bleed into another if both are under the same parent (#25043). Keep repos in separate directory trees.
- **No `.git` = no skills**: Projects without a `.git` directory (extracted archives, mounted volumes) won't discover project-level skills (#16457).

## 9. Quick Setup for a New Repo

```bash
# Create repo-level skill
mkdir -p .opencode/skills/my-skill
cat > .opencode/skills/my-skill/SKILL.md << 'EOF'
# My Skill

Instructions for this skill...
EOF

# Verify discovery (in OpenCode session)
# The skill should appear in the skill tool's available list
```

## 10. References

- Source: `packages/core/src/skill/` in OpenCode repo
- Config resolution: `packages/core/src/config/`
- Worktree detection: `packages/core/src/util/git.ts`
