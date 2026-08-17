---
name: stacked-prs
description: Use when creating, managing, or merging stacked PRs with Graphite. Covers stack creation, restacking after feedback, and merge sequencing.
---
# Stacked PRs with Graphite

Manage dependent PR chains using the Graphite CLI (`gt`).

## When to Use

- User says "stack", "stacked PR", "graphite", or is working on sequential dependent changes
- A large change needs to be split into reviewable slices with dependency ordering
- Migration work spanning multiple directories where each slice builds on the previous

## Prerequisites

- Graphite CLI installed: `brew install withgraphite/tap/graphite`
- Authenticated: `gt auth login`
- On a repo with a GitHub remote

## Creating a Stack

```bash
# Start from up-to-date main
gt checkout main
gt sync

# Create the first branch in the stack
gt create -m "chore: WEB-XXXX | first slice description"
# ... do the work, commit ...

# Stack the next branch on top
gt create -m "chore: WEB-XXXX | second slice description"
# ... do the work, commit ...

# Continue stacking as needed
gt create -m "chore: WEB-XXXX | third slice description"
# ... do the work, commit ...

# Push the entire stack and open/update all PRs
gt stack submit
```

Each `gt create` branches off the current HEAD, creating a linear chain.

## Stack Shape Decisions

### Linear stack (default)

Use when each slice depends on the one below it:

```
main ← slice-1 ← slice-2 ← slice-3
```

Example: TypeScript migration where molecules import atoms, organisms import molecules.

### Fan-out from a common base

Use when slices are independent but share a foundation:

```
main ← foundation ← slice-A
                   ← slice-B
```

To fan out:
```bash
gt create -m "chore: foundation"
# ... work ...
gt create -m "chore: slice A"
# ... work ...
gt checkout foundation        # go back to the fork point
gt create -m "chore: slice B"
# ... work ...
gt stack submit
```

### When NOT to stack

- Slices are completely independent (no shared base) — use parallel branches
- Single-PR change — just use normal `gh` workflow
- Cross-repo work — stacking is per-repo only

## Responding to Review Feedback

When a reviewer requests changes on a PR mid-stack:

```bash
gt checkout <branch-with-feedback>    # jump to that PR
# ... make fixes, commit ...
gt stack restack                      # rebase everything above onto your fix
gt stack submit                       # push the updated stack
```

This is the one scenario where rebasing is acceptable — Graphite manages the cascade and the stack is treated as a unit.

## Merging a Stack

Always merge from the **bottom** upward:

1. Merge the bottom PR on GitHub (squash or merge commit — follow repo convention)
2. Run `gt sync` — pulls main, detects the merge, cleans up the merged branch
3. GitHub auto-retargets the next PR to `main`
4. Wait for CI to pass on the new bottom PR
5. Repeat until the stack is fully merged

### If CI fails after retarget

The retargeted PR may have conflicts with main (usually lockfiles):

```bash
gt checkout <failing-branch>
gt stack restack              # rebase onto updated main
# If conflicts: resolve, then git add + git rebase --continue
gt stack submit               # push the fix
```

## Useful Commands

| Command | What it does |
|---------|--------------|
| `gt stack` | Show the full stack from current branch |
| `gt log` | Show all tracked branches |
| `gt checkout <name>` | Jump to a branch in the stack |
| `gt create -m "msg"` | Create a new stacked branch |
| `gt modify` | Amend the current branch's commit |
| `gt stack restack` | Rebase the entire stack |
| `gt stack submit` | Push all + create/update PRs |
| `gt sync` | Pull main, clean merged branches |
| `gt branch delete <name>` | Delete a branch from the stack |

## Branch Naming

Graphite auto-names branches from the commit message. Override with:

```bash
gt create -m "message" --branch "chore/WEB-4649-ts-molecules"
```

Convention: `<type>/WEB-<TICKET>-<short-slug>`

## Interaction with Other Skills

- **commit-messages**: Each commit within a stacked branch follows the normal convention
- **pull-requests**: `gt stack submit` replaces `gh pr create` for stacked work
- **version-bump (changesets)**: Each PR in the stack that changes source code should include a changeset file
- **build-verify**: Run verification at each stack level before submitting

## Agent Behaviour

1. **Detect stacking intent** — if the user describes work with sequential dependencies or says "stack", use Graphite
2. **Plan the stack order** before creating branches — present the proposed slice order to the user
3. **One logical change per stack level** — each PR should be independently reviewable
4. **Size check** — aim for <100 changed files per PR in the stack. If a slice is too large, split it further
5. **Always run `gt stack submit`** after all branches are ready — don't push individually
6. **After merging bottom PR** — run `gt sync` then `gt stack submit` to keep the remote in sync
