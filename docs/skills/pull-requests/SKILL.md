---
name: pull-requests
description: Use when creating pull requests, writing PR titles/descriptions, or performing git operations during an open PR.
---
# Pull Request Convention

## PR Title Format

Same as commit message format:

```
type(scope): TICKET | description
```

See the commit-messages skill for full rules on type, scope, ticket, and description.

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

## Rebasing / Force-Pushing

**General rule: do NOT rebase or force-push during an open pull request.** It makes it harder to track changes for people who have already reviewed code.

### You can only force-push or rebase if:

- You have no review comments so far AND the PR has been open for less than 5 minutes (or there's no chance anybody is currently reading it).

### Otherwise:

- **Do not force-push or rebase.** Add a new commit with a descriptive message (e.g., "Adjusted x for y").
- If you need the latest `main` in your branch, **merge** it into your branch — do not rebase.

## Agent Behaviour

When creating a PR title and description:

1. **Draft the PR title** using the commit message convention and pause for confirmation.
2. **Suggest a scope** based on the files changed and ask if it's appropriate.
3. **Ask for related PRs** before finalising the description.
4. **Fill in the description template** with context from the branch's commits and changes.
5. **Assign the PR** to the current user.
6. **Add relevant labels** if they exist in the repo.
7. **Pause for final confirmation** before submitting the PR.

When performing git operations during an open PR:

- **Do not force-push or rebase** — add new commits instead.
- **Do not merge** — leave merging to the author via the GitHub web app.
- When addressing review feedback, use descriptive commit messages (e.g., `fix: WEB-1234 | address PR feedback - extract helper function`).
- If the user needs latest `main`, merge it into the branch — never rebase.
