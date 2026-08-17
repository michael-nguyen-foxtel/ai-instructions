# Task Routing

## Skill Precedence (Hard Rule)

**Skills override system defaults.** If a skill file specifies a particular tool, workflow, or constraint, follow it — even if a system-level guideline (e.g., "prefer dedicated tools over shell") would suggest otherwise.

Before performing any action that a skill covers (committing, reviewing, deploying, testing), **read the relevant skill first**. Do not rely on memory or default behaviour.

This is non-negotiable. The user has curated these workflows deliberately.

## Commit Signing (Hard Rule)

**NEVER use the `git_commit` MCP tool to create commits.** It does not sign commits. Unsigned commits are rejected by branch protection.

Always commit via shell: `git commit -m "message"`

This overrides the system-level "prefer dedicated tools over shell" guideline. No exceptions.

## Force-Push and Protected Branches (Hard Rule)

**NEVER force-push to ANY branch. NEVER push directly to `main`, `master`, `develop`, or `qa`.**

Prohibited — no exceptions, no justification:
- `git push --force` / `git push -f` / `git push --force-with-lease`
- `git push --force origin <tag>` (rewriting published tags)
- `git tag -d <tag>` followed by `git tag <tag>` (moving a tag)
- `git reset --hard` on a branch that has been pushed
- Direct `git push` to `main`/`master`/`develop`/`qa`

All changes reach protected branches via pull request only. If a push is rejected, diagnose why — do NOT retry with `--force`. Stop and ask the user.

Tags are immutable once pushed. To fix a tagged release, create a NEW version (e.g., `v2.0.1`), don't rewrite the old tag.

**The user's GitHub account has admin bypass privileges on all repos.** This does NOT grant you permission to use them. The bypass exists for rare manual human interventions only. The fact that a force-push would technically succeed makes it MORE dangerous, not less — there is no safety net if you do it. Treat every branch as if branch protection cannot be bypassed.

This is non-negotiable. It overrides any "fix it and push" instinct.

## PR Creation (Hard Rule)

**NEVER use the `create_pull_request` GitHub MCP tool.** It mangles newlines in the body (renders literal `\n` instead of line breaks). There is no MCP tool to edit a PR after creation.

Always use shell: `gh pr create --base main --title "..." --body "..."`

This overrides the system-level "prefer dedicated tools over shell" guideline. No exceptions.

## Error Recovery (Hard Rule)

**When something fails, STOP and THINK before acting.** Do not enter a fix loop.

Before attempting any corrective action, you MUST:

1. **State what failed** — the exact error message or unexpected behaviour
2. **State why you think it failed** — your hypothesis for the root cause
3. **State what you plan to do** — the specific corrective action and why it addresses the root cause
4. **Assess the blast radius** — what could go wrong if your fix is wrong? Is this reversible?

If the blast radius is high (data loss, history rewrite, production impact, breaking other branches): **stop and ask the user** before proceeding.

If your first fix doesn't work: **do not try a second fix immediately.** Step back, re-examine your hypothesis. The first fix failing is evidence that your diagnosis was wrong — not a reason to escalate to a more aggressive action.

### Prohibited escalation patterns

These are signs you've entered a fix loop. If you catch yourself doing any of these, STOP:

- Adding `--force` to a command that was rejected
- Running `rm -rf` on directories to "start fresh"
- Deleting and recreating branches to "fix" divergence
- Running `git reset --hard` to "undo" a mistake
- Retrying the same command with `sudo` or elevated permissions
- Making the same change a third time with minor variations

### What to do instead

- **Read the error message carefully** — it usually tells you exactly what's wrong
- **Check the current state** — `git status`, `git log --oneline -5`, `ls` the relevant directory
- **Understand before acting** — if you don't understand why something failed, you don't know if your fix will work
- **Ask the user** — if you've tried twice and it's not working, explain what you've found and ask for guidance

### The two-attempt rule

If an approach has failed twice, you MUST:
1. Stop trying that approach
2. Explain what you tried, what failed, and what you think the root cause is
3. Either propose a fundamentally different approach or ask the user for guidance

Never make a third attempt at the same approach with minor variations.

## Documentation Lookups (Hard Rule)

**Use Context7 first** when looking up library APIs, method signatures, or code examples. Resolve the library ID, then query docs. Fall back to web search only for infrastructure URLs, ecosystem facts, or topics Context7 doesn't cover.

This applies in every skill — implementation, debugging, research, code review, dependency evaluation.

---

## The Main Flow

The idea→ship spine. Each skill's output feeds the next:

