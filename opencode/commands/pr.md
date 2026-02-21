---
description: Check GitHub PR status, comments, and reviews for current branch
agent: build
---

Check the PR status for my current branch.

Current branch: !`git branch --show-current`
Repository: !`git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/'`

Use the pr-status skill to:
1. Find any open PRs for this branch
2. Show me:
   - PR title, state, and URL
   - Review status (approved/changes requested/pending)
   - Any review comments or feedback
   - General comments on the PR
3. Highlight any action items I need to address
