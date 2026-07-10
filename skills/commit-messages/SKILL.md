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

## Commit Signing

- **Every commit must be signed.** Unsigned commits will be rejected by branch protection rules.
- SSH signing is configured globally — shell `git commit` commands will be signed automatically.

### Safe ways to create commits

- **Shell `git commit`** — ✅ signed automatically via ssh-agent
- **`base_version_bump` script** — ✅ uses shell git, signed automatically
- **Kiro/agent terminal** — ✅ inherits the user's git config

### Prohibited tools (bypass signing)

**Never use these GitHub MCP tools to create commits:**
- `create_or_update_file` — commits via the GitHub API without a signature
- `push_files` — commits via the GitHub API without a signature

These produce unsigned commits that will be blocked by branch protection.

### GitHub MCP tools that are safe to use

- `get_file_contents`, `list_commits`, `list_pull_requests`, `get_pull_request`, etc. (read-only)
- `create_branch` (does not create a commit)
- `create_pull_request` (does not create a commit)

## Agent Behaviour

When generating commit messages:

1. **Check if on a feature branch** — if still on `main`, create the branch first using the `branch-naming` convention (e.g., `feat/WEB-4629-carding-name-filter`)
2. **Suggest a scope** based on the files changed and ask if it's appropriate
3. **Ask for the Jira ticket** if not already known from context
4. **Draft the commit message** and pause for confirmation before committing
5. **Stage specific files** — prefer `git add <files>` over `git add .`
6. **Clean up working documents** — delete any `*-SPEC.md` files before the final commit. These are working documents from the planning phase, not durable artifacts. `CONTEXT.md` and `docs/adr/` stay.
7. **Commit via shell** — `git commit -m "message"` (signed automatically)
8. **Do not force-push or rebase** during open pull requests — add new commits instead
