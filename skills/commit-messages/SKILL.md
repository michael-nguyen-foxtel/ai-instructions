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

## Agent Behaviour

1. **Verify you're on a feature branch** — if on `main`, create a branch first (e.g., `feat/WEB-4629-carding-name-filter`)
2. **Stage specific files** — `git add <files>`, not `git add .`
3. **Draft the commit message** and confirm with the user before committing
4. **Commit via shell** — `git commit -m "message"`
5. **Push to the feature branch** — `git push -u origin <branch>`
6. **If something goes wrong** — diagnose, explain to the user, and ask for guidance. Do not escalate (see Error Recovery in task-routing steering).
