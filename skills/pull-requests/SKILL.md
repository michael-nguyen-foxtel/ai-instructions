---
name: pull-requests
description: Use when creating pull requests, writing PR titles/descriptions, or performing git operations during an open PR.
---
# Pull Request Convention

## Creating PRs

Always create PRs via shell using `gh`. **Write the body to a file and pass
`--body-file`** — never pass a multi-line body inline via `--body "$(...)"`. An
inline body containing backticks (code spans or fenced blocks) is executed by the
shell as command substitution, silently corrupting the PR description. There is no
MCP tool to create or edit a PR body, but `gh pr edit --body-file <file>` repairs
one after the fact.

```bash
gh pr create \
  --base main \
  --title "type(scope): TICKET | description" \
  --assignee @me \
  --label "<relevant-labels>" \
  --body-file /tmp/pr-body.md
```

### Labels

Add relevant labels based on the PR type:
- `feat` / `fix` / `chore` / `refactor` / `docs` / `test` / `ci` — match the commit type
- Add any additional context labels the repo uses (check existing labels with `gh label list`)

If unsure which labels exist, check first: `gh label list --limit 50`

For stacked PRs managed by Graphite: `gt stack submit` (assignee and labels set via Graphite config or added after with `gh pr edit`)

## PR Title Format

Same as commit message format:

```
type(scope): TICKET | description
```

See the commit-messages skill for full rules on type, scope, ticket, and description.

## PR Description Template

```markdown
## Summary
<!-- What this PR does and why. Lead with the smallest VISUAL that makes the
     change legible (see "Writing the Summary" below), then a line or two of prose. -->

## Evidence
<!-- Concrete proof the change works. Before / After. See "Evidence" below. -->
- **Before:**
- **After:**

## Merge Danger
<!-- See "Merge Danger" below. -->
- **Door:** one-way | two-way —
- **Blast radius:**

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
```

## Writing the body

Skip preamble, keep prose brief, use the project's domain vocabulary (CONTEXT.md /
GLOSSARY.md). The three sections below are where a PR earns a fast, confident review.

### Writing the Summary — lead with a visual

A reviewer reads the shape of a change faster than a paragraph describing it. Lead the
Summary with the **smallest visual** that makes the change legible, then a sentence or
two of prose. Pick the one view that fits — you'll rarely need more than one, never all:

- **Pseudocode** — for logic or an algorithm.
- **Call tree** — for runtime control flow (what calls what).
- **Component tree** — for UI structure, including the state and module boundaries that matter.
- **Shallow file tree** — for file responsibility or a broad refactor (annotate each dir's job).
- **Mermaid** — for component interaction, control flow, or data flow (sequence/flow diagrams).
- **`diff` block** — when the point is *what changes* and the surrounding shape already exists. Match the diff shape to the topic (a component diff, a file-layout diff, a control-flow diff).
- **Whole block** — when most of it is new, when omitted context would hide ownership or order, or when the reviewer needs a copyable target shape.

Place each visual next to the short text it supports. Keep only the calls, files, props,
states, and boundaries needed to make *this* change legible — don't overwhelm.

For a dense visual/UI/layout comparison that none of the above captures, write one focused
HTML artifact (diagram, infographic, or short slide deck) matching the product's styling,
and link or attach it.

Example — a control-flow change shown as a diff:

```diff
on(save)
- write content
+ if content is unchanged
+   return cached result
+ write new content
+ invalidate cache
```

### Evidence — before / after

Concrete proof the change works, as a before/after pair. Tiered by strength:

- **S-tier — screenshots**, when the change is visual and the environment can produce them. Before and after, same viewport.
- **A-tier — execution-based.** Test results, console output. Show the *exact* test that now passes (and failed before), as pseudocode if the real output is noisy.
- Lower — a described manual check. Better than nothing, but reach for the two above first.

For UI changes, screenshots live here (not a separate section) so the proof sits with
the claim.

### Merge Danger — door + blast radius

Two independent axes. State both.

- **Door — reversibility.** A **two-way door** can be walked back cheaply (revert the PR, flip a flag). A **one-way door** cannot: destructive data migrations, deleting a published artifact, a schema change consumers immediately depend on, anything a revert won't undo. Name which, and if one-way, say what makes it so.
- **Blast radius — scope of impact.** What could this reach beyond the obvious? Layout shift, breakage for downstream consumers of a shared widget/workflow, mobile responsiveness, SSR/hydration, cache invalidation, FISO-served versions. Consider the possibilities, not just the happy path.

A cheap-to-roll-back, narrow-blast-radius PR is low risk and reviewers can move fast; a
one-way door with wide blast radius wants a careful review and a named rollback plan.

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
5. **Draft the PR body** — fill the template: a visual-led Summary, before/after Evidence, and Merge Danger (door + blast radius). Confirm the title and body with the user, then submit via `gh pr create --body-file`.
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

---

_The visual-led Summary, before/after Evidence, and Merge Danger (one-way vs two-way door
+ blast radius) sections are adapted from Matt Pocock's `pr` skill
([mattpocock/skills](https://github.com/mattpocock/skills), MIT), which in turn copies the
compact-visual vocabulary from Dex Horthy's `show-me` skill (Humanlayer —
[humanlayer/skills](https://github.com/humanlayer/skills)). Both MIT. The vocabulary is
inlined rather than pointed at because we don't ship a standalone `show-me` skill._
