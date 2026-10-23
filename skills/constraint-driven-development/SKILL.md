---
name: constraint-driven-development
description: Establishes a project's quality bar as a written contract and stops agents quietly lowering it. Interviews for the dimensions that matter, supplies default thresholds when you have no number in mind, records everything in CONSTRAINTS.md at the repo root, and watches the diff for a weakened bar — new eslint-disable or @ts-expect-error suppressions, skipped or deleted tests, assertions stripped out, Fallow findings silenced, thresholds edited down. Use when no quality bar is written down, when you say "set up constraints" or "define our standards", when you want dimensions you care about (accessibility, coverage, dead code, duplication) set up as enforced constraints, when an agent keeps silencing checks to get to green, or when an agent writes more code than anyone will read.
---

# Constraint-Driven Development

## Overview

Other skills describe what good looks like. `code-review` gives you axes. `tdd`
gives you a cycle. `build-verify` gives you a post-change loop. `security-audit`
gives you a checklist. All of it lives in prose the agent reads and may or may not
follow, and none of it survives the end of the session.

This skill produces something different: a written record of **this repo's** bar,
with numbers, that outlives the conversation and can be checked mechanically. An
agent writes more in an afternoon than you will read that week, so the judgement
moves out of your head and into checks that run around the loop. Those checks need
to exist, need numbers you actually chose, and need to fire close enough to the work
that the agent fixes its own output.

`to-spec` says what to build. `tdd` proves it works. Constraint-driven development
defines what "good enough to ship" means, before anyone argues about it in a PR.

## When to Use

- Starting a feature in one of the deep repos (hawk-widgets, hawk-web-server,
  magneto-widgets, magneto-web-server) and no quality bar is written down
- You ask to "set up constraints", "add quality gates", or "stop the agent shipping junk"
- An agent is producing volume nobody is reading line by line
- CI has checks but nobody can say which block a merge and which are decoration
- Coverage or Fallow numbers get argued per-PR instead of decided once
- Before an autonomous or long unattended run where the only thing between it and a
  PR is a test suite the agent also wrote

**When NOT to use:**

- The repo already has a `CONSTRAINTS.md` and you aren't changing it — read it and follow it
- One-off scripts, spikes, throwaway prototypes (use `/prototype`)
- You want a review right now (`code-review`) or a pipeline built (`cicd-conventions`)
- A shallow-consume repo you don't own the standards for (quicksilver, streamotion-web-app,
  fiso-server) — follow the repo's existing bar, don't impose one

## Loading Constraints

The interview needs a live user. **Don't run it in non-interactive contexts**
(autonomous runs, CI). If constraints are missing and you're in one of those, apply
the Floor below, note that you did, and flag the rest for a human.

## The Process

### Step 1: Detect before you ask

Never ask what you can read. Before the first question, gather:

| What | Where to look |
|------|---------------|
| Stack | `package.json`, `.nvmrc` |
| Test runner | Jest config, `test` script, existing `*.spec.js` files |
| Lint config | `@fsa-streamotion/streamotion-web-eslint-config` in devDeps, `.eslintrc*` |
| Style lint | `@fsa-streamotion/streamotion-web-stylelint-config` |
| Dead code / complexity / duplication | whether Fallow runs already (`.fallowrc*`, CI step) |
| Coverage today | `coverage/` output, or run the suite once |
| CI | `.github/workflows/` |
| FISO coupling | `FISO_VERSIONS` in `constants.js` (web-server repos) |

Report what you found in two lines, then ask only what's left.

### Step 2: Four questions, each with a default

Follow the one-question-at-a-time discipline from `grilling`, with one change: every
question has a default, so "I don't know" is a complete answer that still produces a
working config.

```
Q1: Beyond the floor, which of these do you want enforced?
    (a) Test coverage on changed lines
    (b) Fallow — dead code, complexity, duplication
    (c) Accessibility (axe, WCAG 2.1 AA)
    (d) Browser-support verification for Web APIs
    (e) Architecture boundaries (Fallow boundary zones)
    DEFAULT if unsure: (a) and (b) — you have Jest already and Fallow is in the toolchain.
    Say what each costs: (c) needs a running URL, (d) is a Context7/caniuse check per API,
    (e) needs boundary zones configured.
```

```
Q2: When a check fails mid-task, should it block or warn?
    DEFAULT if unsure: Block on the floor, warn on everything else for the first two weeks.
```

```
Q3: Target numbers in mind, or measure where you are today and hold that line?
    DEFAULT if unsure: Measure and hold. See "Ratchets" below.
```

```
Q4: Slowest check you'll tolerate before the agent hands work back?
    DEFAULT if unsure: 90 seconds at task end, unlimited in CI.
```

Stop at four. A twelve-question intake produces a config nobody understands.

### Step 3: Write CONSTRAINTS.md

One file at the repo root — **not** under `.kiro/` (gitignored in the widgets repos).
Any agent reads it, and a change to it shows up in review where it belongs.

