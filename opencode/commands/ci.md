---
description: Check CloudBees CI build status and logs for current branch
agent: build
---

Check the CI build status for my current branch.

Current branch: !`git branch --show-current`
Repository: !`basename $(git remote get-url origin) .git`

Use the ci-status skill to:
1. Find the component for this repository
2. Get the latest workflow runs for this branch
3. Show me:
   - Current build status (passing/failing/in progress)
   - If failed: which step failed and the relevant error logs
   - Recent run history
4. If the build is failing, suggest what might need to be fixed