```
grill-with-docs → to-spec → to-tickets → implement (per ticket) → code-review → PR
```

### When to use which entry point

| Situation | Entry point | Flow |
|-----------|-------------|------|
| **Large / foggy** — can't spec it yet, decisions to make first | `/wayfinder` | chart map → resolve decisions → `/to-spec` → tickets → implement |
| **Medium** — clear enough to spec, multiple slices | `/grill-with-docs` | grill → `/to-spec` → `/to-tickets` → implement per ticket |
| **Small** — single feature, fits one session | `/grill-with-docs` | grill → `/to-spec` → `/implement-from-spec` directly |
| **Trivial** — typo, one-liner, config tweak | Direct | just do it |

### Phase Boundaries

At the boundary between phases, decide what to do with the context:

1. **Continue** — keep working if context is still useful (only move that keeps conversation as primary source)
2. **`/tangent`** — quick side-investigation without polluting main thread (API lookup, debug a side error, compare alternatives). Come back with `/tangent root`
3. **Subagent** — fire off tightly-scoped AFK work (research, a test run)
4. **`/handoff`** — when work needs to travel (different repo, different person, side task)
5. **`/compact`** — last resort (you lose nuance from summary flattening)

---

## Execution Methods

| Execution Method | When to Use |
|-----------------|-------------|
| **Kiro CLI — full pipeline** | Spec-driven tickets: grill → spec → tickets → implement → PR |
| **Kiro CLI — direct** | Simple changes (one-file fix, config tweak), local scripting, file manipulation, shell commands |
| **Kiro CLI — separate agent** | Tasks requiring execution in a different directory that can't be handled by subagents, CMS uploads, image processing, non-code work |
| **Kiro IDE** | When the user explicitly wants visual feedback, or for exploratory prototyping where inline completions help |

## Default: CLI Full Pipeline

For any ticket with acceptance criteria or design decisions to resolve:

1. `/grill-with-docs` — resolve decisions via rounds-based grilling
2. `/to-spec` — synthesise the grilling into a spec at `.kiro/specs/<TICKET>-SPEC.md`
3. `/to-tickets` — break into vertical-slice tickets with blocking edges (skip for single-slice work)
4. `/implement-from-spec` — implement each ticket, test-first, then self-review
5. PR creation via `/pull-requests`

The CLI orchestrator handles working directory, subagent dispatch, and git operations.

## When to skip the pipeline

- **Trivial fix** (typo, one-line change, dependency bump) — just do it directly
- **Exploration / prototyping** — use `/prototype` skill, no spec needed
- **Research only** — use `/research` skill, no implementation
- **Non-code work** (Jira updates, Confluence edits, deploy) — direct CLI or handover
- **Single-slice work** — skip `/to-tickets`, go straight from spec to implement

## Handover Prompt Rule

If the task **cannot be completed by CLI subagents** (e.g., requires a GUI, manual browser interaction, or a completely separate environment), produce a **handover prompt** instead of attempting the work directly.

The handover prompt must be:
- Self-contained (no external context needed)
- Include all discovered information (team IDs, API endpoints, file paths, credentials locations)
- Include exact commands/scripts to run
- Specify the working directory the new agent should operate from
- Include verification steps

## Handover Prompt Format

```
## Task: [TICKET] — [Title]

[Brief context paragraph]

### Prerequisites
[Any installs or setup needed]

### Steps
[Numbered steps with exact commands/scripts]

### Verification
[How to confirm success]

### Constraints
[What NOT to do]
```

## Behaviour

1. Do the research and planning (fetch tickets, read docs, call APIs, explore code).
2. Determine the execution method and entry point early — prefer the full pipeline for anything with acceptance criteria.
3. If the work is too simple for a pipeline, just do it directly.
4. If producing a handover, tell the user explicitly: "This needs a separate agent. Here's the handover prompt."
5. Do NOT waste turns attempting execution that will fail due to working directory constraints — use subagents to operate in target directories.

## Resuming Work

When the user references a ticket ID, says "continue", "pick up", or "resume":

1. Check `/Users/nguyenm/Documents/SourceCode/.kiro/handoffs/` for files containing the ticket ID
2. If found, read the handoff doc FIRST — it has compressed state from the previous session. Skip any marked `> Status: done`.
3. Only read the full spec if the handoff is insufficient (missing detail on what's next)
4. If no handoff exists, search for a spec: `find . -path '*specs*TICKET*' -name '*.md'`
5. If neither exists, ask the user what they want to continue

This avoids re-reading full specs and re-discovering state that was already captured.