```markdown
# Constraints

Last reviewed: 2026-10-23 by @nguyenm

## Floor (always enforced, no setup required)

- No new suppression comments: `eslint-disable`, `@ts-expect-error`, `@ts-ignore`, `istanbul ignore`
- No new Fallow suppression comments (`fallow-ignore`) without a reason in the commit message
- No unimplemented stubs: `throw new Error('not implemented')`, empty `catch {}`
- No skipped or deleted tests without a reason in the commit message
- No secrets in source
- This file does not get weakened to make a change pass

## Enforced with numbers

| Dimension | Rule | Checked by | Runs at |
|-----------|------|-----------|---------|
| Lint | Zero errors from our config | `eslint .` | every edit |
| Style | Zero errors | `stylelint '**/*.js'` | every edit |
| Dead code | No new unused exports/files | `fallow analyze` | task end, CI |
| Complexity | No new function over threshold | `fallow check_health` | task end, CI |
| Duplication | No new clone groups | `fallow find_dupes` | task end, CI |
| Coverage | Changed lines >= 80% covered | `jest --coverage` + git diff | task end, CI |
| Accessibility | Zero critical or serious | `axe $PREVIEW_URL --tags wcag2a,wcag2aa,wcag21aa` | QA build |

Every row names the command that produces the verdict. A dimension with a number and
no command is an aspiration, not a constraint.

## Measured, not yet enforced

| Metric | Today | Direction |
|--------|-------|-----------|
| Project coverage | 62.4% | must not fall |
| Bundle size (main) | 184 kB | must not grow |

## Exceptions

| ID | Rule | Path | Reason | Owner | Expires |
|----|------|------|--------|-------|---------|
| W1 | `no-explicit-any` | `src/legacy/**` | Rewrite tracked in WEB-XXXX | @nguyenm | 2026-12-01 |
```

### Step 4: Install what each dimension needs — map to the existing toolchain

Don't invent a checker when the team already runs one. Every dimension maps to a tool
already in the Streamotion stack:

| Dimension | Tool | Run | Gate on |
|-----------|------|-----|---------|
| Lint | `@fsa-streamotion/streamotion-web-eslint-config` | `eslint .` | any error |
| Style | `@fsa-streamotion/streamotion-web-stylelint-config` | `stylelint '**/*.{js,css}'` | any error |
| Coverage | Jest (`@fsa-streamotion/jest-config`) | `jest --coverage` | coverage of changed lines |
| Dead code | Fallow | `fallow analyze` (or the `analyze` MCP tool) | new unused exports/files |
| Complexity | Fallow | `fallow check_health` | new function over threshold |
| Duplication | Fallow | `fallow find_dupes` | new clone groups |
| Architecture | Fallow boundary zones | `fallow list_boundaries` + `boundary_violations` | any violation |
| Accessibility | axe-core | `axe $URL --tags wcag2a,wcag2aa,wcag21aa` | zero critical or serious |
| Browser support | Context7 (MDN) / caniuse | per Web API, against target browsers | unsupported in a target |

Four things that bite if you skip them:

1. **Fallow's `audit` scopes to the diff.** Gate on *introduced* findings, not the
   inherited backlog — that's `fallow audit` with the default new-only gate, or the
   `audit` MCP tool. Project-wide Fallow numbers are a ratchet (below), not a per-PR gate.
2. **axe needs a URL.** It only works against a running app, so it belongs at the QA-build
   stage (`qa-build` skill → staging URL), not the edit loop. hawk-widgets staging tracks
   `main` via FISO, so a staging deploy is the natural place to run it.
3. **Browser support is a lookup, not a tool.** Per `code-review`'s browser-support check:
   query Context7 (`/mdn/content`) or caniuse against the target browser matrix (last 2
   major of Chrome/Edge/Safari/Firefox + iOS Safari, no IE11). Babel handles syntax; this
   is for Web APIs only.
4. **Coverage needs no second test run.** Read the lcov Jest already writes and intersect
   with `git diff`. Running the suite twice to get a number is how people learn to hate this.

Mirror the commands into `package.json` scripts so they're reproducible without an agent:

```json
{
  "scripts": {
    "check:fast": "eslint . && stylelint '**/*.{js,css}'",
    "check:task": "npm run check:fast && jest --coverage && fallow audit",
    "check:full": "npm run check:task && fallow analyze"
  }
}
```

`CONSTRAINTS.md` is the canonical source — it carries the reason alongside each command
and shows up in review. The scripts mirror it; if they drift, the file wins.

### Step 5: Wire it to the lifecycle

The biggest mistake is running everything everywhere. A check that stalls the agent
gets switched off, and a gate switched off is worse than no gate — the bar still looks
like it exists.

| Phase | Skill | What runs | Budget |
|-------|-------|-----------|--------|
| BUILD | `build-verify` | Lint, style, the floor | under 5s, changed file only |
| VERIFY | `tdd` / `build-verify` | Related tests, coverage on changed lines | under 90s |
| REVIEW | `code-review` | `fallow audit`, everything, plus the guards below | minutes |
| QA | `qa-build` | axe against the staging URL | staging |
| SHIP | `version-bump` / release | Direction checks, no regressions | CI |

Two rules that keep this tolerable:

