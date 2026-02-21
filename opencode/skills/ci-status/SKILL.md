---
name: ci-status
description: Check CloudBees CI workflow status, build results, and logs for the current branch
license: MIT
compatibility: opencode
metadata:
  tools: unify_runs_list, unify_workflow_list, unify_logs_list, unify_components_search
  workflow: cloudbees
---

## Purpose

Check CloudBees CI/CD pipeline status including:
- Workflow run status (success, failed, in progress)
- Build logs for failed jobs
- Recent run history
- Job-level details

## When to Use

Use this skill when:
- User asks about CI status or build status
- User wants to see why a build failed
- User asks "is my build passing"
- User wants to check CI logs
- User mentions CloudBees, workflows, or pipelines

## Instructions

1. First, determine the current branch using git:
   ```
   git branch --show-current
   ```

2. Identify the component by searching for it based on the repository:
   - Extract repo name from `git remote get-url origin`
   - Use `unify_components_search` with the repo name (e.g., "aifr-core")
   - This returns componentId, organizationId, and subOrganizationId

3. List workflows for the component:
   - Use `unify_workflow_list` with organizationId and componentId
   - This shows available workflows/automations

4. List recent runs:
   - Use `unify_runs_list` with subOrganizationId and componentId
   - Filter or sort by the current branch if possible
   - Get the most recent runs

5. For failed runs, get detailed logs:
   - Use `unify_logs_list` with componentId, runId, runAttempt, jobName, and stepId
   - Focus on failed steps to show relevant error information

6. Present a summary including:
   - Current branch and component
   - Most recent run status
   - If failed: which job/step failed and relevant log excerpt
   - Link to the run in CloudBees UI if available

## Known Components

For quick reference, here are known component mappings:
- `aifr-core` repository:
  - componentId: e1d1b9e7-0ec4-4ad5-935b-27f4a6fe99fe
  - organizationId: 0bf1ea4f-2aca-4be2-9339-86287204e6c5
  - subOrganizationId: 0bf1ea4f-2aca-4be2-9339-86287204e6c5

## Output Format

Present the information in a clear, structured format:
- Start with branch and latest run status
- Show run duration and timestamp
- For failures: show the failed step and key error messages
- List any recent runs with their status
- Provide actionable next steps if build is failing
