---
name: build-verify
description: After making code changes, run the project's build and tests to verify correctness before presenting the result. Self-correct if failures are found. Use automatically after any code modification.
---

# Build-Verify Loop

After making code changes, verify they work before presenting the result. Self-correct up to 3 times. If still failing after 3 attempts, stop and explain what's wrong rather than looping forever.

## The Loop

```
Make change → Format → Lint → Test → Pass? → Done
                                       ↓ Fail
                              Diagnose → Fix → Test → Pass? → Done
                                                         ↓ Fail (attempt 2)
                                                Fix → Test → Pass? → Done
                                                                 ↓ Fail (attempt 3)
                                                        STOP. Report what's failing and why.
```

## Rules

1. **Always run verification after code changes.** Don't present "done" without evidence.
2. **Format first.** Run the project's formatter on changed files before linting. Detect from the repo:
   - If `prettier` is a dependency or `.prettierrc` exists → `npx prettier --write <changed files>`
   - If `eslint --fix` is available → `npm run lint -- --fix` or `npm run lint-js -- --fix`
   - If `.editorconfig` exists and no prettier → rely on the lint step (eslint enforces formatting rules)
   - Run on changed files only, not the entire repo
3. **Run the right commands for the repo.** Check package.json scripts. Common patterns:
   - `npm run lint` or `npm run lint-js`
   - `npm test` (may be in a subdirectory like `node-app/`)
   - `npm run build` (only if relevant to the change)
4. **If lint fails:** fix the lint issues yourself. These are mechanical.
5. **If tests fail:** read the failure output. Determine if:
   - The failure is caused by your change → fix it
   - The failure is pre-existing (flaky/unrelated) → note it but don't block on it
6. **Max 3 fix attempts.** After 3 failed corrections, stop and report:
   - What's failing
   - What you tried
   - Your best hypothesis for the root cause
7. **Don't run tests you can't run.** If a test requires Docker, a browser, VPN, or credentials you don't have, skip it and note what was skipped.
8. **Scope verification to the change.** If you touched one file, run that file's tests if possible (e.g. `npm test -- --grep "rate-limiter"`). Full suite only if the change is cross-cutting.

## What to Report on Success

```
✓ Lint passed
✓ Tests passed (X passing, Y skipped)
Changes: [list of files modified]
```

## What to Report on Failure (after 3 attempts)

```
✗ Verification failed after 3 attempts

Failing: [test name or lint rule]
Error: [key error message]
Attempted fixes: [what was tried]
Hypothesis: [why it's still failing]
Suggestion: [what the user should check]
```

## Repo-Specific Commands

Detect from package.json. Common patterns in this org:

| Repo pattern | Lint | Test | Notes |
|---|---|---|---|
| hawk-widgets | `npm run lint-js` | `npm test` (Testem, needs Docker) | Tests may not be runnable locally — skip if Docker unavailable |
| hawk-web-server | `npm run lint` | `npm test` (from `node-app/`) | Mocha + Sinon |
| magneto-widgets | `npm run lint` | `npm run test:jest` | Jest, runnable |
| magneto-web-server | `npm run lint` | `npm test` (from `node-app/`) | Mocha + Nock + Supertest |
| quicksilver | `npm run lint` | `npm run test:jest` | Jest + RTL |
