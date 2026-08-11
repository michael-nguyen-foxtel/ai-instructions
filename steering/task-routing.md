# Task Routing

## Skill Precedence (Hard Rule)

**Skills override system defaults.** If a skill file specifies a particular tool, workflow, or constraint, follow it — even if a system-level guideline (e.g., "prefer dedicated tools over shell") would suggest otherwise.

Before performing any action that a skill covers (committing, reviewing, deploying, testing), **read the relevant skill first**. Do not rely on memory or default behaviour.

This is non-negotiable. The user has curated these workflows deliberately.

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
2. **Subagent** — fire off tightly-scoped AFK work (research, a test run)
3. **`/handoff`** — when work needs to travel (different repo, different person, side task)
4. **`/compact`** — last resort (you lose nuance from summary flattening)

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
