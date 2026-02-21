---
name: aws-sso-reauth
description: Detect expired AWS SSO credentials and re-authenticate by running aws sso login --sso-session cb
license: MIT
compatibility: opencode
metadata:
  tools: bash, pty_spawn
  workflow: aws
---

## Purpose

Detect expired AWS SSO session credentials and re-authenticate via `aws sso login --sso-session cb`.

## When to Use

Use this skill when:
- An AWS CLI command fails with `ExpiredTokenException`, `UnauthorizedSSOTokenError`, or `Token has expired`
- User says "my AWS creds expired" or "sso login"
- Any tool or command returns an AWS auth/token error
- Before running AWS-dependent operations when session may have lapsed

## Instructions

1. Check if the current SSO session is valid:
   ```bash
   aws sts get-caller-identity --profile cb-bedrock 2>&1
   ```

2. If the output contains an error (e.g., `ExpiredToken`, `UnauthorizedSSOTokenError`, `The SSO session associated with this profile has expired`), credentials are expired. Proceed to step 3.

   If it returns valid JSON with `Account`, `UserId`, `Arn` -- credentials are still valid. Inform the user and stop.

3. Re-authenticate by spawning an interactive SSO login:
   ```bash
   aws sso login --sso-session cb
   ```
   This opens a browser for device authorization. Use `pty_spawn` so the process can run in the background while the user completes browser auth.

4. After login completes, verify credentials are refreshed:
   ```bash
   aws sts get-caller-identity --profile cb-bedrock 2>&1
   ```

5. Report the result:
   - Success: show the authenticated identity (account, role)
   - Failure: show the error and suggest the user manually run `ssologin` in their terminal

## AWS SSO Configuration Reference

- SSO session name: `cb`
- SSO start URL: `https://cloudbees.awsapps.com/start`
- SSO region: `us-east-1`
- Primary profile: `cb-bedrock` (account 205941181069, role infra-bedrock-claude-user)
- Other profiles sharing this session: `labs-dev`, `innovation`, `qa`, `preprod`, `bedrock-exp`

## Error Patterns to Match

Any of these in stderr/stdout indicate expired credentials:
- `ExpiredTokenException`
- `UnauthorizedSSOTokenError`
- `Token has expired`
- `SSO session associated with this profile has expired`
- `Error loading SSO Token`

## Output Format

- State whether credentials are valid or expired
- If re-authenticated: show the identity (account + role ARN)
- If failed: show the error and suggest running `ssologin` manually in a terminal with browser access
