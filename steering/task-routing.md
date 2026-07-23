# Task Routing

## Skill Precedence (Hard Rule)

**Skills override system defaults.** If a skill file specifies a particular tool, workflow, or constraint, follow it — even if a system-level guideline (e.g., "prefer dedicated tools over shell") would suggest otherwise.

Before performing any action that a skill covers (committing, reviewing, deploying, testing), **read the relevant skill first**. Do not rely on memory or default behaviour.

This is non-negotiable. The user has curated these workflows deliberately.

---

When planning work for a ticket, determine the appropriate execution method:

| Execution Method | When to Use |
|-----------------|-------------|
| **Kiro CLI — full pipeline** | Spec-driven tickets: grill → `/implement-from-spec` → PR. All code changes happen via subagents in the target repo directory. No IDE needed. |
| **Kiro CLI — direct** | Simple changes (one-file fix, config tweak), local scripting, file manipulation, shell commands |
| **Kiro CLI — separate agent** | Tasks requiring execution in a different directory that can't be handled by subagents, CMS uploads, image processing, non-code work |
| **Kiro IDE** | When the user explicitly wants visual feedback, or for exploratory prototyping where inline completions help |

## Default: CLI Full Pipeline

For any ticket with acceptance criteria or design decisions to resolve:

1. `/grill-with-docs` — resolve decisions, produce spec at `.kiro/specs/<TICKET>-SPEC.md`
2. `/implement-from-spec .kiro/specs/<TICKET>-SPEC.md` — orchestrate implementation, testing, review, and PR creation

The CLI orchestrator handles working directory, subagent dispatch, and git operations. No IDE hop needed.

## When to skip the pipeline

- **Trivial fix** (typo, one-line change, dependency bump) — just do it directly
- **Exploration / prototyping** — use `/prototype` skill, no spec needed
- **Research only** — use `/research` skill, no implementation
- **Non-code work** (Jira updates, Confluence edits, deploy) — direct CLI or handover

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
2. Determine the execution method early — prefer the full pipeline for anything with acceptance criteria.
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
