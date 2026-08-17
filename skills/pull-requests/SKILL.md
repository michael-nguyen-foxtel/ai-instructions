---
name: pull-requests
description: Use when creating pull requests, writing PR titles/descriptions, or performing git operations during an open PR.
---
# Pull Request Convention

## Creating PRs

Always create PRs via shell using `gh`:

```bash
gh pr create \
  --base main \
  --title "type(scope): TICKET | description" \
  --body "## Summary
..."
```

For stacked PRs managed by Graphite: `gt stack submit`

## PR Title Format

Same as commit message format:

```
type(scope): TICKET | description
```

See the commit-messages skill for full rules on type, scope, ticket, and description.

## PR Description Template

```markdown
## Summary
<!-- What does this PR do and why? -->

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
<!-- How was this tested? -->

## Screenshots
<!-- Optional: include for UI changes -->
```

## Pushing Changes

Always push to a feature branch:

```bash
git push -u origin <branch-name>
```

If a push is rejected, check why (`git status`, `git log`). Do NOT add `--force`. Ask the user if unsure.

## Updating a Branch with Latest Main

Use `update-branch` (merges main in locally):

```bash
update-branch    # alias: gcm && gf -p && gl && gco - && gm main
```

## Responding to Review Feedback

Add new commits with descriptive messages:

```bash
git commit -m "fix: WEB-1234 | address PR feedback - extract helper function"
git push
```

## Stacked PRs (Graphite)

When in a Graphite stack (check with `gt stack`):

| Task | Command |
|------|---------|
| Push all + create/update PRs | `gt stack submit` |
| Fix a mid-stack PR | `gt checkout <branch>`, fix, `gt stack restack`, `gt stack submit` |
| After bottom PR merges | `gt sync` |

## Changesets Check

If `.changeset/config.json` exists in the repo and the PR changes source code (not just CI/docs/tests):
- Verify a `.changeset/*.md` file is included
- If missing: `npx changeset`

## Agent Behaviour

1. **Pre-check push access** — `gh api repos/{owner}/{repo} --jq '.permissions.push'`
2. **Run Fallow audit** — dispatch pr-reviewer subagent. Fix 🔴 issues before proceeding.
3. **Check for Graphite stack** — `gt stack` to detect. If yes, use `gt stack submit`.
4. **Check for changesets** — if config exists and source code changed, verify changeset included.
5. **Create PR via `gh pr create`** — draft title, confirm with user, submit.
6. **Assign** to current user.
7. **Pause for final confirmation** before submitting.

## Merging Multiple PRs in Sequence

### Standalone PRs

1. Merge bottom PR on GitHub
2. Update remaining branches: `update-branch`
3. Resolve conflicts if any (run install command, commit)
4. Push, repeat

### Stacked PRs (Graphite)

1. Merge bottom PR on GitHub
2. `gt sync` — pulls main, cleans merged branches, restacks
3. `gt stack submit` — push updated stack
4. Repeat from new bottom
