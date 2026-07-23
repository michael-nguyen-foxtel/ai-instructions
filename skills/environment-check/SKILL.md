---
name: environment-check
description: Pre-validate toolchain and environment before heavy operations (builds, deploys, installs). Use automatically before running npm install, deploy commands, or AWS operations.
---

# Environment Check

Verify the local environment has what's needed before attempting time-consuming operations.

## When to Fire

Before any of these operations:
- `npm install` / `yarn install`
- Build commands (`npm run build`, `webpack`, `grunt`)
- Deploy operations (FISO deploy, EB deploy)
- AWS CLI calls
- Docker operations

## Checks (run only what's relevant to the operation)

### Node.js
```bash
node --version          # compare against .nvmrc
```
If mismatch: warn but don't block (some operations work regardless).

### npm/Yarn
```bash
npm --version           # verify it exists
```

### AWS CLI
```bash
aws --version
aws sts get-caller-identity --profile <profile>  # verify creds are valid
```
If the profile is expired or invalid: stop and tell the user to refresh credentials.

### Docker / Podman
```bash
podman info             # verify Podman machine is running
```
**Important:** This environment uses Podman, not Docker Desktop. When running shell commands:
- Use `podman` instead of `docker` (CLI is compatible)
- Use `podman-compose` instead of `docker-compose` (or `podman compose`)
- The Docker MCP server still works via Podman's Docker-compatible socket
- Do NOT reference Docker Desktop, Rancher Desktop, or `docker` CLI directly

### Environment Variables
Check for required env vars before operations that need them:
- FISO deploy: `PUSHER_KEY`, `PUSHER_SECRET`
- Custom deploys: whatever the script references

### Git state
```bash
git status --porcelain  # warn about uncommitted changes before builds
```

## Behaviour

1. Determine which checks are relevant based on what's about to happen
2. Run them quickly (< 5 seconds total)
3. If everything passes: proceed silently (don't report success for every check)
4. If something fails: report clearly what's wrong and how to fix it, then STOP

## Output (only on failure)

```
⚠️ Environment check failed:
- Node: expected 9.4.0 (.nvmrc), got 20.19.4 → run `nvm use`
- AWS: profile foxsports-web-powerdev expired → run `aws sso login --profile ...`

Fix these before proceeding.
```

## Rules

- Don't run checks for things that aren't about to be used
- Don't block on warnings (version mismatches) — only block on hard failures (missing tools, expired creds)
- Don't re-run checks if they passed earlier in the same session (unless the user switched directories)
- Keep it fast — these are guards, not diagnostics
