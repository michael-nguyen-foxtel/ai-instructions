---
name: 'Pull Requests'
description: 'PR title and description conventions'
applyTo: ''
---
# Pull Request Convention

## PR Title Format

Same as commit message format:

```
type(scope): TICKET | description
```

See [commit-messages.instructions.md](./commit-messages.instructions.md) for full rules on type, scope, ticket, and description.

## PR Description Template

```markdown
## Summary
<!-- What does this PR do and why? Include any extra context for the reviewer. -->

## Jira reference(s)
<!--
* [WEB-1234](https://livesport.atlassian.net/browse/WEB-1234)
-->

## Related PR(s)
<!--
* #22
* fsa-streamotion/streamotion-web-ares-widgets#2
-->

## Testing
<!-- How was this tested? Unit tests, manual steps, etc. -->

## Screenshots
<!-- Optional: include for UI changes -->
```

## Agent Behaviour

When creating a PR title and description:

1. **Draft the PR title** using the commit message convention and pause for confirmation
2. **Suggest a scope** based on the files changed and ask if it's appropriate
3. **Ask for related PRs** before finalising the description
4. **Fill in the description template** with context from the branch's commits and changes
5. **Pause for final confirmation** before submitting the PR

When performing git operations during an open PR:

- **Do not force-push or rebase** — add new commits instead
- **Do not merge** — leave merging to the author via the GitHub web app
- When addressing review feedback, use descriptive commit messages (e.g., `fix: WEB-1234 | address PR feedback - extract helper function`)
