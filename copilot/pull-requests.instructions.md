---
applyTo: "**"
---

# Pull Request Convention

## PR Title Format

Same as commit message format:

```
type(scope): TICKET | description
```

## PR Description Template

```markdown
## Summary
<!-- What does this PR do and why? -->

## Jira reference(s)
<!-- * [WEB-1234](https://livesport.atlassian.net/browse/WEB-1234) -->

## Related PR(s)
<!-- * #22 -->

## Testing
<!-- How was this tested? -->

## Screenshots
<!-- Optional: include for UI changes -->
```

## Rules

- Do NOT rebase or force-push during an open pull request
- If you need latest `main`, merge it into the branch
- Add new commits when addressing review feedback
- Assign the PR to the current user
