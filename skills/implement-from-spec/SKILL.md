---
name: implement-from-spec
description: Orchestrate implementation from a spec file. Runs plan → implement → test → integrate → review → ship. Use after grilling produces a spec.
---

## Trigger

User provides a spec file path (e.g., `/implement-from-spec .kiro/specs/WEB-4629-SPEC.md`) or says "implement the spec".

## Prerequisites

Before starting, verify:
- The spec file exists and contains acceptance criteria
- You are in the correct repo directory (check `package.json` exists)
- CONTEXT.md exists (for domain context)
- `.kiro/` is in `.gitignore` — if not, add it before proceeding. Spec files and AI working state must never be committed.
- **Push access** — run `gh api repos/{owner}/{repo} --jq '.permissions.push'` to confirm write access. If `false`, stop immediately and tell the user: "No push access to {owner}/{repo}. Request write access before proceeding."

### Branch & Dependencies

Before creating or switching to a working branch:

1. **Detect worktree** — `git rev-parse --show-toplevel` and `git worktree list`
   - If you're already in a worktree (path differs from the main worktree), skip branch creation — you're already on the right branch. Jump to step 4.
2. **Check current branch** — `git branch --show-current`
3. **If on a feature branch from previous work**: ask the user if they want to continue on it or start fresh
4. **If starting fresh (or on default branch)**:
   - Determine the default branch (`git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`)
   - Switch to it: `git checkout <default>`
   - Pull latest: `git pull`
   - Create the working branch: `git checkout -b <type>/<TICKET>-<short-description>`
5. **Check if dependencies are stale**:
   - Compare the lockfile against what's installed: `git diff HEAD@{1} --name-only | grep -E 'package-lock\.json|yarn\.lock|pnpm-lock\.yaml'`
   - If the lockfile changed on pull (or `node_modules` doesn't exist): run the repo's install command
   - If the lockfile didn't change and `node_modules` exists: skip install
6. **Verify Node version** against `.nvmrc` (warn if mismatch, don't block)

If any prerequisite fails, tell the user what's missing and stop.

## Pipeline

### Stage 0: Pre-flight (legacy repos)

If the repo has git-based dependencies in `package.json` (URLs containing `git+ssh://` or `git+https://github.com`), run a quick install check:

1. Check Node version: compare `node --version` against `.nvmrc` (warn if mismatch)
2. Run `npm install` (or the repo's install command)
3. If install fails due to a missing git repository:
   - Check if the failing dependency is actually imported in the files you need to modify
   - If NOT imported: note it as a pre-existing issue, proceed with syntax validation only (use `@babel/parser` to verify changed files parse correctly)
   - If imported: STOP — the dep needs to be fixed first, tell the user
4. If install succeeds, proceed normally

Skip this stage for repos using registry-only dependencies (normal npm packages).

### Stage 1: Plan

Read the spec file and produce an implementation plan:

1. Parse acceptance criteria into a checklist
2. Identify files to create or modify
3. Identify which work can be parallelised vs. sequential
4. Identify test scenarios and map them to acceptance criteria
5. Check for existing patterns in the repo (test structure, utility patterns, similar features)

Output the plan as a numbered list. Do NOT ask for confirmation — the spec is already approved. Proceed immediately.

### Stage 2: Implement + Test

Use subagents to parallelise where possible:

**If tests can be written against interfaces/contracts (spec defines clear inputs/outputs):**
- Dispatch `kiro_default` for implementation
- Dispatch `test-writer` for test writing (from spec acceptance criteria)
- Both run in parallel

**If tests depend on implementation details:**
- Implement first (sequential)
- Then write tests

For each subagent, include in the prompt:
- The full spec content
- The implementation plan
- The repo's testing stack (read from package.json/config)
- Reference to CONTEXT.md for domain terminology
- Reference to docs/adr/ for architectural decisions

### Stage 3: Integrate

After implementation and tests are complete:

1. Run lint/format FIRST — `npm run lint` (or equivalent). Fix any failures before proceeding. This is a hard gate.
2. Run the test suite — fix any failures
3. Run the build — fix any failures
4. Run fallow audit (if available) — address any blockers

**Do NOT commit until all four gates pass.** Repeat until clean. If stuck after 3 attempts on the same error, stop and report.

### Stage 4: Review

Dispatch `pr-reviewer` subagent with:
- The diff (all changes vs. base branch)
- The spec file path (for compliance checking)
- Instruction to check spec compliance AND code quality

If the reviewer returns NEEDS_CHANGES:
- Parse the feedback
- Apply fixes (back to Stage 2/3 for the specific issues)
- Re-run the reviewer
- Max 2 review loops — if still failing, stop and report remaining issues

### Stage 5: Ship

Once review passes:

1. Stage changes: `git add -A` — then verify `.kiro/` is NOT staged (`git status` should not show any `.kiro/` files). If it is, the `.gitignore` prerequisite was missed.
2. Commit via **shell** (read `/commit-messages` skill for format and tooling rules — MCP git tools are prohibited for commits)
3. Push the branch: `git push -u origin <branch>`
4. Create a PR using GitHub MCP (title from spec summary, body from acceptance criteria)
5. Report: PR URL, summary of what was built, any caveats

**ALL commits on the branch must include the ticket number in the scope** — including follow-up fixes after the initial push. Example: `fix(WEB-4611): resolve linting errors`, not `fix: resolve linting errors`.

## Parallelisation Rules

- Implementation + tests: parallel ONLY when the spec defines clear function signatures or interfaces
- Everything else: sequential (plan → implement → integrate → review → ship)
- Never parallelise git operations

## Error Handling

| Error | Action |
|-------|--------|
| Tests fail after implementation | Fix the code, not the tests (tests are written from spec) |
| Build fails | Read the error, fix the source, retry |
| Lint fails | Auto-fix where possible (`--fix`), manual fix otherwise |
| Review finds blockers | Apply fixes, re-verify, re-review (max 2 loops) |
| Stuck after 3 attempts | Stop, report what's failing and why, ask user for guidance |

## Output

At the end, produce a summary:
```
## Implementation Complete

**PR:** [URL]
**Branch:** [name]
**Spec:** [path]

### What was built
- [bullet list of changes]

### Verification
- Tests: ✅ passing (X tests)
- Build: ✅ clean
- Lint: ✅ clean
- Review: ✅ passed

### Manual testing
[Copy the manual testing section from the spec]
```