1. **Scope to the diff.** Check the lines this change touched, not the whole repo.
   Coverage of changed lines and Fallow's new-only gate are numbers the agent can move;
   project totals are inherited.
2. **Cost decides placement.** Anything over a few seconds moves out of the edit loop.

### Step 6: Guard the bar itself

If the agent writes the code and the checks, the checks prove nothing — half right.
Agents don't craft clever loopholes; they hit a red check and take the cheapest road to
green. Watch for these five moves in the diff at review time:

1. **The threshold moved.** A budget lowered, a check removed from the fast stage.
   Compare `CONSTRAINTS.md` against its state at the branch point.
2. **A test got easier.** `.skip` added, a test file deleted, assertions pulled out.
3. **A checker got silenced.** New `eslint-disable`, `@ts-expect-error`, `istanbul ignore`,
   or `fallow-ignore` without a reason.
4. **Work is unfinished.** A stub that throws, an empty `catch`, a `TODO` where the
   implementation should be.
5. **An exception appeared.** A new row in the Exceptions table nobody discussed.

None of this needs tooling beyond `git diff`. Tightening the bar should be silent;
loosening it should be loud.

**Not all checks are equally circular.** Rank by one question: can the agent make this
pass by writing code that doesn't work?

- **External** — axe encodes WCAG, caniuse is a real compat database, Fallow's structural
  analysis doesn't care about intent. The agent can't argue with these.
- **Project** — your ESLint config, your boundary zones. A human owns the rules.
- **Suite** — your own Jest tests. Most useful, and the only genuinely circular one.

A bar made entirely of the third kind is worth less than one with an outside opinion.
Check that at least one external constraint (axe, Fallow, browser support) is present.

### Step 7: Ratchets, when you don't have a number

Set 80% coverage on a repo at 62% and you get a red build forever, then a team that
learns to ignore red builds. The alternative asks for no decision: record where you
are, then refuse to get worse. Put it in "Measured, not yet enforced" with today's
number and a direction. Every check compares against the recorded value. When a number
improves, update it; when it drops, that's the finding.

This is the natural home for whole-project Fallow counts and bundle size — inherited
backlogs you hold flat while gating the diff tight.

## Sane Defaults

| Constraint | Default | Why |
|------------|---------|-----|
| Coverage of changed lines | >= 80% | High enough to force a test, low enough to allow a config line |
| Project coverage | today's value, must not fall | No argument needed to adopt |
| Fallow (project) | today's count, must not grow | Backlog held flat, diff gated tight |
| Accessibility | zero critical or serious axe violations | Moderate/minor often debatable |
| Exception lifetime | 90 days | Long enough to plan the fix, short enough to remember |
| Ratchet tolerance | 0.5% | Absorbs drift when an unrelated file moves the number |

State the number and the reason together. A threshold without a rationale gets deleted
by the next person who hits it.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "We'll add constraints once the code settles" | Code settles around whatever was allowed while it was moving |
| "The tests are the constraints" | Tests you wrote prove you agree with yourself; they say nothing about coverage of new code, dead code, or duplication |
| "We can't hit 80% coverage" | Then don't set 80%. Set today's number and hold it |
| "This will slow the agent down" | Only if you put slow checks in the fast loop. That's a placement error |
| "I'll remember our standards" | The agent won't, and it's writing most of the code |
| "Constraints block shipping" | An exception with an owner and a date unblocks you. Deleting the constraint unblocks everyone forever |

## Red Flags

- The interview ran past four questions, or produced a config the user can't explain
- A budget was set that the repo fails today, with no plan to reach it
- A dimension written with a number but no tool behind it
- A checker hand-rolled when Fallow or the ESLint config already does it
- Every constraint checked by the project's own tests, with no external opinion
- `CONSTRAINTS.md` changed in the same commit as the feature that was failing
- An exception with no owner or an expiry over a year out
- The agent proposed relaxing a threshold instead of fixing the code
- Slow checks landed in the edit loop and someone started passing `--no-verify`

## Verification

- [ ] `CONSTRAINTS.md` exists at the repo root, and every number has a stated reason
- [ ] The floor is enforced and passes on the current code without changes
- [ ] Every chosen dimension maps to a tool already in the stack with a command that runs today
- [ ] Each constraint says where it runs, and the fast stage stays under a few seconds
- [ ] At least one external constraint (axe, Fallow, browser support) is present
- [ ] Measured-only metrics record today's value and a direction
- [ ] Exceptions have an owner and an expiry date
- [ ] A trial run on the current branch produces no failures the user disagrees with

## See Also

- `grilling` — the one-question-at-a-time discipline this skill's intake borrows
- `code-review` — how to review; this skill decides what the review enforces
- `build-verify` — the post-change loop the fast checks run in
- `tdd` — the suite coverage constraints measure
- `cicd-conventions` — building the pipeline these constraints run in
- `qa-build` — the staging deploy where axe runs

## Adapted from

[addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) (MIT), reworked to
gate on this stack's toolchain — Fallow, the `@fsa-streamotion` ESLint/stylelint config,
Jest/RTL, axe, and the Context7 browser-support check — with `CONSTRAINTS.md` at the repo
root.
