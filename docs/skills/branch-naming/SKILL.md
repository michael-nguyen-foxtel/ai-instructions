---
name: branch-naming
description: Use when creating git branches or checking out new branches.
---
# Branch Naming Convention

## Format

```
type/TICKET-short-description
```

## Rules

- **type**: matches commit type (`feat`, `fix`, `chore`, `refactor`, `docs`, `test`, etc.)
- **TICKET**: Jira ticket key (e.g., `WEB-4612`) or pseudo-ticket (`WEB-CHORE`, etc.)
- **short-description**: kebab-case, brief summary
- No uppercase letters

## Examples

```
feat/WEB-1234-add-stats-table
fix/WEB-5678-race-condition-request-handler
chore/WEB-4612-remove-react-hammer-js
refactor/WEB-REFACTOR-extract-token-validation
```

## Agent Behaviour

When creating a branch:

1. **Suggest a branch name** following this convention and pause for confirmation
2. **Ask for the Jira ticket** if not already known from context
