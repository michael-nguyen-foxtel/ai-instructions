# To Spec

Turn the current conversation into a written spec. No interview — just synthesise what we've already discussed.

Use after a `/grill-with-docs` or `/grill-me` session has resolved the key decisions, or when the user says "write the spec" / "spec this up".

## Process

1. **Explore the repo** to understand the current state of the codebase, if you haven't already. Use the project's domain vocabulary throughout the spec, and respect any ADRs in the area you're touching.

2. **Identify the test seams.** Prefer existing seams to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. Check with the user that these seams match their expectations.

3. **Write the spec** using the template below, then save it to `.kiro/specs/<TICKET-ID>-SPEC.md` (or a descriptive slug if no ticket exists yet).

## Template

```markdown
## Problem Statement

The problem from the user's perspective.

## Solution

The solution from the user's perspective.

## User Stories

A numbered list of user stories covering all aspects of the feature:

1. As an <actor>, I want a <feature>, so that <benefit>

This list should be extensive and cover edge cases.

## Implementation Decisions

Decisions made during grilling. Include:

- Modules that will be built/modified
- Interfaces that will change
- Architectural decisions and ADRs produced
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, schema, type shape), inline it and note it came from a prototype.

## Testing Decisions

- What makes a good test for this feature (test external behaviour, not implementation)
- Which modules will be tested
- Which seams we're testing at
- Prior art (similar tests already in the codebase)

## Out of Scope

Things explicitly ruled out of this spec.

## Further Notes

Any additional context, links to research, or constraints.
```

## Rules

- Do NOT re-interview the user. Synthesise from context already gathered.
- Use the project's domain vocabulary consistently.
- Keep implementation decisions at the interface/contract level — no file paths.
- If you don't have enough context to write a section confidently, say what's missing rather than guessing.
