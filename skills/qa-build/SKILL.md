---
name: qa-build
description: Push the current branch to QA for a staging build. Use when the user says "QA build", "push to QA", "deploy to staging", "test in staging", or "create a QA build".
---

# QA Build

Push the current branch to the `qa` branch to trigger a staging build.

```bash
git push-qa
```

This force-pushes the current branch to `origin/qa`, which triggers the QA pipeline and deploys to staging.

## Scope — widget and component repos only

QA staging builds apply **only** to the widget repos and component repos — currently
`magneto-widgets` (widget) and `quicksilver` (component). Do not run `push-qa` in the
web-server repos or anywhere else.

`push-qa` is a force-push to the protected `qa` branch, which git-guard blocks by
default. The two in-scope repos carry a **local** alias (`.git/config`) that attaches
the human override (`GIT_GUARD_ALLOW=1`); the global alias does not. So `push-qa`
succeeds in those repos and is correctly blocked everywhere else — including for agents.

The override is per-checkout and not version-controlled. After a fresh clone of a
widget/component repo, re-apply it in that repo:

```bash
git config --local alias.push-qa '!GIT_GUARD_ALLOW=1 git push origin `git symbolic-ref --short HEAD`:qa --force'
```

## Rules

- Only in widget/component repos (`magneto-widgets`, `quicksilver`) — never web-servers.
- Ensure the code builds locally before pushing (`npm run build` or equivalent)
- Warn the user if there are uncommitted changes — commit or stash first
- This is a force-push to a shared branch — warn if someone else might be using QA right now
