---
name: code-review
description: Review GitHub pull requests with structured analysis, inline comments, and severity-based findings
license: MIT
compatibility: opencode
metadata:
  tools: github_pull_request_read, github_pull_request_review_write, github_add_comment_to_pending_review, github_list_pull_requests, github_search_pull_requests
  workflow: github
---

# Code Review — Universal

Structured pull request review workflow. Language and framework agnostic.

## When to Use

- Reviewing any GitHub PR
- Preparing structured review feedback with inline comments
- Checking code quality, patterns, and conventions before approving

## Phase 1: Gather PR Context

1. Identify the repository:
   ```
   git remote get-url origin
   ```
   Parse owner and repo name.

2. Get the PR number. If not provided, find it from the current branch:
   ```
   git branch --show-current
   ```
   Then use `github_search_pull_requests` with `head:<branch> is:open`.

3. Fetch PR details in parallel:
   - `github_pull_request_read` method=`get` — title, description, base branch, author
   - `github_pull_request_read` method=`get_files` — changed files with patch stats
   - `github_pull_request_read` method=`get_diff` — full diff
   - `github_pull_request_read` method=`get_reviews` — existing reviews
   - `github_pull_request_read` method=`get_review_comments` — existing inline comments
   - `github_pull_request_read` method=`get_check_runs` — CI status

4. Read the full diff carefully. For large PRs, review file-by-file.

## Phase 2: Understand Intent

Before critiquing code, understand what the PR is trying to do:

- Read the PR description and any linked issues/tickets
- Identify the category: feature, bugfix, refactor, dependency update, config change
- For dependency update PRs: focus on breaking changes, lockfile conflicts, and CI status

## Phase 3: Detect Project Conventions

Before applying review rules, discover what conventions the project follows:

1. Check for project-level review guidance:
   - `AGENTS.md`, `CONTRIBUTING.md`, `CODING_STANDARDS.md`, `.github/PULL_REQUEST_TEMPLATE.md`
   - If a repo-specific `code-review` skill exists in `.opencode/skill/`, defer to that skill instead

2. Check for linter/formatter configs:
   - `.eslintrc*`, `.prettierrc*`, `golangci-lint.yml`, `pyproject.toml`, `Makefile` lint targets
   - These define the project's style — don't contradict them

3. Sample 2-3 existing files in the same directory as the changed files:
   - Match naming conventions, error handling patterns, logging style
   - New code should look like it belongs

## Phase 4: Review Checklist

Apply these to every changed file. Skip items that don't apply.

### 4.1 Correctness

- [ ] Logic matches the stated intent (PR description, linked issue)
- [ ] Edge cases handled (nil/null, empty collections, boundary values)
- [ ] Concurrent access is safe (shared state, race conditions)
- [ ] Resource cleanup (file handles, connections, goroutines, event listeners)

### 4.2 Error Handling

- [ ] Errors propagated with context, not swallowed
- [ ] Error messages describe what failed at the current abstraction level
- [ ] No empty catch/error blocks that silently discard failures
- [ ] Error types checked correctly (language-idiomatic: `errors.Is()` in Go, `instanceof` in TS, etc.)

### 4.3 Security

- [ ] No hardcoded secrets, tokens, or credentials
- [ ] User input validated/sanitized before use
- [ ] No sensitive data in logs or error messages
- [ ] Auth/authz checks present where needed

### 4.4 Architecture

- [ ] Layer boundaries respected (e.g., handlers don't query DB directly)
- [ ] Dependency direction correct (higher layers depend on lower, not reverse)
- [ ] New abstractions justified (not premature)
- [ ] Follows existing patterns in the codebase (or justifies deviation)

### 4.5 Testing

- [ ] New behavior has corresponding tests (or justification for omission)
- [ ] Tests verify behavior, not implementation details
- [ ] No tests deleted or skipped to make the build pass
- [ ] Edge cases from 4.1 covered in tests

### 4.6 Readability

- [ ] Names are clear and consistent with codebase conventions
- [ ] Complex logic has explanatory comments for the "why"
- [ ] No dead code, commented-out blocks, or debug leftovers
- [ ] Functions are reasonably sized (single responsibility)

### 4.7 Performance (when applicable)

- [ ] No N+1 queries or unbounded loops over external data
- [ ] Large data sets paginated or streamed
- [ ] Expensive operations not in hot paths without caching consideration

## Phase 5: Submit Review

1. Categorize findings by severity:
   - **BLOCKING**: Must fix before merge (security, data loss, broken logic, architecture violations)
   - **IMPORTANT**: Should fix, creates tech debt if not (convention violations, missing error context)
   - **SUGGESTION**: Nice to have, non-blocking (style, minor improvements, alternative approaches)
   - **QUESTION**: Needs clarification from author

2. Create a pending review:
   - Use `github_pull_request_review_write` method=`create` (without `event` to keep pending)

3. Add inline comments on specific lines:
   - Use `github_add_comment_to_pending_review` for each finding
   - Include the checklist reference (e.g., "4.2 Error Handling")
   - Suggest the fix, don't just point out the problem

4. Submit the review:
   - `APPROVE` — no blocking findings, CI passes
   - `REQUEST_CHANGES` — has blocking findings
   - `COMMENT` — only suggestions/questions

## Output Format

Present findings to the user before submitting:

```
## PR #<number>: <title>
**Author**: <author> | **Files changed**: <count> | **CI**: <pass/fail>

### Summary
<1-2 sentence description of what the PR does>

### Blocking
- [4.2] `path/to/file.ext:42` — Error swallowed silently. Propagate or log with context.

### Important
- [4.4] `path/to/file.ext:18` — Handler queries DB directly, bypassing service layer.

### Suggestions
- [4.6] `path/to/file.ext:55` — Consider extracting this block into a named helper.

### Questions
- `path/to/file.ext:30` — Is this intentional? Different pattern from adjacent code.

### Verdict: APPROVE | REQUEST_CHANGES | COMMENT
```

Wait for user confirmation before submitting the review to GitHub.

## Dependency Update PR Review (Shortcut)

For bot-generated dependency update PRs:
1. Check CI status (`get_check_runs`)
2. Check for lockfile conflicts
3. Review changelog for breaking changes (usually in PR description)
4. If CI passes and no breaking changes: recommend `APPROVE`
5. If CI fails: diagnose before recommending
