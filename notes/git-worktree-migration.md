# Git Worktree Migration Guide

How to move git worktrees to a new location and fix all tool references (OpenCode sessions, Superset).

---

## 1. Physical Worktree Move

### Steps

```bash
# 1. Copy the worktree to new location
cp -R ~/.superset/worktrees/<repo>/<name> /Volumes/Work/<org>/<repo>-worktree/<name>

# 2. Fix the gitdir pointer in the MAIN repo
#    The main repo tracks worktrees in .git/worktrees/<name>/gitdir
#    Update it to point to the new .git file location
cat /Volumes/Work/<org>/<repo>/.git/worktrees/<name>/gitdir
# Shows old path - update it:
echo "/Volumes/Work/<org>/<repo>-worktree/<name>/.git" > /Volumes/Work/<org>/<repo>/.git/worktrees/<name>/gitdir

# 3. Fix the .git file inside the worktree itself
#    Each worktree has a .git FILE (not directory) pointing back to main repo
cat /Volumes/Work/<org>/<repo>-worktree/<name>/.git
# Should already point to main repo's .git/worktrees/<name>
# Usually doesn't need changing if main repo didn't move

# 4. Verify
cd /Volumes/Work/<org>/<repo>-worktree/<name>
git branch --show-current  # Should show the correct branch

# 5. Remove old worktree directory
rm -rf ~/.superset/worktrees/<repo>/<name>
```

### Key Files

| File | Location | Purpose |
|------|----------|---------|
| `gitdir` | `<main-repo>/.git/worktrees/<name>/gitdir` | Main repo's pointer TO the worktree's `.git` file |
| `.git` (file) | `<worktree>/.git` | Worktree's pointer BACK to `<main-repo>/.git/worktrees/<name>` |
| `HEAD` | `<main-repo>/.git/worktrees/<name>/HEAD` | Tracks which branch the worktree has checked out |

### Gotchas

- The worktree's `.git` is a **file**, not a directory. It contains a single line: `gitdir: /path/to/main/.git/worktrees/<name>`.
- If the main repo also moved, you need to update BOTH the `gitdir` file AND the worktree's `.git` file.
- `git worktree list` (run from main repo) will show the updated paths after fixing `gitdir`.

---

## 2. OpenCode Session Migration

OpenCode stores sessions in a SQLite database. After moving worktrees, session paths must be updated or sessions won't appear for the worktree.

### Database Location

```
~/.local/share/opencode/opencode.db
```

### Relevant Tables

| Table | Key Column | What to Update |
|-------|-----------|----------------|
| `session` | `directory` | Path to the worktree where session was created |
| `workspace` | `directory` | FK to project (rarely has worktree-specific entries) |
| `project` | `worktree` | Project-level path (usually the main repo, not individual worktrees) |

### Update Sessions

```bash
# Check which sessions reference old paths
sqlite3 ~/.local/share/opencode/opencode.db \
  "SELECT id, directory FROM session WHERE directory LIKE '%OLD_PATH_PATTERN%';"

# Update to new path
sqlite3 ~/.local/share/opencode/opencode.db \
  "UPDATE session SET directory = '/new/path/to/worktree' WHERE directory = '/old/path/to/worktree';"

# Verify
sqlite3 ~/.local/share/opencode/opencode.db \
  "SELECT id, directory FROM session WHERE directory = '/new/path/to/worktree';"
```

### Notes

- Sessions with `parent_id` (subagent sessions) are updated by the same WHERE clause since they share the same `directory` value as their parent.
- The `workspace` table may have no entries for worktrees (all worktrees may share the main repo's project entry).
- Session files are also in `~/.local/share/opencode/storage/message/ses_*` but those are keyed by session ID, not path. The SQLite `directory` column is what maps sessions to worktrees.

---

## 3. Superset Database Migration

Superset tracks worktrees in two SQLite databases.

### Database Locations

| Database | Path | Purpose |
|----------|------|---------|
| `local.db` | `~/.superset/local.db` | Worktree and project definitions |
| `host.db` | `~/.superset/host/<device-id>/host.db` | Workspace state per device |

Device ID: check `~/.superset/host/` for the UUID directory name.

### local.db - Tables

**`worktrees` table:**
```
id, project_id, path, branch, base_branch, created_at, git_status, github_status, created_by_superset
```

**`projects` table:**
```
id, ..., worktree_base_dir, ...
```

### Update Worktree Paths

```bash
# Check current entries
sqlite3 ~/.superset/local.db \
  "SELECT id, path, branch FROM worktrees WHERE path LIKE '%OLD_PATTERN%';"

# Update path
sqlite3 ~/.superset/local.db \
  "UPDATE worktrees SET path = '/new/path' WHERE id = '<worktree-id>';"

# If worktree was "hidden" in Superset UI (not deleted), it creates a ghost entry
# that blocks re-import at the new location. Delete the stale row:
sqlite3 ~/.superset/local.db \
  "DELETE FROM worktrees WHERE id = '<stale-id>';"
```

### host.db - Tables

**`workspaces` table:**
```
id, project_id, worktree_path, branch, created_at, head_sha, pull_request_id
```

Check for stale entries:
```bash
sqlite3 ~/.superset/host/<device-id>/host.db \
  "SELECT id, worktree_path FROM workspaces WHERE worktree_path LIKE '%OLD_PATTERN%';"
```

### Gotchas

- **Hidden vs Deleted**: If you "hide" a worktree in Superset UI, the DB row remains. This prevents importing the same worktree at a new path. You must DELETE the row.
- **Duplicate entries**: If you re-import a worktree at the new location before cleaning up the old DB entry, you get duplicates. Delete the stale one (check `path` to identify which is which).
- **Project worktree_base_dir**: The `projects` table has a `worktree_base_dir` column. If you're changing the base directory for all worktrees of a project, update this too.

---

## 4. Verification Checklist

After migration, verify each worktree:

```bash
# 1. Git works
cd /new/worktree/path
git branch --show-current
git status

# 2. Main repo sees it
cd /main/repo
git worktree list

# 3. OpenCode sessions visible
# Open the worktree in OpenCode, check session history

# 4. Superset recognizes it
# Open Superset, check the worktree appears under the project
```

---

## 5. Quick Reference: Migration Performed (April 2025)

Migrated FROM `~/.superset/worktrees/<repo>/<name>` TO `/Volumes/Work/<org>/<repo>-worktree/<name>`:

| Main Repo | Worktrees Moved | New Base Dir |
|-----------|----------------|--------------|
| unify-assistant-backend | pentestq, pr, gr, UNIFYAI-741 | `/Volumes/Work/UnifyAI/unify-assistant-backend-worktree/` |
| agentic-swe-endpoint | opencode | `/Volumes/Work/Agentic/agentic-swe-endpoint-worktree/` |
| aifr-core | biforst, dd, pr | `/Volumes/Work/AIFR/aifr-core-worktree/` |
| unify-trajectory-endpoint | pr | `/Volumes/Work/UnifyAI/unify-trajectory-endpoint-worktree/` |

**Not migrated**: `short-sessions` worktrees (stayed at `~/.superset/worktrees/short-sessions/`).
