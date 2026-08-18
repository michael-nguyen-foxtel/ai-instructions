---
name: commit-messages
description: Use when creating commits, writing commit messages, staging changes, or pushing code to a GitHub repository.
---
# Commit Message Convention

## Format

```
type(scope): TICKET | description

[optional body]

[optional footer(s)]
```

## Rules

- **type** (required): one of `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`, `ci`, `build`
- **scope** (optional): freeform, in parentheses — e.g., `feat(player):`, `fix(auth):`
- **TICKET** (required): the Jira ticket key (e.g., `WEB-1234`)
- **`|`** separates ticket from description
- **description**: lowercase, imperative mood, no trailing period

## Pseudo-tickets

When no Jira ticket exists, use a pseudo-ticket based on the work type:

- `WEB-CHORE` — maintenance, dependency updates
- `WEB-BUGFIX` — bug fixes without a ticket
- `WEB-FEATURE` — features without a ticket
- `WEB-REFACTOR` — refactoring without a ticket
- `WEB-DOCS` — documentation changes
- `WEB-TEST` — test additions/updates

## Examples

```
feat(player): WEB-1234 | add series stats table widget
fix: WEB-5678 | resolve race condition in request handler
chore: WEB-CHORE | update dependencies
refactor(auth): WEB-REFACTOR | extract token validation into utility
docs: WEB-DOCS | add API endpoint documentation
test(player): WEB-TEST | add unit tests for stats table
```

## How to Commit

All commits are created via shell (signed automatically via ssh-agent):

```bash
git add <specific-files>
git commit -m "type(scope): TICKET | description"
```

## How to Push

Always push to a feature branch:

```bash
git push -u origin <branch-name>
```

If a push is rejected: check `git status` and `git log --oneline -5`. Diagnose the cause. Ask the user for guidance if unsure.

## Changesets

### Detection

Before committing, check if the repo uses changesets by looking for `.changeset/config.json`. If it exists, a changeset file may be required.

### When a Changeset is Required

A changeset is needed when the commit includes **source code changes that affect the published package** — anything a consumer would notice (new feature, bug fix, behaviour change, API change, dependency update that changes runtime behaviour).

A changeset is **NOT needed** for:
- CI/CD workflow changes only
- Documentation-only changes (README, inline comments, storybook prose)
- Test-only changes (new tests, test refactors)
- Dev tooling changes (ESLint config, prettier, editor configs)
- Internal refactors with no public API or behaviour change

When unsure, ask: "Would a consumer of this package notice anything different?" If no → skip changeset.

### How to Create a Changeset

1. Read the package name from `package.json` (the `name` field)
2. Determine the bump type from the commit type:
   - `feat` → `minor`
   - `fix`, `perf` → `patch`
   - Breaking changes (indicated by `!` suffix or user confirmation) → `major`
   - `chore`, `refactor`, `style`, `build` → `patch` (if it affects published output)
3. Name the file using the ticket slug: `<ticket>-<short-description>.md` (lowercased, kebab-case). E.g., `web-1234-add-stats-table.md`. For pseudo-tickets: `web-chore-update-deps.md`.
4. Write the changeset file:

```markdown
---
"<package-name>": <bump-type>
---

<changeset summary>
```

5. Stage it alongside the other files: `git add .changeset/<filename>.md`

### Changeset Summary Style

Use the same format as the commit message:

```
type(scope): TICKET | description
```

This keeps the changelog consistent and traceable. Examples:
- `feat(player): WEB-1234 | add series stats table widget`
- `fix(tooltip): WEB-5678 | fix positioning when parent has overflow hidden`
- `chore: WEB-CHORE | update styled-components peer dependency to v6`

### Agent Behaviour with Changesets

When a changeset is needed:
1. Draft the changeset content and present it to the user alongside the commit message
2. After user confirms, create the file and stage it with the commit

The changeset file is part of the same commit as the code change — not a separate commit.

## Agent Behaviour

1. **Verify you're on a feature branch** — if on `main`, create a branch first (e.g., `feat/WEB-4629-carding-name-filter`)
2. **Stage specific files** — `git add <files>`, not `git add .`
3. **Check for changesets** — if `.changeset/config.json` exists and the change warrants it, draft a changeset file
4. **Draft the commit message** (and changeset if applicable) and confirm with the user before committing
5. **Commit via shell** — `git commit -m "message"`
6. **Push to the feature branch** — `git push -u origin <branch>`
7. **If something goes wrong** — diagnose, explain to the user, and ask for guidance. Do not escalate (see Error Recovery in task-routing steering).
