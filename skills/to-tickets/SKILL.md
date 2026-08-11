# To Tickets

Break a spec or conversation into a set of **tickets** — tracer-bullet vertical slices, each declaring the tickets that **block** it. Publishes to Jira.

## Process

### 1. Gather context

Work from whatever is already in the conversation. If the user passes a reference (a spec path, a Jira ticket key, or URL), fetch and read its full body.

### 2. Explore the codebase

If you haven't already explored the codebase, do so. Ticket titles and descriptions should use the project's domain vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer bullet** tickets.

**Vertical slice rules:**

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

Give each ticket its **blocking edges** — the other tickets that must complete before it can start. A ticket with no blockers can start immediately.

**Wide refactors are the exception to vertical slicing.** When one mechanical change fans across the codebase (rename a column, retype a shared symbol), sequence it as expand–contract: first expand (add the new form beside the old), then migrate call sites in batches, then contract (delete the old form). Each batch is its own ticket blocked by the expand.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Blocked by**: which other tickets (if any) must complete first
- **What it delivers**: the end-to-end behaviour this ticket makes work

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct?
- Should any tickets be merged or split further?

Iterate until the user approves the breakdown.

### 5. Publish to Jira

Publish the approved tickets to Jira (cloudId: `livesport.atlassian.net`, project: `WEB`).

Create issues in dependency order (blockers first) so each ticket's blocking edges can reference real issue keys. Use Jira's native "Blocks" link type for dependencies.

For each ticket, create a Jira issue with:

- **Summary**: the ticket title
- **Issue type**: Task (or Story if user-facing feature)
- **Description** using this template:

```markdown
## What to build

The end-to-end behaviour this ticket makes work, from the user's perspective — not a layer-by-layer implementation list.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- WEB-XXXX (or "None — can start immediately")
```

- **Blocking links**: use `createIssueLink` with type "Blocks" for each dependency

After creating all tickets, link them as sub-tasks to the parent issue if one exists.

Avoid specific file paths or code snippets in ticket descriptions — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, schema, type shape), inline it and note it came from a prototype.

### 6. Offer parallel worktrees

After publishing, check if any tickets share no blocking edges (i.e., they can start simultaneously). If two or more tickets are independent, offer:

> "Tickets X and Y have no blocking edges — want me to set up worktrees so they can be implemented in parallel?"

If accepted:

1. **Create worktrees:**

```bash
# From the repo root (main worktree stays on default branch)
git worktree add ../<repo>-<TICKET>-<slug> -b <type>/<TICKET>-<slug>
```

Naming: `<repo>-<TICKET>-<short-slug>` (e.g., `quicksilver-WEB-4601-ts-foundation`).

2. **Install dependencies** in each worktree so it's ready to implement immediately.

3. **Create a scoped spec** in each worktree at `.kiro/specs/<TICKET>-SPEC.md`. This spec contains only the scope for that ticket — not the full parent spec. Pull content from:
   - The Jira ticket's "What to build" and acceptance criteria
   - Relevant implementation decisions from the parent spec
   - Testing decisions scoped to this slice

4. **Output a launch prompt** for each worktree. This is a self-contained prompt the user pastes into a new Kiro CLI session:

```
## Implement: <TICKET> — <Title>

Working directory: /path/to/<repo>-<TICKET>-<slug>

Implement the spec at `.kiro/specs/<TICKET>-SPEC.md`. The branch is already created
and dependencies are installed.

Run `/implement-from-spec .kiro/specs/<TICKET>-SPEC.md`
```

Each worktree is self-contained: its own branch, its own `node_modules`, its own spec. A Kiro CLI session in that directory has everything it needs to implement without reading from another worktree.

**Note:** `.kiro/` is gitignored — specs in worktrees are ephemeral session artifacts, not committed. This is fine: the Jira ticket holds the durable acceptance criteria, and the spec is a working document for the implementing agent only.

**Cleanup:** After a ticket's PR is merged, remove its worktree: `git worktree remove ../<worktree-dir>`

### Wave orchestration (merging a batch of parallel PRs)

After parallel agents finish and PRs are open:

1. **Review all PRs** from the orchestrator session — cross-cutting visibility catches issues individual agents can't see (phantom dependencies, conflicting changes)
2. **Merge the first PR** on GitHub
3. **Update remaining branches** locally with `update-branch` in each worktree
4. **Resolve conflicts** if any (likely in lockfiles) — run install to regenerate, commit via shell
5. **Push** updated branches
6. **Repeat** until all PRs in the wave are merged
7. **Clean up worktrees**: `git worktree remove ../<dir>` for each merged ticket

## Rules

- Always quiz the user before publishing. Never publish unreviewed tickets.
- Each ticket must be independently demoable or verifiable.
- A ticket's "What to build" describes user-visible behaviour, not implementation steps.
- Size tickets to fit one agent session (~one context window).
- Work the **frontier**: any ticket whose blockers are all done.
