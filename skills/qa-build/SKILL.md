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

## Rules

- Ensure the code builds locally before pushing (`npm run build` or equivalent)
- Warn the user if there are uncommitted changes — commit or stash first
- This is a force-push to a shared branch — warn if someone else might be using QA right now
