# Secret Handling

This machine's dotfiles repo (`~/dotfiles`, github.com/xeaser/dotfiles) is
PUBLIC. Treat every commit as published.

- ALWAYS reference secrets indirectly: `{env:VAR}` in OpenCode config,
  `$VAR` in shell, or a value sourced from `~/.secrets` (mode 600, gitignored).
  Add the variable name with a placeholder to `~/dotfiles/.secrets.example`.
- ALWAYS stop and tell the user when you see a literal token, key, password,
  or private key in a tracked file, diff, or command output. Do not copy it
  elsewhere, echo it, or include it in summaries or commit messages.
- ALWAYS treat a secret that reached a commit (even if later removed) as
  leaked: tell the user it must be rotated. Removing it in a new commit does
  not remove it from history.
- ALWAYS let the git hooks run. Global hooks (`~/.git-hooks`) run gitleaks on
  pre-commit and pre-push. If a scan fails, fix the content; never bypass with
  `--no-verify` or `GITLEAKS_SKIP`. For a genuine false positive, ask the user.
- NEVER read `~/.secrets`, `.env` files, or print environment variables that
  hold credentials. Check whether a variable is set with `[ -n "$VAR" ]`.
