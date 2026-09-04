---
name: cicd-conventions
description: CI/CD and infrastructure conventions. Use when working on GitHub Actions workflows, AWS infrastructure, deployment configs, Jenkinsfiles, or observability (New Relic, Coralogix).
---

# CI/CD & Infrastructure Conventions

## GitHub Actions

- **Pin third-party actions to SHA** — never tags. Tags are mutable, so a compromised or force-moved tag on an untrusted publisher runs arbitrary code with your secrets in scope. `uses: some-org/some-action@<sha> # v1.2.3` (keep the version in a trailing comment).
- **First-party actions may use tags** — `actions/*` (and `github/*`) are GitHub-controlled and low supply-chain risk; `uses: actions/checkout@v5` is fine. SHA-pinning them is optional, not required.
- **Keep first-party action majors current** — old majors run on Node runtimes GitHub removes from runners (e.g. `checkout@v3`/`setup-node@v3` are on the deprecated Node 16; the current runtime is Node 24). Bump the major even though you don't SHA-pin, or the workflow throws deprecation warnings and eventually breaks. `checkout@v5` requires Actions Runner ≥ v2.327.1 (guaranteed on GitHub-hosted `ubuntu-latest`; verify for self-hosted).
- **Include `timeout-minutes`** on all jobs
- **Include `concurrency`** controls to prevent parallel runs on the same branch
- **Never hardcode environment values** — use secrets or vars
- **Cache keys** must include the lockfile hash
- **Shared workflows** live in `fsa-streamotion/streamotion-web-github-workflows`

### Anti-patterns to flag

- Third-party actions pinned to tags instead of SHAs (first-party `actions/*` tags are fine)
- First-party action majors left on a deprecated Node runtime (e.g. `@v3` on Node 16)
- Missing concurrency controls
- Secrets referenced but not configured in repo settings
- Missing timeout-minutes
- Hardcoded env values that should be secrets/vars
- Overly broad cache keys (cache poisoning risk)
- No artifact retention policy
- Shared workflow versions pinned to a branch name instead of a release tag
- Docker steps missing `GITHUB_TOKEN` env (breaks auth to GitHub Container Registry / Packages)
- Feature detection that requires install (e.g., `pnpm run | grep`) — use `node -e` to read package.json directly
- Scripts named for a tool they no longer use (e.g., `test:jest` running Vitest) — can't rename if shared workflows call by name, but flag as tech debt

## AWS

- **Profile**: `foxsports-web-powerdev-185314292360` for most operations
- **Regions**: `ap-southeast-2` (AU staging/prod), `ap-southeast-1` (international staging), `us-east-1` (international prod)
- **Services used**: ElasticBeanstalk, S3, CloudFront
- Always verify credentials before operations: `aws sts get-caller-identity --profile <profile>`

## Observability

- **New Relic**: available via MCP (currently disabled) — for APM queries
- **Coralogix**: log aggregation — query via their API or dashboard
- When debugging production issues, check both application logs (Coralogix) and APM (New Relic)

## General Rules

- Always provide complete, copy-pasteable YAML snippets (partial YAML breaks things)
- Include a rollback strategy for risky changes
- Flag security concerns with ⚠️
- Test workflow changes on a feature branch first — never push untested workflows to main
