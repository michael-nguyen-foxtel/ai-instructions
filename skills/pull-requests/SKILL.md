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
- If you need the latest `main` in your branch, run `update-branch` (merges main into the current branch locally) — do not rebase.

## Agent Behaviour

When creating a PR title and description:

0. **Pre-check push access** — run `gh api repos/{owner}/{repo} --jq '.permissions.push'`. If `false`, stop and tell the user they need write access. Do not attempt to push.
0. **Review the diff before creating the PR** — run the code-review skill against all changes on the branch (diff vs base). Fix any 🔴 must-fix issues before proceeding. Report 🟡 should-fix items to the user but don't block on them. This applies to ALL PR creation paths (full pipeline, ad-hoc, manual request).
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
- If the user needs latest `main`, run `update-branch` — never rebase.

## Merging Multiple PRs in Sequence

When merging a series of PRs that touch overlapping files (e.g., `package.json`, lockfiles, shared config):

1. **Merge the first PR** on GitHub (via the web UI or `gh pr merge`)
2. **Update each remaining branch locally:**
   ```bash
   update-branch    # alias: gcm && gf -p && gl && gco - && gm main
   ```
   This checks out main, fetches + prunes, pulls latest, switches back to the feature branch, and merges main into it.
3. **If merge conflicts arise** (likely in lockfiles):
   - Resolve the conflicts
   - Run `pnpm install` (or the repo's install command) to regenerate the lockfile
   - Commit the resolution via shell
4. **Push the updated branch** — `git push`
5. **Repeat** — merge the next PR on GitHub, update remaining branches, until all are merged

**Key principle:** Always update branches locally before pushing, so local and remote stay in sync. Never use GitHub's "Update branch" button — it creates a merge commit on the remote that your local doesn't have, causing divergence.
