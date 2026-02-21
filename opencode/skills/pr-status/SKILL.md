---
name: pr-status
description: Check GitHub PR status, comments, and review feedback for the current branch
license: MIT
compatibility: opencode
metadata:
  tools: github_pull_request_read, github_list_pull_requests, github_search_pull_requests
  workflow: github
---

## Purpose

Check the status of a GitHub Pull Request including:
- PR details (title, description, state)
- Review comments and feedback from reviewers
- General PR comments
- Review status (approved, changes requested, pending)

## When to Use

Use this skill when:
- User asks about PR status, comments, or reviews
- User wants to see feedback on their PR
- User asks "what comments are on my PR"
- User wants to check if their PR is approved

## Instructions

1. First, determine the current branch using git:
   ```
   git branch --show-current
   ```

2. Extract the repository owner and name from the git remote:
   ```
   git remote get-url origin
   ```
   Parse this to get owner (e.g., "cloudbees") and repo (e.g., "aifr-core")

3. Search for PRs with the current branch as head:
   - Use `github_search_pull_requests` with query `head:<branch-name> is:open`
   - Or use `github_list_pull_requests` filtered by head branch

4. For each PR found, retrieve:
   - PR details using `github_pull_request_read` with method `get`
   - Review comments using `github_pull_request_read` with method `get_review_comments`
   - General comments using `github_pull_request_read` with method `get_comments`
   - Reviews using `github_pull_request_read` with method `get_reviews`

5. Present a summary including:
   - PR title and URL
   - Current state (open/closed/merged)
   - Review status (approved/changes requested/pending)
   - List of review comments with file locations
   - Any action items or requested changes

## Output Format

Present the information in a clear, structured format:
- Start with PR overview (title, state, URL)
- Show review status summary
- List comments grouped by file/location
- Highlight any action items or requested changes
